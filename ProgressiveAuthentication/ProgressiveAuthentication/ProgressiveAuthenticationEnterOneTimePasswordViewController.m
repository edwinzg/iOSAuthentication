//
//  ProgressiveAuthenticationEnterOneTimePasswordViewController.m
//  BasicApp
//
//  Created by Edwin Zhang on 12/10/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationEnterOneTimePasswordViewController.h"
#import "ProgressiveAuthentication.h"

#define ProgressiveAuthenticationNumIncorrectAttemptsUserDefaultsKey @"ProgressiveAuthenticationNumIncorrectAttemptsUserDefaultsKey"

@interface ProgressiveAuthenticationEnterOneTimePasswordViewController ()

@property (nonatomic) UIButton *submitButton;

@end

@implementation ProgressiveAuthenticationEnterOneTimePasswordViewController

#pragma mark - Class Methods

+ (void)resetPasswordAttemptHistory {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults removeObjectForKey:ProgressiveAuthenticationNumIncorrectAttemptsUserDefaultsKey];
    [standardDefaults synchronize];
}

#pragma mark - Self Inflating Views

- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _submitButton.frame = CGRectMake(45, 125, 100, 50);
        [_submitButton setTitle:@"Submit" forState:UIControlStateNormal];
        [_submitButton addTarget:self action:@selector(submitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

#pragma mark - Button Actions

- (void)submitButtonTapped:(UIButton *)sender
{
    [self performSelector:@selector(enteredCode:) withObject:self.passwordField.text afterDelay:0.3];
}

#pragma mark - Layout

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = [self.touchLock model].enterPasswordInitialLabelText;
    [self.view addSubview:[self submitButton]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enteredCode:(NSString *)code {
    if ([self.touchLock isPasswordValid:code]) {
        [[self class] resetPasswordAttemptHistory];
        [self finishWithResult:YES animated:YES];
    } else {
        [self shakeAndVibrateCompletion:^{
            self.titleLabel.text = [self.touchLock model].enterPasswordIncorrectLabelText;
            [self clearPassword];
            [self recordIncorrectPasswordAttempt];
        }];
    }
}

- (void)clearPassword {
    self.passwordField.text = @"";
}

- (void)recordIncorrectPasswordAttempt {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger numberOfAttemptsSoFar = [standardDefaults integerForKey:ProgressiveAuthenticationNumIncorrectAttemptsUserDefaultsKey];
    numberOfAttemptsSoFar ++;
    [standardDefaults setInteger:numberOfAttemptsSoFar forKey:ProgressiveAuthenticationNumIncorrectAttemptsUserDefaultsKey];
    [standardDefaults synchronize];
    if (numberOfAttemptsSoFar >= [self.touchLock passwordAttemptLimit]) {
        [self callExceededLimitActionBlock];
    }
}

- (void)callExceededLimitActionBlock {
    exit(0);
}

- (ProgressiveAuthenticationUnlockViewController *)parentUnlockViewController {
    ProgressiveAuthenticationUnlockViewController *unlockViewController = nil;
    UIViewController *presentingViewController = self.presentingViewController;
    if ([presentingViewController isKindOfClass:[ProgressiveAuthenticationUnlockViewController class]]) {
        unlockViewController = (ProgressiveAuthenticationUnlockViewController *)presentingViewController;
    }
    return unlockViewController;
}

#pragma mark - UITextField Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *newString = textField.text;
    [self performSelector:@selector(enteredCode:) withObject:newString afterDelay:0.3];
    return YES;
}

@end
