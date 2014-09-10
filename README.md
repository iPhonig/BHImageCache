BHImageCache
============

Image caching library that utilizes NSURLSession and supports UIImageView as well as UIButton.

![ss](https://raw.githubusercontent.com/iPhonig/BHImageCache/master/screenshot.png)

Key Features
============

- Refresh cache option (could be used for a user profile photo)
- Fading in images
- Placeholder images while an image is being downloaded (UIImageView only support for now)

Usage
============

- Import UIImageView+BHImageCache for UIImageView support
- Import UIButton+BHImageCache for UIButton support
- Call method on UIImageView or UIButton just like you would normally call any method.

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
