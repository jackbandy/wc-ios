//
//  WebViewController.h
//  Wheaton App
//
//  Created by Chris Anderson on 12/6/13.
//
//  NOTICE: Modified by an LLM (Claude Code), 2026-10-11: UIWebView replaced with
//  WKWebView. The storyboard outlet `webView` is now a plain container view.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WebViewController : UIViewController <WKNavigationDelegate>

@property (strong, nonatomic) IBOutlet UIView *webView;
@property (strong, nonatomic, readonly) WKWebView *wkWebView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;
@property (strong, nonatomic) NSURL *url;
@property BOOL allowZoom;
@property BOOL allowResize;
@property BOOL refresh;

@end
