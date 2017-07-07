//
//  GVUserDefaults+PHAdditions.h
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/3/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

#import <GVUserDefaults/GVUserDefaults.h>

@interface GVUserDefaults (PHAdditions)

@property (nonatomic, retain) NSString *bundleAppVersionInfo;
@property (nonatomic) float displaySpeed;
@property (nonatomic) BOOL notificationEnabled;

/// This property stores subscribed chapters' delivery times, because the delivery time depends on the client side.
/// The key is course_id (string), it doesn't care which chapter is delivered because it's possible that the owner insert a new chapter while a subscriber is waiting the delivery.
@property (nonatomic, retain) NSDictionary *chapterDeliveryDateInfo;

@property (nonatomic, retain) NSDictionary *chapterAsReadPieces;

- (void)resetUserDefaults;

- (void)setChapterDeliveryDate:(NSDictionary *)courseInfo nextDeliveryDateString:(NSString *)nextDeliveryDateString forCourse:(NSInteger)courseID;
- (void)removeChapterDeliveryDateForCourse:(NSInteger)courseID;

- (nullable NSNumber *)asReadPieceIDInChapter:(NSInteger)chapterID;
- (void)setChapterAsReadPiece:(NSInteger)chapterID pieceID:(NSInteger)pieceID;
- (void)removeChapterAsReadPiece:(NSInteger)chapterID;

@end
