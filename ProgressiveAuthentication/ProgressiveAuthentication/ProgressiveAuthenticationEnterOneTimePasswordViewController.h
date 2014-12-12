//
//  ProgressiveAuthenticationEnterOneTimePasswordViewController.h
//  BasicApp
//
//  Created by Edwin Zhang on 12/10/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationOneTimeViewController.h"

@interface ProgressiveAuthenticationEnterOneTimePasswordViewController : ProgressiveAuthenticationOneTimeViewController <UITextFieldDelegate>

+ (void)resetPasswordAttemptHistory;

@end
