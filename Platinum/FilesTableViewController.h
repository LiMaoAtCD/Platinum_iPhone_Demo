//
//  FilesTableViewController.h
//  Platinum
//
//  Created by AlienLi on 15/4/16.
//  Copyright (c) 2015年 AlienLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol selectFileDelegate <NSObject>

-(void)DidSelectedFileAtIndex:(NSInteger)index;

@end

@interface FilesTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *items;

@property (weak,nonatomic) id<selectFileDelegate> delegate;

@end
