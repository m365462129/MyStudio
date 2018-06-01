//
//  TalkingDataMgr.h
//  Unity-iPhone
//
//  Created by Jyz on 2018/1/23.
//

#import <Foundation/Foundation.h>
#import "ProtoMgr.h"
#import "gameEnum.h"
#import "TalkingDataGA.h"
#import "ConfigInfo.h"
@interface TalkingDataMgr : NSObject{
//    NSDictionary* mLaunchOptions;
}
+ (TalkingDataMgr *) instance;
- (void)initSdk;
- (void)recvRquest:(UnityProtos)proto :(NSDictionary *)params;
@end
