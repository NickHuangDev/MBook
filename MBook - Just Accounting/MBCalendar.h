//
//  MBCalendar.h
//  MBCalendar
//
//  Created by 黃琮淵 on 2014/10/24.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBCalendar;

@protocol MBCalendarDelegate <NSObject>

- (void)calendar:(MBCalendar *)calendar didSelectedStartDate:(NSDate *)startDate didSelectedEndDate:(NSDate *)endDate;

@end

@interface MBCalendar : UIView
@property (strong, nonatomic) NSDate *date;
@property (weak, nonatomic) id<MBCalendarDelegate> delegate;
@end
