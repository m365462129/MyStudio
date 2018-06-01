//
//  SDKForTABT.h
//  Unity-iPhone
//
//  Created by Apple on 2017/10/16.
//

#import "UnityAppController.h"
#import <UIKit/UIKit.h>
//#import <Foundation/Foundation.h>
#import "APOpenAPI.h"

@interface SDKForAliPay : NSObject{
    
}
//@property (strong, nonatomic) UIWindow *window;

+ (SDKForAliPay *) SharedInstance;
-(void)shareText:(const char *)json;
-(void)shareUrlImage:(const char *)json;
-(void)shareDataImage:(const char *)json;
-(void)sendWebByUrl:(const char *)json;
-(void)sendWebByData:(const char *)json;
@end
