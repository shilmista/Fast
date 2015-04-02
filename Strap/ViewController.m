//
//  ViewController.m
//  Strap
//
//  Created by Tony Cheng on 3/26/15.
//  Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import "ASDisplayNode+Subclasses.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AVFoundation/AVFoundation.h>

static const CGFloat kHorizontalPadding = 15.0f;
static const CGFloat kVerticalPadding = 11.0f;
static const CGFloat kFontSize = 18.0f;

@interface CollectionViewCell : ASCellNode
@property (nonatomic, strong) ASTextNode *textNode;
@property (nonatomic, strong) ASImageNode *imageNode;
@property (nonatomic, strong) ASDisplayNode *gifImageViewNode;
@property (nonatomic, strong) ASDisplayNode *videoLayerNode;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) NSURL *gifURL;
@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, strong) AVPlayer *videoPlayer;

- (void)startPlayback;
- (void)stopPlayback;
- (BOOL)showImage;
@end

@implementation CollectionViewCell
- (instancetype)init
{
    if (!(self = [super init]))
        return nil;

    _imageNode = [[ASImageNode alloc] init];
    [_imageNode setBackgroundColor:[UIColor clearColor]];
    [_imageNode setContentMode:UIViewContentModeScaleAspectFill];
    [_imageNode setClipsToBounds:YES];
    [_imageNode setLayerBacked:YES];

    [_imageNode setCornerRadius:50.0f];
    [_imageNode setBorderColor:[UIColor blueColor].CGColor];
    [_imageNode setBorderWidth:5.0f];

    [self addSubnode:_imageNode];

    _gifImageViewNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView * {
        FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
        imageView.backgroundColor = [UIColor clearColor];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:YES];

        [imageView.layer setShadowOffset:CGSizeMake(5.0f, 5.0f)];
        [imageView.layer setCornerRadius:50.0f];
        [imageView.layer setShadowColor:[UIColor blackColor].CGColor];
        [imageView.layer setShadowOpacity:0.5f];
        
        return imageView;
    }];
    [self addSubnode:_gifImageViewNode];

    _videoLayerNode = [[ASDisplayNode alloc] initWithLayerBlock:^CALayer * {
        AVPlayerLayer *playerLayer = [[AVPlayerLayer alloc] init];
        [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [playerLayer setMasksToBounds:YES];
        [playerLayer setBackgroundColor:[UIColor clearColor].CGColor];

        [playerLayer setShadowOffset:CGSizeMake(5.0f, 5.0f)];
        [playerLayer setCornerRadius:50.0f];
        [playerLayer setShadowColor:[UIColor blackColor].CGColor];
        [playerLayer setShadowOpacity:0.5f];

        return playerLayer;
    }];
    [self addSubnode:_videoLayerNode];

    _textNode = [[ASTextNode alloc] init];
    [_textNode setLayerBacked:YES];
    [self addSubnode:_textNode];

    return self;
}

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize
{
    CGSize availableSize = CGSizeMake(constrainedSize.width - 2 * kHorizontalPadding,
            constrainedSize.height - 2 * kVerticalPadding);
    CGSize textNodeSize = [_textNode measure:availableSize];
    CGFloat imageWidth = constrainedSize.width - 2.0f * kHorizontalPadding;

    CGFloat totalHeight = (self.showImage ? imageWidth : 0.0f) + (self.showImage ? 3 : 2) * kVerticalPadding + textNodeSize.height;

    return CGSizeMake(ceilf(constrainedSize.width),
            ceilf(totalHeight));
}

- (void)layout
{
    CGFloat imageWidth = self.bounds.size.width - 2.0f * kHorizontalPadding;
    _imageNode.frame = CGRectMake(kHorizontalPadding, kVerticalPadding, imageWidth, imageWidth);
    _gifImageViewNode.frame = CGRectMake(kHorizontalPadding, kVerticalPadding, imageWidth, imageWidth);

    CGFloat originY = kVerticalPadding * (self.showImage ? 2.0f : 1.0f) + (self.showImage ? imageWidth : 0);
    _textNode.frame = CGRectMake(kHorizontalPadding, originY, self.bounds.size.width - 2 * kHorizontalPadding, self.bounds.size.height - kVerticalPadding - originY);
}

- (void)setText:(NSString *)text {
    if (_text == text)
        return;
    _text = [text copy];
    [self updateText];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self updateText];
}

- (void)setFont:(UIFont *)font {
    if (_font == font)
        return;
    _font = font;
    [self updateText];
}

- (BOOL)showImage {
    return (self.gifURL || self.videoURL);
}

- (void)setGifURL:(NSURL *)gifURL {
    _gifURL = gifURL;

    if (_gifURL) {
        UIImage *image = [UIImage imageWithContentsOfFile:gifURL.path];
        self.imageNode.image = image;
    }

    [self updateText];
}

- (void)updateText {
    self.textNode.attributedString = [[NSAttributedString alloc] initWithString:(self.text ? self.text : @"")
                                                                     attributes:@{
                                                                             NSFontAttributeName : (self.font ? self.font : [UIFont systemFontOfSize:kFontSize]),
                                                                             NSForegroundColorAttributeName : (self.textColor ? self.textColor : [UIColor blackColor])
                                                                     }];
    [self invalidateCalculatedSize];
}

- (void)startPlayback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.gifURL) {
            FLAnimatedImageView *animatedImageView = (FLAnimatedImageView *) self.gifImageViewNode.view;
            NSData *gifData = [NSData dataWithContentsOfURL:self.gifURL];

            FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:gifData];
            [animatedImageView setAnimatedImage:image];
            CGFloat imageWidth = self.bounds.size.width - 2.0f * kHorizontalPadding;
            _gifImageViewNode.frame = CGRectMake(kHorizontalPadding, kVerticalPadding, imageWidth, imageWidth);
            [animatedImageView startAnimating];
        }
        else if (self.videoURL) {
            if (self.videoPlayer == nil) {
                self.videoPlayer = [[AVPlayer alloc] init];
                [self.videoPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self];

            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:self.videoURL];
            [self.videoPlayer replaceCurrentItemWithPlayerItem:playerItem];
            AVPlayerLayer *playerLayer = (AVPlayerLayer *) self.videoLayerNode.layer;
            playerLayer.player = self.videoPlayer;
            CGFloat imageWidth = self.bounds.size.width - 2.0f * kHorizontalPadding;
            playerLayer.frame = CGRectMake(kHorizontalPadding, kVerticalPadding, imageWidth, imageWidth);

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(replay)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:self.videoPlayer.currentItem];
            [self.videoPlayer play];
        }
    });
}

- (void)stopPlayback {
    dispatch_async(dispatch_get_main_queue(), ^{
        FLAnimatedImageView *animatedImageView = (FLAnimatedImageView *) self.gifImageViewNode.view;
        [animatedImageView stopAnimating];
        [animatedImageView setAnimatedImage:nil];

        [self.videoPlayer pause];

        [[NSNotificationCenter defaultCenter] removeObserver:self];
    });
}

- (void)replay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoPlayer seekToTime:kCMTimeZero];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@interface ViewController () <ASCollectionViewDataSource, ASCollectionViewDelegate>
@property (nonatomic, strong) ASCollectionView *collectionView;
@property (nonatomic, strong) NSArray *colorsArray;
@property (nonatomic, strong) NSArray *gifArray;
@property (nonatomic, strong) CollectionViewCell *currentNode;
@end


@implementation ViewController

#pragma mark -
#pragma mark UIViewController.

- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;

    [self commonInit];

    return self;
}

- (void)commonInit {
    NSArray *colorsArray = [self dataArrayOfSize:10];
    self.colorsArray = colorsArray;

    NSArray *gifArray = [self gifArrayOfSize:10];
    self.gifArray = gifArray;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    [flowLayout setItemSize:CGSizeMake(screenWidth, 50.0f)];

    _collectionView = [[ASCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.asyncDataSource = self;
    _collectionView.asyncDelegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:_collectionView];
}

- (void)viewWillLayoutSubviews
{
    _collectionView.frame = self.view.bounds;
}

#pragma mark - data
- (NSArray *)dataArrayOfSize:(NSInteger)size {
    NSMutableArray *colorsArray = @[].mutableCopy;
    for (int i = 0; i < size; i++) {
        int red = arc4random_uniform(255);
        int green = arc4random_uniform(255);
        int blue = arc4random_uniform(255);

        UIColor *color = KVNRGBColor(red, green, blue);
        [colorsArray addObject:color];
    }
    return colorsArray;
}

- (NSArray *)gifArrayOfSize:(NSInteger)size {
    NSMutableArray *gifArray = @[].mutableCopy;
    for (int i = 0; i < size; i++) {
        int index = arc4random() % 2;
        [gifArray addObject:@(index)];
    }
    return gifArray;
}

#pragma mark -
#pragma mark - playback

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        [self updatePlayback];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        [self updatePlayback];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        [self updatePlayback];
    }
}

- (void)updatePlayback {
    // cancel previous calls to player
    CGPoint collectionViewCenter = CGPointMake(self.collectionView.center.x + self.collectionView.contentOffset.x, self.collectionView.center.y + self.collectionView.contentOffset.y);
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:collectionViewCenter];
    if (indexPath == nil) {
        indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    CollectionViewCell *node = (CollectionViewCell *) [self.collectionView nodeForItemAtIndexPath:indexPath];
    if (self.currentNode == node)
        return;
    [self.currentNode stopPlayback];
    self.currentNode = node;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(startPlayingCurrentlyViewed)
                                               object:nil];
    [self performSelector:@selector(startPlayingCurrentlyViewed) withObject:nil afterDelay:0.2];
}

- (void)startPlayingCurrentlyViewed {
    [self.currentNode startPlayback];
}

#pragma mark ASCollectionView data source.

- (void)collectionView:(ASCollectionView *)collectionView willDisplayNodeForItemAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)collectionView:(ASCollectionView *)collectionView didEndDisplayingNodeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *node = (CollectionViewCell *) [self.collectionView nodeForItemAtIndexPath:indexPath];
    [node stopPlayback];
}

- (ASCellNode *)collectionView:(ASCollectionView *)collectionView nodeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *node = [[CollectionViewCell alloc] init];
    node.backgroundColor = self.colorsArray[(NSUInteger) indexPath.item];

    // perhaps show video?
    int showVideo = arc4random() % 3;
    if (showVideo == 1) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"yeah" ofType:@"mp4"]];
        node.videoURL = url;
    }
    else {
        int index = [self.gifArray[(NSUInteger) indexPath.item] intValue];
        if (index == 0) {
            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bees" ofType:@"gif"]];
            node.gifURL = url;
        }
        else {
            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"yup" ofType:@"gif"]];
            node.gifURL = url;
        }
    }

    node.text = [self randomText];
    node.textColor = [UIColor whiteColor];
    node.font = KVNFontRegular(20);
    return node;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.colorsArray.count;
}

- (void)collectionView:(ASCollectionView *)collectionView willBeginBatchFetchWithContext:(ASBatchContext *)context {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            NSArray *moreColors = [self dataArrayOfSize:10];
            NSArray *moreGifs = [self gifArrayOfSize:10];
            NSInteger existingColors = self.colorsArray.count;
            for (NSInteger i = 0; i < 10; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:existingColors + i inSection:0]];
            }

            self.colorsArray = [self.colorsArray arrayByAddingObjectsFromArray:moreColors];
            self.gifArray = [self.gifArray arrayByAddingObjectsFromArray:moreGifs];
            [self.collectionView insertItemsAtIndexPaths:indexPaths];

            [context completeBatchFetching:YES];
        });
    });
}

- (BOOL)shouldBatchFetchForCollectionView:(ASCollectionView *)collectionView {
    return self.colorsArray.count < 500;
}


#pragma mark - random
- (NSString *)randomText {
    NSString *string = nil;

    int index = arc4random_uniform(5);

    switch (index) {
        case 0:
            string = @"Well we'd have to be talkin' about one charming motherfuckin' pig. I mean he'd have to be ten times more charmin' than that Arnold on Green Acres, you know what I'm sayin'?";
            break;
        case 1:
            string = @"There's a passage I got memorized. Ezekiel 25:17. \"The path of the righteous man is beset on all sides by the inequities of the selfish and the tyranny of evil men. Blessed is he who, in the name of charity and good will, shepherds the weak through the valley of the darkness, for he is truly his brother's keeper and the finder of lost children. And I will strike down upon thee with great vengeance and furious anger those who attempt to poison and destroy My brothers. And you will know I am the Lord when I lay My vengeance upon you.\" Now... I been sayin' that shit for years. And if you ever heard it, that meant your ass. You'd be dead right now. I never gave much thought to what it meant. I just thought it was a cold-blooded thing to say to a motherfucker before I popped a cap in his ass. But I saw some shit this mornin' made me think twice. See, now I'm thinking: maybe it means you're the evil man. And I'm the righteous man. And Mr. 9mm here... he's the shepherd protecting my righteous ass in the valley of darkness. Or it could mean you're the righteous man and I'm the shepherd and it's the world that's evil and selfish. And I'd like that. But that shit ain't the truth. The truth is you're the weak. And I'm the tyranny of evil men. But I'm tryin', Ringo. I'm tryin' real hard to be the shepherd.";
            break;
        case 2:
            string = @"I'm sorry, did I break your concentration? I didn't mean to do that. Please, continue, you were saying something about best intentions. What's the matter? Oh, you were finished! Well, allow me to retort. What does Marsellus Wallace look like?";
            break;
        case 3:
            string = @"And you know what they call a... a... a Quarter Pounder with Cheese in Paris?";
            break;
        case 4:
            string = @"What now? Let me tell you what now. I'ma call a coupla hard, pipe-hittin' niggers, who'll go to work on the homes here with a pair of pliers and a blow torch. You hear me talkin', hillbilly boy? I ain't through with you by a damn sight. I'ma get medieval on your ass.";
            break;
        default:
            break;
    }
    return string;
}

@end

