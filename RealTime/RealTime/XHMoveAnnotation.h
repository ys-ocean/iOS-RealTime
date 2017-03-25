//
//  XHMoveAnnotation.h
//  RealTime
//
//  Created by huhaifeng on 2017/3/22.
//  Copyright © 2017年 huhaifeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>

@interface XHMoveAnnotation : NSObject<MAAnnotation>

//这里保存用户名 用户标识
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;


//足迹信息数组
@property (nonatomic, strong) NSMutableArray *tracking;

//是否需要动画(没有接收到新的足迹信息设置为NO)
@property (nonatomic, assign) BOOL isAnimation;

//当前所在地理信息
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

//当前足迹的最后一点 同时也是下一段足迹来临的第一个点
@property (nonatomic, assign) CLLocationCoordinate2D lastCoordinate;
@end
