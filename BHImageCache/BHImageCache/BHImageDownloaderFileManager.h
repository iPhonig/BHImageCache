//
//  BHImageDownloaderFileManager.h
//  BHImageCache
//
//  Created by Ben Honig on 7/7/14.
//  Copyright (c) 2014 iPhonig, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHImageDownloaderFileManager : NSObject

+ (BHImageDownloaderFileManager *)sharedFileManager;

- (NSString *)cacheDirectoryPath;

- (NSString *)filePathForKey:(NSString *)key;

- (NSOperationQueue *)saveOperationQueue;

- (void)saveImageToDiskForKey:(UIImage *)image key:(NSString *)key;

- (unsigned long long)freeDiskSpace;

- (void)removeOldFiles:(NSDate *)date;

@property (strong, nonatomic) NSFileManager *fileManager;

@end


