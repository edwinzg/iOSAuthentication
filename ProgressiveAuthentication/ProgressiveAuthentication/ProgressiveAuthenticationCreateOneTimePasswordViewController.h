//
//  ProgressiveAuthenticationCreateOneTimePasswordViewController.h
//  BasicApp
//
//  Created by Edwin Zhang on 12/10/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ProgressiveAuthenticationOneTimeViewController.h"

@protocol AMScanViewControllerDelegate;

@interface ProgressiveAuthenticationCreateOneTimePasswordViewController : ProgressiveAuthenticationOneTimeViewController <NSURLConnectionDataDelegate,AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id<AMScanViewControllerDelegate> delegate;

@end
