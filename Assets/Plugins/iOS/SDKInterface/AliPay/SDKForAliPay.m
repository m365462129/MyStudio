//
//  SDKForTABT.m
//  Unity-iPhone
//
//  Created by Apple on 2017/10/16.
//

#import "SDKForAliPay.h"
//#import "sys/utsname.h"
//#import "NSString+Encrypt.h"
//#import "HttpRequest.h"
#import "APOpenAPI.h"
#import "SDKMain.h"

//在需要处理支付宝应用回调的类内添加对应的Delegate
@interface SDKForAliPay () <APOpenAPIDelegate>

@end

@implementation SDKForAliPay
static SDKForAliPay * instance = nil;

+(SDKForAliPay *) SharedInstance
{
    if (instance == nil)
    {
        instance = [[SDKForAliPay alloc] init];
    }
    
    return instance;
}

/*
 *  以下主要为发送消息代码示例
 */

//  发送文本消息到支付宝
- (void)shareText:(const char *)json
{
    NSDictionary * dict = [self JsonToDic:json];
    NSString * sceneType = [dict objectForKey:@"sceneType"];
    NSString * text = [dict objectForKey:@"text"];
    
    
    //  创建消息载体 APMediaMessage 对象
    APMediaMessage *message = [[APMediaMessage alloc] init];
    
    //  创建文本类型的消息对象
    APShareTextObject *textObj = [[APShareTextObject alloc] init];
    textObj.text = text;
//    textObj.text = @"此处填充发送到支付宝的纯文本信息";
    //  回填 APMediaMessage 的消息对象
    message.mediaObject = textObj;
    
    //  创建发送请求对象
    APSendMessageToAPReq *request = [[APSendMessageToAPReq alloc] init];
    //  填充消息载体对象
    request.message = message;
    //  分享场景，0为分享到好友，1为分享到生活圈；支付宝9.9.5版本至现在版本，分享入口已合并，这个scene并没有被使用，用户会在跳转进支付宝后选择分享场景（好友、动态、圈子等），但为保证老版本上无问题、建议还是照常传入
    request.scene = [sceneType isEqualToString:@"0"] ? 0 : 1;
    //  发送请求
    BOOL result = [APOpenAPI sendReq:request];
    if (!result) {
        //失败处理
        NSLog(@"发送失败");
    }
}

//  发送图片消息到支付宝(图片链接形式)
- (void)shareUrlImage:(const char *)json
{
    NSDictionary * dict = [self JsonToDic:json];
    NSString * imageUrl = [dict objectForKey:@"imageUrl"];
    NSString * sceneType = [dict objectForKey:@"sceneType"];
    
    //  创建消息载体 APMediaMessage 对象
    APMediaMessage *message = [[APMediaMessage alloc] init];
    
    //  创建图片类型的消息对象
    APShareImageObject *imgObj = [[APShareImageObject alloc] init];
    imgObj.imageUrl = imageUrl;
    //  回填 APMediaMessage 的消息对象
    message.mediaObject = imgObj;
    
    //  创建发送请求对象
    APSendMessageToAPReq *request = [[APSendMessageToAPReq alloc] init];
    //  填充消息载体对象
    request.message = message;
    //  分享场景，0为分享到好友，1为分享到生活圈；支付宝9.9.5版本至现在版本，分享入口已合并，这个scene并没有被使用，用户会在跳转进支付宝后选择分享场景（好友、动态、圈子等），但为保证老版本上无问题、建议还是照常传入
    request.scene = [sceneType isEqualToString:@"0"] ? 0 : 1;
    //  发送请求
    BOOL result = [APOpenAPI sendReq:request];
    if (!result) {
        //失败处理
        NSLog(@"发送失败");
    }
}

//  发送图片消息到支付宝(图片数据形式)
- (void)shareDataImage:(const char *)json
{
    NSDictionary * dic = [self JsonToDic:json];
    NSString * sceneType = [dic objectForKey:@"sceneType"];
    NSData * data = [[SDKMain SharedInstance] GetImageData:dic];
    
    //  创建消息载体 APMediaMessage 对象
    APMediaMessage *message = [[APMediaMessage alloc] init];
    
    //  创建图片类型的消息对象
    APShareImageObject *imgObj = [[APShareImageObject alloc] init];
    //  此处填充图片data数据,例如 UIImagePNGRepresentation(UIImage对象)
    //  此处必须填充有效的image NSData类型数据，否则无法正常分享
    imgObj.imageData = data;
    //  回填 APMediaMessage 的消息对象
    message.mediaObject = imgObj;
    
    //  创建发送请求对象
    APSendMessageToAPReq *request = [[APSendMessageToAPReq alloc] init];
    //  填充消息载体对象
    request.message = message;
    //  分享场景，0为分享到好友，1为分享到生活圈；支付宝9.9.5版本至现在版本，分享入口已合并，这个scene并没有被使用，用户会在跳转进支付宝后选择分享场景（好友、动态、圈子等），但为保证老版本上无问题、建议还是照常传入
    request.scene = [sceneType isEqualToString:@"0"] ? 0 : 1;
    
    

    BOOL result = [APOpenAPI sendReq:request];
    if (!result) {
        //失败处理
        NSLog(@"发送失败");
    }
}


//  发送网页消息到支付宝(缩略图链接形式)
- (void)sendWebByUrl:(const char *)json
{
    NSDictionary * dic = [self JsonToDic:json];
    NSString * sceneType = [dic objectForKey:@"sceneType"];
    
    
    //  创建消息载体 APMediaMessage 对象
    APMediaMessage *message = [[APMediaMessage alloc] init];
    
    message.title = [dic objectForKey:@"title"];
    message.desc = [dic objectForKey:@"desc"];
    message.thumbUrl = [dic objectForKey:@"thumbUrl"];
    
    //  创建网页类型的消息对象
    APShareWebObject *webObj = [[APShareWebObject alloc] init];
    webObj.wepageUrl = [dic objectForKey:@"wepageUrl"];
    //  回填 APMediaMessage 的消息对象
    message.mediaObject = webObj;
    
    //  创建发送请求对象
    APSendMessageToAPReq *request = [[APSendMessageToAPReq alloc] init];
    //  填充消息载体对象
    request.message = message;
    //  分享场景，0为分享到好友，1为分享到生活圈；支付宝9.9.5版本至现在版本，分享入口已合并，这个scene并没有被使用，用户会在跳转进支付宝后选择分享场景（好友、动态、圈子等），但为保证老版本上无问题、建议还是照常传入
    request.scene = [sceneType isEqualToString:@"0"] ? 0 : 1;
    //  发送请求
    BOOL result = [APOpenAPI sendReq:request];
    if (!result) {
        //失败处理
        NSLog(@"发送失败");
    }
}

//  发送网页消息到支付宝(缩略图链接形式)
- (void)sendWebByData:(const char *)json
{
    NSDictionary * dic = [self JsonToDic:json];
    NSString * sceneType = [dic objectForKey:@"sceneType"];

    //  创建消息载体 APMediaMessage 对象
    APMediaMessage *message = [[APMediaMessage alloc] init];
    
    message.title = [dic objectForKey:@"title"];
    message.desc = [dic objectForKey:@"desc"];
  
    message.thumbData = [[SDKMain SharedInstance] GetThumbImageData:dic];;
    
    //  创建网页类型的消息对象
    APShareWebObject *webObj = [[APShareWebObject alloc] init];
    webObj.wepageUrl = [dic objectForKey:@"wepageUrl"];
    //  回填 APMediaMessage 的消息对象
    message.mediaObject = webObj;
    
    //  创建发送请求对象
    APSendMessageToAPReq *request = [[APSendMessageToAPReq alloc] init];
    //  填充消息载体对象
    request.message = message;
    //  分享场景，0为分享到好友，1为分享到生活圈；支付宝9.9.5版本至现在版本，分享入口已合并，这个scene并没有被使用，用户会在跳转进支付宝后选择分享场景（好友、动态、圈子等），但为保证老版本上无问题、建议还是照常传入
    request.scene = 0;
    //  发送请求
    BOOL result = [APOpenAPI sendReq:request];
    if (!result) {
        //失败处理
        NSLog(@"发送失败");
    }
}

// json转字典
-(NSDictionary *)JsonToDic:(const char *)json
{
    NSString * jsonData = [NSString stringWithUTF8String:json];
    NSData * data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary * dic = (NSDictionary *)jsonObject;
        return dic;
    }
    
    return nil;
}

- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}



//
///*
// *  第三方应用程序发送一个sendReq后，收到支付宝的响应结果
// *
// *  入参
// *      resp : 第三方应用收到的支付宝的响应结果类，目前支持的类型包括 APSendMessageToAPResp(分享消息)
// */
//- (void)onRespAliPay:(APBaseResp*)resp
//{
//    //  Demo内主要是将响应结果通过alert的形式反馈出来，第三方应用可以根据 errCode 进行相应的处理。
//    NSString *title = nil;
//    NSString *message = nil;
//    if (resp.errCode == APSuccess) {
//        title = @"成功";
//    } else {
//        title = @"失败";
//        message = [NSString stringWithFormat:@"%@(%d)", resp.errStr, resp.errCode];
//    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alert show];
//}




@end
