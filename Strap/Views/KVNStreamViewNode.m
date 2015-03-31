//
// Created by Tony Cheng on 3/30/15.
// Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import <AsyncDisplayKit/ASImageNode.h>
#import <AsyncDisplayKit/ASNetworkImageNode.h>
#import <AsyncDisplayKit/ASTextNode.h>
#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import "Post.h"
#import "KVNStreamViewNode.h"

#import "Constants.h"
#import "UIImageView+WebCache.h"

static const float kStreamViewTopCardHeight = 78.0f;
static const float kStreamViewNodeHorizontalPadding = 5.0f;
static const float kStreamViewNodeVerticalPadding = 12.0f;

@interface KVNStreamViewNode ()

@property (nonatomic, strong) ASDisplayNode *cardBackNode;
@property (nonatomic, strong) ASNetworkImageNode *profileImageNode;
@property (nonatomic, strong) ASTextNode *nameNode;
@property (nonatomic, strong) ASNetworkImageNode *imageNode;
@property (nonatomic, strong) ASTextNode *captionNode;
@property (nonatomic, strong) ASDisplayNode *sdWebImageNode;

@end

@implementation KVNStreamViewNode {

}

#define kUseAsyncDisplayImage NO

- (instancetype) init {
    if (!(self = [super init]))
        return nil;

    [self commonInit];

    return self;
}

- (void)commonInit {
    self.cardBackNode = [[ASDisplayNode alloc] initWithLayerBlock:^CALayer * {
        CALayer *layer = [[CALayer alloc] init];
        return layer;
    }];
    [self.cardBackNode setBackgroundColor:KVNRGBColor(250, 250, 250)];
    [self.cardBackNode setClipsToBounds:YES];
    [self.cardBackNode setCornerRadius:5.0f];
    [self addSubnode:self.cardBackNode];

    if (kUseAsyncDisplayImage) {
        self.imageNode = [[ASNetworkImageNode alloc] init];
        [self.imageNode setLayerBacked:YES];
        [self.imageNode setContentMode:UIViewContentModeScaleAspectFill];
        [self.imageNode setClipsToBounds:YES];
        [self.imageNode setBackgroundColor:[UIColor whiteColor]];
        [self addSubnode:self.imageNode];
    }
    else {
        self.sdWebImageNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView * {
            UIImageView *imageView = [[UIImageView alloc] init];
            return imageView;
        }];
        [self.sdWebImageNode setClipsToBounds:YES];
        [self.sdWebImageNode setContentMode:UIViewContentModeScaleAspectFill];
        [self.sdWebImageNode setBackgroundColor:[UIColor whiteColor]];
        [self addSubnode:self.sdWebImageNode];
    }

    self.captionNode = [[ASTextNode alloc] init];
    [self.captionNode setBackgroundColor:[UIColor clearColor]];
    [self.captionNode setLayerBacked:YES];
    [self addSubnode:self.captionNode];
}

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize
{
    CGSize availableSize = CGSizeMake(constrainedSize.width - 4 * kStreamViewNodeHorizontalPadding,
            constrainedSize.height);
    CGSize textNodeSize = [self.captionNode measure:availableSize];

    CGFloat totalHeight = kStreamViewTopCardHeight + [UIScreen mainScreen].bounds.size.width + kStreamViewNodeVerticalPadding + textNodeSize.height + kStreamViewNodeVerticalPadding;

    return CGSizeMake(ceilf(constrainedSize.width),
            ceilf(totalHeight));
}

- (void)layout {
    [super layout];

    self.cardBackNode.frame = CGRectMake(kStreamViewNodeHorizontalPadding, 0, self.bounds.size.width - 2.0f * kStreamViewNodeHorizontalPadding, self.bounds.size.height);
    self.imageNode.frame = CGRectMake(0, kStreamViewTopCardHeight, self.bounds.size.width, self.bounds.size.width);
    self.sdWebImageNode.frame = CGRectMake(0, kStreamViewTopCardHeight, self.bounds.size.width, self.bounds.size.width);
    self.captionNode.frame = CGRectMake(kStreamViewNodeHorizontalPadding * 2.0f,
            kStreamViewTopCardHeight + self.bounds.size.width + kStreamViewNodeVerticalPadding,
            self.bounds.size.width - kStreamViewNodeHorizontalPadding * 4.0f,
            self.captionNode.calculatedSize.height);
}


#pragma mark - setter
- (void)setPost:(Post *)post {
    if (_post == post)
        return;
    _post = post;

    if (kUseAsyncDisplayImage) {
        [self.imageNode setURL:_post.imageURL];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(UIImageView *) self.sdWebImageNode.view sd_setImageWithURL:_post.imageURL
                                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       if (cacheType == SDImageCacheTypeDisk || cacheType == SDImageCacheTypeNone) {
                                                                           [self.sdWebImageNode.view setAlpha:0];
                                                                           [UIView animateWithDuration:0.3
                                                                                            animations:^{
                                                                                                self.sdWebImageNode.view.alpha = 1.0f;
                                                                                            }
                                                                                            completion:^(BOOL finished) {

                                                                                            }];
                                                                       }
                                                                   });
                                                               }];
        });
    }
    NSAttributedString *captionAttributedString = [[NSAttributedString alloc] initWithString:(_post.text ? _post.text : @"")
                                                                                  attributes:@{NSFontAttributeName : KVNFontRegular(14)}];
    [self.captionNode setAttributedString:captionAttributedString];

    [self invalidateCalculatedSize];
}

@end
