//
//  SCViewController.m
//  SCPageControlDemo
//
//  Created by Shengzhe Chen on 3/13/14.
//  Copyright (c) 2014 Shengzhe Chen. All rights reserved.
//

#import "SCViewController.h"
#import "SCPageControl.h"

@interface SCViewController () < SCPageControlDelegate >

@property (nonatomic, strong) SCPageControl *page;

@end

@implementation SCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.page = [[SCPageControl alloc] initWithFrame:CGRectMake(0, 50, 320, 30)];
    self.page.numberOfPages = 20;
    self.page.delegate = self;
    [self.view addSubview:self.page];
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(update:) userInfo:nil repeats:YES];
}

- (void)update:(id)sender
{
    static BOOL left = YES;
    NSUInteger pageIndex = self.page.currentPageIndex + (left ? 1 : -1);
    if (pageIndex >= self.page.numberOfPages) {
        left = NO;
        return;
    } else if (pageIndex == 0) {
        left = YES;
    }
    self.page.currentPageIndex = pageIndex;
}

- (void)pageControlDidPageIndexChanged:(SCPageControl *)control
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
