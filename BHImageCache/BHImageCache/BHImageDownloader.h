//
//  BHImageDownloader.h
//  BHImageCache
//
//  Created by Ben Honig on 7/7/14.
//  Copyright (c) 2014 iPhonig, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHImageDownloader : NSObject

// When the app goes into the background, more time will be requested so that old files that are past the expiration time are deleted.
// Default is 7 days: -604800
#define DEFAULT_EXPIRATION_INTERVAL -604800
@property (assign, nonatomic) NSTimeInterval fileExpirationInterval;

// If the http response status code is not in the 400-499 range a you can retry a request
// Default: 0
@property (assign, nonatomic) NSInteger maxNumberOfRetries;
// Number of seconds to wait between retries
// Default 0.0
@property (assign, nonatomic) NSTimeInterval retryDelay;


+ (BHImageDownloader *)sharedDownloader;

- (void)imageForURL:(NSString *)url refreshCache:(BOOL)refresh completion:(void (^)(UIImage *image))completion;

- (void)clearAllData;


@end
