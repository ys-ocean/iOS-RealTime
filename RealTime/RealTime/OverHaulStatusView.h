//
//  OverHaulStatusView.h
//  RealTime
//
//  Created by huhaifeng on 2017/3/24.
//  Copyright © 2017年 huhaifeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverHaulStatusView : UIView

@property (nonatomic ,weak) IBOutlet UIImageView *imageZero;
@property (nonatomic ,weak) IBOutlet UIImageView *imageOne;
@property (nonatomic ,weak) IBOutlet UIImageView *imageTwo;
@property (nonatomic ,weak) IBOutlet UIImageView *imageThree;
@property (nonatomic ,weak) IBOutlet UIImageView *imageFour;

@property (nonatomic ,weak) IBOutlet UILabel *lineOne;
@property (nonatomic ,weak) IBOutlet UILabel *lineTwo;
@property (nonatomic ,weak) IBOutlet UILabel *lineThree;
@property (nonatomic ,weak) IBOutlet UILabel *lineFour;
@end
