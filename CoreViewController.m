//
//  CoreViewController.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/9/25.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CoreViewController.h"
#import "MBookAppDelegate.h"

@interface CoreViewController ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation CoreViewController

- (NSManagedObjectContext *)managedObjectContext {
    return [(MBookAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)saveAndDismiss {
    NSError *error;
    
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Save Failed : %@", [error localizedDescription]);
        }else {
            NSLog(@"Save Successed");
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)cancelAndDismiss {
    [self.managedObjectContext rollback];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
