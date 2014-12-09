//
//  ProgressiveAuthenticationEnterPatternViewController.m
//  BasicApp
//
//  Created by Edwin Zhang on 12/9/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationEnterPatternViewController.h"
#import "ProgressiveAuthentication.h"
#import "ProgressiveAuthenticationUnlockViewController.h"

#define ProgressiveAuthenticationNumIncorrectAttemptsUserDefaultsKey @"ProgressiveAuthenticationNumIncorrectAttemptsUserDefaultsKey"

@interface ProgressiveAuthenticationEnterPatternViewController ()

@end

@implementation ProgressiveAuthenticationEnterPatternViewController

#pragma mark - Class Methods

+ (void)resetPasswordAttemptHistory {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults removeObjectForKey:ProgressiveAuthenticationNumIncorrectAttemptsUserDefaultsKey];
    [standardDefaults synchronize];
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = [self.touchLock model].enterPasswordViewControllerTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = [self.touchLock model].enterPasswordInitialLabelText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enteredPattern:(NSString *)pattern {
    if ([self.touchLock isPasswordValid:pattern]) {
        [[self class] resetPasswordAttemptHistory];
        [self finishWithResult:YES animated:YES];
    }
    else {
        [self shakeAndVibrateCompletion:^{
            self.titleLabel.text = [self.touchLock model].enterPasswordIncorrectLabelText;
            [self clearPattern];
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
    [[self parentUnlockViewController] dismissWithUnlockSuccess:NO
                                                     unlockType:ProgressiveAuthenticationUnlockTypeNone
                                                       animated:NO];
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
