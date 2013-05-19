//
//  ZGSAppDelegate.h
//  HZMapHD
//
//  Created by zjugis on 13-5-14.
//  Copyright (c) 2013年 zgis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZGSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSDictionary *userData;

+ (NSString *)offlineDirectory;
+ (NSString *)cacheDirectory;
+ (ZGSAppDelegate *)sharedInstance;

@end
