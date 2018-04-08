//
//  CGLAddTypeViewController.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/3.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CGLAddTypeViewController.h"
#import "TypeEntity.h"

@interface CGLAddTypeViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameField;
- (IBAction)saveType:(UIBarButtonItem *)sender;
- (IBAction)cancelAddType:(UIBarButtonItem *)sender;

@end

@implementation CGLAddTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (IBAction)saveType:(UIBarButtonItem *)sender {
    self.addTypeEntity.category = self.selectedCategoryEntity;
    self.addTypeEntity.typeName = self.nameField.text;
    [self saveAndDismiss];
}

- (IBAction)cancelAddType:(UIBarButtonItem *)sender {
    [self cancelAndDismiss];
}
@end
