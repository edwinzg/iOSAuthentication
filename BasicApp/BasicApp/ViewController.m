//
//  ViewController.m
//  BasicApp
//
//  Created by Edwin Zhang on 11/17/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    NSArray *_pickerData;
    NSString *selectedAuthentication;
}

@property (nonatomic) UIPickerView *authentcationSelector;

@end

@implementation ViewController

#pragma mark - Views

- (UIPickerView *)authentcationSelector {
    if (!_authentcationSelector) {
        _authentcationSelector = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 150)];
    }
    return _authentcationSelector;
}

#pragma mark - Layout

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _pickerData = @[@"None", @"PIN", @"Passcode", @"TouchID", @"Pattern", @"One-time code"];
    [self.view addSubview:[self authentcationSelector]];
    
    [self authentcationSelector].dataSource = self;
    [self authentcationSelector].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Authentcation stuff
- (void)setPasscodeForAuthenticationMethod:(NSString *)authentcationMethod {
    if ([authentcationMethod isEqual: @"PIN"]) {
        
    } else if ([authentcationMethod isEqual:@"Passcode"]) {
        
    } else if ([authentcationMethod isEqual:@"TouchID"]) {
        
    } else if ([authentcationMethod isEqual:@"Pattern"]) {
        
    } else if ([authentcationMethod isEqual:@"One-time code"]) {
        
    } else {
        
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
