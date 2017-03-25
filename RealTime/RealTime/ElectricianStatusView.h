//
//  ElectricianStatusView.h
//  RealTime
//
//  Created by huhaifeng on 2017/3/23.
//  Copyright © 2017年 huhaifeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverHaulStatusView.h"

@interface ElectricianStatusView : UIView

@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic, weak) IBOutlet OverHaulStatusView *overhaulView;

@property (nonatomic, weak) IBOutlet UIButton *button;
@end
