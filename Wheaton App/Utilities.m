//
//  Utilities.m
//  Wheaton App
//
//  NOTICE: Rewritten by an LLM (Claude Code), 2026-10-11. See Utilities.h.
//

#import "Utilities.h"

@implementation Utilities

+ (void)loadImageAtURL:(NSString *)urlString intoImageView:(UIImageView *)imageView placeholder:(UIImage *)placeholder
{
    imageView.image = placeholder;
    NSURL *url = ([urlString isKindOfClass:[NSString class]] && urlString.length > 0) ? [NSURL URLWithString:urlString] : nil;
    if (!url) {
        return;
    }
    __weak UIImageView *weakImageView = imageView;
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *image = data ? [UIImage imageWithData:data] : nil;
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakImageView.image = image;
            });
        }
    }] resume];
}

@end
