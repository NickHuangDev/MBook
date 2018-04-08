//
//  ChartViewController.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/31.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "ChartViewController.h"
#import "MBookAppDelegate.h"

//Entity
#import "KindEntity.h"
#import "CategoryEntity.h"
#import "TypeEntity.h"
#import "DetailEntity.h"

#import "DLPieChart.h"

//Cell
#import "ChartCell.h"

@interface ChartViewController ()<DLPieChartDataSource, DLPieChartDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet UISegmentedControl *kindSegment;
@property (strong, nonatomic) IBOutlet DLPieChart *pieChart;

@property (strong, nonatomic) NSMutableArray *dateDataArray;

@property (strong, nonatomic) KindEntity *selectedKindEntity;

//Chart Data
@property (strong, nonatomic) NSMutableArray *chartDetailArray;

- (void)performFetchAndReloadData;
- (KindEntity *)getKind;
@end

@implementation ChartViewController

- (NSManagedObjectContext *)managedObjectContext {
    return [(MBookAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set kindSegment's border
    self.kindSegment.layer.borderColor = [[UIColor colorWithRed:201.0/255 green:201.0/255 blue:205.0/255 alpha:0.5] CGColor];
    self.kindSegment.layer.borderWidth = 1.0f;
    self.kindSegment.layer.cornerRadius = 8;
    //set kindSegment
    [self.kindSegment addTarget:self action:@selector(changeKind:) forControlEvents:UIControlEventValueChanged];
    self.selectedKindEntity = [self getKind];
    
    //save Chart Data
    NSArray *sectionInfoArray = [self.fetchedResultsController sections];
    self.chartDetailArray = [NSMutableArray arrayWithCapacity:[sectionInfoArray count]];
    
    NSUInteger Index = 0;
    for (id<NSFetchedResultsSectionInfo> sectionInfo in sectionInfoArray) {
        //Dictionary Capacity 3 : name and detail array and color
        NSMutableDictionary *chartDetailDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        //insert name and details and color
        UIColor *chartColor = [UIColor colorWithRed:(rand()%255)/255.0 green:(rand()%255)/255.0 blue:(rand()%255)/255.0 alpha:1.0];
        [chartDetailDictionary setObject:[sectionInfo name] forKey:@"name"];
        [chartDetailDictionary setObject:[sectionInfo objects] forKey:@"details"];
        [chartDetailDictionary setObject:chartColor forKey:@"color"];
        
        [self.chartDetailArray insertObject:chartDetailDictionary atIndex:Index];

        NSLog(@"%@", self.chartDetailArray);
        Index ++;
    }

    NSLog(@"%@", self.chartDetailArray);
    //piechart
    self.pieChart.delegate = self;
    self.pieChart.dataSource = self;
    
    [self performFetchAndReloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pieChart reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if (![kindEntity.kindName isEqualToString:[self.kindSegment titleForSegmentAtIndex:self.kindSegment.selectedSegmentIndex]]) {
        kindEntity = [kindEntityArray lastObject];
    }
    
    return kindEntity;
}

- (void)performFetchAndReloadData {
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"performFetch error : %@", [error localizedDescription]);
        abort();
    }
    [self.tableView reloadData];
}

- (void)changeKind:(UISegmentedControl *)kindSegment {
    self.selectedKindEntity = [self getKind];
}

#pragma mark - DLPieChartDataSource
- (NSUInteger)numberOfSlicesInPieChart:(DLPieChart *)pieChart {
    return [self.chartDetailArray count];
}

- (CGFloat)pieChart:(DLPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    NSDictionary *chartDetailDictionary = [self.chartDetailArray objectAtIndex:index];
    float priceFloat = 0;
    for (DetailEntity *detailEntity in [chartDetailDictionary objectForKey:@"details"]) {
        NSLog(@"%f", [detailEntity.price floatValue]);
        priceFloat += [detailEntity.price floatValue];
    }
    
    return priceFloat;
}

- (UIColor *)pieChart:(DLPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    NSDictionary *chartDetailDictionary = [self.chartDetailArray objectAtIndex:index];
    return [chartDetailDictionary objectForKey:@"color"];
}
- (NSString *)pieChart:(DLPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index {
    NSLog(@"%li", index);
    NSDictionary *chartDetailDictionary = [self.chartDetailArray objectAtIndex:index];
    NSLog(@"%@", [chartDetailDictionary objectForKey:@"name"]);
    return [chartDetailDictionary objectForKey:@"name"];
}
#pragma mark - DLPieChartDelegate
- (void)pieChart:(DLPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index {
    
}
- (void)pieChart:(DLPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index {
    
}
- (void)pieChart:(DLPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index {
    
}
- (void)pieChart:(DLPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index {
    
}

/*
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"chartCell";
    ChartCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
}
 */
#pragma mark - UITableViewDelegate

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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type.category.kind = %@", self.selectedKindEntity];
    [fetchRequest setPredicate:predicate];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"dateSectionYear" cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"performFetch error : %@", [error localizedDescription]);
        abort();
    }
    
    return _fetchedResultsController;
}
@end
