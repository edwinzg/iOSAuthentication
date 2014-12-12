//
//  ProgressiveAuthenticationCreateOneTimePasswordViewController.m
//  BasicApp
//
//  Created by Edwin Zhang on 12/10/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationCreateOneTimePasswordViewController.h"
#import "ProgressiveAuthentication.h"

@interface ProgressiveAuthenticationCreateOneTimePasswordViewController () {
    NSData *responseData;
}

@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureDeviceInput* input;
@property (strong, nonatomic) AVCaptureMetadataOutput* output;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview;

@property (nonatomic) UITextField *username;
@property (nonatomic) UITextField *password;
@property (nonatomic) UITextField *appName;
@property (nonatomic) UIButton *submitButton;

@end

@implementation ProgressiveAuthenticationCreateOneTimePasswordViewController

#pragma mark - Self Inflating Views

- (UITextField *)username {
    if (!_username) {
        _username = [[UITextField alloc] initWithFrame:CGRectMake(20, 75, 250, 30)];
        [_username setPlaceholder:@"Username"];
        [_username setBorderStyle:UITextBorderStyleLine];
        _username.delegate = self;
    }
    return _username;
}

- (UITextField *)password {
    if (!_password) {
        _password = [[UITextField alloc] initWithFrame:CGRectMake(20, 125, 250, 30)];
        [_password setPlaceholder:@"Password"];
        [_password setSecureTextEntry:YES];
        [_password setBorderStyle:UITextBorderStyleLine];
        _password.delegate = self;
    }
    return _password;
}

- (UITextField *)appName {
    if (!_appName) {
        _appName = [[UITextField alloc] initWithFrame:CGRectMake(20, 175, 250, 30)];
        [_appName setPlaceholder:@"App name"];
        [_appName setBorderStyle:UITextBorderStyleLine];
        _appName.delegate = self;
    }
    return _appName;
}

- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _submitButton.frame = CGRectMake(45, 225, 100, 50);
        [_submitButton setTitle:@"Submit" forState:UIControlStateNormal];
        [_submitButton addTarget:self action:@selector(submitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

#pragma mark - Button Actions

- (void)submitButtonTapped:(UIButton *)sender
{
    [self performSelector:@selector(getSecretKey) withObject:nil afterDelay:0.3];
}

# pragma mark - Layout

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.passwordField removeFromSuperview];
    [self.view addSubview:[self username]];
    [[self username] becomeFirstResponder];
    [self.view addSubview:[self password]];
    [self.view addSubview:[self appName]];
    [self.view addSubview:[self submitButton]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self isCameraAvailable]) {
        [self setupScanner];
    }
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
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.username.text forKey:@"username"];
    [dict setObject:self.password.text forKey:@"password"];
    [dict setObject:self.appName.text forKey:@"app"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:8000/keys/getKey"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    (void)[NSURLConnection connectionWithRequest:request delegate:self];
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
    responseData = data;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if ([json objectForKey:@"error"]) {
        UIAlertView *incorrectAuthenticationView = [[UIAlertView alloc] initWithTitle:@"" message:@"Incorrect Authentication" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [incorrectAuthenticationView show];
        self.username.text = @"";
        self.password.text = @"";
        self.appName.text = @"";
    } else {
        [self enteredCode:[json objectForKey: @"key"]];
    }
}

#pragma mark - UITextField Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self performSelector:@selector(getSecretKey) withObject:nil afterDelay:0.3];
    return YES;
}

@end
