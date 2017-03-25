//
//  ViewController.m
//  RealTime
//
//  Created by huhaifeng on 2017/3/22.
//  Copyright © 2017年 huhaifeng. All rights reserved.
//

#import "ViewController.h"
#import "TracingPoint.h"
#import "Util.h"
#import "MovingAnnotationView.h"
#import "NetWorkClass.h"
#import "XHMoveAnnotation.h"
@interface ViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *map;

@property (nonatomic, strong) NSTimer *peopleTimer;

@property (nonatomic, strong) NSMutableArray <XHMoveAnnotation *>*peopleArray;

@property (nonatomic, strong) NSMutableArray * arrayData;
@end

@implementation ViewController
{
    CFTimeInterval _duration;
    int ceshi;
}
#pragma mark life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.map];
    
    _duration = 8.0;
    
    [self initBtn];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.map setZoomLevel:16.0 animated:YES];
}

#pragma mark - MAMapViewDelegate 定位代理 --
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    NSLog(@"userLocation:%f,%f \n",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    static int a=0;
    if (userLocation.location.coordinate.latitude >0 &&a==0)
    {
        ++a;
        [self.map setCenterCoordinate:userLocation.location.coordinate animated:YES];
        self.map.showsUserLocation =NO;
    }
}

- (void)getPeopleModelData
{
    
//    [NetWorkClass RequestPeopleAdress:@{} successBlock:^(id responseObject) {
//        
//    } errorBlock:^(NSError *error) {
//        
//    }];
    self.arrayData =[self getModelData];
    
    ++ceshi;
    
    [self.arrayData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary * dict =(NSDictionary *)obj;
        [self initRoute:dict];
    }];
   
    [self ActionAnnotation];
}

#pragma mark --开始动画--
- (void)ActionAnnotation
{
    [self.peopleArray enumerateObjectsUsingBlock:^(XHMoveAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isAnimation)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                MovingAnnotationView * peopleView = (MovingAnnotationView *)[self.map viewForAnnotation:obj];
                [peopleView addTrackingAnimationForPoints:obj.tracking duration:_duration];
            });
            
        }
    }];

}

#pragma mark --初始化路径--
- (void)initRoute:(NSDictionary *)dict
{
    
    BOOL isAnimation =YES;
    NSArray <NSDictionary *>* moves =dict[@"moves"];
    if (moves.count <1)
    {
        isAnimation =NO;
    }
    //[self showRouteForCoords:coords count:count];
    
    CLLocationCoordinate2D *coords =[self getCoordsFor:moves];
    if ([self isNewPeople:dict[@"name"]])
    {// 是新搜寻到的新人员
        XHMoveAnnotation * newAn =[[XHMoveAnnotation alloc]init];
        newAn.title = dict[@"name"];
        newAn.tracking =[self getTrackingFor:coords count:moves.count];
        newAn.isAnimation =isAnimation;
        
        if (newAn.isAnimation)
        {
            TracingPoint * start = [newAn.tracking firstObject];
            TracingPoint * last = [newAn.tracking lastObject];
            newAn.coordinate = start.coordinate;
            newAn.lastCoordinate =last.coordinate;
        }

        [self.peopleArray addObject:newAn];
        //新的要加载到地图上去
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isAnimation)
            {//如果新用户没有轨迹数据 则不添加到地图上(默认轨迹第一点为用户位置)
                [self.map addAnnotation:newAn];
            }
        });
    }
    else
    {//之前人员 更新足迹
        XHMoveAnnotation *oldPeople =[self returnOldPeopleFor:dict[@"name"]];
        oldPeople.isAnimation =isAnimation;
        
        if (oldPeople.isAnimation)
        {//如果没有新数据 维持原样不变
            oldPeople.tracking =[self getTrackingFor:coords count:moves.count];
            TracingPoint * first = [oldPeople.tracking firstObject];
            TracingPoint * tp = [[TracingPoint alloc] init];
            tp.coordinate = oldPeople.lastCoordinate;
            tp.course = [Util calculateCourseFromCoordinate:oldPeople.lastCoordinate to:first.coordinate];
            [oldPeople.tracking insertObject:tp atIndex:0];
            //更新last coordinate
            TracingPoint * last = [oldPeople.tracking lastObject];
            oldPeople.lastCoordinate =last.coordinate;
        }
    }

}

#pragma mark --判断轮询是否搜寻到新的人
- (BOOL)isNewPeople:(NSString *)name
{
    BOOL newPeople =YES;
    for(XHMoveAnnotation *obj in self.peopleArray)
    {
        if ([obj.title isEqualToString:name])
        {
            newPeople =NO;
        }
    }
    NSLog(@"newPeople ===:%d",newPeople);
    return newPeople;
}

#pragma mark --返回之前已经有的人--
- (XHMoveAnnotation *)returnOldPeopleFor:(NSString *)name
{
    __block XHMoveAnnotation *an;
    
    [self.peopleArray enumerateObjectsUsingBlock:^(XHMoveAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.title isEqualToString:name])
        {
            an =obj;
            *stop =YES;
        }
    }];
    return an;
}

#pragma mark --数据转地理位置--
- (CLLocationCoordinate2D *)getCoordsFor:(NSArray *)moves
{
    CLLocationCoordinate2D * coords = malloc(moves.count * sizeof(CLLocationCoordinate2D));
    [moves enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        coords[idx] =CLLocationCoordinate2DMake([obj[@"latitude"] doubleValue],  [obj[@"longitude"] doubleValue]);
    }];
    return coords;
}

#pragma mark --获得路径数组--
- (NSMutableArray *)getTrackingFor:(CLLocationCoordinate2D *)coords count:(NSInteger)count
{
    NSMutableArray * tracking =[NSMutableArray new];
    
    for (int i = 0; i<count - 1; i++)
    {
        TracingPoint * tp = [[TracingPoint alloc] init];
        tp.coordinate = coords[i];
        tp.course = [Util calculateCourseFromCoordinate:coords[i] to:coords[i+1]];
        [tracking addObject:tp];
    }
    
    TracingPoint * tp = [[TracingPoint alloc] init];
    tp.coordinate = coords[count - 1];
    tp.course = ((TracingPoint *)[tracking lastObject]).course;
    [tracking addObject:tp];
    
    if (coords) {
        free(coords);
    }
    
    return tracking;
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
        annotationView.isHiddenCallView =NO;
        
        annotationView.image =[UIImage imageNamed:@"userPosition"];
        CGPoint centerPoint=CGPointZero;
        [annotationView setCenterOffset:centerPoint];
        return annotationView;
    }
    
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.peopleTimer =  [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(getPeopleModelData) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.peopleTimer forMode:NSDefaultRunLoopMode];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.peopleTimer invalidate];
    self.peopleTimer = nil;
}
#pragma mark - 测试按钮 --

- (void)mov
{
    /* Step 3. */
    [self getPeopleModelData];
}

- (void)initBtn
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, self.view.frame.size.height * 0.8, 60, 40);
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitle:@"move" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(mov) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    [self.view bringSubviewToFront:btn];
}

#pragma mark --模拟数据--
- (NSMutableArray *)getModelData
{
    NSMutableArray *array =[NSMutableArray new];

    if (ceshi ==0)
    {
        [array addObject:@{
                           @"name":@"a",
                           @"moves":@[
                                   @{@"latitude":@"31.605176",@"longitude":@"120.330776"},
                                   @{@"latitude":@"31.60373",@"longitude":@"120.33153"},
                                   @{@"latitude":@"31.60047",@"longitude":@"120.332968"},
                                   @{@"latitude":@"31.593611",@"longitude":@"120.33613"},
                                   ],
                           }];
        [array addObject:@{
                           @"name":@"b",
                           @"moves":@[
                                   @{@"latitude":@"31.611365",@"longitude":@"120.339822"},
                                   @{@"latitude":@"31.610996",@"longitude":@"120.340828"},
                                   @{@"latitude":@"31.609888",@"longitude":@"120.342553"},
                                   @{@"latitude":@"31.606506",@"longitude":@"120.34284"},
                                   ],
                           }];

    }
    
    else if (ceshi ==1)
    {
        [array addObject:@{
                           @"name":@"a",
                           @"moves":@[
                                   @{@"latitude":@"31.590751",@"longitude":@"120.336776"},
                                   @{@"latitude":@"31.590751",@"longitude":@"120.336776"},
                                   @{@"latitude":@"31.589359",@"longitude":@"120.337504"},
                                   @{@"latitude":@"31.589713",@"longitude":@"120.340424"},
                                   ],
                           }];
        [array addObject:@{
                           @"name":@"b",
                           @"moves":@[
                                   @{@"latitude":@"31.604699",@"longitude":@"120.342984"},
                                   @{@"latitude":@"31.603899",@"longitude":@"120.343056"},
                                   @{@"latitude":@"31.602854",@"longitude":@"120.343056"},
                                   @{@"latitude":@"31.600762",@"longitude":@"120.343056"},
                                   ],
                           }];
        [array addObject:@{
                           @"name":@"c",
                           @"moves":@[
                                   @{@"latitude":@"31.599922",@"longitude":@"120.338151"},
                                   @{@"latitude":@"31.599061",@"longitude":@"120.338079"},
                                   @{@"latitude":@"31.597892",@"longitude":@"120.33772"},
                                   @{@"latitude":@"31.597154",@"longitude":@"120.338438"},
                                   ],
                           }];
    }
    else
    {
        [array addObject:@{
                           @"name":@"a",
                           @"moves":@[
                                   @{@"latitude":@"31.589828",@"longitude":@"120.34143"},
                                   @{@"latitude":@"31.589859",@"longitude":@"120.341672"},
                                   @{@"latitude":@"31.589951",@"longitude":@"120.342472"},
                                   @{@"latitude":@"31.589428",@"longitude":@"120.342561"},
                                   ],
                           }];
        [array addObject:@{
                           @"name":@"b",
                           @"moves":@[
                                   @{@"latitude":@"31.599553",@"longitude":@"120.343181"},
                                   @{@"latitude":@"31.5974",@"longitude":@"120.343109"},
                                   @{@"latitude":@"31.594324",@"longitude":@"120.342966"},
                                   @{@"latitude":@"31.59088",@"longitude":@"120.34275"},
                                   ],
                           }];
        [array addObject:@{
                           @"name":@"c",
                           @"moves":@[
                                   @{@"latitude":@"31.594324",@"longitude":@"120.338151"},
                                   @{@"latitude":@"31.594201",@"longitude":@"120.341816"},
                                   @{@"latitude":@"31.591741",@"longitude":@"120.342822"},
                                   @{@"latitude":@"31.588665",@"longitude":@"120.342606"},
                                   ],
                           }];
    }
    return array;
}

#pragma mark --懒加载--
- (NSMutableArray <XHMoveAnnotation *>*)peopleArray
{
    if (_peopleArray ==nil)
    {
        _peopleArray =[NSMutableArray new];
    }
    return _peopleArray;
}

- (MAMapView *)map
{
    if (!_map)
    {
        _map = [[MAMapView alloc] initWithFrame:self.view.frame];
        _map.delegate = self;
        _map.showsLabels = YES;
        
        //加入annotation旋转动画后，暂未考虑地图旋转的情况。 如果不需要转向 可以打开旋转地图
        _map.rotateCameraEnabled = NO;
        _map.rotateEnabled = NO;
        
        _map.userTrackingMode =MAUserTrackingModeFollowWithHeading;//追踪位置更新
        _map.desiredAccuracy =kCLLocationAccuracyNearestTenMeters;//十米更新
        
        _map.pausesLocationUpdatesAutomatically = YES;//可以被系统自动暂停
        _map.allowsBackgroundLocationUpdates = YES;//是否允许后台定位
        _map.showsUserLocation = YES;
    }
    return _map;
}



@end
