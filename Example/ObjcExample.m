//
//  ObjcExample.m
//  LotameDMP
//
//  Created by Dan Rusk on 10/7/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

#import "ObjcExample.h"

@import LotameDMP;

@implementation ObjcExample

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Call initialize before making any calls.
    [DMP initialize:@"25"];
    return YES;
}

- (void) addBehavior{
    [DMP addBehaviorData:@"value" forType:@"behaviorKey"];
}

- (void) sendBehavior{
    [DMP sendBehaviorData];
}

- (void) getAudience{
    [DMP getAudienceDataWithHandler:^(LotameProfile * _Nullable profile, BOOL success) {
        if (success) { //Check for success
            for (LotameAudience * audience in profile.audiences) { //Loop through each audience
                NSLog(@"%@", audience.jsonString);
            }
        }
    }];
}

- (void) sendBehaviorWithHandler{
    [DMP sendBehaviorDataWithHandler: ^(NSError * _Nullable error){
        if (error != nil){
            NSLog(@"error:: %@", error.description);
        } else {
            NSLog(@"sendBehaviorDataWithHandler success");
        }
    }];
}

@end
