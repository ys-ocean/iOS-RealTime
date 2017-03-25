//
//  SecondViewController.h
//  RealTime
//
//  Created by huhaifeng on 2017/3/23.
//  Copyright © 2017年 huhaifeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "ElectricianStatusView.h"
#import "MalfunctionStatusView.h"

typedef enum : NSUInteger {
    OrderStatusTypeNormal =0,
    OrderStatusTypeArrived,
} OrderStatusType;

@interface SecondViewController : UIViewController
//订单状态 默认第一次进来是 normal(未到达指定设备地点)
@property (assign, nonatomic) OrderStatusType orderType;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewBottomLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *malStatusViewTopLayout;

@property (weak, nonatomic) IBOutlet ElectricianStatusView *statusView;
@property (weak, nonatomic) IBOutlet MalfunctionStatusView *malStatusView;

@end
