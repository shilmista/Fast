//
// Created by Tony Cheng on 3/30/15.
// Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASCellNode.h"


@interface StreamCollectionViewNode : ASCellNode

- (void)setText:(NSString *)text;
- (void)setImageURL:(NSURL *)imageURL;

@end