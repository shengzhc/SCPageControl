//
//  SCPageControl.m
//  SCPageControlDemo
//
//  Created by Shengzhe Chen on 3/13/14.
//  Copyright (c) 2014 Shengzhe Chen. All rights reserved.
//

#import "SCPageControl.h"

static NSString *cellIdentifier = @"cellIdentifier";
const float defaultAlpha = 0.2f;
const float highlightAlpha = 1.0f;

@interface SCCollectionViewCell : UICollectionViewCell

@end

@implementation SCCollectionViewCell

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake((rect.size.width - 8)/2.0, (rect.size.height - 8)/2.0, 8, 8));
}

@end

@interface SCCollectionViewLayout : UICollectionViewLayout
{
    CGSize _contentSize;
    NSMutableArray *_layoutAttributes;
}

@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) float itemSpacing;
@property (nonatomic, assign) float padding;

@end

@implementation SCCollectionViewLayout

- (id)init
{
    if (self = [super init]) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize
{
    _layoutAttributes = [NSMutableArray new];
    _itemSize = CGSizeMake(30, 30);
    _itemSpacing = 0;
}

- (void)prepareLayout
{
    if (_layoutAttributes && _layoutAttributes.count == 0) {
        _padding = 0;
        NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
        _contentSize = CGSizeMake(_padding * 2 + numberOfItems * (_itemSize.width + _itemSpacing) - _itemSpacing, _itemSize.height);
        [_layoutAttributes removeAllObjects];
        double offset = _padding;
        for (NSUInteger index = 0; index < numberOfItems; index++) {
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            attribute.frame = CGRectMake(offset, 0, _itemSize.width, _itemSize.height);
            attribute.alpha = defaultAlpha;
            [_layoutAttributes addObject:attribute];
            offset += (_itemSize.width + _itemSpacing);
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[UICollectionViewLayoutAttributes class]]) {
            UICollectionViewLayoutAttributes *attribute = (UICollectionViewLayoutAttributes *)evaluatedObject;
            return CGRectIntersectsRect(attribute.frame, rect);
        }
        return NO;
    }];
    
    if (_layoutAttributes) {
        return [_layoutAttributes filteredArrayUsingPredicate:predicate];
    }
    
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_layoutAttributes && _layoutAttributes.count > indexPath.item) {
        return [_layoutAttributes objectAtIndex:indexPath.item];
    }
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}

@end


@interface SCPageControl () < UICollectionViewDataSource, UICollectionViewDelegate >
{
    UICollectionView *_collectionView;
    SCCollectionViewLayout *_layout;
}
@end

@implementation SCPageControl

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _initialize];
    }
    
    return self;
}

- (void)_initialize
{
    _numberOfPages = 20;
    _layout = [[SCCollectionViewLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[SCCollectionViewLayout alloc] init]];
    [_collectionView registerClass:[SCCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.scrollEnabled = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:_collectionView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _collectionView.frame = self.bounds;
}

- (void)refresh
{
    [_collectionView reloadData];
}

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex
{
    [self setCurrentPageIndex:currentPageIndex animated:YES];
}

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated
{
    if (currentPageIndex > _numberOfPages || currentPageIndex <= 0 || _currentPageIndex == currentPageIndex) {
        return;
    }
    
    NSUInteger _previousPageIndex = _currentPageIndex;
    _currentPageIndex = currentPageIndex;
    BOOL direction = _currentPageIndex > _previousPageIndex ? YES : NO;
    
    UICollectionViewLayoutAttributes *firstAttributes = [_collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UICollectionViewLayoutAttributes *lastAttributes = [_collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:_numberOfPages-1 inSection:0]];
    UICollectionViewLayoutAttributes *previousAttributes = [_collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:_previousPageIndex inSection:0]];
    UICollectionViewLayoutAttributes *currentAttributes = [_collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPageIndex inSection:0]];
    
    void (^shift)(void) = ^{
        CGPoint offset = CGPointMake(CGRectGetMidX(currentAttributes.frame) - _collectionView.bounds.size.width/2.0f, 0);
        [_collectionView setContentOffset:offset animated:animated];
        previousAttributes.alpha = defaultAlpha;
        currentAttributes.alpha = highlightAlpha;
        [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_currentPageIndex inSection:0], [NSIndexPath indexPathForItem:_previousPageIndex inSection:0]]];
    };
    
    void (^move)(void) = ^{
        NSLog(@"Move");
        previousAttributes.alpha = defaultAlpha;
        currentAttributes.alpha = highlightAlpha;
        [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_currentPageIndex inSection:0], [NSIndexPath indexPathForItem:_previousPageIndex inSection:0]]];
    };

    if (direction) {
        if (lastAttributes.frame.origin.x >= _collectionView.contentOffset.x + _collectionView.bounds.size.width &&
            previousAttributes.center.x >= _collectionView.contentOffset.x + _collectionView.bounds.size.width/2.0f) {
            shift();
        } else {
            move();
        }
    } else {
        if (firstAttributes.frame.origin.x + firstAttributes.frame.size.width < _collectionView.contentOffset.x &&
            previousAttributes.center.x <= _collectionView.contentOffset.x + _collectionView.bounds.size.width/2.0f) {
            shift();
        } else {
            move();
        }
    }
}

#pragma UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _numberOfPages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

@end
