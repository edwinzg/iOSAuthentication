//
//  ProgressiveAuthenticationPatternViewController.h
//  BasicApp
//
//  Created by Edwin Zhang on 12/9/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgressiveAuthentication;

@interface ProgressiveAuthenticationPatternViewController : UIViewController {
    NSMutableArray *_path;
    NSMutableString *_key;
}

@property (nonatomic) UILabel *titleLabel;

@property (nonatomic, strong) ProgressiveAuthentication *touchLock;

@property (nonatomic, copy) void (^willFinishWithResult)(BOOL success);

- (void)clearPattern;
- (void)enteredPattern:(NSString *)pattern;
- (void)generateKey;

- (void)finishWithResult:(BOOL)success animated:(BOOL)animated;

- (void)shakeAndVibrateCompletion:(void (^)())completionBlock;


@end
