//
//  ProgressiveAuthentication.h
//  ProgressiveAuthentication
//
//  Created by Edwin Zhang on 11/19/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProgressiveAuthenticationLockModel.h"
#import "ProgressiveAuthenticationCreatePasswordViewController.h"
#import "ProgressiveAuthenticationEnterPasswordViewController.h"
#import "ProgressiveAuthenticationUnlockViewController.h"
#import "ProgressiveAuthenticationLockModel.h"
#import "ProgressiveAuthenticationCreatePatternViewController.h"
#import "ProgressiveAuthenticationEnterPatternViewController.h"
#import "ProgressiveAuthenticationCreateOneTimePasswordViewController.h"
#import "ProgressiveAuthenticationEnterOneTimePasswordViewController.h"

typedef NS_ENUM(NSUInteger, ProgressiveAuthenticationTouchIDResponse) {
    ProgressiveAuthenticationTouchIDResponseUndefined,
    ProgressiveAuthenticationTouchIDResponseSuccess,
    ProgressiveAuthenticationTouchIDResponseUsePassword,
    ProgressiveAuthenticationTouchIDResponseCanceled,
};

@interface ProgressiveAuthentication : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isPasswordSet;
- (NSString *)currentPassword;
- (ProgressiveAuthenticationUnlockType)authenticationType;
- (void)setAuthenticationType:(ProgressiveAuthenticationUnlockType)authenticationType;
- (BOOL)isPasswordValid:(NSString *)password;
- (void)setPassword:(NSString *)password forAuthenticationType:(ProgressiveAuthenticationUnlockType)authenticationType;
- (void)deletePassword;

+ (BOOL)canUseTouchID;
+ (BOOL)shouldUseTouchID;
+ (void)setShouldUseTouchID:(BOOL)shouldUseTouchID;
- (void)requestTouchIDWithCompletion:(void(^)(ProgressiveAuthenticationTouchIDResponse response))completionBlock;
- (void)requestTouchIDWithCompletion:(void(^)(ProgressiveAuthenticationTouchIDResponse response))completionBlock reason:(NSString *)reason;

- (NSUInteger)passwordAttemptLimit;
- (ProgressiveAuthenticationLockModel *)model;

@end


