//
//  CGLDetailViewController.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/9/30.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CGLDetailViewController.h"
#import "MBookAppDelegate.h"

#import "CategoryEntity.h"
#import "TypeEntity.h"
#import "DetailEntity.h"

#import "CGLDetailCell.h"

#import "CGLEditDetailViewController.h"
#import "CGLSearchDetailViewController.h"

@interface CGLDetailViewController () <CGLSearchDetailViewDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

-(NSString *)convertDateToDateString:(NSDate *)date;
- (void)performFetchAndReloadData;
@end

@implementation CGLDetailViewController

- (NSManagedObjectContext *)managedObjectContext {
    return [(MBookAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //set NavigationBar color
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1]];
    NSLog(@"%@", self.tableView.superview);
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"performFetch error : %@", [error localizedDescription]);
        abort();
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self performFetchAndReloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editDetail"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CGLEditDetailViewController *editDetailViewController = (CGLEditDetailViewController *)navigationController.topViewController;
        
        DetailEntity *selectedDetailEntity = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        
        editDetailViewController.selectedDetailEntity = selectedDetailEntity;
    }if ([segue.identifier isEqualToString:@"searchDetail"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CGLSearchDetailViewController *searchDetailViewController = (CGLSearchDetailViewController *)navigationController.topViewController;
        
        searchDetailViewController.delegate = self;
    }
}

#pragma mark - Custom Method
-(NSString *)convertDateToDateString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:date];
}

- (void)performFetchAndReloadData {
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"performFetch error : %@", [error localizedDescription]);
        abort();
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%@", [[(NSArray *)[self.fetchedResultsController sections] objectAtIndex:0] indexTitle]);
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *detailCellIdentifier = @"detailCell";
    CGLDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:detailCellIdentifier];
    DetailEntity *detailEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    detailCell.priceLabel.text = [detailEntity.price stringValue];
    detailCell.dateLabel.text = [self convertDateToDateString:detailEntity.date];
    detailCell.categoryTypeLabel.text = [NSString stringWithFormat:@"%@-%@", detailEntity.type.category.categoryName, detailEntity.type.typeName];
    return detailCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self managedObjectContext];
        DetailEntity *deleteDetailEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [context deleteObject:deleteDetailEntity];
        
        //save
        NSError *error;
        if ([context hasChanges]) {
            if (![context save:&error]) {
                NSLog(@"save delete error : %@", [error localizedDescription]);
                abort();
            }
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    /*
     Section information derives from an event's sectionIdentifier, which is a string representing the number (year * 1000) + month.
     To display the section title, convert the year and month components to a string representation.
     */
    static NSDateFormatter *formatter = nil;
    
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        
        NSString *formatTemplate = [NSDateFormatter dateFormatFromTemplate:@"MMMM YYYY" options:0 locale:[NSLocale currentLocale]];
        [formatter setDateFormat:formatTemplate];
    }
    
    NSInteger numericSection = [[theSection name] integerValue];
    NSInteger year = numericSection / 1000;
    NSInteger month = numericSection - (year * 1000);
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = year;
    dateComponents.month = month;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    NSString *titleString = [formatter stringFromDate:date];
    
    return titleString;

}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - CGLSearchDetailViewDelegate
- (void)searchDetailViewController:(CGLSearchDetailViewController *)searchDetailViewController inputMinPrice:(NSDecimalNumber *)minPrice inputMaxPrice:(NSDecimalNumber *)maxPrice inputStartDate:(NSDate *)startDate inputEndDate:(NSDate *)endDate descriptionContainCharacters:(NSString *)descriptionCharacter {
    NSLog(@"%@\n%@\n%@\n%@\n%@\n", minPrice, maxPrice, startDate, endDate, descriptionCharacter);
    
    [self.fetchedResultsController.fetchRequest setPredicate:nil];
    
    NSPredicate *predicate = [[NSPredicate alloc] init];
    if (descriptionCharacter.length == 0) {
        predicate = [NSPredicate predicateWithFormat:@"type = %@ AND price BETWEEN{%@, %@} AND date BETWEEN{%@, %@}", self.selectedTypeEntity, minPrice, maxPrice, startDate, endDate];
    }else {
    predicate = [NSPredicate predicateWithFormat:@"type = %@ AND price BETWEEN{%@, %@} AND date BETWEEN{%@, %@} AND descriptions contains[cd] %@", self.selectedTypeEntity, minPrice, maxPrice, startDate, endDate, descriptionCharacter];
    }
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    [self performFetchAndReloadData];
}


#pragma mark - Fetched Results Controller Section
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequset = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DetailEntity" inManagedObjectContext:context];
    [fetchRequset setEntity:entityDescription];
    
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *sortDescriptions = [NSArray arrayWithObjects:sortDescription, nil];
    [fetchRequset setSortDescriptors:sortDescriptions];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", self.selectedTypeEntity];
    [fetchRequset setPredicate:predicate];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequset managedObjectContext:context sectionNameKeyPath:@"dateSectionYearAndMonth" cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
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
            CGLDetailCell *detailCell = (CGLDetailCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            detailCell.priceLabel.text = [editDetailEntity.price stringValue];
            detailCell.dateLabel.text = [self convertDateToDateString:editDetailEntity.date];
            detailCell.categoryTypeLabel.text = [NSString stringWithFormat:@"%@-%@", editDetailEntity.type.category.categoryName, editDetailEntity.type.typeName];
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
