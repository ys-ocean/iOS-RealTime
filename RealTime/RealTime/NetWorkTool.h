//
//  NetWorkTool.h
//  RealTime
//
//  Created by huhaifeng on 2017/3/22.
//  Copyright © 2017年 huhaifeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface NetWorkTool : NSObject

@property (strong ,nonatomic)NSString * baseURL;
@property (strong ,nonatomic)AFHTTPSessionManager *defaultAFNManager;
/*
 * @brief   单例初始化
 */
+ (instancetype)defaultManager;

/*
 * @brief   监听网络状态
 */
- (int)NetWorkStatus;

/*
 * @brief   发送get/post请求
 * @param   method    <NSString>       请求模式(GET或POST)
 url       <NSString>       请求地址
 param     <NSDictionary>   请求参数
 success   <NSDictionary>   回调返回请求到的数据
 errorInfo <NSError>        错误
 */


/**
 发送get/post请求
 
 @param method         请求模式(GET或POST)
 @param url            请求地址
 @param param          请求参数
 @param uploadProgress 请求进度
 @param success        回调返回请求到的数据
 @param errorInfo      错误
 */
- (void)RequestAPI:(NSString *)method
            apiUrl:(NSString *)url
            params:(NSDictionary *)param
          progress:(void (^)(NSProgress *uploadProgress))uploadProgress
      successBlock:(void (^)(id ))success
        errorBlock:(void (^)(NSError *))errorInfo;


/**
 文件下载
 
 @param url 文件路径url
 @param fileName 文件名称
 @param uploadProgress 下载进度
 @param completionHandler 成功回调
 @return 返回下载Task 便于暂停 开始
 */
- (NSURLSessionDownloadTask *)DownFileApi:(NSString *)url
                                 fileName:(NSString *)fileName
                                 progress:(void (^)(NSProgress * uploadProgress))uploadProgress
                               completion:(void (^)(NSURLResponse * response,NSURL * filePath, NSError *error))completionHandler;
@end
