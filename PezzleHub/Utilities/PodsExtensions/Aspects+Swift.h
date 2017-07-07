//
//  Aspects+Swift.h
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/3/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Aspects/Aspects.h>

/// Since Swift doesn't allow passing closure as AnyObject..
typedef void (^AspectsHookActionBlock)(id<AspectInfo> aspectInfo);

@interface NSObject (AspectsSwift)

+ (id<AspectToken>)aspect_hookSelector:(SEL)selector withOptions:(AspectOptions)options usingAspectBlock:(AspectsHookActionBlock)block error:(NSError **)error;

@end
