//
//  SCPageControl.h
//  SCPageControlDemo
//
//  Created by Shengzhe Chen on 3/13/14.
//  Copyright (c) 2014 Shengzhe Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCPageControl : UIView

@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger currentPageIndex;

- (void)refresh;
- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated;

@end
