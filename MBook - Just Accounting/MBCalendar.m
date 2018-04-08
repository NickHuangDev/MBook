//
//  MBCalendar.m
//  MBCalendar
//
//  Created by 黃琮淵 on 2014/10/24.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "MBCalendar.h"

@interface MBCalendar() <UITextFieldDelegate>
@property (strong, nonatomic) UITextField *calendarTextField;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;
@property (strong, nonatomic) NSMutableArray *dayButtonArray;

@property (strong, nonatomic) UIButton *selectedStartButton;
@property (strong, nonatomic) UIButton *selectedEndButton;
@property (assign, nonatomic) BOOL isStartDate;
@property (assign, nonatomic) BOOL isEndDate;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (strong, nonatomic) UIDatePicker *datePicker;

- (NSUInteger)getYear:(NSDate *)date;
- (NSUInteger)getMonth:(NSDate *)date;
- (NSUInteger)getDay:(NSDate *)date;
- (NSUInteger)getWeekOfMonth:(NSDate *)date;
- (NSUInteger)getWeekDay:(NSDate *)date;

- (void)setDefaultView;
- (void)setDayCalendar:(NSDate *)date;
- (void)clearStartDateAndEndDate;
@end

@implementation MBCalendar
- (instancetype)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
    if (self) {
        [self setDefaultView];
    }
    return self;
}

- (void)setDefaultView {
    //isStart/isEnd Date
    self.isStartDate = NO;
    self.isEndDate = NO;
    //Draw Calendar
    [self setBackgroundColor:[UIColor orangeColor]];
    
    CGFloat width = CGRectGetWidth(self.frame) / 7;
    CGFloat height = CGRectGetHeight(self.frame) / 8;
    //Title
    self.calendarTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), height)];
    [self.calendarTextField setBorderStyle:UITextBorderStyleNone];
    [self.calendarTextField setTintColor:[UIColor clearColor]];
    [self.calendarTextField setBackgroundColor:[UIColor orangeColor]];
    [self.calendarTextField setTextColor:[UIColor whiteColor]];
    [self.calendarTextField setTextAlignment:NSTextAlignmentCenter];
    [self.calendarTextField setFont:[UIFont systemFontOfSize:16]];
    self.calendarTextField.delegate = self;
    [self addSubview:self.calendarTextField];
    //datePicker
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker setCalendar:[NSCalendar currentCalendar]];
    [self.datePicker setLocale:[NSLocale systemLocale]];
    [self.datePicker setTimeZone:[NSTimeZone systemTimeZone]];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    
    //Title Button
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(width * 6, 0, width, height)];
    [self.leftButton setTitle:@"<" forState:UIControlStateNormal];
    [self.rightButton setTitle:@">" forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(lastMonth:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(nextMonth:) forControlEvents:UIControlEventTouchUpInside];
    [self.calendarTextField addSubview:self.leftButton];
    [self.calendarTextField addSubview:self.rightButton];
    
    //Week Day
    NSArray *weekDayArray = [NSArray arrayWithObjects:@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", nil];
    for (int i = 0; i < 7; i++) {
        UILabel *weekDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * width, height, width, height)];
        [weekDayLabel setText:weekDayArray[i]];
        [weekDayLabel setTextAlignment:NSTextAlignmentCenter];
        [weekDayLabel setTextColor:[UIColor whiteColor]];
        [weekDayLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:weekDayLabel];
    }
    
    //Day Button background
    UIView *buttonBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 2 * height, 7 * width, 6 * height)];
    [buttonBackgroundView setBackgroundColor:[UIColor grayColor]];
    [self addSubview:buttonBackgroundView];
    
    //Day Button
    self.dayButtonArray = [NSMutableArray arrayWithCapacity:42];
    for (int weekColumn = 0; weekColumn < 6; weekColumn++) {
        [self.dayButtonArray addObject:[NSMutableArray arrayWithCapacity:7]];
        for (int weekDayRow = 0; weekDayRow < 7; weekDayRow++) {
            UIButton *dayButton = [[UIButton alloc] init];
            [dayButton setUserInteractionEnabled:YES];
            [dayButton setTitle:@"" forState:UIControlStateNormal];
            [dayButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [dayButton setFrame:CGRectMake((weekDayRow % 7) * width, (weekColumn) * height, width, height)];
            
            //layer Border
            [dayButton.layer setBorderColor:[UIColor grayColor].CGColor];
            [dayButton.layer setBorderWidth:1.0f];
            [dayButton.layer setCornerRadius:8];
            [dayButton addTarget:self action:@selector(getTheDate:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:dayButton];
            [(NSMutableArray *)[self.dayButtonArray objectAtIndex:weekColumn] addObject:dayButton];
            [buttonBackgroundView addSubview:dayButton];
        }
    }
}

- (void)setDate:(NSDate *)date {
    _date = date;
    [self setDayCalendar:date];
}

#pragma mark - Custom Method
- (void)getTheDate:(UIButton *)dayButton {
    //set Date
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self.date];
    if (!self.isStartDate && !self.isEndDate) {
        [self clearStartDateAndEndDate];
        [dayButton setSelected:YES];
        self.selectedStartButton = dayButton;
        [dayButton setBackgroundColor:[UIColor greenColor]];
        [dayButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateSelected];
        //get start date
        [dateComponents setTimeZone:[NSTimeZone systemTimeZone]];
        [dateComponents setYear:[self getYear:self.date]];
        [dateComponents setMonth:[self getMonth:self.date]];
        [dateComponents setDay:[dayButton.titleLabel.text integerValue]];
        [dateComponents setHour:0];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
        self.startDate = [calendar dateFromComponents:dateComponents];
        NSLog(@"startDate:%@", self.startDate);
        NSLog(@"endDate:%@", self.endDate);
        //set isStartDate
        [self setIsStartDate:YES];
    } else if (self.isStartDate && !self.isEndDate) {
        self.selectedEndButton = dayButton;
        [dayButton setSelected:YES];
        [dayButton setBackgroundColor:[UIColor redColor]];
        [dayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        //get end date
        [dateComponents setTimeZone:[NSTimeZone systemTimeZone]];
        [dateComponents setYear:[self getYear:self.date]];
        [dateComponents setMonth:[self getMonth:self.date]];
        [dateComponents setDay:[dayButton.titleLabel.text integerValue]];
        [dateComponents setHour:24];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
        self.endDate = [calendar dateFromComponents:dateComponents];
        NSLog(@"startDate:%@", self.startDate);
        NSLog(@"endDate:%@", self.endDate);
        [self.delegate calendar:self didSelectedStartDate:self.startDate didSelectedEndDate:self.endDate];
        //set isEndDate
        [self setIsEndDate:YES];
    } else if (self.isStartDate && self.isEndDate) {
        [self clearStartDateAndEndDate];
        [dayButton setSelected:YES];
        self.selectedStartButton = dayButton;
        [dayButton setBackgroundColor:[UIColor greenColor]];
        [dayButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateSelected];
        //get start date
        [dateComponents setTimeZone:[NSTimeZone systemTimeZone]];
        [dateComponents setYear:[self getYear:self.date]];
        [dateComponents setMonth:[self getMonth:self.date]];
        [dateComponents setDay:[dayButton.titleLabel.text integerValue]];
        [dateComponents setHour:0];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
        self.startDate = [calendar dateFromComponents:dateComponents];
        NSLog(@"%@", self.startDate);
        //set isStartDate and isEndDate
        [self setIsStartDate:YES];
        [self setIsEndDate:NO];
    }
}

- (void)lastMonth:(UIButton *)leftButton {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.date];
    [dateComponents setMonth:[dateComponents month] - 1];
    self.date = [calendar dateFromComponents:dateComponents];
    
    [self clearStartDateAndEndDate];
}

- (void)nextMonth:(UIButton *)rightButton {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.date];
    [dateComponents setMonth:[dateComponents month] + 1];
    self.date = [calendar dateFromComponents:dateComponents];
    
    [self clearStartDateAndEndDate];
}

- (void)clearStartDateAndEndDate {
    //set selected StartDate display effect
    [self.selectedStartButton setSelected:NO];
    [self.selectedStartButton setBackgroundColor:[UIColor grayColor]];
    [self.selectedStartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //set selected EndDate display effect
    [self.selectedEndButton setSelected:NO];
    [self.selectedEndButton setBackgroundColor:[UIColor grayColor]];
    [self.selectedEndButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)cancelSetDate:(UIBarButtonItem *)cancelButtonItem {
    [self.calendarTextField resignFirstResponder];
}

- (void)doneSetDate:(UIBarButtonItem *)doneButtonItem {
    self.date = self.datePicker.date;
    [self.calendarTextField resignFirstResponder];
}

#pragma mark - Get Date Information
- (NSUInteger)getYear:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date];
    return dateComponents.year;
}
- (NSUInteger)getMonth:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:date];
    return dateComponents.month;
}
- (NSUInteger)getDay:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date];
    return dateComponents.day;
}
- (NSUInteger)getWeekOfMonth:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfMonth fromDate:date];
    return dateComponents.weekOfMonth;
}
- (NSUInteger)getWeekDay:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date];
    return dateComponents.weekday;
}

#pragma mark - date Calendar set
- (void)setDayCalendar:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    
    //catch number of days in month
    NSRange dayRange = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    
    //setTitle
    [self.calendarTextField setText:[NSString stringWithFormat:@"%li - %li", [dateComponents year], [dateComponents month]]];
    NSLog(@"%@", [(NSMutableArray *)[self.dayButtonArray objectAtIndex:0] objectAtIndex:6]);
    
    //set day in month
    NSMutableArray *buttonDaysArray = [NSMutableArray arrayWithCapacity:dayRange.length];
    for (int days = 1; days < (dayRange.length + 1); days++) {
        [dateComponents setDay:days];
        NSDate *date = [calendar dateFromComponents:dateComponents];
        
        NSLog(@"weekOfMonth = %li, weekDay = %li", [self getWeekOfMonth:date], [self getWeekDay:date]);
        UIButton *dayButton = [(NSMutableArray *)[self.dayButtonArray objectAtIndex:[self getWeekOfMonth:date] - 1] objectAtIndex:[self getWeekDay:date]-1];
        [dayButton setTitle:[NSString stringWithFormat:@"%i", days] forState:UIControlStateNormal];
        [buttonDaysArray addObject:dayButton];
    }
    
    //Check Button Enable and Button Title Text
    for (NSMutableArray *weekOfMonthArray in self.dayButtonArray) {
        for (UIButton *daysButton in weekOfMonthArray) {
            if ([buttonDaysArray containsObject:daysButton]) {
                [daysButton setEnabled:YES];
            }else {
                [daysButton setTitle:@"" forState:UIControlStateNormal];
                [daysButton setEnabled:NO];
            }
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.calendarTextField]) {
        
        //add DatePicker
        [self.datePicker setDate:self.date animated:YES];
        [self.calendarTextField setInputView:self.datePicker];
        //add toolBar
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.calendarTextField.inputAccessoryView.bounds.size.width, 44)];
        UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSetDate:)];
        UIBarButtonItem *FlexibleSpaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSetDate:)];
        NSArray *barButtonArray = [NSArray arrayWithObjects:cancelButtonItem, FlexibleSpaceButtonItem, doneButtonItem, nil];
        [toolBar setItems:barButtonArray animated:YES];
        [self.calendarTextField setInputAccessoryView:toolBar];
        
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.calendarTextField]) {
        [self clearStartDateAndEndDate];
    }
}

@end
