//
//  TypeEntity.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/1.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CategoryEntity, DetailEntity;

@interface TypeEntity : NSManagedObject

@property (nonatomic, retain) NSString * typeName;
@property (nonatomic, retain) CategoryEntity *category;
@property (nonatomic, retain) NSSet *details;
@end

@interface TypeEntity (CoreDataGeneratedAccessors)

- (void)addDetailsObject:(DetailEntity *)value;
- (void)removeDetailsObject:(DetailEntity *)value;
- (void)addDetails:(NSSet *)values;
- (void)removeDetails:(NSSet *)values;

@end
