//
//  SampleTabViewController.m
//  TabViewController
//
//  Created by Josh Wright on 7/1/14.
//  Copyright (c) 2014 Josh Wright. All rights reserved.
//

#import "SampleTabViewController.h"

@interface SampleTabViewController ()

@end

@implementation SampleTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIViewController *test1 = [[self storyboard] instantiateViewControllerWithIdentifier:@"Test"];
    UIViewController *test2 = [[self storyboard] instantiateViewControllerWithIdentifier:@"Test"];
    UIViewController *test3 = [[self storyboard] instantiateViewControllerWithIdentifier:@"Test"];
    UIViewController *test4 = [[self storyboard] instantiateViewControllerWithIdentifier:@"Test"];
    UIViewController *test5 = [[self storyboard] instantiateViewControllerWithIdentifier:@"Test"];
    UIViewController *test6 = [[self storyboard] instantiateViewControllerWithIdentifier:@"Test"];
    
    [self putViewControllers:@[test1,test2,test3,test4,test5,test6]
                  withTitles:@[@"1",@"2",@"3",@"4",@"5",@"6"]];
    // Do any additional setup after loading the view.
}

@end