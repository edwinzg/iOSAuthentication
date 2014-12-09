//
//  ProgressiveAuthenticationPatternViewController.m
//  BasicApp
//
//  Created by Edwin Zhang on 12/9/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import "ProgressiveAuthenticationPatternViewController.h"
#import "ProgressiveAuthenticationPatternView.h"
#import "ProgressiveAuthentication.h"

@import AudioToolbox;

#define PatternDimensions 3

@interface ProgressiveAuthenticationPatternViewController ()

@end

@implementation ProgressiveAuthenticationPatternViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _touchLock = [ProgressiveAuthentication sharedInstance];
    }
    return self;
}

#pragma mark - Self Inflating Views

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 150, 50)];
        _titleLabel.text = @"Enter Your Pattern";
    }
    return _titleLabel;
}

#pragma mark - Layout

- (void)loadView {
    [super loadView];
    self.view = [[ProgressiveAuthenticationPatternView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:[self titleLabel]];
    
    for (int i=0; i<PatternDimensions; i++) {
        for (int j=0; j<PatternDimensions; j++) {
            UIImage *dotImage = [UIImage imageNamed:@"dot_off.png"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:dotImage
                                                       highlightedImage:[UIImage imageNamed:@"dot_on.png"]];
            imageView.frame = CGRectMake(0, 0, dotImage.size.width, dotImage.size.height);
            imageView.userInteractionEnabled = YES;
            imageView.tag = j*PatternDimensions + i + 1;
            [self.view addSubview:imageView];
        }
    }
}

- (void)viewWillLayoutSubviews {
    int width = (self.view.frame.size.width-50)/PatternDimensions;
    int height = (self.view.frame.size.height-50)/PatternDimensions;
    
    int i=0;
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            int x = width*(i/PatternDimensions) + width/2;
            int y = height*(i%PatternDimensions) + height/2;
            view.center = CGPointMake(x, y);
            i++;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishWithResult:(BOOL)success animated:(BOOL)animated {
    if (self.willFinishWithResult) {
        self.willFinishWithResult(success);
    } else {
        [self dismissViewControllerAnimated:animated completion:nil];
    }
}

- (void)shakeAndVibrateCompletion:(void (^)())completionBlock {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (completionBlock) {
            completionBlock();
        }
    }];
    NSString *keyPath = @"position";
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:keyPath];
    [animation setDuration:0.04];
    [animation setRepeatCount:4];
    [animation setAutoreverses:YES];
    CGFloat delta = 10.0;
    CGPoint center = self.view.center;
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake(center.x - delta, center.y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake(center.x + delta, center.y)]];
    [[[self view] layer] addAnimation:animation forKey:keyPath];
    [CATransaction commit];
}

- (void)enteredPattern:(NSString *)pattern {
    // Subclass
}

- (void)clearPattern {
    ProgressiveAuthenticationPatternView *dots = (ProgressiveAuthenticationPatternView*)self.view;
    [dots clearDotViews];
    
    for (UIView *view in self.view.subviews)
        if ([view isKindOfClass:[UIImageView class]])
            [(UIImageView*)view setHighlighted:NO];
    
    [self.view setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _path = [[NSMutableArray alloc] init];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    UIView *touched = [self.view hitTest:pt withEvent:event];
    
    ProgressiveAuthenticationPatternView *dots = (ProgressiveAuthenticationPatternView*)self.view;
    [dots drawLineFromLastDotTo:pt];
    
    if (touched!=self.view) {
        BOOL found = NO;
        for (NSNumber *tag in _path) {
            found = tag.integerValue==touched.tag;
            if (found)
                break;
        }
        
        if (found)
            return;
        
        [_path addObject:[NSNumber numberWithLong:touched.tag]];
        [dots addDotView:touched];
        
        UIImageView* dotTouched = (UIImageView*)touched;
        dotTouched.highlighted = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self clearPattern];
    [self generateKey];
}

- (void)generateKey {
    _key = [NSMutableString string];
    
    for (NSNumber *tag in _path) {
        [_key appendFormat:@"%ld", tag.integerValue];
    }
    
    [self enteredPattern:_key];
}

@end
