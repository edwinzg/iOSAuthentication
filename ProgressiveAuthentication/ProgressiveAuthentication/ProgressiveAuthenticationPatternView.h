//
//  ProgressiveAuthenticationPatternView.h
//  BasicApp
//
//  Created by Edwin Zhang on 12/9/14.
//  Copyright (c) 2014 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressiveAuthenticationPatternView : UIView {
    NSValue *_trackPointValue;
    NSMutableArray *_dotViews;
}

- (void)clearDotViews;
- (void)addDotView:(UIView *)view;
- (void)drawLineFromLastDotTo:(CGPoint)pt;

@end
