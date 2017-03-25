//
//  NetWorkClass.h
//  RealTime
//
//  Created by huhaifeng on 2017/3/22.
//  Copyright © 2017年 huhaifeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetWorkClass : NSObject

/*
 *
 */
+ (void)RequestPeopleAdress:(NSDictionary *)param
        successBlock:(void (^)(id responseObject))success
          errorBlock:(void (^)(NSError *error))errorInfo;

@end
