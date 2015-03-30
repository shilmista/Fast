//
// Created by Tony Cheng on 3/30/15.
// Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import "Post.h"
#import "AppDotNetAPIClient.h"


@implementation Post {

}

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (!(self = [super init]))
        return nil;

    self.text = [attributes valueForKeyPath:@"text"];
    self.imageURL = [NSURL URLWithString:[[attributes valueForKeyPath:@"user"] valueForKeyPath:@"avatar_image.url"]];

    return self;
}

+ (NSURLSessionDataTask *)globalTimelinePostsForPage:(NSNumber *)page withBlock:(void (^)(NSArray *posts, NSError *error))block {
    AppDotNetAPIClient *client = [AppDotNetAPIClient sharedClient];
    return [client GET:@"stream/0/posts/stream/global"
     parameters:@{@"page":(page ? page : @0)}
        success:^(NSURLSessionDataTask *task, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *postsFromResponse = [responseObject valueForKeyPath:@"data"];
                NSMutableArray *mutablePosts = @[].mutableCopy;
                for (NSDictionary *attributes in postsFromResponse) {
                    Post *post = [[Post alloc] initWithAttributes:attributes];
                    [mutablePosts addObject:post];
                }
                if (block) {
                    block([NSArray arrayWithArray:mutablePosts], nil);
                }
            });
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (block) {
                block([NSArray array], error);
            }
        }];
}


@end