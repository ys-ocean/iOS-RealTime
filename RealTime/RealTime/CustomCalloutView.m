//
//  CustomCalloutView.m
//  UserTestControl
//
//  Created by huhaifeng on 16/7/11.
//  Copyright © 2016年 huhaifeng. All rights reserved.
//

#import "CustomCalloutView.h"
#import <QuartzCore/QuartzCore.h>
#define kArrorHeight    10
#define kCalloutWidth   170.0
#define kCalloutHeight  60.0
#define TelBtnH 40.0
#define Space 5.0
@implementation CustomCalloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.telBtn];
    [self addSubview:self.line];
    [self addSubview:self.name];
    
    self.name.text =@"电工007";
}

- (void)CallTelPhoneClick:(UIButton *)sender
{
    if (self.callTelBlock)
    {
        self.callTelBlock();
    }
}

- (UIButton *)telBtn
{
    if (_telBtn ==nil)
    {
        _telBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        _telBtn.frame =CGRectMake(Space, Space, TelBtnH, TelBtnH);
        [_telBtn setImage:[UIImage imageNamed:@"telephone"] forState:UIControlStateNormal];
        [_telBtn addTarget:self action:@selector(CallTelPhoneClick:) forControlEvents:UIControlEventTouchUpInside];
        [_telBtn setBackgroundColor:[UIColor clearColor]];
    }
    return _telBtn;
}

- (UILabel *)line
{
    if (_line ==nil)
    {
        _line = [[UILabel alloc] initWithFrame:CGRectMake(Space +TelBtnH +Space , 2*Space, 1, TelBtnH-2*Space)];
        _line.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
    }
    return _line;
}

- (UILabel *)name
{
    if (_name ==nil)
    {
        _name = [[UILabel alloc] initWithFrame:CGRectMake(Space +TelBtnH +Space, Space, kCalloutWidth -3*Space -TelBtnH, TelBtnH)];
        _name.backgroundColor = [UIColor clearColor];
        _name.textColor = [UIColor blackColor];
        _name.textAlignment =NSTextAlignmentCenter;
        _name.font =[UIFont systemFontOfSize:17];
        _name.numberOfLines =0;
        _name.adjustsFontSizeToFitWidth =YES;
    }
    return _name;
}

#pragma mark - draw rect

- (void)drawRect:(CGRect)rect
{
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.35;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

- (void)drawInContext:(CGContextRef)context
{
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
    
}

- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

@end
