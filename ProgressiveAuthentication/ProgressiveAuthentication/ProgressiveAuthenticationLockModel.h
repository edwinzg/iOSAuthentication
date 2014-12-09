//
//  ProgressiveAuthenticationLockModel.h
//  ProgressiveAuthentication
//
//  Created by Edwin Zhang on 12/5/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ProgressiveAuthenticationLockModel : NSObject

@property (strong, nonatomic) NSString *createPasswordInitialLabelText;
@property (strong, nonatomic) NSString *createPasswordConfirmLabelText;
@property (strong, nonatomic) NSString *createPasswordMismatchedLabelText;
@property (strong, nonatomic) NSString *createPasswordViewControllerTitle;

@property (strong, nonatomic) NSString *enterPasswordInitialLabelText;
@property (strong, nonatomic) NSString *enterPasswordIncorrectLabelText;
@property (strong, nonatomic) NSString *enterPasswordViewControllerTitle;

@end
