//
//  ProgressiveAuthenticationPasswordViewController.h
//  ProgressiveAuthentication
//
//  Created by Edwin Zhang on 12/5/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgressiveAuthentication;

@interface ProgressiveAuthenticationPasswordViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITextField *passwordField;

@property (nonatomic, strong) ProgressiveAuthentication *touchLock;

@property (nonatomic, copy) void (^willFinishWithResult)(BOOL success);

- (void)clearPassword;
- (void)enteredPassword:(NSString *)password;

- (void)finishWithResult:(BOOL)success animated:(BOOL)animated;

- (void)shakeAndVibrateCompletion:(void (^)())completionBlock;


@end
