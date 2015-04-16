//
//  ViewController.m
//  Platinum
//
//  Created by AlienLi on 15/4/13.
//  Copyright (c) 2015年 AlienLi. All rights reserved.
//

#import "ViewController.h"
#import "DLNAManager.h"
#import "RenderDetailViewController.h"
#import "FilesTableViewController.h"

@interface ViewController ()<SelectionDelegate,selectFileDelegate>{
    NSArray *rendererArr;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [DLNAManager DefaultManager];
    
    
    
  
}
- (IBAction)fetchDMSResources:(id)sender {
    
    NSArray *files = [[DLNAManager DefaultManager]fetchLocalFilesfromDMS];

    if (files.count > 0) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        FilesTableViewController *serverController = [sb instantiateViewControllerWithIdentifier:@"FilesTableViewController"];
        
        serverController.delegate = self;
        serverController.items = files;
        [self showDetailViewController:serverController sender:nil];
    }
    
    
}
- (IBAction)retrivingDMSs:(id)sender {
    
    [[DLNAManager DefaultManager] getServerResources];
}

- (IBAction)retrivingDMRs:(id)sender {
    
    rendererArr = [[DLNAManager DefaultManager] getRendererResources];
    
    if (rendererArr.count >0) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        RenderDetailViewController *renderController = [sb instantiateViewControllerWithIdentifier:@"RenderDetailViewController"];
        renderController.delegate = self;
        renderController.items = rendererArr;
        [self showDetailViewController:renderController sender:nil];
    }

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didSelectIndexAtList:(NSInteger)index{
    [[DLNAManager DefaultManager] specifyRenderer:index];
}

-(void)DidSelectedFileAtIndex:(NSInteger)index{
    [[DLNAManager DefaultManager] specifyFileInDMS:index];
}



@end
