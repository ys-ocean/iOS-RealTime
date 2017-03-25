//
//  NetWorkTool.m
//  RealTime
//
//  Created by huhaifeng on 2017/3/22.
//  Copyright © 2017年 huhaifeng. All rights reserved.
//

#import "NetWorkTool.h"
static NetWorkTool *_manager;
@implementation NetWorkTool

+ (instancetype)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager =[[self alloc]init];
    });
    return _manager;
}

- (void)setBaseURL:(NSString *)baseURL{
    
    if (![_baseURL isEqualToString:baseURL]) {
        _baseURL =baseURL;
        self.defaultAFNManager =[[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:_baseURL]];
        //https安全验证
        self.defaultAFNManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
        self.defaultAFNManager.securityPolicy.allowInvalidCertificates = YES; //是否信任服务器无效或过期的SSL证书。(自签名证书)
        
        self.defaultAFNManager.securityPolicy.validatesDomainName = NO; //是否验证域名
        self.defaultAFNManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.defaultAFNManager.responseSerializer = [AFJSONResponseSerializer serializer]; //可以不写不解析 保持原有数据形式.
        self.defaultAFNManager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
        
        self.defaultAFNManager.requestSerializer.timeoutInterval = 10.0; // 超时时间
        
        ((AFJSONResponseSerializer *)self.defaultAFNManager.responseSerializer).removesKeysWithNullValues =YES;
        //关闭缓存避免干扰测试
        self.defaultAFNManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
}


- (int)NetWorkStatus
{
    __block int net =1;
    /**
     AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G 花钱
     AFNetworkReachabilityStatusReachableViaWiFi = 2,   // 局域网络,不花钱
     */
    // 如果要检测网络状态的变化,必须用检测管理器的单例的startMonitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        //网络断开提示
        if(status == 0){
            
            UIAlertView *alertV = [[UIAlertView alloc]
                                   initWithTitle:nil
                                   message:@"抱歉,网络已断开..."
                                   delegate:nil
                                   cancelButtonTitle:@"确定"
                                   otherButtonTitles:nil,nil];
            [alertV show];
            net =0;
        }
        
    }];
    return net;
}

- (NSURLSessionDownloadTask *)DownFileApi:(NSString *)url
                                 fileName:(NSString *)fileName
                                 progress:(void (^)(NSProgress * uploadProgress))uploadProgress
                               completion:(void (^)(NSURLResponse * response,NSURL * filePath, NSError *error))completionHandler
{
    if ([self NetWorkStatus] ==0) {
        NSLog(@"没有网络环境!");
        return NULL;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com/img/bdlogo.png"]];
    
    NSURLSessionDownloadTask * downloadTask = [self.defaultAFNManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        uploadProgress(downloadProgress);
        NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSLog(@"response.suggestedFilename:%@ \n",response.suggestedFilename);
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        completionHandler(response,filePath,error);
    }];
    
    return downloadTask;
}

- (void)RequestAPI:(NSString *)method
            apiUrl:(NSString *)url
            params:(NSDictionary *)param
          progress:(void (^)(NSProgress * uploadProgress))uploadProgress
      successBlock:(void (^)(id ))success
        errorBlock:(void (^)(NSError *))errorInfo {
    
    if([method isEqualToString:@"GET"])
    {
        [self.defaultAFNManager GET:url parameters:param progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self RequestSuccessBlock:success responseObject:responseObject];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self RequestFailedBlock:errorInfo error:error];
        }];
    }
    else
    {
        [self.defaultAFNManager POST:url parameters:param progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self RequestSuccessBlock:success responseObject:responseObject];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self RequestFailedBlock:errorInfo error:error];
        }];
    }
}

- (void)RequestSuccessBlock:(void (^)(id ))success responseObject:(id)responseObject
{
#ifdef DEBUG
    [self NSLogData:responseObject];
#endif
}

- (void)RequestFailedBlock:(void (^)(NSError *))errorInfo error:(NSError *)error
{
    NSLog(@"error*___:%@",[error localizedDescription]);
}



- (void)NSLogData:(id)responseObject{
    
    NSError * error;
    if ([NSJSONSerialization isValidJSONObject:responseObject]){
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
        NSString * string =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"responseObject:%@\n",string);
        NSLog(@"responseObject-error:%@ \n",[error localizedDescription]);
    }
    else
    {
        NSLog(@"responseObject not json format");
    }
}
@end
