//
//  CGLTypeViewController.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/9/30.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CategoryEntity;

@interface CGLTypeViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) CategoryEntity *selectedCategoryEntity;

@end
