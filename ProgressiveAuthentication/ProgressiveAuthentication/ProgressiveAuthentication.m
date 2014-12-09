//
//  ProgressiveAuthentication.m
//  ProgressiveAuthentication
//
//  Created by Edwin Zhang on 11/19/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <LocalAuthentication/LocalAuthentication.h>

#import "ProgressiveAuthentication.h"
#import "ProgressiveAuthenticationLockModel.h"
#import "ProgressiveAuthenticationUnlockViewController.h"
#import "ProgressiveAuthenticationPasswordViewController.h"
#import "ProgressiveAuthenticationEnterPasswordViewController.h"

#define useTouchID @"UseTouchID"

@interface ProgressiveAuthentication ()

@property (assign, nonatomic) NSUInteger passwordAttemptLimit;
@property (strong, nonatomic) ProgressiveAuthenticationLockModel *model;

@end

@implementation ProgressiveAuthentication

+ (instancetype)sharedInstance {
    static ProgressiveAuthentication *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
        sharedInstance.model = [[ProgressiveAuthenticationLockModel alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        self.passwordAttemptLimit = 5;
    }
    return self;
}

#pragma mark - Keychain Methods

- (BOOL)isPasswordSet {
    return !![self currentPassword];
}

- (NSString *)currentPassword {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"passwordInfo"];
}

- (ProgressiveAuthenticationUnlockType)authenticationType {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"authenticationType"];
}

- (BOOL)isPasswordValid:(NSString *)password {
    return [password isEqualToString:[self currentPassword]];
}

- (void)setPassword:(NSString *)password forAuthenticationType:(ProgressiveAuthenticationUnlockType)authenticationType{
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"passwordInfo"];
    [[NSUserDefaults standardUserDefaults] setValue:@(authenticationType) forKey:@"authenticationType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deletePassword {
    if ([self isPasswordSet]) {
        [ProgressiveAuthenticationEnterPasswordViewController resetPasswordAttemptHistory];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passwordInfo"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authenticationType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark - TouchID Methods

+ (BOOL)canUseTouchID {
    return [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                                 error:nil];
}

+ (BOOL)shouldUseTouchID {
    return [[NSUserDefaults standardUserDefaults] boolForKey:useTouchID] && [self canUseTouchID];
}

+ (void)setShouldUseTouchID:(BOOL)shouldUseTouchID {
    [[NSUserDefaults standardUserDefaults] setBool:shouldUseTouchID forKey:useTouchID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)requestTouchIDWithCompletion:(void (^)(ProgressiveAuthenticationTouchIDResponse))completionBlock {
    [self requestTouchIDWithCompletion:completionBlock reason:@"Scan your fingerprint."];
}

- (void)requestTouchIDWithCompletion:(void (^)(ProgressiveAuthenticationTouchIDResponse))completionBlock reason:(NSString *)reason {
    if ([[self class] canUseTouchID]) {
        LAContext *context = [[LAContext alloc] init]; 
        context.localizedFallbackTitle = NSLocalizedString(@"Enter Password", nil);
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:reason
                          reply:^(BOOL success, NSError *error) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if (success) {
                                      if (completionBlock) {
                                          completionBlock(ProgressiveAuthenticationTouchIDResponseSuccess);
                                      }
                                  }
                                  else {
                                      if (completionBlock) {
                                          ProgressiveAuthenticationTouchIDResponse response;
                                          switch (error.code) {
                                              case LAErrorUserFallback:
                                                  response = ProgressiveAuthenticationTouchIDResponseUsePassword;
                                                  break;
                                              case LAErrorUserCancel:
                                                  response = ProgressiveAuthenticationTouchIDResponseCanceled;
                                                  break;
                                              default:
                                                  response = ProgressiveAuthenticationTouchIDResponseUndefined;
                                                  break;
                                          }
                                          completionBlock(response);
                                      }
                                  }
                              });
                          }];
    }
}

- (void)lockFromBackground:(BOOL)fromBackground {
    ProgressiveAuthenticationUnlockViewController *unlockViewController = [[ProgressiveAuthenticationUnlockViewController alloc] init];
    UIWindow *mainWindow = [[UIApplication sharedApplication].windows firstObject];
    UIViewController *rootViewController = [self getTopMostController];
    
    if (fromBackground) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        ProgressiveAuthenticationUnlockViewController *unlockViewController = [[ProgressiveAuthenticationUnlockViewController alloc] init];
        [unlockViewController loadView];
        [unlockViewController viewDidLoad];
        unlockViewController.view.frame = mainWindow.bounds;
        [mainWindow addSubview:unlockViewController.view];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [rootViewController presentViewController:unlockViewController animated:NO completion:^{
            [unlockViewController showUnlockAnimated:NO];
        }];
    });
}

- (UIViewController *)getTopMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

#pragma mark - NSNotifications

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    if ([self isPasswordSet]) {
        [self lockFromBackground:NO];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if ([self isPasswordSet]) {
        [self lockFromBackground:YES];
    }
}


@end
