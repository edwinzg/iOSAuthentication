//
//  ViewController.m
//  BasicApp
//
//  Created by Edwin Zhang on 11/17/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ViewController.h"
#import "ProgressiveAuthentication.h"

@interface ViewController () {
    NSArray *_pickerData;
    NSString *selectedAuthentication;
}

@property (nonatomic) UIPickerView *authentcationSelector;
@property (nonatomic) UILabel *successLabel;
@property (nonatomic) UIButton *turnOffPasswordButton;
@property (nonatomic) UIButton *resetPasswordButton;
@property (nonatomic) UIButton *changeAuthenticationTypeButton;

@end

@implementation ViewController

#pragma mark - Views

- (UIPickerView *)authentcationSelector {
    if (!_authentcationSelector) {
        _authentcationSelector = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 150)];
    }
    return _authentcationSelector;
}

- (UILabel *)successLabel {
    if (!_successLabel) {
        _successLabel = [[UILabel alloc]
                                 initWithFrame:CGRectMake(0, 25, self.view.bounds.size.width, 30)];
        [_successLabel setText:@"Successfully authenticated"];
    }
    return _successLabel;
}

- (UIButton *)turnOffPasswordButton {
    if (!_turnOffPasswordButton) {
        _turnOffPasswordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _turnOffPasswordButton.frame = CGRectMake(0, 125, 200, 30);
        [_turnOffPasswordButton setTitle:@"Turn Off Password" forState:UIControlStateNormal];
        [_turnOffPasswordButton addTarget:self action:@selector(deletePasswordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _turnOffPasswordButton;
}

- (UIButton *)resetPasswordButton {
    if (!_resetPasswordButton) {
        _resetPasswordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _resetPasswordButton.frame = CGRectMake(0, 75, 200, 30);
        [_resetPasswordButton setTitle:@"Reset Password" forState:UIControlStateNormal];
        [_resetPasswordButton addTarget:self action:@selector(resetPasswordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetPasswordButton;
}

- (UIButton *)changeAuthenticationTypeButton {
    if (!_changeAuthenticationTypeButton) {
        _changeAuthenticationTypeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _changeAuthenticationTypeButton.frame = CGRectMake(0, 75, 200, 30);
        [_changeAuthenticationTypeButton setTitle:@"Reset Password" forState:UIControlStateNormal];
        [_changeAuthenticationTypeButton addTarget:self action:@selector(changeAuthenticationTypeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeAuthenticationTypeButton;
}

#pragma mark - Layout

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self authentcationSelector].dataSource = self;
    [self authentcationSelector].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    if ([[ProgressiveAuthentication sharedInstance] isPasswordSet] || [[ProgressiveAuthentication sharedInstance] authenticationType] == ProgressiveAuthenticationUnlockTypeNone) {
        [self setUpAuthenticatedView];
    } else {
        [self setUpSelectAuthentication];
    }
}

- (void)setUpAuthenticatedView {
    for (UIView* view in self.view.subviews) {
        [view removeFromSuperview];
    }
    [self.view addSubview:[self successLabel]];
    [self.view addSubview:[self turnOffPasswordButton]];
    [self.view addSubview:[self resetPasswordButton]];
}

- (void)setUpSelectAuthentication {
    for (UIView* view in self.view.subviews) {
        [view removeFromSuperview];
    }
    UILabel *setPasscodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, self.view.bounds.size.width, 50)];
    [setPasscodeLabel setText:@"Select your authentication method"];
    [self.view addSubview:setPasscodeLabel];
    _pickerData = @[@"", @"None", @"PIN", @"Password", @"TouchID", @"Pattern", @"One-time code"];
    [self.view addSubview:[self authentcationSelector]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Button click

- (void)deletePasswordButtonClicked:(id)sender {
    if ([[ProgressiveAuthentication sharedInstance] isPasswordSet]) {
        [[ProgressiveAuthentication sharedInstance] deletePassword];
        UIAlertView *passwordDeletedAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Password has succesfully been deleted" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [passwordDeletedAlertView show];
    } else {
        UIAlertView *noPasswordAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"No Password to Delete!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [noPasswordAlertView show];
    }
}

- (void)resetPasswordButtonClicked:(id)sender {
    if ([[ProgressiveAuthentication sharedInstance] authenticationType] == ProgressiveAuthenticationUnlockTypePassword) {
        ProgressiveAuthenticationCreatePasswordViewController *createPasswordVC = [[ProgressiveAuthenticationCreatePasswordViewController alloc] init];
        [self presentViewController:createPasswordVC animated:YES completion:nil];
    } else if ([[ProgressiveAuthentication sharedInstance] authenticationType] == ProgressiveAuthenticationUnlockTypeNone) {
        UIAlertView *noPasswordAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"No Password to Reset!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [noPasswordAlertView show];
    }
}

- (void)changeAuthenticationTypeButtonClicked:(id)sender {
    [self setUpSelectAuthentication];
}

# pragma mark - Authentcation stuff

- (void)setPasscodeForAuthenticationMethod:(NSString *)authenticationMethod {
    if ([authenticationMethod isEqual: @"PIN"]) {

    } else if ([authenticationMethod isEqual:@"Password"]) {
        ProgressiveAuthenticationCreatePasswordViewController *createPasswordVC = [[ProgressiveAuthenticationCreatePasswordViewController alloc] init];
        [self presentViewController:createPasswordVC animated:YES completion:nil];
    } else if ([authenticationMethod isEqual:@"TouchID"]) {
        
    } else if ([authenticationMethod isEqual:@"Pattern"]) {
        
    } else if ([authenticationMethod isEqual:@"One-time code"]) {
        
    } else if ([authenticationMethod isEqual: @"None"]) {
        [self setUpAuthenticatedView];
    }
}

#pragma mark - PickerView delegate

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_pickerData objectAtIndex:row];
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    selectedAuthentication = [_pickerData objectAtIndex:row];
    [self setPasscodeForAuthenticationMethod:selectedAuthentication];
}

@end
