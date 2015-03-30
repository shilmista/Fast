//
// Created by Tony Cheng on 3/30/15.
// Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import "StreamCollectionViewNode.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ASDisplayNode+Subclasses.h"
#import "Constants.h"

static const CGFloat kHorizontalPadding = 15.0f;
static const CGFloat kVerticalPadding = 10.0f;
static const CGFloat kStreamCellImageWidth = 80.0f;

@interface StreamCollectionViewNode ()
@property (nonatomic, strong) ASTextNode *textNode;
@property (nonatomic, strong) ASNetworkImageNode *imageNode;
@end

@implementation StreamCollectionViewNode {

}

- (instancetype)init {
    if (!(self = [super init]))
        return nil;

    self.imageNode = [[ASNetworkImageNode alloc] init];
    [self.imageNode setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageNode setClipsToBounds:YES];
    [self.imageNode setCornerRadius:10.0f];
    [self addSubnode:self.imageNode];

    self.textNode = [[ASTextNode alloc] init];
    [self.textNode setBackgroundColor:[UIColor redColor]];
    [self addSubnode:self.textNode];

    self.backgroundColor = [UIColor whiteColor];

    return self;
}

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize
{
    CGSize availableSize = CGSizeMake(constrainedSize.width - 3 * kHorizontalPadding - kStreamCellImageWidth,
            constrainedSize.height - 2 * kVerticalPadding);
    CGSize textNodeSize = [_textNode measure:availableSize];

    CGFloat totalHeight = 2 * kVerticalPadding + ((kStreamCellImageWidth > textNodeSize.height) ? kStreamCellImageWidth : textNodeSize.height);

    return CGSizeMake(ceilf(constrainedSize.width),
            ceilf(totalHeight));
}

- (void)setImageURL:(NSURL *)imageURL {
    [self.imageNode setURL:imageURL];
    [self invalidateCalculatedSize];
}

- (void)setText:(NSString *)text {
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:(text ? text : @"")
                                                                           attributes:@{NSFontAttributeName : KVNFontRegular(15)}];
    [self.textNode setAttributedString:attributedString];
    [self invalidateCalculatedSize];
}

- (void)layout {
    [super layout];

    [self.imageNode setFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, kStreamCellImageWidth, kStreamCellImageWidth)];

    [self.textNode setFrame:CGRectMake(kHorizontalPadding * 2.0f + kStreamCellImageWidth, kVerticalPadding, self.bounds.size.width - kStreamCellImageWidth - 3.0f * kHorizontalPadding, self.textNode.calculatedSize.height)];
}


@end
