//
//  ViewController.m
//  customCamera
//
//  Created by David on 16/7/24.
//  Copyright © 2016年 detu. All rights reserved.
//

#import "ViewController.h"
#import "cameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view   addSubview:btn];
    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"camera" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(camera) forControlEvents:UIControlEventTouchDown];
    
}


- (void)camera {
 
    [self presentViewController:[cameraViewController new] animated:YES completion:nil];
    
}


@end
