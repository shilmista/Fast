//
// Created by Tony Cheng on 3/30/15.
// Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import "StreamViewController.h"
#import "StreamCollectionViewNode.h"
#import "ASCollectionView.h"
#import "Post.h"
#import "Constants.h"
#import "KVNStreamViewNode.h"

@interface StreamViewController () <ASCollectionViewDataSource, ASCollectionViewDelegate>
@property (nonatomic, strong) ASCollectionView *collectionView;
@property (nonatomic, strong) NSArray *streamDataArray;
@property (nonatomic, strong) NSNumber *page;
@end

@implementation StreamViewController {

}

- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    [self commonInit];
    return self;
}


- (void)commonInit {
    self.streamDataArray = @[];
    self.page = @0;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 100.0f)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView = [[ASCollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:flowLayout
                                                asyncDataFetching:YES];
    [self.collectionView setAsyncDataSource:self];
    [self.collectionView setAsyncDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setBackgroundColor:KVNRGBColor(228, 228, 228)];

    [self.view addSubview:self.collectionView];

    // begin loading
    [Post globalTimelinePostsForPage:self.page
                           withBlock:^(NSArray *posts, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (error)
                                       DLog(@"error: %@", error);
                                   if (posts.count)
                                       self.page = @(self.page.intValue + 1);
                                   NSMutableArray *indexPaths = @[].mutableCopy;
                                   NSUInteger existingPosts = self.streamDataArray.count;
                                   for (int i = 0; i < posts.count; i++) {
                                       [indexPaths addObject:[NSIndexPath indexPathForItem:(existingPosts + i)
                                                                                 inSection:0]];
                                   }
                                   self.streamDataArray = [self.streamDataArray arrayByAddingObjectsFromArray:posts];
                                   [self.collectionView reloadData];
                               });
                           }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self.collectionView setFrame:self.view.bounds];
}

#pragma mark - ASCollectionView data source + delegate

- (void)collectionView:(ASCollectionView *)collectionView willDisplayNodeForItemAtIndexPath:(NSIndexPath *)indexPath {
    KVNStreamViewNode *node = (KVNStreamViewNode *) [collectionView nodeForItemAtIndexPath:indexPath];
    Post *post = self.streamDataArray[(NSUInteger) indexPath.item];
    [node setPost:post];
}

- (void)collectionView:(ASCollectionView *)collectionView didEndDisplayingNodeForItemAtIndexPath:(NSIndexPath *)indexPath {
    KVNStreamViewNode *node = (KVNStreamViewNode *) [collectionView nodeForItemAtIndexPath:indexPath];
    [node setPost:nil];
}

- (ASCellNode *)collectionView:(ASCollectionView *)collectionView nodeForItemAtIndexPath:(NSIndexPath *)indexPath {
    KVNStreamViewNode *node = [[KVNStreamViewNode alloc] init];

    Post *post = self.streamDataArray[(NSUInteger) indexPath.item];
    node.post = post;

    return node;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.streamDataArray.count;
}

- (void)collectionView:(ASCollectionView *)collectionView willBeginBatchFetchWithContext:(ASBatchContext *)context {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Post globalTimelinePostsForPage:self.page
                               withBlock:^(NSArray *posts, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (error)
                                           DLog(@"error: %@", error);
                                       if (posts.count)
                                           self.page = @(self.page.intValue + 1);
                                       NSMutableArray *indexPaths = @[].mutableCopy;
                                       NSUInteger existingPosts = self.streamDataArray.count;
                                       for (int i = 0; i < posts.count; i++) {
                                           [indexPaths addObject:[NSIndexPath indexPathForItem:(existingPosts + i)
                                                                                     inSection:0]];
                                       }
                                       self.streamDataArray = [self.streamDataArray arrayByAddingObjectsFromArray:posts];

                                       [self.collectionView insertItemsAtIndexPaths:indexPaths];
                                       [context completeBatchFetching:YES];
                                   });
                               }];
    });
}

- (BOOL)shouldBatchFetchForCollectionView:(ASCollectionView *)collectionView {
    return self.streamDataArray.count < 500;
}


@end
