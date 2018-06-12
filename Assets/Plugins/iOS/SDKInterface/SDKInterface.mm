/**
 *    功能描述: iOS SdkInterface
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SDKForWechat.h"
#import "SDKMain.h"
#import "SDKForAliPay.h"
#import "SDKForXianLiao.h"
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>
#import "IAPManager.h"
//#import "SDKForTABT.h"
#import "ProtoMgr.h"

#define MakeStringCopyA( _x_ ) ( _x_ != NULL && [_x_ isKindOfClass:[NSString class]] ) ? strdup( [_x_ UTF8String] ) : NULL


@interface SDKInterface : NSObject
{
    
}
@end

@implementation SDKInterface

static SDKInterface * instance = nil;
static IAPManager *iapManager = nil;

+(SDKInterface *) SharedInstance
{
    if (instance == nil)
    {
        instance = [[SDKInterface alloc] init];
    }
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    
    return self;
}


@end


//实现对外接口, C#调用Objective C;
#if defined(__cplusplus)
extern "C"{
#endif
    
    char* MakeStringCopy (const char* string)
    {
        if (string == NULL)
        {
            return NULL;
        }
        
        char* res = (char*)malloc(strlen(string) + 1);
        strcpy(res, string);
        return res;
    }
    
    const char* getIPv6(const char *mHost)
    {
        if( nil == mHost )
            return NULL;
        const char *newChar = "No";
        const char *cause = NULL;
        struct addrinfo* res0;
        struct addrinfo hints;
        struct addrinfo* res;
        int n, s;
        
        memset(&hints, 0, sizeof(hints));
        
        hints.ai_flags = AI_DEFAULT;
        hints.ai_family = PF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;
        
        if((n=getaddrinfo(mHost, "http", &hints, &res0))!=0)
        {
            printf("getaddrinfo error: %s\n",gai_strerror(n));
            return NULL;
        }
        
        struct sockaddr_in6* addr6;
        struct sockaddr_in* addr;
        NSString * NewStr = NULL;
        char ipbuf[32];
        s = -1;
        for(res = res0; res; res = res->ai_next)
        {
            if (res->ai_family == AF_INET6)
            {
                addr6 =( struct sockaddr_in6*)res->ai_addr;
                newChar = inet_ntop(AF_INET6, &addr6->sin6_addr, ipbuf, sizeof(ipbuf));
                NSString * TempA = [[NSString alloc] initWithCString:(const char*)newChar
                                                            encoding:NSASCIIStringEncoding];
                NSString * TempB = [NSString stringWithUTF8String:"&&ipv6"];
                
                NewStr = [TempA stringByAppendingString: TempB];
                printf("%s\n", newChar);
            }
            else
            {
                addr =( struct sockaddr_in*)res->ai_addr;
                newChar = inet_ntop(AF_INET, &addr->sin_addr, ipbuf, sizeof(ipbuf));
                NSString * TempA = [[NSString alloc] initWithCString:(const char*)newChar
                                                            encoding:NSASCIIStringEncoding];
                NSString * TempB = [NSString stringWithUTF8String:"&&ipv4"];
                
                NewStr = [TempA stringByAppendingString: TempB];
                printf("%s\n", newChar);
            }
            break;
        }
        
        
        freeaddrinfo(res0);
        
        printf("getaddrinfo OK");
        
        NSString * mIPaddr = NewStr;
        return MakeStringCopyA(mIPaddr);
    }
    
    void IosLogin()
    {
    }
    
    void _jpushStopPush(const char * param)
    {
        [[SDKForWechat SharedInstance] JpushStopPush:param];
    }
    
    void IosPayment(const char * json)
    {
        [[SDKForWechat SharedInstance] Recharge:json];
    }
    
    void IosCommonRecharge(const char * json)
    {
        //        [[SDKForTABT SharedInstance] Recharge:json];
    }
    
    const char * IosGetIDFA()
    {
        return MakeStringCopy("");
    }
    
    const char * IosGetIpv6(const char * ipv4)
    {
        return MakeStringCopy(getIPv6(ipv4));
    }
    
    const char * IosGetDataFromKeychain(const char * key)
    {
        return MakeStringCopy("");
    }
    
    
    bool IosSaveDataToKeychain(const char * key, const char * data)
    {
        return false;
    }
    
    const char * IosGetThirdPlatformName()
    {
#ifdef AppStore
        return MakeStringCopy("ios_app");
#else
        return MakeStringCopy("ios_none");
#endif
    }
    
    void IosInit()
    {
    }
    
    void IosInitApp(const char *json)
    {
        
    }
    
    void IosLoginApp(const char *json)
    {
        NSDictionary * dic = [[SDKMain SharedInstance]JsonToDic:json];
        if ([[dic objectForKey:@"shareApp"] isEqualToString: @"XianLiao"]) {
            [[SDKForXianLiao SharedInstance] login:json];
        }
    }
    
    void IosInitWechat(const char * appid)
    {
        [[SDKForWechat SharedInstance] Init:appid];
    }
    
    void IosLoginWechat()
    {
        [[SDKForWechat SharedInstance] Login];
    }
    
    void IosShareUrl(const char * json)
    {
        NSDictionary * dic = [[SDKMain SharedInstance]JsonToDic:json];
        if ([[dic objectForKey:@"shareApp"] isEqualToString: @"XianLiao"]) {
            if ([dic objectForKey:@"roomToken"] != NULL) {
                [[SDKForXianLiao SharedInstance] shareGame:json];
            }
            else if ([dic objectForKey:@"imageUrl"] != NULL) {
                [[SDKForXianLiao SharedInstance] shareUrlImage:json];
            }
            else {
                [[SDKForXianLiao SharedInstance] shareText:json];
            }
            
        } else if ([[dic objectForKey:@"shareApp"] isEqualToString: @"Alipay"]) {
            if ([dic objectForKey:@"thumbUrl"] != NULL) {
                [[SDKForAliPay SharedInstance] sendWebByUrl:json];
            } else {
                [[SDKForAliPay SharedInstance] sendWebByData:json];
            }
        } else {
            [[SDKForWechat SharedInstance] ShareUrl:json];
        }
    }
    
    void IosShareText(const char * json)
    {
        NSDictionary * dic = [[SDKMain SharedInstance]JsonToDic:json];
        if ([[dic objectForKey:@"shareApp"] isEqualToString: @"XianLiao"]) {
            [[SDKForXianLiao SharedInstance] shareText:json];
        } else if ([[dic objectForKey:@"shareApp"] isEqualToString: @"Alipay"]) {
            [[SDKForAliPay SharedInstance] shareText:json];
        } else {
            
        }
    }
    
    void IosShareImage(const char * json)
    {
        NSDictionary * dic = [[SDKMain SharedInstance]JsonToDic:json];
        if ([[dic objectForKey:@"shareApp"] isEqualToString: @"XianLiao"]) {
            if ([dic objectForKey:@"imageUrl"] != NULL) {
                [[SDKForXianLiao SharedInstance] shareUrlImage:json];
            } else {
                [[SDKForXianLiao SharedInstance] shareDataImage:json];
            }
        } else if ([[dic objectForKey:@"shareApp"] isEqualToString: @"Alipay"]) {
            if ([dic objectForKey:@"imageUrl"] != NULL) {
                [[SDKForAliPay SharedInstance] shareUrlImage:json];
            } else {
                [[SDKForAliPay SharedInstance] shareDataImage:json];
            }
        } else {
            [[SDKForWechat SharedInstance] ShareImage:json];
        }
    }
    
    void IosShareMiniProgram(const char * json)
    {
        [[SDKForWechat SharedInstance] ShareMiniProgram:json];
    }
    
    void IosBeginLocation(bool isRegeocode)
    {
        [[SDKMain SharedInstance] BeginLocation:isRegeocode];
    }
    
    double IosCaculateDistance(double latitude1, double longitude1, double latitude2, double longitude2)
    {
        return [[SDKMain SharedInstance] CaculateDistance:latitude1 :longitude1 :latitude2 :longitude2];
    }
    
    int IosGetCurBatteryLevel()
    {
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        float level = [UIDevice currentDevice].batteryLevel;
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
        
        int batteryLevel = level * 100;
        
        return batteryLevel;
    }
    
    const char * IosGetCurSignalType()
    {
        if (iapManager == NULL) {
            iapManager = [[IAPManager alloc] init];
            [iapManager attachObserver];
        }
        
        if(iapManager.isIphoneX)
        {
            // Iphone X 未获取到网络信息时  判断当前链接有没有wifi名，有的话就返回wifi
            switch (iapManager.networktype) {
                case 1:
                    return MakeStringCopy("2g");
                    break;
                case 2:
                    return MakeStringCopy("3g");
                    break;
                case 3:
                    return MakeStringCopy("4g");
                    break;
                case 4:
                    return MakeStringCopy("4g");
                    break;
                case 5:
                    return MakeStringCopy("wifi");
                    break;
                default:
                    return MakeStringCopy("none");
                    break;
            }
        }
        else
        {
            NSString* netWorkStatus = [[SDKMain SharedInstance] getNetWorkStatus];
            //            NSLog(@"-----------------netWorkStatus = %@",netWorkStatus);
            if(netWorkStatus != nil)
            {
                const char* constNet = [netWorkStatus UTF8String];
                return MakeStringCopy(constNet);
            }
            UIApplication * app = [UIApplication sharedApplication];
            NSArray * arr = nil;
            if ([[app valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
                arr = [[[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
            } else {
                arr = [[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
            }
            
            NSString * dataNetworkItemView = nil;
            
            for (id subview in arr) {
                if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")])
                {
                    int networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
                    //                    NSLog(@"-----------------networkType = %d",networkType);
                    dataNetworkItemView = subview;
                    switch (networkType) {
                        case 0:
                            return MakeStringCopy("none");
                        case 1:
                            return MakeStringCopy("2g");
                            break;
                        case 2:
                            return MakeStringCopy("3g");
                            break;
                        case 3:
                            return MakeStringCopy("4g");
                            break;
                        case 5:
                            return MakeStringCopy("wifi");
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        
        
        return MakeStringCopy("none");
    }
    
    int IosGetCurSignalStrenth()
    {
        if (iapManager == NULL) {
            iapManager = [[IAPManager alloc] init];
            [iapManager attachObserver];
        }
        
        if(iapManager.isIphoneX)
        {
            // Iphone X
            //            NSLog(@"--- Iphone X Iphone X");
            return iapManager.wifiStrenth;
        }
        else
        {
            UIApplication * app = [UIApplication sharedApplication];
            NSArray * arr = nil;
            if ([[app valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
                arr = [[[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
            } else {
                arr = [[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
            }
            NSString * dataNetworkItemView = nil;
            
            for (id subview in arr) {
                if ([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]])
                {
                    dataNetworkItemView = subview;
                }
            }
            
            int strenth = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
            //            NSLog(@"--- strenth = %d",strenth);
            return strenth + 1;
        }
    }
    
    void IosShakePhone()
    {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    
    bool IosGetCurChargeState()
    {
        //        NSLog(@"---------- IosGetCurChargeState ");
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        UIDeviceBatteryState state = [[UIDevice currentDevice] batteryState];
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
        
        if (state == UIDeviceBatteryStateCharging || state == UIDeviceBatteryStateFull)
        {
            return true;
        }
        
        return false;
    }
    
    const char * IosGetIpsByHttpDNS(const char * url)
    {
        return MakeStringCopy([[SDKMain SharedInstance] getIpsByHttpDNS:url]);
    }
    
    
    
    //购买商品
    void IosBuyProduct(const char  *p){
        if (iapManager == NULL) {
            iapManager = [[IAPManager alloc] init];
            [iapManager attachObserver];
        }
        [iapManager buyRequest:[NSString stringWithUTF8String:p]];
    }
    
    //IOS10下是否因为玩家选择而无网络连接
    bool IosIsUserCloseNetWork(){
        if (iapManager == NULL) {
            iapManager = [[IAPManager alloc] init];
            [iapManager attachObserver];
        }
        bool isbool = [iapManager isUserCloseNetWork];
        return isbool;
    }
    
    float IosGetCurSdCardSize(){
        if (iapManager == NULL) {
            iapManager = [[IAPManager alloc] init];
            [iapManager attachObserver];
        }
        
        return [iapManager getCurSdCardSize];
    }
    
    void IosCopyTextToClipboard(const char *p){
        NSString *text = [NSString stringWithUTF8String: p];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = text;
    }
    
    const char* IosGetClipBoardContent()
    {
        UIPasteboard* pBoard=[UIPasteboard generalPasteboard];
        if(pBoard!=NULL)
        {
            NSString* pNsStr=pBoard.string;
            if(pNsStr!=NULL)
            {
                return MakeStringCopy([pNsStr UTF8String]);
            }
            else
            {
                NSLog(@"pBoard.string is null");
                return MakeStringCopy("");
            }
        }
        else {
            NSLog (@ "UIPasteboard pBoard is null") ;
            return MakeStringCopy ("" ) ;
        }
    }
    
    bool IosIsAppExist(const char *url){
        bool isbool = true;
        if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithUTF8String:url]]])
        {
            isbool = false;
        }
        return isbool;
    }
    
    void IosStartApp(const char *url)
    {
        NSURL* urlLocal = [NSURL URLWithString:[NSString stringWithUTF8String:url]];
        if (![[UIApplication sharedApplication] canOpenURL:urlLocal])
        {
            NSLog(@"不存在应用：%s",url);
            return;
        }
        [[UIApplication sharedApplication] openURL: urlLocal];
    }
    
    void IosSendRequestToPhone(const char *json)
    {
        [[ProtoMgr instance] recvRquest:json];
    }
    
    
    
    
#if defined(__cplusplus)
}
#endif
