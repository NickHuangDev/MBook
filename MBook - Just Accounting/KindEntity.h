//
//  KindEntity.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/1.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CategoryEntity;

@interface KindEntity : NSManagedObject

@property (nonatomic, retain) NSString * kindName;
@property (nonatomic, retain) NSSet *categorys;
@end

@interface KindEntity (CoreDataGeneratedAccessors)

- (void)addCategorysObject:(CategoryEntity *)value;
- (void)removeCategorysObject:(CategoryEntity *)value;
- (void)addCategorys:(NSSet *)values;
- (void)removeCategorys:(NSSet *)values;

@end
