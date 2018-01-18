//
//  FMXWebConfiguration.h
//  FMXWebView
//
//  Created by HEJIE on 2017/7/6.
//  Copyright © 2017年 Formax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FMXWebViewController;
@interface FMXWebConfiguration : NSObject <NSCopying>

@property (nonatomic, strong) UIImage *backItemImage;
@property (nonatomic, strong) UIImage *closeItemImage;
@property (nonatomic, strong) UIImage *moreItemImage;

//item event
@property (nonatomic, copy, nullable) void(^onClickMoreItem)(id);

//WKWebViewConfiguration Construct Block
@property (nonatomic, copy, nullable) WKWebViewConfiguration*(^webViewConfigurationConstructBlock)();

//URL Modify
@property (nonatomic, copy, nullable) void(^URLModifyBlock)(NSURL*, void(^CompletionHandler)(NSURL *));

//URL Request Modify
@property (nonatomic, copy, nullable) void(^URLRequestModifyBlock)(NSMutableURLRequest*, void(^CompletionHandler)(NSURLRequest *));

//webview delegate
@property (nonatomic, copy, nullable) void(^didStartLoad)(FMXWebViewController *);
@property (nonatomic, copy, nullable) void(^didFinishLoad)(FMXWebViewController *);
@property (nonatomic, copy, nullable) void(^didFailLoad)(FMXWebViewController *, NSError * _Nullable);
@property (nonatomic, copy, nullable) BOOL(^shouldStartLoad)(FMXWebViewController *, NSURLRequest * _Nullable, WKNavigationType);

//在App的入口需要对`defaultConfiguration`进行一次全局的配置
+ (instancetype)defaultConfiguration;
@end
NS_ASSUME_NONNULL_END
