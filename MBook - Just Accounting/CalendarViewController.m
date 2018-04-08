//
//  CalendarViewController.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/27.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CalendarViewController.h"
#import "MBookAppDelegate.h"

#import "CalendarEditViewController.h"

#import "MBCalendar.h"
#import "CalendarCell.h"

//Entity
#import "KindEntity.h"
#import "CategoryEntity.h"
#import "TypeEntity.h"
#import "DetailEntity.h"


@interface CalendarViewController () <MBCalendarDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) KindEntity *selectedKindEntity;

@property (strong, nonatomic) IBOutlet UISegmentedControl *kindSegment;
@property (strong, nonatomic) IBOutlet MBCalendar *calendar;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (assign, nonatomic) BOOL isSelectedDate;
- (KindEntity *)getKind;
- (void)setPredicateWithKindAndDate;
- (void)performFetchAndReloadData;
- (NSString *)convertDateToDateString:(NSDate *)date;

@end

@implementation CalendarViewController
- (NSManagedObjectContext *)managedObjectContext {
    return [(MBookAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //set isSelectedDate
    self.isSelectedDate = NO;
    //set NavigationBar color
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1]];
    //set kindSegment's border
    self.kindSegment.layer.borderColor = [[UIColor colorWithRed:201.0/255 green:201.0/255 blue:205.0/255 alpha:0.5] CGColor];
    self.kindSegment.layer.borderWidth = 1.0f;
    self.kindSegment.layer.cornerRadius = 8;
    //set kindSegment
    [self.kindSegment addTarget:self action:@selector(changeKind:) forControlEvents:UIControlEventValueChanged];
    self.selectedKindEntity = [self getKind];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //set Calendar
    self.calendar = [[MBCalendar alloc] initWithFrame:self.calendar.frame];
    self.calendar.date = [NSDate date];
    self.calendar.delegate = self;
    [self.tableView addSubview:self.calendar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editDetail"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CalendarEditViewController *editViewController = (CalendarEditViewController *)navigationController.topViewController;
        
        DetailEntity *selectedDetailEntity = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        editViewController.selectedDetailEntity = selectedDetailEntity;
    }
}
#pragma mark - Custom Method
- (KindEntity *)getKind {
    //catch Kind
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [self managedObjectContext];
    //entity
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"KindEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    //Description
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"kindName" ascending:YES];
    NSArray *sortDescriptions = [NSArray arrayWithObjects:sortDescription, nil];
    [fetchRequest setSortDescriptors:sortDescriptions];
    //fetchedResultsController
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    //performFetch
    NSError *error;
    if(![fetchedResultsController performFetch:&error]) {
        NSLog(@"performFetch error : %@", [error localizedDescription]);
        abort();
    }
    NSArray *kindEntityArray = [fetchedResultsController fetchedObjects];
    KindEntity *kindEntity = [kindEntityArray firstObject];
    NSLog(@"%@", kindEntity);
    if (![kindEntity.kindName isEqualToString:[self.kindSegment titleForSegmentAtIndex:self.kindSegment.selectedSegmentIndex]]) {
        kindEntity = [kindEntityArray lastObject];
    }
    
    return kindEntity;
}

- (void)setPredicateWithKindAndDate {
    self.isSelectedDate = YES;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type.category.kind = %@ AND date BETWEEN{%@, %@}", self.selectedKindEntity, self.startDate, self.endDate];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    [self performFetchAndReloadData];
}

- (void)performFetchAndReloadData {
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"performFetch error : %@", [error localizedDescription]);
        abort();
    }
    [self.tableView reloadData];
}

- (NSString *)convertDateToDateString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:date];
}

- (void)changeKind:(UISegmentedControl *)kindSegment {
    self.selectedKindEntity = [self getKind];
    //set isSelectedDate
    self.isSelectedDate = NO;
    [self setPredicateWithKindAndDate];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSelectedDate) {
        return [[self.fetchedResultsController sections] count];
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo>sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *calendarIdentifier = @"calendarCell";
    CalendarCell *calendarCell = [tableView dequeueReusableCellWithIdentifier:calendarIdentifier];
    DetailEntity *detailEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    calendarCell.priceLabel.text = [detailEntity.price stringValue];
    calendarCell.dateLabel.text = [self convertDateToDateString:detailEntity.date];
    calendarCell.categoryTypeLabel.text = [NSString stringWithFormat:@"%@-%@", detailEntity.type.category.categoryName, detailEntity.type.typeName];
    return calendarCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *detailArray = [self.fetchedResultsController fetchedObjects];
    CGFloat priceFloat = 0;
    for (DetailEntity *detailEntity in detailArray) {
        priceFloat += [detailEntity.price floatValue];
    }
    
    NSString *totalPriceString = [NSString stringWithFormat:@"Detail Total : $%f", priceFloat];
    return totalPriceString;
}

#pragma mark - UITableViewDelegate

#pragma mark - MBCalendarDelegate
- (void)calendar:(MBCalendar *)calendar didSelectedStartDate:(NSDate *)startDate didSelectedEndDate:(NSDate *)endDate {
    [self setStartDate:startDate];
    [self setEndDate:endDate];
    [self setPredicateWithKindAndDate];
}

#pragma mark - Fetched Results Controller Section
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DetailEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
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

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            DetailEntity *editDetailEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
            CalendarCell *calendarCell = (CalendarCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            calendarCell.priceLabel.text = [editDetailEntity.price stringValue];
            calendarCell.dateLabel.text = [self convertDateToDateString:editDetailEntity.date];
            calendarCell.categoryTypeLabel.text = [NSString stringWithFormat:@"%@-%@", editDetailEntity.type.category.categoryName, editDetailEntity.type.typeName];
        }
            break;
            
        default:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    UITableView *tableView = self.tableView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
