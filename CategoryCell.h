//
//  CategoryCell.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/9/26.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *colorView;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;

@end
