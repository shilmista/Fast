//
// Created by Tony Cheng on 3/30/15.
// Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


@interface AppDotNetAPIClient : AFHTTPSessionManager
+ (instancetype)sharedClient;
@end