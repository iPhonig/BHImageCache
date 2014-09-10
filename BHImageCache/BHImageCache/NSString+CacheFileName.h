//
//  NSString+CacheFileName.h
//  BHImageCache
//
//  Created by Ben Honig on 7/7/14.
//  Copyright (c) 2014 iPhonig, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CacheFileName)

+ (NSString *)createCachedFileNameForKey:(NSString *)key;

@end
