//
//  ProgressiveAuthenticationCreateOneTimePasswordViewController.m
//  BasicApp
//
//  Created by Edwin Zhang on 12/10/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationCreateOneTimePasswordViewController.h"
#import "ProgressiveAuthentication.h"

@interface ProgressiveAuthenticationCreateOneTimePasswordViewController ()

@end

@implementation ProgressiveAuthenticationCreateOneTimePasswordViewController

# pragma mark - Layout

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Force users to login first
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self getSecretKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enteredCode:(NSString *)code {
    [self.touchLock setPassword:code forAuthenticationType:ProgressiveAuthenticationUnlockTypeOneTime];
    [self finishWithResult:YES animated:YES];
}

- (void)getSecretKey {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: 128];
    for (int i=0; i<128; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    //NSData *randomData = [[NSFileHandle fileHandleForReadingAtPath:@"/dev/random"] readDataOfLength:128];
    //NSString *randomString = [[NSString alloc] initWithData:randomData encoding:[NSString defaultCStringEncoding]];
    

    [self enteredCode:randomString];
    
    /*
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"username", @"username", nil];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *  request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:8000/keys/getKey"]];
    //[request setValue:jsonString forHTTPHeaderField:@"json"];
    //[request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setHTTPBody:jsonData];
    (void)[NSURLConnection connectionWithRequest:request delegate:self];
    */
}

#pragma mark - NSURLConnectionDataDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  {
    NSLog(@"Data is %@", data);
}

@end
