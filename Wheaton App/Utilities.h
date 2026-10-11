//
//  Utilities.h
//  Wheaton App
//
//  NOTICE: Rewritten by an LLM (Claude Code), 2026-10-11. The push-notification
//  check was removed; the image loader replaces AFNetworking's UIImageView category.
//

#import <UIKit/UIKit.h>

@interface Utilities : NSObject

+ (void)loadImageAtURL:(NSString *)urlString intoImageView:(UIImageView *)imageView placeholder:(UIImage *)placeholder;

@end
