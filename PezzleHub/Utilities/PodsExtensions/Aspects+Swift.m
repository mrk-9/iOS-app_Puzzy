//
//  Aspects+Swift.m
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/3/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

#import "Aspects+Swift.h"

@implementation NSObject (AspectsSwift)

+ (id<AspectToken>)aspect_hookSelector:(SEL)selector withOptions:(AspectOptions)options usingAspectBlock:(AspectsHookActionBlock)block error:(NSError **)error {
    
    return [self aspect_hookSelector:selector withOptions:options usingBlock:block error:error];
}

@end
