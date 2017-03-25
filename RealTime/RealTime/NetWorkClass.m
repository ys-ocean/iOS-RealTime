//
//  NetWorkClass.m
//  RealTime
//
//  Created by huhaifeng on 2017/3/22.
//  Copyright © 2017年 huhaifeng. All rights reserved.
//

#import "NetWorkClass.h"
#import "NetWorkTool.h"

@implementation NetWorkClass

+ (void)RequestPeopleAdress:(NSDictionary *)param
               successBlock:(void (^)(id responseObject))success
                 errorBlock:(void (^)(NSError *error))errorInfo
{
        [[NetWorkTool defaultManager]RequestAPI:@"POST" apiUrl:[self stringByUTF8Encod:[NSString stringWithFormat:@"XXXXXXX/%@",[param objectForKey:@"userId"]]] params:nil progress:nil successBlock:success errorBlock:errorInfo];
}

+ (NSString *)stringByUTF8Encod:(NSString *)str
{
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
