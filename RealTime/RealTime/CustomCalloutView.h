//
//  CustomCalloutView.h
//  UserTestControl
//
//  Created by huhaifeng on 16/7/11.
//  Copyright © 2016年 huhaifeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TouchViewBlock)();

@interface CustomCalloutView : UIView

@property (copy ,nonatomic)TouchViewBlock callTelBlock;

@property (strong, nonatomic) UIButton * telBtn;
@property (strong, nonatomic) UILabel * line;
@property (strong, nonatomic) UILabel * name;

@end
