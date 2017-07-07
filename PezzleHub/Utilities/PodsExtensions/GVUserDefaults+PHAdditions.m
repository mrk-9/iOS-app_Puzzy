//
//  GVUserDefaults+PHAdditions.m
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/3/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

#import "GVUserDefaults+PHAdditions.h"

@implementation GVUserDefaults (PHAdditions)

@dynamic bundleAppVersionInfo;
@dynamic displaySpeed;
@dynamic notificationEnabled;
@dynamic chapterDeliveryDateInfo;
@dynamic chapterAsReadPieces;

#pragma mark - Utility
- (NSString *)transformKey:(NSString *)key {
    
    if ([key isEqualToString:@"bundleAppVersionInfo"]) {
        return @"app_version_info"; // This key is for Settings app (see: Settings.bundle/Root.plist)
    }
    
    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;
    return [NSString stringWithFormat:@"%@.%@", bundleID, key];
}

- (NSDictionary *)setupDefaults {
    return @{
             @"registeredCources": @[],
             @"displaySpeed": @1.6f,
             @"chapterDeliveryDateInfo": @{},
             @"chapterAsReadPieces": @{},
             @"notificationEnabled": @(YES),
            };
}

- (void)resetUserDefaults {
    
    NSDictionary *defaultValues = [self setupDefaults];
    
    for (NSString *key in defaultValues.allKeys) {
        
        if ([self respondsToSelector:NSSelectorFromString(key)]) {
            
            id value = defaultValues[key];
            [self setValue:value forKey:key];
        }
    }
}

#pragma mark - 
- (void)setChapterDeliveryDate:(NSDictionary *)courseInfo nextDeliveryDateString:(NSString *)nextDeliveryDateString forCourse:(NSInteger)courseID {

    NSString *key = [NSString stringWithFormat:@"%ld", (long)courseID];
    
    NSMutableDictionary *tempDictionary = self.chapterDeliveryDateInfo.mutableCopy;
    tempDictionary[key] = @{
                            @"course": courseInfo,
                            @"next_delivery_date": nextDeliveryDateString,
                            };

    self.chapterDeliveryDateInfo = tempDictionary;
}

- (void)removeChapterDeliveryDateForCourse:(NSInteger)courseID {

    NSString *key = [NSString stringWithFormat:@"%ld", (long)courseID];

    NSMutableDictionary *tempDictionary = self.chapterDeliveryDateInfo.mutableCopy;
    [tempDictionary removeObjectForKey:key];
    
    self.chapterDeliveryDateInfo = tempDictionary;
}

- (nullable NSNumber *)asReadPieceIDInChapter:(NSInteger)chapterID {

    NSString *key = [NSString stringWithFormat:@"%ld", (long)chapterID];

    return self.chapterAsReadPieces[key];
}

- (void)setChapterAsReadPiece:(NSInteger)chapterID pieceID:(NSInteger)pieceID {
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)chapterID];
    
    NSMutableDictionary *tempDictionary = self.chapterAsReadPieces.mutableCopy;
    tempDictionary[key] = @(pieceID);
    
    self.chapterAsReadPieces = tempDictionary;
}

- (void)removeChapterAsReadPiece:(NSInteger)chapterID {
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)chapterID];
    
    NSMutableDictionary *tempDictionary = self.chapterAsReadPieces.mutableCopy;
    [tempDictionary removeObjectForKey:key];
    
    self.chapterAsReadPieces = tempDictionary;
}

@end
