//
//  CategoryEntity.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/1.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KindEntity, TypeEntity;

@interface CategoryEntity : NSManagedObject

@property (nonatomic, retain) NSData * categoryColor;
@property (nonatomic, retain) NSString * categoryIconPath;
@property (nonatomic, retain) NSString * categoryName;
@property (nonatomic, retain) KindEntity *kind;
@property (nonatomic, retain) NSSet *types;
@end

@interface CategoryEntity (CoreDataGeneratedAccessors)

- (void)addTypesObject:(TypeEntity *)value;
- (void)removeTypesObject:(TypeEntity *)value;
- (void)addTypes:(NSSet *)values;
- (void)removeTypes:(NSSet *)values;

@end
