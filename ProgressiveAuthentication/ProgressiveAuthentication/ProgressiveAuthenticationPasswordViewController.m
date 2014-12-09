//
//  ProgressiveAuthenticationPasswordViewController.m
//  ProgressiveAuthentication
//
//  Created by Edwin Zhang on 12/5/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationPasswordViewController.h"
#import "ProgressiveAuthentication.h"

@import AudioToolbox;

@implementation ProgressiveAuthenticationPasswordViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _touchLock = [ProgressiveAuthentication sharedInstance];
    }
    return self;
}

#pragma mark - Self Inflating Views

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 25, 300, 30)];
        _titleLabel.text = @"Enter Your Password";
    }
    return _titleLabel;
}

- (UITextField *)passwordField {
    if (!_passwordField) {
        _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20, 75, 250, 30)];
        [_passwordField setSecureTextEntry:YES];
        [_passwordField setBorderStyle:UITextBorderStyleLine];
        _passwordField.delegate = self;
    }
    return _passwordField;
}

#pragma mark - Layout

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:[self titleLabel]];
    [self.view addSubview:[self passwordField]];
    [self.passwordField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishWithResult:(BOOL)success animated:(BOOL)animated {
    [self.passwordField resignFirstResponder];
    if (self.willFinishWithResult) {
        self.willFinishWithResult(success);
    } else {
        [self dismissViewControllerAnimated:animated completion:nil];
    }
}

- (void)shakeAndVibrateCompletion:(void (^)())completionBlock {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (completionBlock) {
            completionBlock();
        }
    }];
    NSString *keyPath = @"position";
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:keyPath];
    [animation setDuration:0.04];
    [animation setRepeatCount:4];
    [animation setAutoreverses:YES];
    CGFloat delta = 10.0;
    CGPoint center = self.view.center;
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake(center.x - delta, center.y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake(center.x + delta, center.y)]];
    [[[self view] layer] addAnimation:animation forKey:keyPath];
    [CATransaction commit];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect newKeyboardFrame = [(NSValue *)[notification.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat passwordLockViewHeight = CGRectGetHeight(self.view.frame) - CGRectGetHeight(newKeyboardFrame);
    CGFloat passwordLockViewWidth = CGRectGetWidth(self.view.frame);
    self.view.frame = CGRectMake(0, 0, passwordLockViewWidth, passwordLockViewHeight);
}

- (void)enteredPassword:(NSString *)password {
    // Subclass
}

- (void)clearPassword {
    self.passwordField.text = @"";
}


#pragma mark - UITextField Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *newString = textField.text;
    [self performSelector:@selector(enteredPassword:) withObject:newString afterDelay:0.3];
    return YES;
}

@end
