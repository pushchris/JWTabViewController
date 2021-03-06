//
//  ViewController.m
//  TabbedViewController
//
//  Created by Josh Wright on 7/1/14.
//  Copyright (c) 2014 Josh Wright. All rights reserved.
//

#import "TabViewController.h"

@interface TabViewController ()
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIView *tabBar;
@property (nonatomic, strong) UIView *selectedTab;
@end

@implementation TabViewController
{
    float offsetPerView;
    NSInteger selectedIndex;
    float tabLength;
    NSArray *titles;
    NSMutableArray *tabs;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedTabColor = [UIColor blackColor];
    self.highlightedTextColor = [UIColor lightGrayColor];
    self.textColor = [UIColor blackColor];
    self.tabFont = [UIFont systemFontOfSize:18];
    self.topBarHeight = 44;
    self.tabsPerScreen = 3;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.pageViewController = [self createPageViewController];
}

- (UIView *)createTabs // MEMORY LEAK
{
    if (self.tabBar != nil) {
        [self.tabBar removeFromSuperview];
    }
    
    UIView *tabBar = [[UIView alloc] init];
    [self.view addSubview:tabBar];
    
    if ([self.viewControllers count] < 1) {
           return tabBar;
    }
    
    float screenWidth = self.pageViewController.view.bounds.size.width;
    
    if (self.tabsPerScreen <= [self.viewControllers count]) {
        tabLength = screenWidth / self.tabsPerScreen;
    } else {
        tabLength = screenWidth / [self.viewControllers count];
    }
    
    float barLength = tabLength * [self.viewControllers count];
    
    if (barLength < self.view.bounds.size.width) {
        barLength = self.view.bounds.size.width;
    }
    
    tabs = [[NSMutableArray alloc] init];
    
    tabBar.frame = CGRectMake(self.view.bounds.origin.x, self.view.frame.origin.y, barLength, self.topBarHeight);
    
    for (int i = 0; i < [self.viewControllers count]; i++) {
        UILabel *tab = [[UILabel alloc] initWithFrame:CGRectMake((tabLength * i), tabBar.bounds.origin.y, tabLength, tabBar.bounds.size.height)];
        [tab setTextAlignment:NSTextAlignmentCenter];
        
        tab.text = [titles objectAtIndex:i];
        tab.font = self.tabFont;
        tab.textColor = (i == 0) ? self.highlightedTextColor : self.textColor;
        
        tab.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToView:)];
        [tab addGestureRecognizer:tapGesture];
        
        [tabBar addSubview:tab];
        NSLog(@"%@", NSStringFromCGRect(tab.frame));
        [tabs addObject:tab];
    }
    self.selectedTab = [[UIView alloc] initWithFrame:CGRectMake(selectedIndex*tabLength+10, tabBar.bounds.size.height - 5, tabLength-20, 5)];
    
    self.selectedTab.backgroundColor = self.selectedTabColor;
    
    [tabBar addSubview:self.selectedTab];
    

    
    for (UIView *view in self.pageViewController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]){
            ((UIScrollView *)view).delegate = self;
        }
    }
    
    return tabBar;
}

- (void)jumpToView:(UITapGestureRecognizer *)gesture
{
    NSInteger index = [tabs indexOfObject:gesture.view];
    
    [self jumpBarToIndex:index];
    [self jumpViewToIndex:index];
    selectedIndex = index;
}

- (UIPageViewController *)createPageViewController
{
    UIPageViewController *pageViewController = [[UIPageViewController alloc]
                                                initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                options:nil];
    pageViewController.dataSource = self;
    pageViewController.delegate = self;
    pageViewController.view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y+self.topBarHeight, self.view.bounds.size.width, self.view.bounds.size.height-self.topBarHeight);
    [self.view addSubview:pageViewController.view];
    [self addChildViewController:pageViewController];
    [pageViewController didMoveToParentViewController:self];
    
    return pageViewController;
}

- (void)putViewControllers:(NSArray *)viewControllers withTitles:(NSArray *)viewControllerTitles
{
    self.viewControllers = viewControllers;
    titles = viewControllerTitles;
    self.tabBar = [self createTabs];
    
    [self.pageViewController setViewControllers:@[self.viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    selectedIndex = 0;

}

#pragma mark - UIPageViewControllerSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger newIndex = [self.viewControllers indexOfObject:viewController]+1;
    if(newIndex < [self.viewControllers count]){
        return [self.viewControllers objectAtIndex:newIndex];
    }else{
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger newIndex = [self.viewControllers indexOfObject:viewController]-1;
    if (newIndex >= 0) {
        return [self.viewControllers objectAtIndex:newIndex];
    } else {
        return nil;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float pageWidth = self.view.frame.size.width;
    float offsetScrollViewPage = scrollView.contentOffset.x - pageWidth;
    float actualTabs = (self.tabsPerScreen <= [self.viewControllers count]) ? self.tabsPerScreen : [self.viewControllers count];
    float index = selectedIndex + (offsetScrollViewPage / pageWidth);
    float offset = (([self.viewControllers count] - actualTabs) * tabLength)/([self.viewControllers count]-1);
    float offsetTabBar = -index * offset;
    
    if (offsetTabBar < 0) {
        self.tabBar.frame = CGRectMake(offsetTabBar, self.tabBar.frame.origin.y, self.tabBar.bounds.size.width, self.tabBar.bounds.size.height);
    }
    
    if (offsetScrollViewPage > pageWidth/2) {
        [self jumpSelectedToIndex:selectedIndex+1];
    } else if (offsetScrollViewPage < -(pageWidth/2)) {
        [self jumpSelectedToIndex:selectedIndex-1];
    } else {
        [self jumpSelectedToIndex:selectedIndex];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSInteger newIndex = [self.viewControllers indexOfObject:self.pageViewController.viewControllers[0]];
    [self jumpBarToIndex:newIndex];
    selectedIndex = newIndex;
}

- (void)jumpBarToIndex:(NSInteger)index
{
    
    float actualTabs = (self.tabsPerScreen <= [self.viewControllers count]) ? self.tabsPerScreen : [self.viewControllers count];
    
    float offSet = (([self.viewControllers count] - actualTabs) * tabLength)/([self.viewControllers count]-1);
    
    
    UILabel *oldLabel = ((UILabel *)[tabs objectAtIndex:selectedIndex]);
    UILabel *newLabel = ((UILabel *)[tabs objectAtIndex:index]);
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.selectedTab.frame = CGRectMake(index*tabLength+10, self.selectedTab.frame.origin.y, tabLength-20, self.selectedTab.bounds.size.height);
        
        self.tabBar.frame = CGRectMake(-index*(offSet), self.tabBar.frame.origin.y, self.tabBar.bounds.size.width, self.tabBar.bounds.size.height);
    } completion:nil];
    
    [UIView transitionWithView:oldLabel duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        oldLabel.textColor = self.textColor;
    } completion:nil];
    [UIView transitionWithView:newLabel duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        newLabel.textColor = self.highlightedTextColor;
    } completion:nil];
}

- (void)jumpSelectedToIndex:(NSInteger)index
{
    UILabel *oldLabel = ((UILabel *)[tabs objectAtIndex:selectedIndex]);
    UILabel *newLabel = ((UILabel *)[tabs objectAtIndex:index]);
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.selectedTab.frame = CGRectMake(index*tabLength+10, self.selectedTab.frame.origin.y, tabLength-20, self.selectedTab.bounds.size.height);
    } completion:nil];
    
    [UIView transitionWithView:oldLabel duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        oldLabel.textColor = self.textColor;
    } completion:nil];
    [UIView transitionWithView:newLabel duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        newLabel.textColor = self.highlightedTextColor;
    } completion:nil];
}

- (void)jumpViewToIndex:(NSInteger)index
{
    
    UIPageViewControllerNavigationDirection direction = index > selectedIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    [self.pageViewController setViewControllers:@[self.viewControllers[index]] direction:direction animated:YES completion:nil];
}

#pragma mark - setters

- (void)setTabsPerScreen:(NSInteger)tabsPerScreen
{
    _tabsPerScreen = tabsPerScreen;
    //TODO
    //self.tabBar = [self createTabs];
}

- (void)setTopBarHeight:(NSInteger)topBarHeight
{
    _topBarHeight = topBarHeight;
    //TODO
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    for (int i = 0 ; i < [tabs count] ; i++) {
        if (i != selectedIndex) {
            ((UILabel *)[tabs objectAtIndex:i]).textColor = textColor;
        }
    }
}

- (void)setTabFont:(UIFont *)tabFont
{
    _tabFont = tabFont;
    for (UILabel *label in tabs) {
        label.font = tabFont;
    }
}

- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor
{
    _highlightedTextColor = highlightedTextColor;
    ((UILabel *)[tabs objectAtIndex:selectedIndex]).textColor = highlightedTextColor;
}

- (void)setSelectedTabColor:(UIColor *)selectedTabColor
{
    _selectedTabColor = selectedTabColor;
    self.selectedTab.backgroundColor = selectedTabColor;
}

- (void)setPageViewBackgroundColor:(UIColor *)pageViewBackgroundColor
{
    _pageViewBackgroundColor = pageViewBackgroundColor;
    self.pageViewController.view.backgroundColor = pageViewBackgroundColor;
}

- (void)setTabBarBackgroundColor:(UIColor *)tabBarBackgroundColor
{
    _tabBarBackgroundColor = tabBarBackgroundColor;
    self.tabBar.backgroundColor = tabBarBackgroundColor;
}

@end
