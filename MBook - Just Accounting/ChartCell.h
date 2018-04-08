//
//  ChartCell.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/11/13.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *noLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *chartColorView;

@end
