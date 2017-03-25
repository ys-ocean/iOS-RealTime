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
@interface SecondViewController : UIViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewBottomLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *malStatusViewTopLayout;

@property (weak, nonatomic) IBOutlet ElectricianStatusView *statusView;
@property (weak, nonatomic) IBOutlet MalfunctionStatusView *malStatusView;

@end
