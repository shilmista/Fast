//
// Created by Tony Cheng on 3/30/15.
// Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Post : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSURL *imageURL;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

+ (NSURLSessionDataTask *)globalTimelinePostsForPage:(NSNumber *)page withBlock:(void (^)(NSArray *posts, NSError *error))block;

@end