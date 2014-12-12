//
//  ProgressiveAuthenticationUnlockViewController.m
//  ProgressiveAuthentication
//
//  Created by Edwin Zhang on 12/4/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationUnlockViewController.h"
#import "ProgressiveAuthentication.h"
#import "ProgressiveAuthenticationEnterPasswordViewController.h"
#import "ProgressiveAuthenticationEnterPatternViewController.h"

@implementation ProgressiveAuthenticationUnlockViewController

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}


#pragma mark - Present unlock methods

- (void)showUnlockAnimated:(BOOL)animated {
    if ([[ProgressiveAuthentication sharedInstance] authenticationType] ==
        ProgressiveAuthenticationUnlockTypeTouchID) {
        [self showTouchID];
    } else if ([[ProgressiveAuthentication sharedInstance] authenticationType] ==
                ProgressiveAuthenticationUnlockTypePassword) {
        [self showPasswordAnimated:animated];
    } else if ([[ProgressiveAuthentication sharedInstance] authenticationType] ==
               ProgressiveAuthenticationUnlockTypePattern) {
        [self showPatternAnimated:animated];
    } else if ([[ProgressiveAuthentication sharedInstance] authenticationType] ==
               ProgressiveAuthenticationUnlockTypeOneTime) {
        [self showOneTimeAnimated:animated];
    }
}

- (void)showTouchID {
    __weak ProgressiveAuthenticationUnlockViewController *weakSelf = self;
    [self.touchLock requestTouchIDWithCompletion:^(ProgressiveAuthenticationTouchIDResponse response) {
        switch (response) {
            case ProgressiveAuthenticationTouchIDResponseSuccess:
                [weakSelf unlockWithType:ProgressiveAuthenticationUnlockTypeTouchID];
                break;
            case ProgressiveAuthenticationTouchIDResponseUsePassword:
                [weakSelf showPasswordAnimated:YES];
                break;
            default:
                break;
        }
    }];
}

- (void)showPasswordAnimated:(BOOL)animated {
    [self presentViewController:[self enterPasswordVC] animated:animated completion:nil];
}

- (void)showPatternAnimated:(BOOL)animated {
    [self presentViewController:[self enterPatternVC] animated:animated completion:nil];
}

- (void)showOneTimeAnimated:(BOOL)animted{
    [self presentViewController:[self enterOneTimeVC] animated:YES completion:nil];
}

- (ProgressiveAuthenticationEnterPasswordViewController *)enterPasswordVC {
    ProgressiveAuthenticationEnterPasswordViewController *enterPasswordVC = [[ProgressiveAuthenticationEnterPasswordViewController alloc] init];
    __weak ProgressiveAuthenticationUnlockViewController *weakSelf = self;
    enterPasswordVC.willFinishWithResult = ^(BOOL success) {
        if (success) {
            [weakSelf unlockWithType:ProgressiveAuthenticationUnlockTypePassword];
        }
        else {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    };
    return enterPasswordVC;
}

- (ProgressiveAuthenticationEnterPatternViewController *)enterPatternVC {
    ProgressiveAuthenticationEnterPatternViewController *enterPatternVC = [[ProgressiveAuthenticationEnterPatternViewController alloc] init];
    __weak ProgressiveAuthenticationUnlockViewController *weakSelf = self;
    enterPatternVC.willFinishWithResult = ^(BOOL success) {
        if (success) {
            [weakSelf unlockWithType:ProgressiveAuthenticationUnlockTypePattern];
        }
        else {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    };
    return enterPatternVC;
}

- (ProgressiveAuthenticationEnterOneTimePasswordViewController *)enterOneTimeVC {
    ProgressiveAuthenticationEnterOneTimePasswordViewController *enterOneTimeVC = [[ProgressiveAuthenticationEnterOneTimePasswordViewController alloc] init];
    __weak ProgressiveAuthenticationUnlockViewController *weakSelf = self;
    enterOneTimeVC.willFinishWithResult = ^(BOOL success) {
        if (success) {
            [weakSelf unlockWithType:ProgressiveAuthenticationUnlockTypeOneTime];
        }
        else {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    };
    return enterOneTimeVC;
}

- (void)appWillEnterForeground {
    if (!self.presentedViewController) {
        [self showUnlockAnimated:NO];
    }
}

- (void)unlockWithType:(ProgressiveAuthenticationUnlockType)unlockType {
    [self dismissWithUnlockSuccess:YES
                        unlockType:unlockType
                          animated:YES];
}

- (void)dismissWithUnlockSuccess:(BOOL)success
                      unlockType:(ProgressiveAuthenticationUnlockType)unlockType
                        animated:(BOOL)animated {
    [self.presentingViewController dismissViewControllerAnimated:animated completion:^{
        if (self.didFinishWithSuccess) {
            self.didFinishWithSuccess(success, unlockType);
        }
    }];
}

- (void)initialize {
    _touchLock = [ProgressiveAuthentication sharedInstance];
}

@end
