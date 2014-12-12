//
//  ProgressiveAuthenticationOneTimeViewController.h
//  BasicApp
//
//  Created by Edwin Zhang on 12/10/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgressiveAuthentication;

@interface ProgressiveAuthenticationOneTimeViewController : UIViewController

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITextField *passwordField;

@property (nonatomic, strong) ProgressiveAuthentication *touchLock;

@property (nonatomic, copy) void (^willFinishWithResult)(BOOL success);

- (void)enteredCode:(NSString *)code;

- (void)finishWithResult:(BOOL)success animated:(BOOL)animated;

- (void)shakeAndVibrateCompletion:(void (^)())completionBlock;

@end
