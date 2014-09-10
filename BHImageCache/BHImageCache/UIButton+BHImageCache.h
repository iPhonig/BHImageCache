//
//  UIButton+BHImageCache.h
//  Paperless
//
//  Created by Ben Honig on 7/29/14.
//  Copyright (c) 2014 iPhonig, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (BHImageCache)

- (void)setImageURL:(NSString*)url
       refreshCache:(BOOL)refresh
               fade:(BOOL)fadeButton
         completion:(void(^)(BOOL finished))completion;

@end
