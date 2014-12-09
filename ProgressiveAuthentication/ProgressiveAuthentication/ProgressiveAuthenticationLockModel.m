//
//  ProgressiveAuthenticationLockModel.m
//  ProgressiveAuthentication
//
//  Created by Edwin Zhang on 12/5/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationLockModel.h"

@implementation ProgressiveAuthenticationLockModel

- (instancetype)init {
    self = [super init];
    if (self) { // Set default values
        _createPasswordInitialLabelText = NSLocalizedString(@"Enter a new password",nil);
        _createPasswordConfirmLabelText = NSLocalizedString(@"Please re-enter your password", nil);
        _createPasswordMismatchedLabelText = NSLocalizedString(@"Passwords did not match. Try again", nil);
        _createPasswordViewControllerTitle = NSLocalizedString(@"Set Password", nil);
        _enterPasswordInitialLabelText = NSLocalizedString(@"Enter your password", nil);
        _enterPasswordIncorrectLabelText = NSLocalizedString(@"Incorrect password. Try again.", nil);
        _enterPasswordViewControllerTitle = NSLocalizedString(@"Enter Password", nil);
    }
    return self;
}

@end
