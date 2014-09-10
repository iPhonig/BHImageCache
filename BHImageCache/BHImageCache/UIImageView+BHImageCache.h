//
//  UIImageView+BHImageCache.h
//  BHImageCache
//
//  Created by Ben Honig on 7/8/14.
//  Copyright (c) 2014 iPhonig, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (BHImageCache)

-(void)setImageURL:(NSString*)url placeholder:(UIImage*)placeholder
      refreshCache:(BOOL)refresh
              fade:(BOOL)fadeImage
        completion:(void(^)(BOOL finished))completion;
@end
