//
//  MovingAnnotationView.h
//  test
//
//  Created by yi chen on 14-9-3.
//  Copyright (c) 2014年 yi chen. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "TracingPoint.h"
#import "CustomCalloutView.h"
@interface MovingAnnotationView : MAPinAnnotationView

/**
 是否需要显示calloutView
 */
@property (nonatomic, assign) BOOL isHiddenCallView;

@property (nonatomic, strong) CustomCalloutView *calloutView;
/*!
 @brief 添加动画
 @param points 轨迹点串，每个轨迹点为TracingPoint类型
 @param duration 动画时长，包括从上一个动画的终止点过渡到新增动画起始点的时间
 */
- (void)addTrackingAnimationForPoints:(NSArray *)points duration:(CFTimeInterval)duration;

@end
