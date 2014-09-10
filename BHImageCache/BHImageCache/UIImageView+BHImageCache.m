//
//  UIImageView+BHImageCache.m
//  BHImageCache
//
//  Created by Ben Honig on 7/8/14.
//  Copyright (c) 2014 iPhonig, LLC. All rights reserved.
//
#import "UIImageView+BHImageCache.h"
#import "BHImageDownloader.h"

#define kFadeDuration 0.3

@implementation UIImageView (BHImageCache)

-(void)setImageURL:(NSString *)url placeholder:(UIImage *)placeholder
      refreshCache:(BOOL)refresh
              fade:(BOOL)fadeImage
        completion:(void (^)(BOOL))completion{
    if (placeholder != nil) {
        self.image = placeholder;
    }
    
    BHImageDownloader *imageDownloader = [BHImageDownloader sharedDownloader];
    __weak UIImageView *weakSelf = self;
    [imageDownloader imageForURL:url refreshCache:refresh completion:^(UIImage *image) {
        __strong UIImageView *strongSelf = weakSelf;
        if (!strongSelf) return;
        if (image){
            strongSelf.image = image;
            //if user chooses to fade the image fade it
            if (fadeImage) {
                [self transitionImage:strongSelf];
            }
        }
        if (completion) {
            completion(image != nil);
        }
    }];
}

- (void)transitionImage:(UIImageView *)imageView{
    [UIView transitionWithView:imageView
                      duration:kFadeDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                    } completion:^(BOOL finished) {
                    }];
}


@end