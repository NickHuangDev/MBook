//
//  CGLAddTypeViewController.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/3.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CoreViewController.h"
@class CategoryEntity;
@class TypeEntity;

@interface CGLAddTypeViewController : CoreViewController
@property (strong, nonatomic) CategoryEntity *selectedCategoryEntity;
@property (strong, nonatomic) TypeEntity *addTypeEntity;

@end
