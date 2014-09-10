BHImageCache
============

Image caching library that utilizes NSURLSession and supports UIImageView as well as UIButton. 
Also supports fading images and placeholders while image is being downloaded.

![ss](https://raw.githubusercontent.com/iPhonig/BHImageCache/master/screenshot.png)

Usage
============

- Import UIImageView+BHImageCache for UIImageView support
- Import UIButton+BHImageCache for UIButton support
- Call method on UIImageView or UIButton just like you you normally would.

```
//UIImageView
[self.imageView setImageURL:@"http://www.site.com/image.png"
                    placeholder:nil
                   refreshCache:NO
                           fade:YES
                     completion:^(BOOL finished) {
}];

//UIButton
[self.button setImageURL:@"http://www.site.com/image.png"
                refreshCache:NO
                        fade:YES
                  completion:^(BOOL finished) {
                      //completion code here
                  }];
```
