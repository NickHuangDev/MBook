//
//  CGLEditDetailViewController.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/8.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CoreViewController.h"
@class DetailEntity;

@interface CGLEditDetailViewController : CoreViewController
@property (strong, nonatomic) DetailEntity *selectedDetailEntity;
@end
