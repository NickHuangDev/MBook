//
//  DetailEntity.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/11/13.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "DetailEntity.h"
#import "TypeEntity.h"


@interface DetailEntity()

@property (nonatomic) NSDate *primitiveDate;
@property (nonatomic) NSString *primitiveDateSectionYear;
@property (nonatomic) NSString *primitiveDateSectionYearAndMonth;

@end

@implementation DetailEntity

@dynamic date;
@dynamic descriptions;
@dynamic imagePath;
@dynamic price;
@dynamic dateSectionYear;
@dynamic dateSectionYearAndMoth;
@dynamic type;
@dynamic primitiveDate;
@dynamic primitiveDateSectionYear;
@synthesize primitiveDateSectionYearAndMonth;

#pragma mark - Transient properties

- (NSString *)dateSectionYear
{
    // Create and cache the section identifier on demand.
    
    [self willAccessValueForKey:@"dateSectionYear"];
    NSString *tmp = [self primitiveDateSectionYear];
    [self didAccessValueForKey:@"dateSectionYear"];
    
    if (!tmp)
    {
        /*
         Sections are organized by month and year. Create the section identifier as a string representing the number (year * 1000) + month; this way they will be correctly ordered chronologically regardless of the actual name of the month.
         */
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[self date]];
        tmp = [NSString stringWithFormat:@"%d", [components year]];
        [self setPrimitiveDateSectionYear:tmp];
    }
    return tmp;
}

- (NSString *)dateSectionYearAndMoth
{
    // Create and cache the section identifier on demand.
    
    [self willAccessValueForKey:@"dateSectionYearAndMonth"];
    NSString *tmp = [self primitiveDateSectionYearAndMonth];
    [self didAccessValueForKey:@"dateSectionYearAndMonth"];
    
    if (!tmp)
    {
        /*
         Sections are organized by month and year. Create the section identifier as a string representing the number (year * 1000) + month; this way they will be correctly ordered chronologically regardless of the actual name of the month.
         */
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[self date]];
        tmp = [NSString stringWithFormat:@"%d", ([components year] * 1000) + [components month]];
        [self setPrimitiveDateSectionYearAndMonth:tmp];
    }
    return tmp;
}


#pragma mark - Time stamp setter

- (void)setDate:(NSDate *)newDate
{
    // If the time stamp changes, the section identifier become invalid.
    [self willChangeValueForKey:@"date"];
    [self setPrimitiveDate:newDate];
    [self didChangeValueForKey:@"date"];
    
    
    [self setPrimitiveDateSectionYear:nil];
    [self setPrimitiveDateSectionYearAndMonth:nil];
}


#pragma mark - Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingdateSection
{
    // If the value of date changes, the section identifier may change as well.
    return [NSSet setWithObject:@"date"];
}



@end
