//
//  UIButton+BHImageCache.m
//  Paperless
//
//  Created by Ben Honig on 7/29/14.
//  Copyright (c) 2014 iPhonig, LLC. All rights reserved.
//
#import "UIButton+BHImageCache.h"
#import "BHImageDownloader.h"

#define kFadeDuration 0.3

@implementation UIButton (BHImageCache)

- (void)setImageURL:(NSString *)url refreshCache:(BOOL)refresh fade:(BOOL)fadeButton completion:(void (^)(BOOL))completion{
    BHImageDownloader *imageDownloader = [BHImageDownloader sharedDownloader];
    __weak UIButton *weakSelf = self;
    [imageDownloader imageForURL:url refreshCache:refresh completion:^(UIImage *image) {
        __strong UIButton *strongSelf = weakSelf;
        if (!strongSelf) return;
        if (image){
            [strongSelf setBackgroundImage:image forState:UIControlStateNormal];
            if (fadeButton) {
                [self transitionButton:strongSelf];
            }
        }
        if (completion) {
            completion(image != nil);
        }
    }];
}

- (void)transitionButton:(UIButton *)button{
    [UIView transitionWithView:button
                      duration:kFadeDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                    } completion:^(BOOL finished) {
                    }];
}

@end
