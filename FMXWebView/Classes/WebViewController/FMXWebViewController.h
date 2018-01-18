//
//  FMXWebViewController.h
//  FMXWebView
//
//  Created by LIYINGPENG on 2017/7/3.
//  Copyright © 2017年 Formax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "FMXWebConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const FMXWebViewRefreshNotification;

@protocol FMXWebViewControllerDelegate;
@interface FMXWebViewController : UIViewController

@property (nonatomic, strong, null_resettable, readonly) WKWebView *webView;
@property (nonatomic, strong) FMXWebConfiguration *configuration;///< default: defaultConfiguration
@property (nonatomic, weak) id<FMXWebViewControllerDelegate> delegate;///< 当delegate实现了configuration中相应的方法时，会优先调用delegate的方法，忽略configuration对应的方法

@property (nonatomic, strong) NSURL *url;
- (void)reloadWithURL:(NSURL *)url;

@property (nonatomic, copy, nullable) NSString *customTitle;

- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
@end

@protocol FMXWebViewControllerDelegate <NSObject>

@optional
- (void)webViewControllerDidStartLoad:(FMXWebViewController *)webViewController;
- (void)webViewControllerDidFinishLoad:(FMXWebViewController *)webViewController;
- (void)webViewController:(FMXWebViewController *)webViewController didFailLoadWithError:(NSError *)error;
- (BOOL)webViewController:(FMXWebViewController *)webViewController shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType;

@end
NS_ASSUME_NONNULL_END
