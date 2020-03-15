
#import <UIKit/UIKit.h>
#import <React/RCTLog.h>
#import <React/RCTConvert.h>
#import <React/RCTLinkingManager.h>
#import "RNTWechat.h"

RNTWechat *wechatInstance;

NSString *wechatAuthResponse = @"wechatAuthResponse";
NSString *wechatShareResponse = @"wechatShareResponse";

typeof(void (^)(NSString*, void (^)(UIImage*))) wechatLoadImage;

@implementation RNTWechat

RCT_EXPORT_MODULE(RNTWechat);

+ (void)init:(NSString *)appId universalLink:(NSString *)universalLink loadImage:(void (^)(NSString*, void (^)(UIImage*)))loadImage {
    wechatLoadImage = loadImage;
    
    RCTLogInfo(appId);
    RCTLogInfo(universalLink);
    BOOL success = [WXApi registerApp:appId universalLink:universalLink];
    if (success) {
       RCTLogInfo(@"registerApp success");
    }
    else {
       RCTLogInfo(@"registerApp failed");
    }
    
}

+ (BOOL)handleOpenURL:(UIApplication *)application openURL:(NSURL *)url
options:(NSDictionary<NSString*, id> *)options {
    if (wechatInstance != nil) {
        return [WXApi handleOpenURL:url delegate:wechatInstance];
    }
    return NO;
}

+ (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity {
    if (wechatInstance != nil) {
        return [WXApi handleOpenUniversalLink:userActivity delegate:wechatInstance];
    }
    return NO;
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (instancetype)init {
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handleAuthResponse:)
                                            name:wechatAuthResponse
                                            object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handleShareResponse:)
                                            name:wechatShareResponse
                                            object:nil];
        
    }
    wechatInstance = self;
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    wechatInstance = nil;
}

- (NSArray<NSString *> *)supportedEvents {
  return @[
      @"auth",
      @"share",
  ];
}

- (void)handleAuthResponse:(NSNotification *)notification {
    [self sendEventWithName:@"auth" body:notification.object];
}

- (void)handleShareResponse:(NSNotification *)notification {
    [self sendEventWithName:@"share" body:notification.object];
}

- (void) onReq:(BaseReq *)req {
    
}

- (void) onResp:(BaseResp *)resp {
    // 微信登录
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        
        SendAuthResp *r = (SendAuthResp *)resp;
        
        NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
        body[@"err_code"] = @(r.errCode);
        body[@"err_str"] = r.errStr;
        body[@"state"] = r.state;
        body[@"lang"] = r.lang;
        body[@"country"] = r.country;
        
        if (resp.errCode == WXSuccess) {
            body[@"code"] = r.code;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:wechatAuthResponse object:body];
        
    }
    // 微信分享
    else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        
        SendMessageToWXResp *r = (SendMessageToWXResp *)resp;
    
        NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
        body[@"err_code"] = @(r.errCode);
        body[@"err_str"] = r.errStr;
        body[@"lang"] = r.lang;
        body[@"country"] = r.country;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:wechatShareResponse object:body];

    }
}

RCT_EXPORT_METHOD(isInstalled:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    BOOL installed = [WXApi isWXAppInstalled];
    resolve(@{
        @"installed": @(installed)
    });
}

RCT_EXPORT_METHOD(isSupportOpenApi:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    BOOL supported = [WXApi isWXAppSupportApi];
    resolve(@{
        @"supported": @(supported)
    });
}

RCT_EXPORT_METHOD(getInstallUrl:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    NSString *url = [WXApi getWXAppInstallUrl];
    resolve(@{
        @"url": url
    });
}

RCT_EXPORT_METHOD(getApiVersion:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    NSString *version = [WXApi getApiVersion];
    resolve(@{
        @"version": version
    });
}

RCT_EXPORT_METHOD(open:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    BOOL success = [WXApi openWXApp];
    resolve(@{
        @"success": @(success)
    });
}

RCT_EXPORT_METHOD(sendAuthRequest:(NSDictionary*)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {

    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = [RCTConvert NSString:options[@"scope"]];
    req.state = [RCTConvert NSString:options[@"state"]];
    
    [WXApi sendReq:req completion:^(BOOL success) {
        resolve(@{
            @"success": @(success)
        });
    }];
    
}

// 分享文本
// scene 0-会话 1-朋友圈 2-收藏
RCT_EXPORT_METHOD(shareText:(NSDictionary*)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text = [RCTConvert NSString:options[@"text"]];
    req.scene = [RCTConvert int:options[@"scene"]];

    [WXApi sendReq:req completion:^(BOOL success) {
        resolve(@{
            @"success": @(success)
        });
    }];
    
}

RCT_EXPORT_METHOD(shareImage:(NSDictionary*)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    typeof(void(^)(UIImage *image)) sendShareReq = ^(UIImage *image){
        
        if (image == nil) {
            reject(@"1", @"image is not found.", nil);
            return;
        }
        
        NSData *imageData = UIImagePNGRepresentation(image);
        
        WXImageObject *object = [WXImageObject object];
        object.imageData = imageData;
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.thumbData = imageData;
        message.mediaObject = object;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = [RCTConvert int:options[@"scene"]];
        
        [WXApi sendReq:req completion:^(BOOL success) {
            resolve(@{
                @"success": @(success)
            });
        }];
        
    };
    
    NSString *url = [RCTConvert NSString:options[@"image_url"]];
    
    // 本地图片
    if ([url hasPrefix:@"/"]) {
        sendShareReq([UIImage imageWithContentsOfFile:url]);
    }
    // 网络图片
    else {
        wechatLoadImage(url, sendShareReq);
    }
    
}

RCT_EXPORT_METHOD(shareAudio:(NSDictionary*)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    typeof(void(^)(UIImage *image)) sendShareReq = ^(UIImage *image){
        
        if (image == nil) {
            reject(@"1", @"thumbnail is not found.", nil);
            return;
        }
        
        NSData *imageData = UIImagePNGRepresentation(image);
        
        WXMusicObject *object = [WXMusicObject object];
        object.musicUrl = [RCTConvert NSString:options[@"page_url"]];
        object.musicLowBandUrl = object.musicUrl;
        object.musicDataUrl = [RCTConvert NSString:options[@"audio_url"]];
        object.musicLowBandDataUrl = object.musicDataUrl;

        WXMediaMessage *message = [WXMediaMessage message];
        message.title = [RCTConvert NSString:options[@"title"]];
        message.description = [RCTConvert NSString:options[@"description"]];
        message.thumbData = imageData;
        message.mediaObject = object;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = [RCTConvert int:options[@"scene"]];
        
        [WXApi sendReq:req completion:^(BOOL success) {
            resolve(@{
                @"success": @(success)
            });
        }];
        
    };
    
    NSString *url = [RCTConvert NSString:options[@"thumbnail_url"]];
    
    // 本地图片
    if ([url hasPrefix:@"/"]) {
        sendShareReq([UIImage imageWithContentsOfFile:url]);
    }
    // 网络图片
    else {
        wechatLoadImage(url, sendShareReq);
    }
    
}

RCT_EXPORT_METHOD(shareVideo:(NSDictionary*)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    typeof(void(^)(UIImage *image)) sendShareReq = ^(UIImage *image){
        
        if (image == nil) {
            reject(@"1", @"thumbnail is not found.", nil);
            return;
        }
        
        NSData *imageData = UIImagePNGRepresentation(image);
        
        WXVideoObject *object = [WXVideoObject object];
        object.videoUrl = [RCTConvert NSString:options[@"video_url"]];
        object.videoLowBandUrl = object.videoUrl;
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = [RCTConvert NSString:options[@"title"]];
        message.description = [RCTConvert NSString:options[@"description"]];
        message.thumbData = imageData;
        message.mediaObject = object;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = [RCTConvert int:options[@"scene"]];
        
        [WXApi sendReq:req completion:^(BOOL success) {
            resolve(@{
                @"success": @(success)
            });
        }];
        
    };
    
    NSString *url = [RCTConvert NSString:options[@"thumbnail_url"]];
    
    // 本地图片
    if ([url hasPrefix:@"/"]) {
        sendShareReq([UIImage imageWithContentsOfFile:url]);
    }
    // 网络图片
    else {
        wechatLoadImage(url, sendShareReq);
    }
    
}

RCT_EXPORT_METHOD(sharePage:(NSDictionary*)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    typeof(void(^)(UIImage *image)) sendShareReq = ^(UIImage *image){
        
        if (image == nil) {
            reject(@"1", @"thumbnail is not found.", nil);
            return;
        }
        
        NSData *imageData = UIImagePNGRepresentation(image);
        
        WXWebpageObject *object = [WXWebpageObject object];
        object.webpageUrl = [RCTConvert NSString:options[@"page_url"]];
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = [RCTConvert NSString:options[@"title"]];
        message.description = [RCTConvert NSString:options[@"description"]];
        message.thumbData = imageData;
        message.mediaObject = object;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = [RCTConvert int:options[@"scene"]];
        
        [WXApi sendReq:req completion:^(BOOL success) {
            resolve(@{
                @"success": @(success)
            });
        }];
        
    };
    
    NSString *url = [RCTConvert NSString:options[@"thumbnail_url"]];
    
    // 本地图片
    if ([url hasPrefix:@"/"]) {
        sendShareReq([UIImage imageWithContentsOfFile:url]);
    }
    // 网络图片
    else {
        wechatLoadImage(url, sendShareReq);
    }
    
}

RCT_EXPORT_METHOD(shareMiniProgram:(NSDictionary*)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    typeof(void(^)(UIImage *image)) sendShareReq = ^(UIImage *image){
        
        if (image == nil) {
            reject(@"1", @"thumbnail is not found.", nil);
            return;
        }
        
        NSData *imageData = UIImagePNGRepresentation(image);
        
        WXMiniProgramObject *object = [WXMiniProgramObject object];
        // 兼容低版本的网页链接
        object.webpageUrl = [RCTConvert NSString:options[@"page_url"]];
        // 小程序的 userName
        object.userName = [RCTConvert NSString:options[@"user_name"]];
        // 小程序的页面路径
        object.path = [RCTConvert NSString:options[@"path"]];
        // 小程序新版本的预览图二进制数据，6.5.9及以上版本微信客户端支持
        object.hdImageData = imageData;
        // 是否使用带 shareTicket 的分享
        object.withShareTicket = [RCTConvert BOOL:options[@"with_share_ticket"]];
        // 小程序的类型，默认正式版，1.8.1及以上版本开发者工具包支持分享开发版和体验版小程序
        // 0-正式版 1-开发版 2-体验版
        object.miniProgramType = [RCTConvert int:options[@"type"]];
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = [RCTConvert NSString:options[@"title"]];
        message.description = [RCTConvert NSString:options[@"description"]];
        // 兼容旧版本节点的图片，小于32KB，新版本优先
        // 使用 WXMiniProgramObject 的 hdImageData 属性
        message.thumbData = nil;
        message.mediaObject = object;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        // 目前只支持会话
        req.scene = WXSceneSession;
        
        [WXApi sendReq:req completion:^(BOOL success) {
            resolve(@{
                @"success": @(success)
            });
        }];
        
    };
    
    NSString *url = [RCTConvert NSString:options[@"thumbnail_url"]];
    
    // 本地图片
    if ([url hasPrefix:@"/"]) {
        sendShareReq([UIImage imageWithContentsOfFile:url]);
    }
    // 网络图片
    else {
        wechatLoadImage(url, sendShareReq);
    }
    
}

@end
