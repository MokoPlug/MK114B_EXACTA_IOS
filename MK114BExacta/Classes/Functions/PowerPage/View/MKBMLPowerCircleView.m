//
//  MKBMLPowerCircleView.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLPowerCircleView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

static CGFloat const circleLabelViewOffset = 23.f;

#define start_Angle (M_PI_4 * 3)
#define end_Angle (M_PI_4)
#define circleRadius ((self.bounds.size.width - 2 * 30) / 2)

@interface MKBMLPowerCircleView ()

@property (nonatomic, strong)CAShapeLayer *bottomCircleLayer;

@property (nonatomic, strong)CAShapeLayer *topCircleLayer;

@property (nonatomic, strong)UILabel *valueLabel;

@property (nonatomic, strong)UILabel *wattsLabel;

@property (nonatomic, strong)UIImageView *circleIcon;

@end

@implementation MKBMLPowerCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.circleIcon];
        [self.circleIcon addSubview:self.wattsLabel];
        [self.circleIcon addSubview:self.valueLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.circleIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(circleLabelViewOffset);
        make.right.mas_equalTo(-circleLabelViewOffset);
        make.top.mas_equalTo(circleLabelViewOffset);
        make.bottom.mas_equalTo(-circleLabelViewOffset);
    }];
    [self.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.circleIcon.mas_centerX);
        make.bottom.mas_equalTo(self.circleIcon.mas_centerY).mas_offset(-6.f);
        make.width.mas_equalTo(150.f);
        make.height.mas_equalTo(MKFont(30.f).lineHeight);
    }];
    [self.wattsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.circleIcon.mas_centerX);
        make.top.mas_equalTo(self.circleIcon.mas_centerY).mas_offset(6.f);
        make.width.mas_equalTo(150.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    if (!self.bottomCircleLayer.superlayer) {
        [self.layer addSublayer:self.bottomCircleLayer];
    }
    if (!self.topCircleLayer.superlayer) {
        [self.layer addSublayer:self.topCircleLayer];
    }
    [self addTickLabels];
}

#pragma mark - public method
- (void)updatePowerValues:(float)powerValue {
    if (powerValue >= 3600) {
        powerValue = 3600;
    }
    float progress = (powerValue / 3600);
    progress = fabsf(progress);
    if (progress >= 1) {
        progress = 1;
    }
    self.valueLabel.text = [NSString stringWithFormat:@"%.1f",powerValue];
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

- (void)addTickLabels {
    CGFloat perAngle = 1.5 * M_PI / 4;
    NSArray *tips = @[@"0",@"900",@"1800",@"2700",@"3600"];
    for (NSInteger i = 0; i < 5; i ++) {
        CGFloat startAngel = (start_Angle + perAngle * i);
        CGFloat endAngel = startAngel + perAngle * 0.1;
        CGPoint point = [self calculateTextPositonWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.width/2)
                                                          Angle:-(startAngel + endAngel)/2];
        UILabel *text = [[UILabel alloc] init];
        text.text = tips[i];
        text.font = MKFont(11.f);
        text.textColor = RGBCOLOR(128, 128, 128);
        text.textAlignment = NSTextAlignmentCenter;
        CGFloat w = [text sizeThatFits:CGSizeZero].width;
        CGFloat h = [text sizeThatFits:CGSizeZero].height;
        text.frame = CGRectMake(point.x - w/2, point.y - h/2, w, h);
        [self addSubview:text];
    }
}

- (CGPoint)calculateTextPositonWithArcCenter:(CGPoint)center Angle:(CGFloat)angel {
    CGFloat x = (circleRadius - circleLabelViewOffset - 7.f) * cosf(angel);
    CGFloat y = (circleRadius - circleLabelViewOffset - 7.f) * sinf(angel);
    return CGPointMake(center.x + x, center.y - y);
}

#pragma mark - getter
- (UIImageView *)circleIcon {
    if (!_circleIcon) {
        _circleIcon = [[UIImageView alloc] init];
        _circleIcon.image = LOADICON(@"MK114BExacta", @"MKBMLPowerCircleView", @"mk_bml_haloRing.png");
        _circleIcon.userInteractionEnabled = YES;
    }
    return _circleIcon;
}

- (CAShapeLayer *)bottomCircleLayer {
    if (!_bottomCircleLayer) {
        _bottomCircleLayer = [CAShapeLayer layer];
        _bottomCircleLayer.frame = self.bounds;
        _bottomCircleLayer.path = [self circleLayerPath].CGPath;
        _bottomCircleLayer.strokeColor = RGBCOLOR(203, 203, 204).CGColor;
        _bottomCircleLayer.fillColor = [UIColor clearColor].CGColor;
        _bottomCircleLayer.lineWidth = 12.f;
        //线的宽度  每条线的间距
        _bottomCircleLayer.lineDashPattern  = @[@2,@2.5];
    }
    return _bottomCircleLayer;
}

- (CAShapeLayer *)topCircleLayer{
    if (!_topCircleLayer) {
        _topCircleLayer = [CAShapeLayer layer];
        _topCircleLayer.frame = self.bounds;
        _topCircleLayer.path = [self circleLayerPath].CGPath;
        _topCircleLayer.strokeColor = RGBCOLOR(38,129,255).CGColor;
        _topCircleLayer.fillColor = [UIColor clearColor].CGColor;
        _topCircleLayer.lineWidth = 12.f;
        //线的宽度  每条线的间距
        _topCircleLayer.lineDashPattern  = @[@2,@2.5];
        _topCircleLayer.strokeStart = 0;
        _topCircleLayer.strokeEnd = 0;
    }
    return _topCircleLayer;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.textColor = RGBCOLOR(38, 129, 255);
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.font = MKFont(30.f);
        _valueLabel.text = @"0.0";
    }
    return _valueLabel;
}

- (UILabel *)wattsLabel {
    if (!_wattsLabel) {
        _wattsLabel = [[UILabel alloc] init];
        _wattsLabel.textColor = RGBCOLOR(51, 51, 51);
        _wattsLabel.textAlignment = NSTextAlignmentCenter;
        _wattsLabel.font = MKFont(15.f);
        _wattsLabel.text = @"WATTS";
    }
    return _wattsLabel;
}

- (UIBezierPath *)circleLayerPath {
    CGFloat centerX = self.frame.size.width / 2;
    CGFloat centerY = self.frame.size.height / 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY)
                                                        radius:circleRadius
                                                    startAngle:start_Angle
                                                      endAngle:end_Angle
                                                     clockwise:YES];
    return path;
}

@end
