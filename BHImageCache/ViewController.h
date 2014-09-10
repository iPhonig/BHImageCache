//
//  ViewController.h
//  BHImageCache
//
//  Created by Ben Honig on 9/10/14.
//  Copyright (c) 2014 iPhonig, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
//To use BHImageImage cache all you have to do is import it like so
//UIImageView
#import "UIImageView+BHImageCache.h"
//UIButton
#import "UIButton+BHImageCache.h"

@interface ViewController : UIViewController

- (IBAction)downloadImage:(id)sender;
- (IBAction)downloadButton:(id)sender;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *button;

@end
