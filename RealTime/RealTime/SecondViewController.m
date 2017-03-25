//
//  SecondViewController.m
//  RealTime
//
//  Created by huhaifeng on 2017/3/23.
//  Copyright © 2017年 huhaifeng. All rights reserved.
//
#define LowMeter 15
#define MALSTATUSHH 150
#define NAVHH 64
#define STATUSHH 200
#import "SecondViewController.h"
#import "XHMoveAnnotation.h"
#import "MovingAnnotationView.h"

#import <ifaddrs.h>
#import <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#import <CoreLocation/CoreLocation.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MANaviRoute.h"
#import "CommonUtility.h"

static const NSInteger RoutePlanningPaddingEdge                    = 20;
@interface SecondViewController ()
<MAMapViewDelegate,AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *map;

@property (nonatomic, assign) MAMapPoint lastPoint;


//测试专用
@property (nonatomic, strong) UILabel *showLabel;
//测试专用
@property (nonatomic, strong) UILabel *latlongLabel;

@property (nonatomic, assign) MAMapPoint ceshiPoint;



@property (nonatomic, strong) AMapRoute *route;
/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;
/* 路线方案个数. */
@property (nonatomic) NSInteger totalCourse;
/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;
@property (nonatomic, strong) AMapSearchAPI *search;
/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.view addSubview:self.map];
    
    [self.view addSubview:self.showLabel];
    [self.view bringSubviewToFront:self.showLabel];
    
    [self.view addSubview:self.latlongLabel];
    [self.view bringSubviewToFront:self.latlongLabel];
    self.showLabel.text =@"start !";
    
    //两个点相同
    self.destinationCoordinate  = CLLocationCoordinate2DMake(31.57624122, 120.30021787);
    self.ceshiPoint =MAMapPointForCoordinate(CLLocationCoordinate2DMake(31.57624122,120.30021787));
    
    [self.view bringSubviewToFront:self.statusView];
    [self.view bringSubviewToFront:self.malStatusView];
    self.statusViewBottomLayout.constant =-STATUSHH;
    self.malStatusViewTopLayout.constant =-MALSTATUSHH +NAVHH;
}

#pragma mark --规划线路
- (void)drawTheRoute
{
    //绘制路线
    CLLocationCoordinate2D start =MACoordinateForMapPoint(self.lastPoint);
    CLLocationCoordinate2D stop =MACoordinateForMapPoint(self.ceshiPoint);
    if (start.latitude <0 || start.longitude <0)
    {
        //定位失败
        return;
    }
    CLLocationCoordinate2D * coords = malloc(2 * sizeof(CLLocationCoordinate2D));
    coords[0] =CLLocationCoordinate2DMake(start.latitude,start.longitude);
    coords[1] =CLLocationCoordinate2DMake(stop.latitude,stop.longitude);
    [self showRouteForCoords:coords count:2];
    
    
    //规划路线
    self.startCoordinate =start;
    self.destinationCoordinate =stop;
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
    
    navi.requireExtension = YES;
    navi.strategy = 0;//速度优先
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [self.search AMapDrivingRouteSearch:navi];
}

#pragma mark - MAMapViewDelegate 定位代理 --
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    self.latlongLabel.text =[NSString stringWithFormat:@" %f,%f %d\n",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude,updatingLocation];
    
    if (userLocation.location.coordinate.latitude >0 &&userLocation.location.coordinate.longitude >0)
    {
        static int once =0;
        if (once ==0)
        {
            ++once;
            self.lastPoint =MAMapPointForCoordinate(CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude));
            
            [self.map setCenterCoordinate:userLocation.location.coordinate animated:YES];
            
            //获取定位成功开始规划路径
            [self drawTheRoute];
        }
        
    }
    
    MAMapPoint startPoint =MAMapPointForCoordinate(CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude));
    static int num =0;
    if ([self isGreaterThanHectometre:self.lastPoint stop:startPoint])
    {
        ++num;
        //上传地理位置信息
        self.showLabel.text =[NSString stringWithFormat:@"提交次数:%d lat:%f long:%f",num,userLocation.location.coordinate.latitude ,userLocation.location.coordinate.longitude];
        self.lastPoint =startPoint;
    }
    
    //实时刷新用户距离地点长度
    //self.statusView.distanceLabel.text =[self distanceForUserLocation];
}

#pragma mark - 地图返回标注代理 --
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    /* Step 2. */
    if ([annotation isKindOfClass:[XHMoveAnnotation class]])
    {
        XHMoveAnnotation * xhMoveAnnotation =(XHMoveAnnotation *)annotation;
        
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MovingAnnotationView *annotationView = (MovingAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MovingAnnotationView alloc] initWithAnnotation:xhMoveAnnotation
                                                              reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.isHiddenCallView =YES;
        
        if ([annotation.subtitle isEqualToString:@"route"])
        {
            annotationView.image = [UIImage imageNamed:@"trackingPoints.png"];
        }
        return annotationView;
    }
    return nil;
}

#pragma mark --选中标注--
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    if ([view isKindOfClass:[MovingAnnotationView class]])
    {
        XHMoveAnnotation * xhMoveAnnotation =view.annotation;
        if ([xhMoveAnnotation.title isEqualToString:@"设备"])
        {
            self.statusViewBottomLayout.constant =0;
            self.malStatusViewTopLayout.constant =NAVHH;
            [UIView animateWithDuration:0.4 animations:^{
                [self.view layoutIfNeeded];
            }];
        }
        
    }
}

#pragma mark --点击地图空白地方--
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    if ([view isKindOfClass:[MovingAnnotationView class]])
    {
        XHMoveAnnotation * xhMoveAnnotation =view.annotation;
        if ([xhMoveAnnotation.title isEqualToString:@"设备"])
        {
            self.statusViewBottomLayout.constant =-STATUSHH;
            self.malStatusViewTopLayout.constant =-MALSTATUSHH-NAVHH;
            
            [UIView animateWithDuration:0.4 animations:^{
                [self.view layoutIfNeeded];
            }];
        }
        
    }

}
#pragma mark --绘制路线--
- (void)showRouteForCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    //show route
    MAPolyline *route = [MAPolyline polylineWithCoordinates:coords count:count];
    [self.map addOverlay:route];
    
    NSMutableArray * routeAnno = [NSMutableArray array];
    for (int i = 0 ; i < count; i++)
    {
        XHMoveAnnotation * a = [[XHMoveAnnotation alloc] init];
        a.coordinate = coords[i];
        if (i ==0)//第一个点为电工地理位置
        {
            a.title = @"电工";
        }
        else
        {
            a.title = @"设备";
        }
        a.subtitle =@"route";
        [routeAnno addObject:a];
    }
    [self.map addAnnotations:routeAnno];
    [self.map showAnnotations:routeAnno animated:NO];
}

#pragma mark --绘制线路的颜色--
- (MAPolylineRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{

    //路线规划
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth   = 8;
        polylineRenderer.lineDash = YES;
        polylineRenderer.strokeColor = [UIColor redColor];
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MANaviPolyline class]])
    {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = 8;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking)
        {
            polylineRenderer.strokeColor = self.naviRoute.walkingColor;
        }
        else if (naviPolyline.type == MANaviAnnotationTypeRailway)
        {
            polylineRenderer.strokeColor = self.naviRoute.railwayColor;
        }
        else
        {
            polylineRenderer.strokeColor = self.naviRoute.routeColor;
        }
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 10;
        polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
        polylineRenderer.gradient = YES;
        
        return polylineRenderer;
    }
    
    //绘制路线
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.lineWidth   = 5.f;
        polylineRenderer.strokeColor = [UIColor colorWithRed:0 green:0.47 blue:1.0 alpha:0.9];
        
        return polylineRenderer;
    }
    return nil;
}

#pragma mark --路径规划搜索回调--
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (response.route == nil)
    {
        return;
    }
    self.route = response.route;
    self.totalCourse = self.route.paths.count;
    self.currentCourse = 0;
    if (response.count > 0)
    {
        [self presentCurrentCourse];
    }
    AMapPath * path =self.route.paths[self.currentCourse];
    NSLog(@"path.distance:%ld \n",(long)path.distance);//第0条 路线总长
    NSLog(@"path.duration:%ld \n",(long)path.duration);//第0条 路线耗时 s
    if (path.distance>1000)
    {
        self.statusView.distanceLabel.text =[NSString stringWithFormat:@"%.1ld",path.distance/1000];
    }
    else
    {
        if (path.distance>100)
        {
            self.statusView.distanceLabel.text =[NSString stringWithFormat:@"%@%ld",@"0.",path.distance/100];
        }
        else
        {
            self.statusView.distanceLabel.text =@"0.1";
        }
    }
    self.statusView.timeLabel.text =[NSString stringWithFormat:@"%ld",path.duration>60?path.duration/60:1];
}



#pragma mark --展示当前路线方案-
- (void)presentCurrentCourse
{
    MANaviAnnotationType type = MANaviAnnotationTypeDrive;
    self.naviRoute = [MANaviRoute naviRouteForPath:self.route.paths[self.currentCourse] withNaviType:type showTraffic:YES startPoint:[AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude] endPoint:[AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude longitude:self.destinationCoordinate.longitude]];
    [self.naviRoute addToMapView:self.map];
    
    /* 缩放地图使其适应polylines的展示. */
    [self.map setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                        edgePadding:UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge)
                           animated:YES];
}

#pragma mark -路径规划失败 --
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"SearchRequestError: %@", error);
}

#pragma mark -定位失败 --
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"LocateUserWithError: %@", error);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self isWiFiEnabled])
    {
        NSLog(@"开启wifi 能够定位更为准确!!!");
    }
    
    BOOL isOPen = NO;
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        isOPen = YES;
    }
    if (!isOPen)
    {
        //自定义弹框引导用户去 打开定位
        NSLog(@"您没有打开定位,打开能够更好的为您服务!");
    }
}


#pragma mark --两点间的直线距离--
- (NSString *)distanceForUserLocation
{
    CLLocationDistance distance =MAMetersBetweenMapPoints(self.lastPoint,self.ceshiPoint);
    NSString *str =[NSString stringWithFormat:@"%.f",fabs(distance)/1000];//两点间的距离 加不加绝对值无所谓
    return str;
}

#pragma mark - 计算两点间的距离是否大于预设距离 --
- (BOOL)isGreaterThanHectometre:(MAMapPoint)pointStart stop:(MAMapPoint)PointStop
{
    CLLocationDistance distance = MAMetersBetweenMapPoints(pointStart,PointStop);
    if (fabs(distance)>LowMeter)
    {
        return YES;
    }
    return NO;
}

#pragma mark - 是否打开wifi--
- (BOOL)isWiFiEnabled
{
    NSCountedSet * cset = [NSCountedSet new];
    struct ifaddrs *interfaces;
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

- (UILabel *)showLabel
{
    if (_showLabel ==nil)
    {
        _showLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height -30, self.view.frame.size.width, 30)];
        _showLabel.font =[UIFont systemFontOfSize:15];
        _showLabel.textAlignment =NSTextAlignmentCenter;
    }
    return _showLabel;
}

- (UILabel *)latlongLabel
{
    if (_latlongLabel ==nil)
    {
        _latlongLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 30)];
        _latlongLabel.font =[UIFont systemFontOfSize:15];
        _latlongLabel.textAlignment =NSTextAlignmentCenter;
    }
    return _latlongLabel;
}

- (MAMapView *)map
{
    if (!_map)
    {
        _map = [[MAMapView alloc] initWithFrame:self.view.frame];
        _map.delegate = self;
        _map.showsLabels = YES;
        
        _map.userTrackingMode =MAUserTrackingModeFollow;//追踪位置更新
        _map.desiredAccuracy =kCLLocationAccuracyBest;//精确度
        _map.distanceFilter =kCLDistanceFilterNone;
        _map.pausesLocationUpdatesAutomatically = YES;//可以被系统自动暂停
        _map.allowsBackgroundLocationUpdates = YES;//是否允许后台定位
        _map.showsUserLocation = YES;//开始定位
    }
    return _map;
}

@end
