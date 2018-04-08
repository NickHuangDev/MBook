//
//  CGLEditCategoryViewController.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/10.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CoreViewController.h"
@class KindEntity;
@class CategoryEntity;

@interface CGLEditCategoryViewController : CoreViewController
@property (strong, nonatomic) KindEntity *editKindEntity;
@property (strong, nonatomic) CategoryEntity *editCategoryEntity;

@end
