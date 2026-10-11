//
//  WebViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 12/6/13.
//
//  NOTICE: Modified by an LLM (Claude Code), 2026-10-11. See WebViewController.h.
//

#import "WebViewController.h"

@interface WebViewController ()

@property (strong, nonatomic, readwrite) WKWebView *wkWebView;

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activityView.hidesWhenStopped = YES;

    UIView *container = self.webView ?: self.view;
    self.wkWebView = [[WKWebView alloc] initWithFrame:container.bounds configuration:[[WKWebViewConfiguration alloc] init]];
    self.wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.wkWebView.navigationDelegate = self;
    [container addSubview:self.wkWebView];
    if (self.activityView) {
        [self.activityView.superview bringSubviewToFront:self.activityView];
    }

    if (self.url.isFileURL) {
        [self.wkWebView loadFileURL:self.url allowingReadAccessToURL:self.url];
    } else if (self.url) {
        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.activityView startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.activityView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.activityView stopAnimating];
}

- (void)viewDidLayoutSubviews
{
    if (self.allowResize != NO) {
        self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}

@end
