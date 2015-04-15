//
//  RenderDetailViewController.h
//  Platinum
//
//  Created by AlienLi on 15/4/15.
//  Copyright (c) 2015年 AlienLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectionDelegate <NSObject>

-(void)didSelectIndexAtList:(NSInteger)index;

@end

@interface RenderDetailViewController : UITableViewController

@property (nonatomic, strong) NSArray *items;

@property (weak,nonatomic) id<SelectionDelegate> delegate;

@end
