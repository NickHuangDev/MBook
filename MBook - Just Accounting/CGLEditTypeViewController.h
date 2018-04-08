//
//  CGLEditTypeViewController.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/11.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CoreViewController.h"
@class CategoryEntity;
@class TypeEntity;

@interface CGLEditTypeViewController : CoreViewController
@property (strong, nonatomic) CategoryEntity *editCategoryEntity;
@property (strong, nonatomic) TypeEntity *editTypeEntity;

@end
