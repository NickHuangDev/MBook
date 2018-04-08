//
//  CGLDetailCell.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/9/30.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CGLDetailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *detailImage;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryTypeLabel;

@end
