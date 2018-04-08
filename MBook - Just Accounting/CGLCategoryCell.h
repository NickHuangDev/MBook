//
//  CGLCategoryCell.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/9/29.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CGLCategoryCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *markView;

@property (strong, nonatomic) IBOutlet UIImageView *iconImage;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;

@end
