//
//  BHImageDownloaderFileManager.m
//  BHImageCache
//
//  Created by Ben Honig on 7/7/14.
//  Copyright (c) 2014 iPhonig, LLC. All rights reserved.
//

#import "BHImageDownloaderFileManager.h"

@implementation BHImageDownloaderFileManager

+ (BHImageDownloaderFileManager *)sharedFileManager{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = [[self alloc] init];});
    return instance;
}

- (id)init{
    if (self = [super init]){
        _fileManager = [[NSFileManager alloc] init];
    }
    return self;
}

- (NSString *)cacheDirectoryPath {
    static NSString *cacheDirectoryPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cacheDirectoryPath = [[caches[0] stringByAppendingPathComponent:@"BHImageCache"] copy];
        if([self.fileManager fileExistsAtPath:cacheDirectoryPath isDirectory:nil] == NO) {
            [self.fileManager createDirectoryAtPath:cacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    return cacheDirectoryPath;
}

- (NSString *)filePathForKey:(NSString *)key {
    return [[self cacheDirectoryPath] stringByAppendingPathComponent:key];
}

- (NSOperationQueue *)saveOperationQueue {
    static NSOperationQueue *operationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operationQueue = [[NSOperationQueue alloc] init];
        //only allow one thing to be saved at a time
        operationQueue.maxConcurrentOperationCount = 1;
    });
    return operationQueue;
}

- (void)saveImageToDiskForKey:(UIImage *)image key:(NSString *)key {
    [[self saveOperationQueue] addOperationWithBlock:^{
        NSString *filePath = [self filePathForKey:key];
        NSData *imageData = UIImagePNGRepresentation(image);
        //if there is room for the image to be downloaded, download it
        if(imageData.length < [self freeDiskSpace]) {
            [self.fileManager createFileAtPath:filePath contents:imageData attributes:nil];
        }
    }];
}

- (unsigned long long)freeDiskSpace {
    unsigned long long totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [self.fileManager attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    }
    else if(error) {
        NSLog(@"BHImageDownloader+FileManager -- Error: %@", error);
    }
    return totalFreeSpace;
}

- (void)removeOldFiles:(NSDate *)date {
    NSString *cachePath = [self cacheDirectoryPath];
    NSDirectoryEnumerator *directoryEnumerator = [self.fileManager enumeratorAtPath:cachePath];
    NSString *file;
    //enumerate through all objects in the directory and remove them
    while (file = [directoryEnumerator nextObject]) {
        NSError *error = nil;
        NSString *filepath = [cachePath stringByAppendingPathComponent:file];
        NSDate *modifiedDate = [[self.fileManager attributesOfItemAtPath:filepath error:&error] fileModificationDate];
        if(error == nil) {
            //delete oldest files
            if ([modifiedDate compare:date] == NSOrderedAscending) {
                [self.fileManager removeItemAtPath:filepath error:&error];
            }
        }
        if(error != nil) {
            NSLog(@"BHImageDownloaderFileManager -- Error: %@", error);
        }
    }
}

@end