//
//  SCPageControl.h
//  SCPageControlDemo
//
//  Created by Shengzhe Chen on 3/13/14.
//  Copyright (c) 2014 Shengzhe Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCPageControl;

@protocol SCPageControlDelegate <NSObject>
@optional
- (void)pageControlDidPageIndexChanged:(SCPageControl *)control;

@end

@interface SCPageControl : UIView

@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, weak) id < SCPageControlDelegate > delegate;

- (void)refresh;
- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated;
- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex;

@end
