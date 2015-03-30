//
// Created by Tony Cheng on 3/30/15.
// Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/ASCellNode.h>

@class Post;


@interface KVNStreamViewNode : ASCellNode

@property (nonatomic, strong) Post *post;

@end