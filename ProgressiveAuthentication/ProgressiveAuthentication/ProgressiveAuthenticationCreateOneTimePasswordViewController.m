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

@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureDeviceInput* input;
@property (strong, nonatomic) AVCaptureMetadataOutput* output;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview;

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
    if ([self isCameraAvailable]) {
        [self setupScanner];
    }
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

- (BOOL) isCameraAvailable;
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
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

#pragma mark AVFoundationSetup

- (void) setupScanner {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    self.session = [[AVCaptureSession alloc] init];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    AVCaptureConnection *con = self.preview.connection;
    
    con.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
}

- (void)startScanning {
    [self.session startRunning];
    
}

- (void) stopScanning {
    [self.session stopRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    for(AVMetadataObject *current in metadataObjects) {
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];
            [self enteredCode:scannedValue];
        }
    }
}

#pragma mark - NSURLConnectionDataDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  {
    NSLog(@"Data is %@", data);
}

@end
