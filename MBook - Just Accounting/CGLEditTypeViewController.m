//
//  CGLEditTypeViewController.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/11.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CGLEditTypeViewController.h"

#import "TypeEntity.h"

@interface CGLEditTypeViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameField;
- (IBAction)saveType:(UIBarButtonItem *)sender;
- (IBAction)cancelEditType:(UIBarButtonItem *)sender;

@end

@implementation CGLEditTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameField.text = self.editTypeEntity.typeName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)saveType:(UIBarButtonItem *)sender {
    self.editTypeEntity.category = self.editCategoryEntity;
    self.editTypeEntity.typeName = self.nameField.text;
    
    [self saveAndDismiss];
}

- (IBAction)cancelEditType:(UIBarButtonItem *)sender {
    [self cancelAndDismiss];
}
@end
