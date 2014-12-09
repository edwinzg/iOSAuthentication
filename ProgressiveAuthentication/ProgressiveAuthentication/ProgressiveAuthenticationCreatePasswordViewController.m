//
//  ProgressiveAuthenticationCreatePasswordViewController.m
//  ProgressiveAuthentication
//
//  Created by Edwin Zhang on 12/5/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationCreatePasswordViewController.h"
#import "ProgressiveAuthentication.h"

@interface ProgressiveAuthenticationCreatePasswordViewController () {
    BOOL authenticated;
}

@property (strong, nonatomic) NSString *firstPassword;
@property (nonatomic) UIButton *confirmButton;
@property (nonatomic) UIButton *cancelButton;

@end

@implementation ProgressiveAuthenticationCreatePasswordViewController

#pragma mark - Self Inflating Views

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _confirmButton.frame = CGRectMake(45, 125, 100, 50);
        [_confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _cancelButton.frame = CGRectMake(285, 125, 100, 50);
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark - Button Actions

- (void)confirmButtonTapped:(UIButton *)sender {
    [self enteredPassword:self.passwordField.text];
}

- (void)cancelButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.titleLabel.text = [self.touchLock model].enterPasswordViewControllerTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = [self.touchLock model].createPasswordInitialLabelText;
    if ([[ProgressiveAuthentication sharedInstance] isPasswordSet]) {
        [self.view addSubview:[self cancelButton]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[ProgressiveAuthentication sharedInstance] isPasswordSet] & !authenticated) {
        ProgressiveAuthenticationEnterPasswordViewController *enterPasswordVC = [[ProgressiveAuthenticationEnterPasswordViewController alloc] init];
        [self presentViewController:enterPasswordVC animated:YES completion:nil];
        authenticated = YES;
    }
    [self.passwordField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enteredPassword:(NSString *)password; {
    if (self.firstPassword) {
        if ([password isEqualToString:self.firstPassword]) {
            [self.touchLock setPassword:password forAuthenticationType:ProgressiveAuthenticationUnlockTypePassword];
            [self finishWithResult:YES animated:YES];
        }
        else {
            [self shakeAndVibrateCompletion:^{
                self.firstPassword = nil;
                self.passwordField.text = @"";
                [[self confirmButton] removeFromSuperview];
            }];
        }
    }
    else {
        self.firstPassword = password;
        self.passwordField.text = @"";
        [self.view addSubview:[self confirmButton]];
    }
}
@end
