//
//  ViewController.m
//  helloObjC
//
//  Created by 李茵 on 15/11/16.
//  Copyright © 2015年 李茵. All rights reserved.
//

#import "ViewController.h"
#import "cameraViewController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(_mainLabel.text);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
