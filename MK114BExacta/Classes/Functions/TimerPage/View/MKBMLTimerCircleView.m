//
//  MKBMLTimerCircleView.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLTimerCircleView.h"

#import "MKMacroDefines.h"

@interface MKBMLTimerCircleView ()

@property (nonatomic, strong)CAShapeLayer *bottomCircleLayer;

@property (nonatomic, strong)CAShapeLayer *topCircleLayer;

@end

@implementation MKBMLTimerCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [self.layer addSublayer:self.bottomCircleLayer];
        [self.layer addSublayer:self.topCircleLayer];
    }
    return self;
}

#pragma mark - public method
- (void)updateProgress:(float)progress {
    if (progress >= 1.f) {
        progress = 1.f;
    }
    if (progress <= 0) {
        progress = 0;
    }
    [self.topCircleLayer removeAnimationForKey:@"mk_progressAnimationKey"];
    [self.topCircleLayer addAnimation:[self circleAnimationWithEndValue:progress] forKey:@"mk_progressAnimationKey"];
}

#pragma mark - private method
- (CABasicAnimation *)circleAnimationWithEndValue:(CGFloat)endValue{
    CABasicAnimation * circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circleAnimation.duration = 0.01f;
    circleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    circleAnimation.fromValue = @(0);
    circleAnimation.toValue = @(endValue);
    circleAnimation.autoreverses = NO;
    circleAnimation.fillMode = kCAFillModeForwards;
    circleAnimation.removedOnCompletion = NO;
    return circleAnimation;
}

#pragma mark - getter

- (CAShapeLayer *)bottomCircleLayer {
    if (!_bottomCircleLayer) {
        _bottomCircleLayer = [CAShapeLayer layer];
        _bottomCircleLayer.frame = self.bounds;
        _bottomCircleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(30, 30, self.bounds.size.width - 2 * 30, self.bounds.size.height - 2 * 30)].CGPath;
        _bottomCircleLayer.strokeColor = RGBCOLOR(203, 203, 204).CGColor;
        _bottomCircleLayer.fillColor = [UIColor clearColor].CGColor;
        _bottomCircleLayer.lineWidth = 8.f;
        //线的宽度  每条线的间距
        CGFloat width = ((M_PI * (self.bounds.size.height - 2 * 30)) - 36 * 10) / 36;
        _bottomCircleLayer.lineDashPattern  = @[@(width),@(10)];
    }
    return _bottomCircleLayer;
}

- (CAShapeLayer *)topCircleLayer{
    if (!_topCircleLayer) {
        _topCircleLayer = [CAShapeLayer layer];
        _topCircleLayer.frame = self.bounds;
        _topCircleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(30, 30, self.bounds.size.width - 2 * 30, self.bounds.size.height - 2 * 30)].CGPath;
        _topCircleLayer.strokeColor = RGBCOLOR(38,129,255).CGColor;
        _topCircleLayer.fillColor = [UIColor clearColor].CGColor;
        _topCircleLayer.lineWidth = 8.f;
        //线的宽度  每条线的间距
        CGFloat width = ((M_PI * (self.bounds.size.height - 2 * 30)) - 36 * 10) / 36;
        _topCircleLayer.lineDashPattern  = @[@(width),@(10)];
        _topCircleLayer.strokeStart = 0;
        _topCircleLayer.strokeEnd = 0;
    }
    return _topCircleLayer;
}

@end
