//
//  FMXWebViewController.m
//  FMXWebView
//
//  Created by HEJIE on 2017/7/3.
//  Copyright © 2017年 Formax. All rights reserved.
//

#import "FMXWebViewController.h"
#import "FMXWebViewProgressView.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

NSString *const FMXWebViewRefreshNotification = @"com.fmx.webview.refresh.notification";

@interface FMXWebViewController () <UIGestureRecognizerDelegate, WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) FMXWebViewProgressView *progressView;
@property (nonatomic, strong) UIButton *closebutton;
@end

@implementation FMXWebViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _configuration = [FMXWebConfiguration defaultConfiguration];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        _configuration = [FMXWebConfiguration defaultConfiguration];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    
    self = [self initWithNibName:nil bundle:nil];
    
    if (self) {
        
        _url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerNotification];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNavigationbarButtonItem];
    [self setupContentView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController.navigationBar addSubview:self.progressView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    if (_progressView) {
        
        [_progressView removeFromSuperview];
    }
}

- (void)setupContentView {
    
    [self.view addSubview:self.webView];
    if (self.url) {
        
        [self getURLRequestWithCompletionHandler:^(NSURLRequest *req) {
           
            [self.webView loadRequest:req];
        }];
    }
    
    if (self.navigationController && self.navigationController.topViewController == self) {
        CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
        CGFloat progressHeight = 2;
        self.progressView = [[FMXWebViewProgressView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(navigationBarFrame) - progressHeight, CGRectGetWidth(navigationBarFrame), progressHeight)];
        self.progressView.progress = 0.1;
        self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
}

- (void)setupNavigationbarButtonItem {
    
    if (!self.navigationController || self.navigationController.topViewController != self || self.navigationController.viewControllers.firstObject == self) return;
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithImage:self.configuration.moreItemImage style:UIBarButtonItemStylePlain target:self action:@selector(onTappedMoreItem:)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44.0)];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44.0, 44.0)];
    [backBtn setImage:self.configuration.backItemImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onTappedBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:backBtn];
    if (@available(iOS 11.0, *)) {
        backBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    }

    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(40.0, 0, 44.0, 44.0)];
    closeBtn.hidden = YES;
    [closeBtn setImage:self.configuration.closeItemImage forState:UIControlStateNormal];
    closeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [closeBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onTappedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:closeBtn];
    self.closebutton = closeBtn;
    if (@available(iOS 11.0, *)) {
        closeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        closeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    }

    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButtonItem.width = -20.f;
    [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem, leftBarItem]];
}

- (void)registerNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotification:) name:FMXWebViewRefreshNotification object:nil];
}

- (void)unregisterNotificaiton {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshNotification:(NSNotification *)notification {
    
    [self reloadWithURL:self.url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [self unregisterNotificaiton];
    
    if (_webView) {
        
        _webView.UIDelegate = nil;
        _webView.navigationDelegate = nil;
        
        [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [_webView removeObserver:self forKeyPath:@"title"];
    }
    
    if (_progressView) {
        
        [_progressView removeFromSuperview];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        [_progressView setProgress:[change[NSKeyValueChangeNewKey] floatValue] animated:YES];
    } else if ([keyPath isEqualToString:@"title"]) {
      
        if (!self.customTitle) {
            
            self.navigationItem.title = change[NSKeyValueChangeNewKey];
        }
    } else {
        
        if ([super respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
            
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

#pragma mark - Public Methods

- (void)reloadWithURL:(NSURL *)url {
    
    self.url = url;
    [self getURLRequestWithCompletionHandler:^(NSURLRequest *req) {
       
        [self.webView loadRequest:req];
    }];
}

#pragma mark - Event

- (void)onTappedMoreItem:(UIBarButtonItem *)item {
    
    !self.configuration.onClickMoreItem ?: self.configuration.onClickMoreItem(item);
}

- (void)onTappedBackButton:(UIButton *)btn {
    
    if ([self.webView canGoBack]) {
        
        [self.webView goBack];
    } else {
        
        [self close];
    }
}

- (void)onTappedCloseButton:(UIButton *)btn {
    
    [self close];
}

- (void)close {
    
    if (!self.navigationController ||
        (self.navigationController.viewControllers.count == 1 &&
        self.navigationController.viewControllers.firstObject == self)) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView*)webView didStartProvisionalNavigation:(WKNavigation*)navigation {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewControllerDidStartLoad:)]) {
        
        [self.delegate webViewControllerDidStartLoad:self];
    } else {
        
        !self.configuration.didStartLoad ?: self.configuration.didStartLoad(self);
    }
}

- (void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation {
    
    self.closebutton.hidden = ![webView canGoBack];
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        
        [self.delegate webViewControllerDidFinishLoad:self];
    } else {
      
        !self.configuration.didFinishLoad ?: self.configuration.didFinishLoad(self);
    };
}

- (void)webView:(WKWebView*)webView didFailProvisionalNavigation:(WKNavigation*)navigation withError:(NSError*)error {
    
    // fix fast reload same url
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:didFailLoadWithError:)]) {
        
        [self.delegate webViewController:self didFailLoadWithError:error];
    } else {
        
        !self.configuration.didFailLoad ?: self.configuration.didFailLoad(self, error);
    }
}

- (void)webView:(WKWebView*)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    BOOL res = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:shouldStartLoadWithRequest:navigationType:)]) {
        
        res = [self.delegate webViewController:self shouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    } else {
        
        if (self.configuration.shouldStartLoad) {
            
            res = self.configuration.shouldStartLoad(self, navigationAction.request, navigationAction.navigationType);
        }
    }
    
    decisionHandler(res ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
}

#pragma mark - Private Methods

- (void)getURLRequestWithCompletionHandler:(void(^)(NSURLRequest*)) completion {
    
    if (!self.url) {
        
        !completion ?: completion(nil);
        return;
    }
    
    //生成URL Block
    void(^URLConstructBlock)(void(^URLConstructCompletionHandle)(NSURL*)) = ^(void(^URLConstructCompletionHandle)(NSURL*)){
      
        if (!self.configuration.URLModifyBlock) {
            
            !URLConstructCompletionHandle ?: URLConstructCompletionHandle(self.url);
        } else {
            
            self.configuration.URLModifyBlock(self.url, ^(NSURL *url){
                
                !URLConstructCompletionHandle ?: URLConstructCompletionHandle(url);
            });
        }
    };
    
    //生成Request Block
    void(^URLRequestConstructBlock)(void(^URLRequestConstructCompletionHandle)(NSURLRequest*)) = ^(void(^URLRequestConstructCompletionHandle)(NSURLRequest*)){
        
        //先调用生成URL Block
        URLConstructBlock(^(NSURL* url){
            
            NSMutableURLRequest *oriReq = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
            if (!self.configuration.URLRequestModifyBlock) {
                
                !URLRequestConstructCompletionHandle ?: URLRequestConstructCompletionHandle(oriReq.copy);
            } else {
                
                self.configuration.URLRequestModifyBlock(oriReq, ^(NSURLRequest * _Nonnull req) {
                   
                    !URLRequestConstructCompletionHandle ?: URLRequestConstructCompletionHandle(req);
                });
            }
        });
    };
    
    URLRequestConstructBlock(^(NSURLRequest *req){
       
        !completion ?: completion(req);
    });
}

-  (WKWebViewConfiguration *)getWebViewConfuration {
    
    WKWebViewConfiguration *configuration = nil;
    if (self.configuration.webViewConfigurationConstructBlock) {
        
        configuration = self.configuration.webViewConfigurationConstructBlock();
    }
    
    if (!configuration) {
        
        configuration = [[WKWebViewConfiguration alloc] init];
    }
    
    return configuration;
}

#pragma mark - Getter

- (WKWebView *)webView {
    
    if (!_webView) {
        
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[self getWebViewConfuration]];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.scrollView.alwaysBounceHorizontal = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:(NSKeyValueObservingOptionNew) context:nil];
        [_webView addObserver:self forKeyPath:@"title" options:(NSKeyValueObservingOptionNew) context:nil];
    }
    return _webView;
}

- (void)setCustomTitle:(NSString *)customTitle {
    
    _customTitle = customTitle;
    self.navigationItem.title = customTitle;
}
@end
