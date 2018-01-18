//
//  FMXWebConfiguration.m
//  FMXWebView
//
//  Created by LIYINGPENG on 2017/7/6.
//  Copyright © 2017年 Formax. All rights reserved.
//

#import "FMXWebConfiguration.h"

@implementation FMXWebConfiguration

+ (instancetype)defaultConfiguration {
    
    static dispatch_once_t onceToken;
    static FMXWebConfiguration *configuration = nil;
    dispatch_once(&onceToken, ^{
        
        configuration = [[FMXWebConfiguration alloc] init];
    });
    
    return configuration;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.backItemImage = [[UIImage imageNamed:@"FMXWeb.bundle/web_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.closeItemImage = [[UIImage imageNamed:@"FMXWeb.bundle/web_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.moreItemImage = [[UIImage imageNamed:@"FMXWeb.bundle/web_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    return self;
}

#pragma mark -NSCoping
- (instancetype)copyWithZone:(NSZone *)zone {
    
    FMXWebConfiguration *configCopy = [[[self class] allocWithZone:zone] init];
    configCopy.backItemImage = self.backItemImage;
    configCopy.closeItemImage = self.closeItemImage;
    configCopy.moreItemImage = self.moreItemImage;
    
    if (self.onClickMoreItem) {
        
        configCopy.onClickMoreItem = [self.onClickMoreItem copy];
    }
    
    if (self.URLModifyBlock) {
        
        configCopy.URLModifyBlock = [self.URLModifyBlock copy];
    }
    
    if (self.didStartLoad) {
        
        configCopy.didStartLoad = [self.didStartLoad copy];
    }
    if (self.didFinishLoad) {
        
        configCopy.didFinishLoad = [self.didFinishLoad copy];
    }
    if (self.didFailLoad) {
        
        configCopy.didFailLoad = [self.didFailLoad copy];
    }
    if (self.shouldStartLoad) {
        
        configCopy.shouldStartLoad = [self.shouldStartLoad copy];
    }
    
    
    return configCopy;
}
@end
