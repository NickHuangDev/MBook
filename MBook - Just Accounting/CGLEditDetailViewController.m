//
//  CGLEditDetailViewController.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/8.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CGLEditDetailViewController.h"
#import "MBookAppDelegate.h"

#import "KindEntity.h"
#import "CategoryEntity.h"
#import "TypeEntity.h"
#import "DetailEntity.h"

#define CategoryComponent 0
#define TypeComponent 1

@interface CGLEditDetailViewController ()<UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UITextView *priceTextView;
@property (strong, nonatomic) IBOutlet UITextView *dateTextView;
@property (strong, nonatomic) IBOutlet UITextView *categoryTypeTextView;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *typePicker;

@property (strong, nonatomic) NSDecimalNumber *saveToCoreDataDecimal;
@property (strong, nonatomic) NSDate *saveToCoreDatadate;
@property (strong, nonatomic) TypeEntity *saveToCoreDataTypeEntity;
@property (strong, nonatomic) NSString *saveToCoreDataDescription;
@property (strong, nonatomic) NSString *saveToCoreDataPicturePath;

- (IBAction)editAndSaveDetail:(UIBarButtonItem *)sender;
- (IBAction)cancelEditDetail:(UIBarButtonItem *)sender;

- (void)setDefaultValue;
- (void)disableAllObject;
- (void)enableAllObject;

- (void)setPrice;
- (void)setDate;
- (void)setType;
- (void)setDescription;
@end

@implementation CGLEditDetailViewController

- (NSManagedObjectContext *)managedObjectContext {
    return [(MBookAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setDefaultValue];
    [self disableAllObject];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Method
- (void)setDefaultValue {
    //price
    [self.priceTextView setText:[self.selectedDetailEntity.price stringValue]];
    
    self.saveToCoreDataDecimal = self.selectedDetailEntity.price;
    //date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:self.selectedDetailEntity.date];
    [self.dateTextView setText:dateString];
    self.saveToCoreDatadate = self.selectedDetailEntity.date;
    
    //datePicker
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker setCalendar:[NSCalendar currentCalendar]];
    [self.datePicker setLocale:[NSLocale systemLocale]];
    [self.datePicker setTimeZone:[NSTimeZone systemTimeZone]];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    
    //category and type
    CategoryEntity *selectedCategoryEntity = self.selectedDetailEntity.type.category;
    TypeEntity *selectedTypeEntity = self.selectedDetailEntity.type;
    NSString *categoryTypeString = [NSString stringWithFormat:@"%@-%@", selectedCategoryEntity.categoryName, selectedTypeEntity.typeName];
    [self.categoryTypeTextView setText:categoryTypeString];
    self.saveToCoreDataTypeEntity = self.selectedDetailEntity.type;
    
    //categoryType Picker
    self.typePicker = [[UIPickerView alloc] init];

    //description
    [self.descriptionTextView setText:self.selectedDetailEntity.descriptions];
    
    self.saveToCoreDataDescription = self.selectedDetailEntity.descriptions;
    //category and Type saveToCoreDataType
    
}

- (void)disableAllObject {
    [self.priceTextView setEditable:NO];
    [self.dateTextView setEditable:NO];
    [self.categoryTypeTextView setEditable:NO];
    [self.descriptionTextView setEditable:NO];
}

- (void)enableAllObject {
    [self.priceTextView setEditable:YES];
    [self.dateTextView setEditable:YES];
    [self.categoryTypeTextView setEditable:YES];
    [self.descriptionTextView setEditable:YES];
}

- (void)setPrice {
    [self.priceTextView setText:nil];
}

- (void)setDate {
    //add datePicker
    [self.datePicker setDate:[NSDate date]];
    [self.dateTextView setInputView:self.datePicker];
    //add toolBar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.dateTextView.inputView.bounds.size.width, 44)];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSetDate:)];
    UIBarButtonItem *FlexibleSpaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSetDate:)];
    NSArray *barButtonArray = [NSArray arrayWithObjects:cancelButtonItem, FlexibleSpaceButtonItem, doneButtonItem, nil];
    [toolBar setItems:barButtonArray animated:YES];
    [self.dateTextView setInputAccessoryView:toolBar];
}

- (void)cancelSetDate:(UIBarButtonItem *)cancelButtonItem {
    [self.dateTextView resignFirstResponder];
}

- (void)doneSetDate:(UIBarButtonItem *)doneButtonItem {
    //Convert date to dateString
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLog(@"%@", self.datePicker.date);
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.dateTextView.text = [dateFormatter stringFromDate:self.datePicker.date];
    //save date
    self.saveToCoreDatadate = self.datePicker.date;
    [self.dateTextView resignFirstResponder];
}

- (void)setType {
    
    //add typePicker
    self.typePicker.delegate = self;
    self.typePicker.dataSource = self;
    [self.categoryTypeTextView setInputView:self.typePicker];
    //add toolBar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.categoryTypeTextView.inputView.bounds.size.width, 44)];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSetCategoryAndTpye:)];
    UIBarButtonItem *FlexibleSpaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSetCategoryAndTpye:)];
    NSArray *barButtonArray = [NSArray arrayWithObjects:cancelButtonItem, FlexibleSpaceButtonItem, doneButtonItem, nil];
    [toolBar setItems:barButtonArray animated:YES];
    [self.categoryTypeTextView setInputAccessoryView:toolBar];
}

- (void)cancelSetCategoryAndTpye:(UIBarButtonItem *)cancelButtonItem {
    [self.categoryTypeTextView resignFirstResponder];
}

- (void)doneSetCategoryAndTpye:(UIBarButtonItem *)doneButtonItem {
    KindEntity *selectedKindEntity = self.selectedDetailEntity.type.category.kind;
    CategoryEntity *selectedCategoryEntity = [[selectedKindEntity.categorys allObjects] objectAtIndex:[self.typePicker selectedRowInComponent:CategoryComponent]];
    TypeEntity *selectedTypeEntity = [[selectedCategoryEntity.types allObjects] objectAtIndex:[self.typePicker selectedRowInComponent:TypeComponent]];
    //Convert Category And Type to String
    NSString *categoryAndTypeString = [NSString stringWithFormat:@"%@-%@", selectedTypeEntity.category.categoryName, selectedTypeEntity.typeName];
    [self.categoryTypeTextView setText:categoryAndTypeString];
    
    //save date
    
    self.saveToCoreDataTypeEntity = selectedTypeEntity;
    [self.categoryTypeTextView resignFirstResponder];
}

- (void)setDescription {
    [self.descriptionTextView setText:nil];
}


- (IBAction)editAndSaveDetail:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Edit"]) {
        [self enableAllObject];
        [sender setTitle:@"Save"];
    }else if ([sender.title isEqualToString:@"Save"]) {
        [self disableAllObject];
        if (!self.saveToCoreDataDecimal || !self.saveToCoreDatadate || !self.saveToCoreDataTypeEntity) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can not save" message:@"Please Check Basic Section" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }else {
            //Update or Insert
            if ([self.saveToCoreDataTypeEntity isEqual:self.selectedDetailEntity.type]) {
                //Update
                self.selectedDetailEntity.price = self.saveToCoreDataDecimal;
                self.selectedDetailEntity.date = self.saveToCoreDatadate;
                self.selectedDetailEntity.descriptions = self.saveToCoreDataDescription;
                self.selectedDetailEntity.imagePath = self.saveToCoreDataPicturePath;
                
            }else {
                //Insert
                //delete object
                NSManagedObjectContext *context = [self managedObjectContext];
                [context deleteObject:self.selectedDetailEntity];
                
                //Insert Object
                //[self savePictureToPicturePath];
                DetailEntity *saveDetailEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DetailEntity" inManagedObjectContext:[self managedObjectContext]];
                saveDetailEntity.type = self.saveToCoreDataTypeEntity;
                saveDetailEntity.price = self.saveToCoreDataDecimal;
                saveDetailEntity.date = self.saveToCoreDatadate;
                saveDetailEntity.descriptions = self.saveToCoreDataDescription;
                saveDetailEntity.imagePath = self.saveToCoreDataPicturePath;
            }
            NSString *detailAlertString = [NSString stringWithFormat:@"price:%f\ndate:%@\ncategory&type:%@\ndescription:%@\npicturepath:%@", [self.saveToCoreDataDecimal doubleValue], self.saveToCoreDatadate, self.saveToCoreDataTypeEntity.typeName, self.saveToCoreDataDescription, self.saveToCoreDataPicturePath];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Success" message:detailAlertString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            [self saveAndDismiss];
            [sender setTitle:@"Edit"];
        }
    }
}

- (IBAction)cancelEditDetail:(UIBarButtonItem *)sender {
    [self cancelAndDismiss];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView isEqual:self.priceTextView]) {
        [self setPrice];
    }else if ([textView isEqual:self.dateTextView]) {
        [self setDate];
    }else if([textView isEqual:self.categoryTypeTextView]) {
        [self setType];
    }else if([textView isEqual:self.descriptionTextView]) {
        [self setDescription];
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView isEqual:self.priceTextView]) {
        self.saveToCoreDataDecimal = [[NSDecimalNumber alloc] initWithString:self.priceTextView.text];
    }else if([textView isEqual:self.descriptionTextView]) {
        self.saveToCoreDataDescription = self.descriptionTextView.text;
    }
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    KindEntity *selectedKindEntity = self.selectedDetailEntity.type.category.kind;
    if (component == CategoryComponent) {
        return [selectedKindEntity.categorys count];
    }else if (component == TypeComponent) {
        CategoryEntity *selectedCategoryEntity = [[selectedKindEntity.categorys allObjects] objectAtIndex:[pickerView selectedRowInComponent:CategoryComponent]];
        return [selectedCategoryEntity.types count];
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    KindEntity *selectedKindEntity = self.selectedDetailEntity.type.category.kind;
    if (component == CategoryComponent) {
        CategoryEntity *selectedCategoryEntity = [[selectedKindEntity.categorys allObjects] objectAtIndex:row];
        return selectedCategoryEntity.categoryName;
    }else if (component == TypeComponent) {
        CategoryEntity *selectedCategoryEntity = [[selectedKindEntity.categorys allObjects] objectAtIndex:[pickerView selectedRowInComponent:CategoryComponent]];
        TypeEntity *selectedTypeEntity = [[selectedCategoryEntity.types allObjects] objectAtIndex:row];
        return selectedTypeEntity.typeName;
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [pickerView reloadAllComponents];
}


@end
