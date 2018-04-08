//
//  InputViewController_iphone.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/9/18.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "InputViewController_iphone.h"
#import "MBookAppDelegate.h"
//Entity
#import "KindEntity.h"
#import "CategoryEntity.h"
#import "TypeEntity.h"
#import "DetailEntity.h"

#define CategoryComponent 0
#define TypeComponent 1

static NSString *kIsExecuteFirstTime = @"isExecuteFirstTime";

@interface InputViewController_iphone ()<UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveToCoreDateButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *kindSegment;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextView *dateTextView;
@property (strong, nonatomic) IBOutlet UITextView *priceTextView;
@property (strong, nonatomic) IBOutlet UITextView *categoryTypeTextView;

@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (strong, nonatomic) NSDecimalNumber *saveToCoreDataDecimal;
@property (strong, nonatomic) NSDate *saveToCoreDatadate;
@property (strong, nonatomic) TypeEntity *saveToCoreDataTypeEntity;
@property (strong, nonatomic) NSString *saveToCoreDataDescription;
@property (strong, nonatomic) NSString *saveToCoreDataPicturePath;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *typePicker;

@property (strong, nonatomic) NSString *pictureFolderPathString;
@property (strong, nonatomic) NSString *pictureFilePathString;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

- (NSString *)checkAndCreateImageFolder;
- (void)createKindOnExecuteTime;
- (void)setDefaultValue;
- (void)setTextViewColor;
- (void)setCursorAndBorder:(UIView *)View;

- (void)setPrice;
- (void)setDate;
- (void)setType;
- (void)setDescription;

- (KindEntity *)getKind;

- (IBAction)resignKeyBoard:(UITapGestureRecognizer *)sender;
- (IBAction)getPicutre:(UITapGestureRecognizer *)sender;
- (UIImage *)aspectFitImageWithoriginaIimage:(UIImage *)image;

- (void)saveToCoreDataEntity;
- (IBAction)saveToCoreData:(UIBarButtonItem *)sender;


@end

@implementation InputViewController_iphone
- (NSManagedObjectContext *)managedObjectContext {
    return [(MBookAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //check the imageFolder exit
    [self checkAndCreateImageFolder];
    
    //create Kind On First Execute Time
    [self createKindOnExecuteTime];
    //set default
    [self setDefaultValue];
    //set UI Cursor and Border
    [self setCursorAndBorder:self.priceTextView];
    [self setCursorAndBorder:self.dateTextView];
    [self setCursorAndBorder:self.categoryTypeTextView];
    [self setCursorAndBorder:self.descriptionTextView];
    [self setCursorAndBorder:self.kindSegment];
    
    //Enable For Recognize
    self.imageView.userInteractionEnabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.tableView endEditing:YES];
}

/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/

#pragma mark - Custom Mathod
- (NSString *)checkAndCreateImageFolder {
    NSArray *documentPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPathString = [documentPathArray objectAtIndex:0];
    NSString *imageFolderString = [documentPathString stringByAppendingPathComponent:@"CoreDataImage"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageFolderString]) {
        
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:imageFolderString withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"create ImageFolder Error : %@", [error localizedDescription]);
            abort();
        }
    }
    return imageFolderString;
}

- (void)setDefaultValue {
    //price
    self.saveToCoreDataDecimal = nil;
    self.priceTextView.text = @"0";
    //categoryType
    self.saveToCoreDataTypeEntity = nil;
    self.categoryTypeTextView.text = @"Input C&T";
    //categoryType Picker
    self.typePicker = [[UIPickerView alloc] init];
    //description
    self.saveToCoreDataDescription = @"";
    self.descriptionTextView.text = @"Input Description here...";
    //date
    self.saveToCoreDatadate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.dateTextView.text = [dateFormatter stringFromDate:self.saveToCoreDatadate];
    //datePicker
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker setCalendar:[NSCalendar currentCalendar]];
    [self.datePicker setLocale:[NSLocale systemLocale]];
    [self.datePicker setTimeZone:[NSTimeZone systemTimeZone]];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    //textValueColor
    [self setTextViewColor];
}

- (void)setTextViewColor {
    if (self.saveToCoreDataDecimal !=nil) {
        [self.priceTextView setTextColor:[UIColor blackColor]];
    }else {
        [self.priceTextView setTextColor:[UIColor grayColor]];
    }
    if (self.saveToCoreDataTypeEntity !=nil) {
        [self.categoryTypeTextView setTextColor:[UIColor blackColor]];
    }else {
        [self.categoryTypeTextView setTextColor:[UIColor grayColor]];
    }
    if (self.saveToCoreDataDescription.length != 0) {
        [self.descriptionTextView setTextColor:[UIColor blackColor]];
    }else {
        [self.descriptionTextView setTextColor:[UIColor grayColor]];
    }
}

- (void)setCursorAndBorder:(UIView *)View {
    //Let dateField cursor hide
    if ([View isEqual:self.dateTextView]) {
        [View setTintColor:[UIColor clearColor]];
    }
    //Let TypeField cursor hide
    if ([View isEqual:self.categoryTypeTextView]) {
    [View setTintColor:[UIColor clearColor]];
    }
    //set NavigationBar color
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1]];
    
    //set TextView's border
    View.layer.borderColor = [[UIColor colorWithRed:201.0/255 green:201.0/255 blue:205.0/255 alpha:0.5] CGColor];
    View.layer.borderWidth = 1.0f;
    View.layer.cornerRadius = 8;
}

- (void)setPrice {
    [self.priceTextView setText:nil];
    [self setTextViewColor];
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
    KindEntity *selectedKindEntity = [self getKind];
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
    [self setTextViewColor];
}

- (void)createKindOnExecuteTime {
    [self.kindSegment addTarget:self action:@selector(segmentIndexChange:) forControlEvents:UIControlEventValueChanged];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kIsExecuteFirstTime]) {
        //add Income
        KindEntity *kindIncome = [NSEntityDescription insertNewObjectForEntityForName:@"KindEntity" inManagedObjectContext:[self managedObjectContext]];
        kindIncome.kindName = [self.kindSegment titleForSegmentAtIndex:0];
        //add Expense
        KindEntity *kindExpense = [NSEntityDescription insertNewObjectForEntityForName:@"KindEntity" inManagedObjectContext:[self managedObjectContext]];
        kindExpense.kindName = [self.kindSegment titleForSegmentAtIndex:1];
        
        //save
        NSLog(@"%@%@", kindIncome.kindName, kindExpense.kindName);
        
        [self saveToCoreDataEntity];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsExecuteFirstTime];
    }
}

- (void)segmentIndexChange:(UISegmentedControl *)segmentControl {
    [self setDefaultValue];
}

- (KindEntity *)getKind {
    NSLog(@"%@", [self.fetchedResultsController fetchedObjects]);
    NSArray *kindEntityArray = [self.fetchedResultsController fetchedObjects];
    KindEntity *kindEntity = [kindEntityArray firstObject];
    if (![kindEntity.kindName isEqualToString:[self.kindSegment titleForSegmentAtIndex:self.kindSegment.selectedSegmentIndex]]) {
        kindEntity = [kindEntityArray lastObject];
    }
    return kindEntity;
}

- (IBAction)resignKeyBoard:(UITapGestureRecognizer *)sender {
    [self.priceTextView resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
}

//Camera Section -----------------------------------------------------
- (IBAction)getPicutre:(UITapGestureRecognizer *)sender {
    /*
    NSString *imageFolderString = [self checkAndCreateImageFolder];
    self.pictureFolderPathString = [imageFolderString stringByAppendingPathComponent:@"CoreDataPicture"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.pictureFolderPathString]) {
        
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:self.pictureFolderPathString withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
            abort();
        }
    }
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"CameraAction" message:@"Select catch mode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take a picture", @"Select from the album", nil];
    alerView.delegate = self;
    [alerView show];
     */
}

//Camera Section -----------------------------------------------------
- (UIImage *)aspectFitImageWithoriginaIimage:(UIImage *)image {
    /*
    UIGraphicsBeginImageContext(self.imageView.bounds.size);
    [image drawInRect:self.imageView.bounds];
    UIImage *aspectFitImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aspectFitImage;
     */
    return nil;
}
//Camera Section -----------------------------------------------------
- (void)savePictureToPicturePath {
    /*
    NSData *pictureData = [NSKeyedArchiver archivedDataWithRootObject:self.imageView.image];
    
    NSString *PictureName = [NSDateFormatter localizedStringFromDate:self.saveToCoreDatadate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    
    self.saveToCoreDataPicturePath = [self.pictureFolderPathString stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", PictureName]];
    if (![pictureData writeToFile:self.saveToCoreDataPicturePath atomically:YES]) {
        NSLog(@"Save Picture Failed");
        abort();
    }
     */
}

- (void)saveToCoreDataEntity {
    NSError *error;
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Save Failed : %@", [error localizedDescription]);
        }else {
            NSLog(@"Save Successed");
        }
    }
}
//Camera Section -----------------------------------------------------
- (IBAction)saveToCoreData:(UIBarButtonItem *)sender {
    if (!self.saveToCoreDataDecimal || !self.saveToCoreDatadate || !self.saveToCoreDataTypeEntity) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can not save" message:@"Please Check Basic Section" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }else {
        //[self savePictureToPicturePath];
        DetailEntity *saveDetailEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DetailEntity" inManagedObjectContext:[self managedObjectContext]];
        saveDetailEntity.type = self.saveToCoreDataTypeEntity;
        saveDetailEntity.price = self.saveToCoreDataDecimal;
        saveDetailEntity.date = self.saveToCoreDatadate;
        saveDetailEntity.descriptions = self.saveToCoreDataDescription;
        saveDetailEntity.imagePath = self.saveToCoreDataPicturePath;
        
        [self saveToCoreDataEntity];
        NSString *detailAlertString = [NSString stringWithFormat:@"price:%f\ndate:%@\ncategory&type:%@\ndescription:%@\npicturepath:%@", [self.saveToCoreDataDecimal doubleValue], self.saveToCoreDatadate, self.saveToCoreDataTypeEntity.typeName, self.saveToCoreDataDescription, self.saveToCoreDataPicturePath];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Success" message:detailAlertString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        NSLog(@"%@", [alertView subviews]);
        [self setDefaultValue];
        [alertView show];
        
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    //Disable SaveButton
    [self.saveToCoreDateButton setEnabled:NO];
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
    //Enable SaveButton
    [self.saveToCoreDateButton setEnabled:YES];
    if ([textView isEqual:self.priceTextView]) {
        self.saveToCoreDataDecimal = [[NSDecimalNumber alloc] initWithString:self.priceTextView.text];
        [self setTextViewColor];
    }else if([textView isEqual:self.categoryTypeTextView]) {
        [self setTextViewColor];
    }else if([textView isEqual:self.descriptionTextView]) {
        self.saveToCoreDataDescription = self.descriptionTextView.text;
        [self setTextViewColor];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

//Camera Section -----------------------------------------------------
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    /*
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    
    if ([alertView.title isEqualToString:@"CameraAction"]) {
        if (buttonIndex == 0) {
            [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        }else if (buttonIndex == 1){
            [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        }else if (buttonIndex == 2){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
     */
}
//Camera Section -----------------------------------------------------
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    /*
    
    UIImage *originaIimage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *aspectFitImage = [self aspectFitImageWithoriginaIimage:originaIimage];
    [self.imageView setImage:aspectFitImage];
    [self dismissViewControllerAnimated:YES completion:nil];
     */
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    KindEntity *selectedKindEntity = [self getKind];
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
    KindEntity *selectedKindEntity = [self getKind];
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
#pragma mark - Fetched Results Controller Section
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"KindEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"kindName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"performFetch error : %@", [error localizedDescription]);
        abort();
    }
    
    return _fetchedResultsController;
}

@end
