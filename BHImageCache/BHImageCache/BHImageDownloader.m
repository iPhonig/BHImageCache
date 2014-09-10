//
//  BHImageDownloader.m
//  BHImageCache
//
//  Created by Ben Honig on 7/7/14.
//  Copyright (c) 2014 iPhonig, LLC. All rights reserved.
//

#import "BHImageDownloader.h"
#import "BHImageDownloaderFileManager.h"
#import "NSString+CacheFileName.h"
@interface BHImageDownloader ()

@property (strong, nonatomic) NSCache *imageCache;
@property (strong, nonatomic) NSURLSession *urlSession;
@property (strong, nonatomic) BHImageDownloaderFileManager *bhFileManager;

@end

@implementation BHImageDownloader

+ (void)initialize{
    //TODO: put activity indicator or some sort of way to show users visually that something is downloading here, use the download start and stop notifications to determine when it should start and stop
}

+ (BHImageDownloader *)sharedDownloader{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = [[self alloc] init];});
    return instance;
}

- (BHImageDownloaderFileManager *)createFileManager
{
    return [BHImageDownloaderFileManager sharedFileManager];
}

- (id)init {
    self = [super init];
    if(self) {
        _fileExpirationInterval = DEFAULT_EXPIRATION_INTERVAL;
        _imageCache = [[NSCache alloc] init];
        _maxNumberOfRetries = 0;
        _retryDelay = 0.0;
        _bhFileManager = [self createFileManager];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        _urlSession = urlSession;
        
        //set up notification for when app closes so the time interval to delete images is updated
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        __weak BHImageDownloader *weakSelf = self;
        
        //if there is a memory warning clear the cache
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf.imageCache removeAllObjects];
        }]; 
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    UIBackgroundTaskIdentifier backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
    }];
    
    if(backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        __weak BHImageDownloader *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDate *maxAge = [NSDate dateWithTimeIntervalSinceNow:weakSelf.fileExpirationInterval];
            [self.bhFileManager removeOldFiles:maxAge];
            
            //prevent an exceedingly amount of background tasks from operating
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
        });
    }
}

- (void)imageForURL:(NSURL *)url refreshCache:(BOOL)refresh completion:(void (^)(UIImage *image))completion {
    
    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, XCode won't
    // throw any warning so here we handle the case if you accidently send an NSSTRing rather than an NSURL
    if ([url isKindOfClass:NSString.class]){
        url = [NSURL URLWithString:(NSString *)url];
    }
    
    // Prevents app crashing on argument type error like sending NSNULL instead of NSURL
    if (![url isKindOfClass:NSURL.class])
    {
        url = nil;
    }
    
    //tell coder that url can't be nil (obviously, or you're not fetching anything)
    
    NSString *stringFromURL = [url absoluteString];
    
    NSAssert(stringFromURL.length > 0, @"C'mon you can't try to fetch from a nil URL ;-)");
    
    
    __weak BHImageDownloader *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *md5 = [NSString createCachedFileNameForKey:stringFromURL];
        //if refresh cache, always load from url because it could have updated on the server
        if (refresh) {
            //clear key for this url
            [self clearObjectAtKey:md5];
            //if the key exists on disk, delete it
            if ([[self.bhFileManager fileManager] fileExistsAtPath:[self.bhFileManager filePathForKey:md5]]) {
                [[self.bhFileManager fileManager] removeItemAtPath:[self.bhFileManager filePathForKey:md5] error:NULL];
            }
            NSLog(@"REFRESH IMAGE");
        }
        UIImage *image = [weakSelf.imageCache objectForKey:md5];
        if(image == nil) {
            image = [weakSelf imageFromDiskForKey:md5];
            NSLog(@"LOADED FROM DISK");
        }
        
        if(image == nil) {
            [weakSelf loadRemoteImageForURL:url key:md5 retryCount:0 completion:completion];
            NSLog(@"LOADED FROM URL");
        }
        else if(completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image);
            });
        }
    });
}

- (UIImage *)imageFromDiskForKey:(NSString *)key {
    UIImage *image = nil;
    NSString *filePath = [self.bhFileManager filePathForKey:key];
    NSFileManager *fileManager = [self.bhFileManager fileManager];
    
    if([fileManager fileExistsAtPath:filePath]) {
        NSData *imageData = [fileManager contentsAtPath:filePath];
        if(imageData) {
            //set modification date of image so we know how old it is
            [fileManager setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:filePath error:NULL];
            image = [UIImage imageWithData:imageData];
            if (image) {
                [_imageCache setObject:image forKey:key];
            }
        }
        return image;
    }
    else{
        return nil;
    }
}

- (void)loadRemoteImageForURL:(NSURL *)url key:(NSString *)key retryCount:(NSInteger)retryCount completion:(void (^)(UIImage *image))completion {
    if ([url isKindOfClass:NSString.class]){
        url = [NSURL URLWithString:(NSString *)url];
    }
    
    // Prevents app crashing on argument type error like sending NSNULL instead of NSURL
    if (![url isKindOfClass:NSURL.class])
    {
        url = nil;
    }
    
    NSString *stringFromURL = [url absoluteString];
    
    if (stringFromURL.length > 0) {
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        urlRequest.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        __weak BHImageDownloader *weakSelf = self;
        NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger httpStatusCode = httpResponse.statusCode;
            switch (httpStatusCode) {
                case 200: {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *image = nil;
                        if(data.length) {
                            image = [[UIImage alloc] initWithData:data];
                        }
                        
                        if(image) {
                            [weakSelf.bhFileManager saveImageToDiskForKey:image key:key];
                            [weakSelf.imageCache setObject:image forKey:key];
                            
                        }
                        
                        if(completion) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(image);
                            });
                        }
                    });
                } break;
                    
                default: {
                    NSLog(@"BHImageDownloader -- URL Error: %@", url);
                    if((retryCount >= weakSelf.maxNumberOfRetries) || (httpStatusCode >= 400 && httpStatusCode <= 499)) {
                        //out of retries or got a 400 error so don't retry
                        if(completion) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(nil);
                            });
                        }
                    }
                    else {
                        //try again
                        //increment retry count
                        NSInteger nextRetryCount = retryCount + 1;
                        //add delay to retry
                        double delayInSeconds = self.retryDelay;
                        //define time for how lond the delay prior to retry should be
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        //once the delay has happened, retry
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [self loadRemoteImageForURL:url key:key retryCount:nextRetryCount completion:completion];
                        });
                    }
                    
                    NSLog(@"BHImageDownloader -- Error Code: %ldd Error: %@",(long) (long)httpStatusCode, error);
                    
                } break;
            }
        }];
        [task resume];
    }
    else if(completion) {
        completion(nil);
    }
}

- (void)clearObjectAtKey:(NSString *)key{
    [self.imageCache removeObjectForKey:key];
}

- (void)clearAllData {
    [self.imageCache removeAllObjects];
    
    UIBackgroundTaskIdentifier backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
    }];
    
    if(backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //remove all files from today
            [self.bhFileManager removeOldFiles:[NSDate date]];
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
        });
    }
}

@end
