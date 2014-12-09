//
//  ProgressiveAuthenticationCreatePatternViewController.m
//  BasicApp
//
//  Created by Edwin Zhang on 12/9/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationCreatePatternViewController.h"
#import "ProgressiveAuthentication.h"

@interface ProgressiveAuthenticationCreatePatternViewController () {
    BOOL authenticated;
}

@property (strong, nonatomic) NSString *firstPattern;
@property (nonatomic) UIButton *confirmButton;
@property (nonatomic) UIButton *cancelButton;

@end

@implementation ProgressiveAuthenticationCreatePatternViewController

#pragma mark - Self Inflating Views

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _confirmButton.frame = CGRectMake(175, 20, 100, 30);
        [_confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _cancelButton.frame = CGRectMake(285, 20, 100, 30);
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark - Button Actions

- (void)confirmButtonTapped:(UIButton *)sender {
    [self enteredPattern:_key];
}

- (void)cancelButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = [self.touchLock model].createPasswordInitialLabelText;
    if ([[ProgressiveAuthentication sharedInstance] isPasswordSet]) {
        [self.view addSubview:[self cancelButton]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[ProgressiveAuthentication sharedInstance] isPasswordSet] & !authenticated) {
        ProgressiveAuthenticationEnterPatternViewController *enterPatternVC = [[ProgressiveAuthenticationEnterPatternViewController alloc] init];
        [self presentViewController:enterPatternVC animated:YES completion:nil];
        authenticated = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enteredPattern:(NSString *)pattern; {
    if (self.firstPattern) {
        if ([pattern isEqualToString:self.firstPattern]) {
            [self.touchLock setPassword:pattern forAuthenticationType:ProgressiveAuthenticationUnlockTypePattern];
            [self finishWithResult:YES animated:YES];
        }
        else {
            [self shakeAndVibrateCompletion:^{
                self.firstPattern = nil;
                [self clearPattern];
                [[self confirmButton] removeFromSuperview];
            }];
        }
    }
    else {
        self.firstPattern = pattern;
        [self clearPattern];
        [self.view addSubview:[self confirmButton]];
    }
}

@end
