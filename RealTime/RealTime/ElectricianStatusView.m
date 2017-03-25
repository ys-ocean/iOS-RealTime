//
//  ElectricianStatusView.m
//  RealTime
//
//  Created by huhaifeng on 2017/3/23.
//  Copyright © 2017年 huhaifeng. All rights reserved.
//

#import "ElectricianStatusView.h"

@implementation ElectricianStatusView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
}


- (IBAction)ButtonClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(overHaulButtonClick:)])
    {
        [self.delegate overHaulButtonClick:sender];
    }
}
@end
