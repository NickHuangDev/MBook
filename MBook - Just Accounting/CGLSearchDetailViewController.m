//
//  CGLSearchDetailViewController.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/20.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CGLSearchDetailViewController.h"

@interface CGLSearchDetailViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *maxPriceField;
@property (strong, nonatomic) IBOutlet UITextField *minPriceField;
@property (strong, nonatomic) IBOutlet UITextField *startDateField;
@property (strong, nonatomic) IBOutlet UITextField *endDateField;
@property (strong, nonatomic) IBOutlet UITextField *decsriptionCharField;
- (IBAction)startSearch:(UIBarButtonItem *)sender;
- (IBAction)cancelSearch:(UIBarButtonItem *)sender;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) NSDecimalNumber *minPriceDecimalNumber;
@property (strong, nonatomic) NSDecimalNumber *maxPriceDecimalNumber;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSString *descriptionString;
- (void)textFieldSetDate:(UITextField *)textField;
- (void)setTextFieldTextColor:(UITextField *)textField;
@end

@implementation CGLSearchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Default Price
    NSString *minPriceString = @"0";
    NSString *maxPriceString = @"9999999";
    
    self.minPriceDecimalNumber = [NSDecimalNumber decimalNumberWithString:minPriceString];
    self.maxPriceDecimalNumber = [NSDecimalNumber decimalNumberWithString:maxPriceString];
    
    self.minPriceField.text = minPriceString;
    self.maxPriceField.text = maxPriceString;
    
    //Default Date
    NSTimeInterval startTimeInterval = -(60 * 60 * 24 * 356 * 10);
    NSTimeInterval endTimeInterval = 0;
    self.startDate = [NSDate dateWithTimeIntervalSinceNow:startTimeInterval];
    self.endDate = [NSDate dateWithTimeIntervalSinceNow:endTimeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.startDateField.text = [dateFormatter stringFromDate:self.startDate];
    self.endDateField.text = [dateFormatter stringFromDate:self.endDate];
    
    //datePicker
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker setCalendar:[NSCalendar currentCalendar]];
    [self.datePicker setLocale:[NSLocale systemLocale]];
    [self.datePicker setTimeZone:[NSTimeZone systemTimeZone]];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    //Default string
    self.decsriptionCharField.text = nil;
    
    [self setTextFieldTextColor:self.minPriceField];
    [self setTextFieldTextColor:self.maxPriceField];
    [self setTextFieldTextColor:self.startDateField];
    [self setTextFieldTextColor:self.endDateField];
    [self setTextFieldTextColor:self.decsriptionCharField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)startSearch:(UIBarButtonItem *)sender {
    self.minPriceDecimalNumber = [NSDecimalNumber decimalNumberWithString:self.minPriceField.text];
    self.maxPriceDecimalNumber = [NSDecimalNumber decimalNumberWithString:self.maxPriceField.text];
    self.descriptionString = self.decsriptionCharField.text;
    NSLog(@"%@", self.descriptionString);
    
    [self.delegate searchDetailViewController:self inputMinPrice:self.minPriceDecimalNumber inputMaxPrice:self.maxPriceDecimalNumber inputStartDate:self.startDate inputEndDate:self.endDate descriptionContainCharacters:self.descriptionString];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelSearch:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Method
- (void)textFieldSetDate:(UITextField *)textField {
    //add DatePicker
    [textField setInputView:self.datePicker];
    //add toolBar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, textField.inputView.bounds.size.width, 44)];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSetDate:)];
    UIBarButtonItem *FlexibleSpaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSetDate:)];
    NSArray *barButtonArray = [NSArray arrayWithObjects:cancelButtonItem, FlexibleSpaceButtonItem, doneButtonItem, nil];
    [toolBar setItems:barButtonArray animated:YES];
    [textField setInputAccessoryView:toolBar];
}

- (void)cancelSetDate:(UIBarButtonItem *)cancelButtonItem {
    if ([self.startDateField isEditing]) {
        [self.startDateField resignFirstResponder];
    }else if ([self.endDateField isEditing]) {
        [self.startDateField resignFirstResponder];
    }
}

- (void)doneSetDate:(UIBarButtonItem *)doneButtonItem {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self.datePicker.date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if ([self.startDateField isEditing]) {
        //set StartDate
        [dateComponents setHour:0];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
        self.startDate = [calendar dateFromComponents:dateComponents];
        //Convert Date To DateString
        [self.startDateField setText:[dateFormatter stringFromDate:self.datePicker.date]];
        
        [self.startDateField resignFirstResponder];
    }else if ([self.endDateField isEditing]) {
        //set EndDate
        [dateComponents setHour:24];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
        self.endDate = [calendar dateFromComponents:dateComponents];
        //Convert Date To DateString
        [self.endDateField setText:[dateFormatter stringFromDate:self.datePicker.date]];
        
        [self.endDateField resignFirstResponder];
    }
}

- (void)setTextFieldTextColor:(UITextField *)textField {
    if ([textField isEditing]) {
        [textField setTextColor:[UIColor darkTextColor]];
    }else {
        [textField setTextColor:[UIColor grayColor]];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.startDateField] || [textField isEqual:self.endDateField]) {
        [self textFieldSetDate:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField setText:@""];
    [self setTextFieldTextColor:textField];
}

@end
