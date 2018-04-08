//
//  CGLTypeViewController.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/9/30.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CGLTypeViewController.h"
#import "MBookAppDelegate.h"

#import "CategoryEntity.h"
#import "TypeEntity.h"

#import "CGLTypeCell.h"

#import "CGLDetailViewController.h"
#import "CGLAddTypeViewController.h"
#import "CGLEditTypeViewController.h"

@interface CGLTypeViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
- (IBAction)editType:(UIButton *)sender;

- (void)drawMarkAndColorInLayer:(CAShapeLayer *)shapeLayer withColor:(UIColor *)markColor;
- (void)performFetchAndReloadData;


@end

@implementation CGLTypeViewController

- (NSManagedObjectContext *)managedObjectContext {
    return [(MBookAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //set NavigationBar color
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1]];
    NSLog(@"%@", self.selectedCategoryEntity.categoryColor);
    
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
    if ([segue.identifier isEqualToString:@"goDetail"]) {
        CGLDetailViewController *detailViewController = segue.destinationViewController;
        TypeEntity *selectedTypeEntity = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        detailViewController.selectedTypeEntity = selectedTypeEntity;
    } else if ([segue.identifier isEqualToString:@"addType"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CGLAddTypeViewController *addTypeViewController = (CGLAddTypeViewController *)navigationController.topViewController;
        TypeEntity *addTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"TypeEntity" inManagedObjectContext:[self managedObjectContext]];
        addTypeViewController.selectedCategoryEntity = self.selectedCategoryEntity;
        addTypeViewController.addTypeEntity = addTypeEntity;
    } else if ([segue.identifier isEqualToString:@"editType"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CGLEditTypeViewController *editTypeViewController = (CGLEditTypeViewController *)navigationController.topViewController;
        
        editTypeViewController.editCategoryEntity = self.selectedCategoryEntity;
        editTypeViewController.editTypeEntity = sender;
    }
}

#pragma mark - Custom method
- (IBAction)editType:(UIButton *)sender {
    
    CGLTypeCell *selectedCell = (CGLTypeCell *)sender.superview.superview;
    static NSString *editCategoryIdentifier = @"editType";
    
    TypeEntity *editTypeEntity = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:selectedCell]];
    [self performSegueWithIdentifier:editCategoryIdentifier sender:editTypeEntity];
}

- (void)drawMarkAndColorInLayer:(CAShapeLayer *)shapeLayer withColor:(UIColor *)markColor {
    //Draw BezierPath
    UIBezierPath *markPath=[[UIBezierPath alloc] init];
    UIBezierPath *detailMarkPath=[[UIBezierPath alloc] init];
    [markPath appendPath:detailMarkPath];
    
    [markPath moveToPoint:CGPointMake(0, 0)];
    [markPath addLineToPoint:CGPointMake(26, 0)];
    [markPath addLineToPoint:CGPointMake(26, 30)];
    [markPath addLineToPoint:CGPointMake(13, 50)];
    [markPath addLineToPoint:CGPointMake(0, 30)];
    [markPath addLineToPoint:CGPointMake(0, 0)];
    
    shapeLayer.path=markPath.CGPath;
    
    shapeLayer.strokeColor=markColor.CGColor;
    shapeLayer.fillColor=markColor.CGColor;
    shapeLayer.lineWidth=1.0;
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
    NSLog(@"%lu", (unsigned long)[[self.fetchedResultsController sections] count]);
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
    static NSString *typeCellIdentifier = @"typeCell";
    CGLTypeCell *typeCell = [tableView dequeueReusableCellWithIdentifier:typeCellIdentifier];
    TypeEntity *typeEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    typeCell.typeLabel.text = typeEntity.typeName;
    //draw
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIColor *markColor = [NSKeyedUnarchiver unarchiveObjectWithData:self.selectedCategoryEntity.categoryColor];
    [self drawMarkAndColorInLayer:shapeLayer withColor:markColor];
    [typeCell.markView.layer addSublayer:shapeLayer];
    
    return typeCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectContext *context = [self managedObjectContext];
    TypeEntity *deleteTypeEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [context deleteObject:deleteTypeEntity];
    
    //save
    NSError *error;
    if ([context hasChanges]) {
        if (![context save:&error]) {
            NSLog(@"save delete error : %@", [error localizedDescription]);
            abort();
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Type";
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Fetched Results Controller Section
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TypeEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"typeName" ascending:YES];
    NSArray *sortDescriptions = [NSArray arrayWithObjects:sortDescription, nil];
    [fetchRequest setSortDescriptors:sortDescriptions];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category = %@", self.selectedCategoryEntity];
    [fetchRequest setPredicate:predicate];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
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
            TypeEntity *editTypeEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
            CGLTypeCell *cell = (CGLTypeCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.typeLabel.text = editTypeEntity.typeName;
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
