//
//  ProgressiveAuthenticationUnlockViewController.h
//  ProgressiveAuthentication
//
//  Created by Edwin Zhang on 12/4/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ProgressiveAuthenticationUnlockType) {
    ProgressiveAuthenticationUnlockTypeNoAuth,
    ProgressiveAuthenticationUnlockTypeNone,
    ProgressiveAuthenticationUnlockTypeTouchID,
    ProgressiveAuthenticationUnlockTypePassword,
    ProgressiveAuthenticationUnlockTypePIN,
    ProgressiveAuthenticationUnlockTypeOneTime,
    ProgressiveAuthenticationUnlockTypePattern
};

@class ProgressiveAuthentication;

@interface ProgressiveAuthenticationUnlockViewController : UIViewController

@property (nonatomic, copy) void (^didFinishWithSuccess)(BOOL success, ProgressiveAuthenticationUnlockType unlockType);

@property (nonatomic, strong) ProgressiveAuthentication *touchLock;

- (void)showUnlockAnimated:(BOOL)animated;
- (void)showTouchID;
- (void)showPasswordAnimated:(BOOL)animated;

- (void)dismissWithUnlockSuccess:(BOOL)success
                      unlockType:(ProgressiveAuthenticationUnlockType)unlockType
                        animated:(BOOL)animated;

@end
