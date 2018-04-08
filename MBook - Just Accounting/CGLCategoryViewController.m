//
//  CGLCategoryViewController.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/9/29.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CGLCategoryViewController.h"
#import "MBookAppDelegate.h"

#import "KindEntity.h"
#import "CategoryEntity.h"
#import "TypeEntity.h"
#import "CGLCategoryCell.h"

#import "CGLTypeViewController.h"
#import "CGLAddCategoryViewController.h"
#import "CGLEditCategoryViewController.h"

@interface CGLCategoryViewController ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) IBOutlet UISegmentedControl *kindSegment;

@property (strong, nonatomic) KindEntity *selectedKindEntity;

- (IBAction)actionCategory:(UIButton *)sender;
- (void)drawMarkAndColorInLayer:(CAShapeLayer *)shapeLayer withColor:(UIColor *)markColor;
- (void)performFetchAndReloadData;

@end

@implementation CGLCategoryViewController
- (NSManagedObjectContext *)managedObjectContext {
    return [(MBookAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //set NavigationBar color
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1]];
    //set kindSegment's border
    self.kindSegment.layer.borderColor = [[UIColor colorWithRed:201.0/255 green:201.0/255 blue:205.0/255 alpha:0.5] CGColor];
    self.kindSegment.layer.borderWidth = 1.0f;
    self.kindSegment.layer.cornerRadius = 8;
    //kind
    [self.kindSegment addTarget:self action:@selector(checkKind:) forControlEvents:UIControlEventValueChanged];
    [self checkKind:self.kindSegment];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self performFetchAndReloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addCategory"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CGLAddCategoryViewController *addCategoryViewContoller = (CGLAddCategoryViewController *)navigationController.topViewController;
        CategoryEntity *addCategoryEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CategoryEntity" inManagedObjectContext:[self managedObjectContext]];
        addCategoryViewContoller.selectedKindEntity = self.selectedKindEntity;
        addCategoryViewContoller.addCategoryEntity = addCategoryEntity;
    }else if ([segue.identifier isEqualToString:@"goType"]) {
        CGLTypeViewController *typeViewController = segue.destinationViewController;
        CategoryEntity *selectedCategoryEntity = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        typeViewController.selectedCategoryEntity = selectedCategoryEntity;
    }else if ([segue.identifier isEqualToString:@"editCategory"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CGLEditCategoryViewController *editCategoryViewController = (CGLEditCategoryViewController *)navigationController.topViewController;
        
        editCategoryViewController.editKindEntity = self.selectedKindEntity;
        editCategoryViewController.editCategoryEntity = sender;
    }
}

#pragma mark - Custom method

- (IBAction)actionCategory:(UIButton *)sender {
    CGLCategoryCell *selectedCell = (CGLCategoryCell *)sender.superview.superview;
    static NSString *editCategoryIdentifier = @"editCategory";
    
    CategoryEntity *editCategoryEntity = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:selectedCell]];
    
    [self performSegueWithIdentifier:editCategoryIdentifier sender:editCategoryEntity];
        
    
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

- (void)checkKind:(UISegmentedControl *)segment {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"KindEntity" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entityDescription];
    
    NSSortDescriptor *sortDecription = [NSSortDescriptor sortDescriptorWithKey:@"kindName" ascending:YES];
    NSArray *sortDecriptions = [NSArray arrayWithObjects:sortDecription, nil];
    
    [fetchRequest setSortDescriptors:sortDecriptions];
    
    //catchKindEntity
    NSError *error;
    NSArray *kindEntityArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    //checkKindEntity
    KindEntity *selectedKindEntity = [kindEntityArray firstObject];
    if (![selectedKindEntity.kindName isEqualToString:[self.kindSegment titleForSegmentAtIndex:self.kindSegment.selectedSegmentIndex]]) {
        selectedKindEntity = [kindEntityArray lastObject];
    }
    self.selectedKindEntity = selectedKindEntity;
    [self.fetchedResultsController.fetchRequest setPredicate:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kind = %@", self.selectedKindEntity];
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *categoryCellIdentifier = @"categoryCell";
    CGLCategoryCell *categoryCell = [tableView dequeueReusableCellWithIdentifier:categoryCellIdentifier];
    CategoryEntity *categoryEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    categoryCell.categoryLabel.text = categoryEntity.categoryName;
    categoryCell.typeLabel.text = @"";
    for (TypeEntity *typeEntity in [categoryEntity.types allObjects]) {
        categoryCell.typeLabel.text = [[categoryCell.typeLabel.text stringByAppendingString:typeEntity.typeName] stringByAppendingString:@" "];
    }
    //draw mark
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIColor *markColor = [NSKeyedUnarchiver unarchiveObjectWithData:categoryEntity.categoryColor];
    [self drawMarkAndColorInLayer:shapeLayer withColor:markColor];
    [categoryCell.markView.layer addSublayer:shapeLayer];
    
    return categoryCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self managedObjectContext];
        CategoryEntity *deleteCategoryEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:deleteCategoryEntity];
        
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
    return @"Category";
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
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CategoryEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"categoryName" ascending:YES];
    NSArray *sortDescriptions = [NSArray arrayWithObjects:sortDescription, nil];
    [fetchRequest setSortDescriptors:sortDescriptions];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kind = %@", self.selectedKindEntity];
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
    UITableView *tableview = self.tableView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            CategoryEntity *changeCategoryEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
            CGLCategoryCell *categoryCell = (CGLCategoryCell *)[tableview cellForRowAtIndexPath:indexPath];
            categoryCell.categoryLabel.text = changeCategoryEntity.categoryName;
            categoryCell.typeLabel.text = @"";
            for (TypeEntity *typeEntity in [changeCategoryEntity.types allObjects]) {
                categoryCell.typeLabel.text = [[categoryCell.typeLabel.text stringByAppendingString:typeEntity.typeName] stringByAppendingString:@" "];
            }
            //draw mark
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            UIColor *markColor = [NSKeyedUnarchiver unarchiveObjectWithData:changeCategoryEntity.categoryColor];
            [self drawMarkAndColorInLayer:shapeLayer withColor:markColor];
            [categoryCell.markView.layer addSublayer:shapeLayer];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            
    }

}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}
@end
