//
//  ProgressiveAuthenticationEnterPasswordViewController.m
//  ProgressiveAuthentication
//
//  Created by Edwin Zhang on 12/5/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationEnterPasswordViewController.h"
#import "ProgressiveAuthentication.h"
#import "ProgressiveAuthenticationUnlockViewController.h"

#define ProgressiveAuthenticationNumIncorrectAttemptsUserDefaultsKey @"ProgressiveAuthenticationNumIncorrectAttemptsUserDefaultsKey"

@interface ProgressiveAuthenticationEnterPasswordViewController ()

@property (nonatomic) UIButton *submitButton;

@end

@implementation ProgressiveAuthenticationEnterPasswordViewController

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
    [self performSelector:@selector(enteredPassword:) withObject:self.passwordField.text afterDelay:0.3];
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = [self.touchLock model].enterPasswordViewControllerTitle;
    }
    return self;
}

#pragma mark - Views

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

- (void)enteredPassword:(NSString *)password {
    if ([self.touchLock isPasswordValid:password]) {
        [[self class] resetPasswordAttemptHistory];
        [self finishWithResult:YES animated:YES];
    }
    else {
        [self shakeAndVibrateCompletion:^{
            self.titleLabel.text = [self.touchLock model].enterPasswordIncorrectLabelText;
            [self clearPassword];
            [self recordIncorrectPasswordAttempt];
        }];
        
    }
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

@end
