//
//  CGLSearchDetailViewController.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/20.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CGLSearchDetailViewController;

@protocol CGLSearchDetailViewDelegate <NSObject>

- (void)searchDetailViewController:(CGLSearchDetailViewController *)searchDetailViewController inputMinPrice:(NSDecimalNumber *)minPrice inputMaxPrice:(NSDecimalNumber *)maxPrice inputStartDate:(NSDate *)startDate inputEndDate:(NSDate *)endDate descriptionContainCharacters:(NSString *)descriptionCharacter;

@end

@interface CGLSearchDetailViewController : UITableViewController
@property (weak, nonatomic) id<CGLSearchDetailViewDelegate> delegate;
@end
