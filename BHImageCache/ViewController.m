//
//  ViewController.m
//  BHImageCache
//
//  Created by Ben Honig on 9/10/14.
//  Copyright (c) 2014 iPhonig, LLC. All rights reserved.
//

#import "ViewController.h"

#define kImageURL @"http://4.bp.blogspot.com/-uEH75pSdcNM/Te_R5vkhI9I/AAAAAAAAG5o/XuxKdT5FtUI/s640/nature+photos.jpg"
#define kButtonURL @"http://kbase.vectorworks.net/images/os-x-mavericks-logo.png"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - UIImageView+BHImageCache

- (IBAction)downloadImage:(id)sender{
    [self.imageView setImageURL:kImageURL
                    placeholder:nil
                   refreshCache:NO
                           fade:YES
                     completion:^(BOOL finished) {
                         //Once download is finished, perform code here.
                         //You may for instance want to stop and remove a UIActivityIndicator here
                     }];
}

#pragma mark - UIButton+BHImageCache

- (IBAction)downloadButton:(id)sender{
    [self.button setImageURL:kButtonURL
                refreshCache:NO
                        fade:YES
                  completion:^(BOOL finished) {
                      //completion code here
                  }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
