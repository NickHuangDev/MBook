//
//  CGLAddCategoryViewController.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/3.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreViewController.h"
@class KindEntity;
@class CategoryEntity;

@interface CGLAddCategoryViewController : CoreViewController
@property (strong, nonatomic) KindEntity *selectedKindEntity;
@property (strong, nonatomic) CategoryEntity *addCategoryEntity;
@end
