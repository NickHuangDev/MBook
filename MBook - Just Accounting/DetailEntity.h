//
//  DetailEntity.h
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/11/13.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TypeEntity;

@interface DetailEntity : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * dateSectionYearAndMoth;
@property (nonatomic, retain) NSString * descriptions;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSString * dateSectionYear;
@property (nonatomic, retain) TypeEntity *type;

@end
