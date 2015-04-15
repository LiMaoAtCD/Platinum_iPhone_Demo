//
//  ViewController.m
//  Platinum
//
//  Created by AlienLi on 15/4/13.
//  Copyright (c) 2015年 AlienLi. All rights reserved.
//

#import "ViewController.h"
#import "DLNAManager.h"

@interface ViewController (){

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [DLNAManager DefaultManager];
  
}
- (IBAction)retrivingDMSs:(id)sender {
    [[DLNAManager DefaultManager] getServerResources];
}

- (IBAction)retrivingDMRs:(id)sender {
    [[DLNAManager DefaultManager] getRedererResources];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
