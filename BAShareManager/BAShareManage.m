//
//  ShareManage.m
//  yrapp
//
//  Created by 博爱 on 16/2/3.
//  Copyright © 2016年 有人科技. All rights reserved.
//  友盟分享工具类

#import "BAShareManage.h"
#import "NSObject+BAProgressHUD.h"
//#import "BAShareAnimationView.h"


#define BAUMSocialManager        [UMSocialManager defaultManager]
#define BAUMSocialShareUIConfig  [UMSocialShareUIConfig shareInstance]


@interface BAShareManage()

@property (nonatomic, strong) UMSocialUserInfoResponse *responseDic;

@end

@implementation BAShareManage

+ (BAShareManage *)ba_shareManage
{
    static BAShareManage *ba_shareManage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ba_shareManage = [[BAShareManage alloc] init];
    });
    return ba_shareManage;
}

#pragma mark - 判断平台是否安装
- (BOOL)ba_UMSocialIsInstall:(UMSocialPlatformType)platformType
{
    return [BAUMSocialManager isInstall:platformType];
}

#pragma mark 注册友盟分享微信
- (void)ba_setupShareConfig
{
    /*! 打开调试log的开关 */
    [BAUMSocialManager openLog:YES];
    
    // 是否清除缓存在获得用户资料的时候
    [UMSocialGlobal shareInstance].isClearCacheWhenGetUserInfo = NO;
    [BAUMSocialManager setUmSocialAppkey:BA_Umeng_Appkey];
    
    
    /*! 获取友盟social版本号 */
    NSLog(@"获取友盟social版本号: %@", [UMSocialGlobal umSocialSDKVersion]);
    
    /*! 如果你要支持不同的屏幕方向，需要这样设置，否则在iPhone只支持一个竖屏方向 */
    //    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
    
    /*! 苹果审核要求,隐藏未安装的应用 的分享选项 */
    //    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToSina, UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
    
    /*! 设置新浪的appKey和appSecret */
    [BAUMSocialManager setPlaform:UMSocialPlatformType_Sina
                           appKey:BA_Sina_AppKey
                        appSecret:BA_SinaAppSecret
                      redirectURL:@"http://sns.whalecloud.com/sin"];
    
    /*! 设置微信的appKey和appSecret
     [微信平台从U-Share 4/5升级说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_1 */
    [BAUMSocialManager setPlaform:UMSocialPlatformType_WechatSession
                           appKey:BA_WX_APPKEY
                        appSecret:BA_WX_APPSECRET
                      redirectURL:nil];
    
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     100424468.no permission of union id
     [QQ/QZone平台集成说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_3
     */
    [BAUMSocialManager setPlaform:UMSocialPlatformType_QQ
                           appKey:BA_QQAppID
                        appSecret:nil
                      redirectURL:nil];
    
    /* 支付宝的appKey */
    [BAUMSocialManager setPlaform:UMSocialPlatformType_AlipaySession appKey:BA_ZhiFuBaoAppID appSecret:nil redirectURL:nil];
    
    
    /*! 这段代码是用友盟自带的自定义分享的时候打开！ */
    /*
     * 添加某一平台会加入平台下所有分享渠道，如微信：好友、朋友圈、收藏，QQ：QQ和QQ空间
     * 以下接口可移除相应平台类型的分享，如微信收藏，对应类型可在枚举中查找
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    //    UMSocialSnsPlatform *copyPlatform = [[UMSocialSnsPlatform alloc] initWithPlatformName:@"copy"];
    //    copyPlatform.displayName = @"复制";
    //    copyPlatform.smallImageName = @"icon"; //用于tableView样式的分享列表
    //    copyPlatform.bigImageName = @"icon"; //用于actionsheet样式的分享列表
    //    copyPlatform.snsClickHandler = ^(UIViewController *presentingController, UMSocialControllerService * socialControllerService, BOOL isPresentInController){ NSLog(@"copy!"); };                                                                                                                                                                                                          [UMSocialConfig addSocialSnsPlatform:@[copyPlatform]];                                                                                                                                                                                                        [UMSocialConfig setSnsPlatformNames:@[UMShareToSina, UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone]];
}

#pragma mark - share type
#pragma mark 分享纯文本
- (void)ba_shareTextToPlatformType:(UMSocialPlatformType)platformType
                         shareText:(NSString *)shareText
                    viewController:(UIViewController *)viewController
                        completion:(UMSocialRequestCompletionHandler)completion
{
    /*! 创建分享消息对象 */
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    /*! 设置文本 */
    messageObject.text = shareText;
    
    /*! 调用分享接口 */
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            if (completion)
            {
                completion(nil, error);
            }
            // 调用服务器
            [self shareSuccussForServer];
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                if (completion)
                {
                    completion(data, nil);
                }
                UMSocialShareResponse *resp = data;
                /*! 分享结果消息 */
                UMSocialLogInfo(@"response message is %@", resp.message);
                /*! 第三方原始返回的数据 */
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
            // 调用服务器
            [self shareSuccussForServer];
        }
//        [self alertWithError:error];
    }];
}

#pragma mark 分享纯图片
- (void)ba_shareImageToPlatformType:(UMSocialPlatformType)platformType
                         thumbImage:(NSString *)thumbImage
                           bigImage:(NSString *)bigImage
                     viewController:(UIViewController *)viewController
                         completion:(UMSocialRequestCompletionHandler)completion
{
    /*! 创建分享消息对象 */
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    /*! 创建图片内容对象 */
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    /*! 如果有缩略图，则设置缩略图本地 */
    shareObject.thumbImage = [UIImage imageNamed:thumbImage];
    
    [shareObject setShareImage:[UIImage imageNamed:bigImage]];
    
//    /*! 设置Pinterest参数 */
//    if (platformType == UMSocialPlatformType_Pinterest) {
//        [self setPinterstInfo:messageObject];
//    }
//    
//    /*! 设置Kakao参数 */
//    if (platformType == UMSocialPlatformType_KakaoTalk) {
//        messageObject.moreInfo = @{@"permission" : @1}; // @1 = KOStoryPermissionPublic
//    }
    
    /*! 分享消息对象设置分享内容对象 */
    messageObject.shareObject = shareObject;
    
    /*! 调用分享接口 */
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            if (completion)
            {
                completion(nil, error);
            }
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                if (completion)
                {
                    completion(data, nil);
                }
                UMSocialShareResponse *resp = data;
                /*! 分享结果消息 */
                UMSocialLogInfo(@"response message is %@", resp.message);
                /*! 第三方原始返回的数据 */
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
            // 调用服务器
            [self shareSuccussForServer];
        }
        //        [self alertWithError:error];
    }];
}

#pragma mark 分享网络图片
- (void)ba_shareImageURLToPlatformType:(UMSocialPlatformType)platformType
                            thumbImage:(NSString *)thumbImage
                              imageUrl:(NSString *)imageUrl
                        viewController:(UIViewController *)viewController
                            completion:(UMSocialRequestCompletionHandler)completion
{
    /*! 创建分享消息对象 */
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    /*! 创建图片内容对象 */
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    /*! 如果有缩略图，则设置缩略图，此处为 URL */
    shareObject.thumbImage = thumbImage;
    [shareObject setShareImage:imageUrl];

    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            if (completion)
            {
                completion(nil, error);
            }
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                if (completion)
                {
                    completion(data, nil);
                }
                UMSocialShareResponse *resp = data;
                /*! 分享结果消息 */
                UMSocialLogInfo(@"response message is %@", resp.message);
                /*! 第三方原始返回的数据 */
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
            // 调用服务器
            [self shareSuccussForServer];
        }
        //        [self alertWithError:error];
    }];
    
}

#pragma mark 网页分享
- (void)ba_shareWebPageToPlatformType:(UMSocialPlatformType)platformType
                                title:(NSString *)title
                            shareText:(NSString *)shareText
                             imageUrl:(NSString *)imageUrl
                           webpageUrl:(NSString *)webpageUrl
                       viewController:(UIViewController *)viewController
                           completion:(UMSocialRequestCompletionHandler)completion
{
    /*! 创建分享消息对象 */
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    NSLog(@"分享的图片链接：%@", imageUrl);
    
    UMShareWebpageObject *shareObject;
    if ([BAKit_RegularExpression ba_regularIsUrl:imageUrl])
    {
        /*! 创建网页内容对象 */
        shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:shareText thumImage:imageUrl];
    }
    else
    {
        /*! 创建网页内容对象 */
        shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:shareText thumImage:BAKit_ImageName(imageUrl)];
    }
    
//    /*! 创建网页内容对象 */
//    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:shareText thumImage:BAKit_ImageName(imageUrl)];
    /*! 设置网页地址 */
    shareObject.webpageUrl = webpageUrl;
    
    /*! 分享消息对象设置分享内容对象 */
    messageObject.shareObject = shareObject;
    
    /*! 调用分享接口 */
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            if (completion)
            {
                completion(nil, error);
            }
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                if (completion)
                {
                    completion(data, nil);
                }
                UMSocialShareResponse *resp = data;
                /*! 分享结果消息 */
                UMSocialLogInfo(@"response message is %@", resp.message);
                /*! 第三方原始返回的数据 */
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
            // 调用服务器
            [self shareSuccussForServer];
        }
        //        [self alertWithError:error];
    }];

}

#pragma mark 分享图片和文字
- (void)ba_shareImageAndTextToPlatformType:(UMSocialPlatformType)platformType
                                 shareText:(NSString *)shareText
                                thumbImage:(NSString *)thumbImage
                                  imageUrl:(NSString *)imageUrl
                            viewController:(UIViewController *)viewController
                                completion:(UMSocialRequestCompletionHandler)completion
{
    /*! 创建分享消息对象 */
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    /*! 设置文本 */
    messageObject.text = shareText;
    
    /*! 创建图片内容对象 */
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    /*! 如果有缩略图，则设置缩略图 */
    
    shareObject.thumbImage = thumbImage;
    shareObject.shareImage = imageUrl;

    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    /*! 调用分享接口 */
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            if (completion)
            {
                completion(nil, error);
            }
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                if (completion)
                {
                    completion(data, nil);
                }
                UMSocialShareResponse *resp = data;
                /*! 分享结果消息 */
                UMSocialLogInfo(@"response message is %@", resp.message);
                /*! 第三方原始返回的数据 */
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
            // 调用服务器
            [self shareSuccussForServer];
        }
        //        [self alertWithError:error];
    }];
}

#pragma mark 音乐分享
- (void)ba_shareMusicToPlatformType:(UMSocialPlatformType)platformType
                              title:(NSString *)title
                          shareText:(NSString *)shareText
                           imageUrl:(NSString *)imageUrl
                           musicUrl:(NSString *)musicUrl
                       musicDataUrl:(NSString *)musicDataUrl
                     viewController:(UIViewController *)viewController
                         completion:(UMSocialRequestCompletionHandler)completion
{
    /*! 创建分享消息对象 */
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    /*! 创建音乐内容对象 */
    UMShareMusicObject *shareObject = [UMShareMusicObject shareObjectWithTitle:title descr:shareText thumImage:imageUrl];
    /*! 设置音乐网页播放地址 */
    shareObject.musicUrl = musicUrl;
    shareObject.musicDataUrl = musicDataUrl;
    /*! 分享消息对象设置分享内容对象 */
    messageObject.shareObject = shareObject;
    
    /*! 调用分享接口 */
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            if (completion)
            {
                completion(nil, error);
            }
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                if (completion)
                {
                    completion(data, nil);
                }
                UMSocialShareResponse *resp = data;
                /*! 分享结果消息 */
                UMSocialLogInfo(@"response message is %@", resp.message);
                /*! 第三方原始返回的数据 */
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
            // 调用服务器
            [self shareSuccussForServer];
        }
        //        [self alertWithError:error];
    }];
    
}

#pragma mark 视频分享
- (void)ba_shareVedioToPlatformType:(UMSocialPlatformType)platformType
                              title:(NSString *)title
                          shareText:(NSString *)shareText
                           imageUrl:(NSString *)imageUrl
                           videoUrl:(NSString *)videoUrl
                     viewController:(UIViewController *)viewController
                         completion:(UMSocialRequestCompletionHandler)completion
{
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    UMShareVideoObject *shareObject = [UMShareVideoObject shareObjectWithTitle:title descr:shareText thumImage:imageUrl];
    /*! 设置视频网页播放地址 */
    shareObject.videoUrl = videoUrl;
    
    messageObject.shareObject = shareObject;
    
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            if (completion)
            {
                completion(nil, error);
            }
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                if (completion)
                {
                    completion(data, nil);
                }
                UMSocialShareResponse *resp = data;
                /*! 分享结果消息 */
                UMSocialLogInfo(@"response message is %@", resp.message);
                /*! 第三方原始返回的数据 */
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
            // 调用服务器
            [self shareSuccussForServer];
        }
        //        [self alertWithError:error];
    }];
}

#pragma mark gif 动图分享
- (void)ba_shareEmoticonToPlatformType:(UMSocialPlatformType)platformType
                                 title:(NSString *)title
                             shareText:(NSString *)shareText
                              imageUrl:(NSString *)imageUrl
                           gifFilePath:(NSString *)gifFilePath
                        viewController:(UIViewController *)viewController
                            completion:(UMSocialRequestCompletionHandler)completion
{
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    UMShareEmotionObject *shareObject = [UMShareEmotionObject shareObjectWithTitle:title descr:shareText thumImage:imageUrl];
    
    NSData *emoticonData = [NSData dataWithContentsOfFile:gifFilePath];
    shareObject.emotionData = emoticonData;
    
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            if (completion)
            {
                completion(nil, error);
            }
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                if (completion)
                {
                    completion(data, nil);
                }
                UMSocialShareResponse *resp = data;
                /*! 分享结果消息 */
                UMSocialLogInfo(@"response message is %@", resp.message);
                /*! 第三方原始返回的数据 */
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
            // 调用服务器
            [self shareSuccussForServer];
        }
        
    }];
}

#pragma mark 文件分享
- (void)ba_shareFileToPlatformType:(UMSocialPlatformType)platformType
                             title:(NSString *)title
                         shareText:(NSString *)shareText
                          imageUrl:(NSString *)imageUrl
                      fileFilePath:(NSString *)fileFilePath
                 fileFileExtension:(NSString *)fileFileExtension
                    viewController:(UIViewController *)viewController
                        completion:(UMSocialRequestCompletionHandler)completion
{
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    UMShareFileObject *shareObject = [UMShareFileObject shareObjectWithTitle:title descr:shareText thumImage:imageUrl];
    
    NSString *kFileExtension = fileFileExtension;
    NSData *fileData = [NSData dataWithContentsOfFile:fileFilePath];
    shareObject.fileData = fileData;
    shareObject.fileExtension = kFileExtension;
    
    messageObject.shareObject = shareObject;
    
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            if (completion)
            {
                completion(nil, error);
            }
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                if (completion)
                {
                    completion(data, nil);
                }
                UMSocialShareResponse *resp = data;
                /*! 分享结果消息 */
                UMSocialLogInfo(@"response message is %@", resp.message);
                /*! 第三方原始返回的数据 */
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
            // 调用服务器
            [self shareSuccussForServer];
        }
        //        [self alertWithError:error];
    }];
}

//- (void)alertWithError:(NSError *)error
//{
//    NSString *result = nil;
//    if (!error) {
//        result = [NSString stringWithFormat:@"分享成功！"];
//        // 调用服务器
//        [self shareSuccussForServer];
//    }
//    else{
//        NSMutableString *str = [NSMutableString string];
//        if (error.userInfo) {
//            for (NSString *key in error.userInfo) {
//                [str appendFormat:@"%@ = %@\n", key, error.userInfo[key]];
//            }
//        }
//        if (error) {
//            result = [NSString stringWithFormat:@"Share fail with error code: %d\n%@",(int)error.code, str];
//        }
//        else{
//            result = [NSString stringWithFormat:@"Share fail"];
//        }
//    }
//}

//- (void)setPinterstInfo:(UMSocialMessageObject *)messageObj
//{
//    messageObj.moreInfo = @{@"source_url": @"http://www.umeng.com",
//                            @"app_name": @"U-Share",
//                            @"suggested_board_name": @"UShareProduce",
//                            @"description": @"U-Share: best social bridge"};
//}
//
//- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
//{
//    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
//    CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
//    [image drawInRect:imageRect];
//    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return retImage;
//}

#pragma mark - 友盟分享
#pragma mark 微信分享
- (void)ba_wechatShareWithShareType:(BAKit_UMShareType)shareType
                     viewController:(UIViewController *)viewController
                         completion:(UMSocialRequestCompletionHandler)completion
{
    switch (shareType) {
        case BAKit_UMShareType_Text:
            if ([BACommon ba_isNSStringNULL:_shareText])
            {
                NSLog(@"分享失败：纯文本分享中，文本内容不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：纯文本分享中，文本内容不能为空！");
                return;
            }
            [self ba_shareTextToPlatformType:UMSocialPlatformType_WechatSession
                                   shareText:_shareText
                              viewController:viewController
                                  completion:completion];
            break;
        case BAKit_UMShareType_Image:
            if ([BACommon ba_isNSStringNULL:_shareBigImage])
            {
                NSLog(@"分享失败：shareBigImage 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareBigImage 不能为空！");
                return;
            }
            [self ba_shareImageToPlatformType:UMSocialPlatformType_WechatSession
                                   thumbImage:nil
                                     bigImage:_shareBigImage
                               viewController:viewController
                                   completion:completion];
            break;
        case BAKit_UMShareType_Image_Url:
            if ([BACommon ba_isNSStringNULL:_shareImageUrl])
            {
                NSLog(@"分享失败：shareImageUrl 不能为空！");
               BAKit_ShowAlertWithMsg(@"分享失败：shareImageUrl 不能为空！");
                return;
            }
            [self ba_shareImageURLToPlatformType:UMSocialPlatformType_WechatSession
                                      thumbImage:nil
                                        imageUrl:_shareImageUrl
                                  viewController:viewController
                                      completion:completion];
            break;
        case BAKit_UMShareType_Web_Link:
            if ([BACommon ba_isNSStringNULL:_shareWebpageUrl])
            {
                NSLog(@"分享失败：shareWebpageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareWebpageUrl 不能为空！" );
                return;
            }
            [self ba_shareWebPageToPlatformType:UMSocialPlatformType_WechatSession
                                          title:_shareTitle
                                      shareText:_shareText
                                       imageUrl:_shareImageUrl
                                     webpageUrl:_shareWebpageUrl
                                 viewController:viewController
                                     completion:completion];
            break;
        case BAKit_UMShareType_Text_Image:
            /*! 注：友盟此方法暂时不能用 */
            if ([BACommon ba_isNSStringNULL:_shareImageUrl])
            {
                NSLog(@"分享失败：shareImageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareImageUrl 不能为空！" );
                return;
            }
            [self ba_shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession
                                           shareText:_shareText
                                          thumbImage:nil
                                            imageUrl:_shareImageUrl
                                      viewController:viewController
                                          completion:completion];
            break;
        case BAKit_UMShareType_Music_Link:
            if ([BACommon ba_isNSStringNULL:_shareMusicUrl])
            {
                NSLog(@"分享失败：shareMusicUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareMusicUrl 不能为空！" );
                return;
            }
            [self ba_shareMusicToPlatformType:UMSocialPlatformType_WechatSession
                                        title:_shareTitle
                                    shareText:_shareText
                                     imageUrl:_shareImageUrl
                                     musicUrl:_shareMusicUrl
                                 musicDataUrl:_shareMusicDataUrl
                               viewController:viewController
                                   completion:completion];
            break;
        case BAKit_UMShareType_Video_Link:
            if ([BACommon ba_isNSStringNULL:_shareVideoUrl])
            {
                NSLog(@"分享失败：shareVideoUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareVideoUrl 不能为空！" );
                return;
            }
            [self ba_shareVedioToPlatformType:UMSocialPlatformType_WechatSession
                                        title:_shareTitle
                                    shareText:_shareText
                                     imageUrl:_shareImageUrl
                                     videoUrl:_shareVideoUrl
                               viewController:viewController
                                   completion:completion];
            break;
        case BAKit_UMShareType_Gif:
            [self ba_shareEmoticonToPlatformType:UMSocialPlatformType_WechatSession
                                           title:_shareTitle
                                       shareText:_shareText
                                        imageUrl:_shareImageUrl
                                     gifFilePath:_shareGifFilePath
                                  viewController:viewController
                                      completion:completion];
            break;
        case BAKit_UMShareType_File:
                        [self ba_shareFileToPlatformType:UMSocialPlatformType_WechatSession
                                                   title:_shareTitle
                                               shareText:_shareText
                                                imageUrl:_shareImageUrl
                                            fileFilePath:_shareFileFilePath
                                       fileFileExtension:_shareFileFileExtension
                                          viewController:viewController
                                              completion:completion];
            break;
            
        default:
            break;
    }
}

#pragma mark 微信朋友圈分享
- (void)ba_wechatTimeLineShareWithShareType:(BAKit_UMShareType)shareType
                             viewController:(UIViewController *)viewController
                                 completion:(UMSocialRequestCompletionHandler)completion
{
    switch (shareType) {
        case BAKit_UMShareType_Text:
            if ([BACommon ba_isNSStringNULL:_shareText])
            {
                NSLog(@"分享失败：纯文本分享中，文本内容不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：纯文本分享中，文本内容不能为空！");
                return;
            }
            [self ba_shareTextToPlatformType:UMSocialPlatformType_WechatTimeLine
                                   shareText:_shareText
                              viewController:viewController
                                  completion:completion];
            break;
        case BAKit_UMShareType_Image:
            if ([BACommon ba_isNSStringNULL:_shareBigImage])
            {
                NSLog(@"分享失败：shareBigImage 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareBigImage 不能为空！" );
                return;
            }
            [self ba_shareImageToPlatformType:UMSocialPlatformType_WechatTimeLine
                                   thumbImage:nil
                                     bigImage:_shareBigImage
                               viewController:viewController
                                   completion:completion];
            break;
        case BAKit_UMShareType_Image_Url:
            if ([BACommon ba_isNSStringNULL:_shareImageUrl])
            {
                NSLog(@"分享失败：shareImageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareImageUrl 不能为空！" );
                return;
            }
            [self ba_shareImageURLToPlatformType:UMSocialPlatformType_WechatTimeLine
                                      thumbImage:nil
                                        imageUrl:_shareImageUrl
                                  viewController:viewController
                                      completion:completion];
            break;
        case BAKit_UMShareType_Web_Link:
            if ([BACommon ba_isNSStringNULL:_shareWebpageUrl])
            {
                NSLog(@"分享失败：shareWebpageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareWebpageUrl 不能为空！" );
                return;
            }
            [self ba_shareWebPageToPlatformType:UMSocialPlatformType_WechatTimeLine
                                          title:_shareTitle
                                      shareText:_shareText
                                       imageUrl:_shareImageUrl
                                     webpageUrl:_shareWebpageUrl
                                 viewController:viewController
                                     completion:completion];
            break;
        case BAKit_UMShareType_Text_Image:
            /*! 注：友盟此方法暂时不能用 */
            if ([BACommon ba_isNSStringNULL:_shareImageUrl])
            {
                NSLog(@"分享失败：shareImageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareImageUrl 不能为空！" );
                return;
            }
            [self ba_shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine
                                           shareText:_shareText
                                          thumbImage:nil
                                            imageUrl:_shareImageUrl
                                      viewController:viewController
                                          completion:completion];
            break;
        case BAKit_UMShareType_Music_Link:
            if ([BACommon ba_isNSStringNULL:_shareMusicUrl])
            {
                NSLog(@"分享失败：shareMusicUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareMusicUrl 不能为空！" );
                return;
            }
            [self ba_shareMusicToPlatformType:UMSocialPlatformType_WechatTimeLine
                                        title:_shareTitle
                                    shareText:_shareText
                                     imageUrl:_shareImageUrl
                                     musicUrl:_shareMusicUrl
                                 musicDataUrl:_shareMusicDataUrl
                               viewController:viewController
                                   completion:completion];
            break;
        case BAKit_UMShareType_Video_Link:
            if ([BACommon ba_isNSStringNULL:_shareVideoUrl])
            {
                NSLog(@"分享失败：shareVideoUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareVideoUrl 不能为空！" );
                return;
            }
            [self ba_shareVedioToPlatformType:UMSocialPlatformType_WechatTimeLine
                                        title:_shareTitle
                                    shareText:_shareText
                                     imageUrl:_shareImageUrl
                                     videoUrl:_shareVideoUrl
                               viewController:viewController
                                   completion:completion];
            break;
        case BAKit_UMShareType_Gif:
            NSLog(@"分享失败：受 微信朋友圈 平台限制，不能分享 gif 动图到 微信朋友圈！");
            BAKit_ShowAlertWithMsg(@"分享失败：受 微信朋友圈 平台限制，不能分享 gif 动图到 微信朋友圈！");
            return;
            //            [self ba_shareEmoticonToPlatformType:UMSocialPlatformType_WechatTimeLine
            //                                           title:_shareTitle
            //                                       shareText:_shareText
            //                                        imageUrl:_shareImageUrl
            //                                     gifFilePath:_shareGifFilePath
            //                                  viewController:viewController
//                                   completion:completion];;
            break;
        case BAKit_UMShareType_File:
            NSLog(@"分享失败：受 微信朋友圈 平台限制，不能分享文件到 微信朋友圈！");
            BAKit_ShowAlertWithMsg(@"分享失败：受 微信朋友圈 平台限制，不能分享文件到 微信朋友圈！");
            return;
            //            [self ba_shareFileToPlatformType:UMSocialPlatformType_WechatTimeLine
            //                                       title:_shareTitle
            //                                   shareText:_shareText
            //                                    imageUrl:_shareImageUrl
            //                                fileFilePath:_shareFileFilePath
            //                           fileFileExtension:_shareFileFileExtension
            //                              viewController:viewController
//                                   completion:completion];;
            break;
            
        default:
            break;
    }
}

#pragma mark 新浪微博分享
- (void)ba_sinaShareWithShareType:(BAKit_UMShareType)shareType
                   viewController:(UIViewController *)viewController
                       completion:(UMSocialRequestCompletionHandler)completion
{
    shareType = BAKit_UMShareType_Text_Image;
    if (_shareText && _shareWebpageUrl)
    {
        _shareText = [NSString stringWithFormat:@"%@，分享自：@博爱1616，详见链接：%@", _shareText, _shareWebpageUrl];
    }
    switch (shareType) {
        case BAKit_UMShareType_Text:
            if ([BACommon ba_isNSStringNULL:_shareText])
            {
                NSLog(@"分享失败：纯文本分享中，文本内容不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：纯文本分享中，文本内容不能为空！");
                return;
            }
            [self ba_shareTextToPlatformType:UMSocialPlatformType_Sina
                                   shareText:_shareText
                              viewController:viewController
                                  completion:completion];
            break;
        case BAKit_UMShareType_Image:
            if ([BACommon ba_isNSStringNULL:_shareBigImage])
            {
                NSLog(@"分享失败：shareBigImage 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareBigImage 不能为空！" );
                return;
            }
            [self ba_shareImageToPlatformType:UMSocialPlatformType_Sina
                                   thumbImage:nil
                                     bigImage:_shareBigImage
                               viewController:viewController
                                   completion:completion];
            break;
        case BAKit_UMShareType_Image_Url:
            if ([BACommon ba_isNSStringNULL:_shareImageUrl])
            {
                NSLog(@"分享失败：shareImageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareImageUrl 不能为空！" );
                return;
            }
            [self ba_shareImageURLToPlatformType:UMSocialPlatformType_Sina
                                      thumbImage:nil
                                        imageUrl:_shareImageUrl
                                  viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Web_Link:
            if ([BACommon ba_isNSStringNULL:_shareWebpageUrl])
            {
                NSLog(@"分享失败：shareWebpageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareWebpageUrl 不能为空！" );
                return;
            }
            [self ba_shareWebPageToPlatformType:UMSocialPlatformType_Sina
                                          title:_shareTitle
                                      shareText:_shareText
                                       imageUrl:_shareImageUrl
                                     webpageUrl:_shareWebpageUrl
                                 viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Text_Image:
            /*! 注：友盟此方法暂时只对新浪分享有用 */
            if ([BACommon ba_isNSStringNULL:_shareImageUrl])
            {
                NSLog(@"分享失败：shareImageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareImageUrl 不能为空！" );
                return;
            }
            [self ba_shareImageAndTextToPlatformType:UMSocialPlatformType_Sina
                                           shareText:_shareText
                                          thumbImage:nil
                                            imageUrl:_shareImageUrl
                                      viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Music_Link:
            if ([BACommon ba_isNSStringNULL:_shareMusicUrl])
            {
                NSLog(@"分享失败：shareMusicUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareMusicUrl 不能为空！" );
                return;
            }
            [self ba_shareMusicToPlatformType:UMSocialPlatformType_Sina
                                        title:_shareTitle
                                    shareText:_shareText
                                     imageUrl:_shareImageUrl
                                     musicUrl:_shareMusicUrl
                                 musicDataUrl:_shareMusicDataUrl
                               viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Video_Link:
            if ([BACommon ba_isNSStringNULL:_shareVideoUrl])
            {
                NSLog(@"分享失败：shareVideoUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareVideoUrl 不能为空！" );
                return;
            }
            [self ba_shareVedioToPlatformType:UMSocialPlatformType_Sina
                                        title:_shareTitle
                                    shareText:_shareText
                                     imageUrl:_shareImageUrl
                                     videoUrl:_shareVideoUrl
                               viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Gif:
            NSLog(@"分享失败：受 新浪微博 平台限制，不能分享 gif 动图到 新浪微博！");
            BAKit_ShowAlertWithMsg(@"分享失败：受 新浪微博 平台限制，不能分享 gif 动图到 新浪微博！");
            return;
//            [self ba_shareEmoticonToPlatformType:UMSocialPlatformType_Sina
//                                           title:_shareTitle
//                                       shareText:_shareText
//                                        imageUrl:_shareImageUrl
//                                     gifFilePath:_shareGifFilePath
//                                  viewController:viewController
//                                   completion:completion];;
            break;
        case BAKit_UMShareType_File:
            NSLog(@"分享失败：受 新浪微博 平台限制，不能分享文件到 新浪微博！");
            BAKit_ShowAlertWithMsg(@"分享失败：受 新浪微博 平台限制，不能分享文件到 新浪微博！");
            return;
            //            [self ba_shareFileToPlatformType:UMSocialPlatformType_QQ
            //                                       title:_shareTitle
            //                                   shareText:_shareText
            //                                    imageUrl:_shareImageUrl
            //                                fileFilePath:_shareFileFilePath
            //                           fileFileExtension:_shareFileFileExtension
            //                              viewController:viewController
//                                   completion:completion];;
            break;
            
        default:
            break;
    }
}

#pragma mark qq分享
- (void)ba_qqShareWithShareType:(BAKit_UMShareType)shareType
                 viewController:(UIViewController *)viewController
                     completion:(UMSocialRequestCompletionHandler)completion
{
    switch (shareType) {
        case BAKit_UMShareType_Text:
            if ([BACommon ba_isNSStringNULL:_shareText])
            {
                NSLog(@"分享失败：纯文本分享中，文本内容不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：纯文本分享中，文本内容不能为空！");
                return;
            }
            [self ba_shareTextToPlatformType:UMSocialPlatformType_QQ
                                   shareText:_shareText
                              viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Image:
            if ([BACommon ba_isNSStringNULL:_shareBigImage])
            {
                NSLog(@"分享失败：shareBigImage 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareBigImage 不能为空！" );
                return;
            }
            [self ba_shareImageToPlatformType:UMSocialPlatformType_QQ
                                   thumbImage:nil
                                     bigImage:_shareBigImage
                               viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Image_Url:
            if ([BACommon ba_isNSStringNULL:_shareImageUrl])
            {
                NSLog(@"分享失败：shareImageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareImageUrl 不能为空！" );
                return;
            }
            [self ba_shareImageURLToPlatformType:UMSocialPlatformType_QQ
                                      thumbImage:nil
                                        imageUrl:_shareImageUrl
                                  viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Web_Link:
            if ([BACommon ba_isNSStringNULL:_shareWebpageUrl])
            {
                NSLog(@"分享失败：shareWebpageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareWebpageUrl 不能为空！" );
                return;
            }
            [self ba_shareWebPageToPlatformType:UMSocialPlatformType_QQ
                                          title:_shareTitle
                                      shareText:_shareText
                                       imageUrl:_shareImageUrl
                                     webpageUrl:_shareWebpageUrl
                                 viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Text_Image:
            /*! 注：友盟此方法暂时不能用 */
            if ([BACommon ba_isNSStringNULL:_shareImageUrl])
            {
                NSLog(@"分享失败：shareImageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareImageUrl 不能为空！" );
                return;
            }
            [self ba_shareImageAndTextToPlatformType:UMSocialPlatformType_QQ
                                           shareText:_shareText
                                          thumbImage:nil
                                            imageUrl:_shareImageUrl
                                      viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Music_Link:
            if ([BACommon ba_isNSStringNULL:_shareMusicUrl])
            {
                NSLog(@"分享失败：shareMusicUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareMusicUrl 不能为空！" );
                return;
            }
            [self ba_shareMusicToPlatformType:UMSocialPlatformType_QQ
                                        title:_shareTitle
                                    shareText:_shareText
                                     imageUrl:_shareImageUrl
                                     musicUrl:_shareMusicUrl
                                 musicDataUrl:_shareMusicDataUrl
                               viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Video_Link:
            if ([BACommon ba_isNSStringNULL:_shareVideoUrl])
            {
                NSLog(@"分享失败：shareVideoUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareVideoUrl 不能为空！" );
                return;
            }
            [self ba_shareVedioToPlatformType:UMSocialPlatformType_QQ
                                        title:_shareTitle
                                    shareText:_shareText
                                     imageUrl:_shareImageUrl
                                     videoUrl:_shareVideoUrl
                               viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Gif:
                NSLog(@"分享失败：受 QQ 平台限制，不能分享 gif 动图到 QQ！");
                BAKit_ShowAlertWithMsg(@"分享失败：受 QQ 平台限制，不能分享 gif 动图到 QQ！");
                return;
//            [self ba_shareEmoticonToPlatformType:UMSocialPlatformType_QQ
//                                           title:_shareTitle
//                                       shareText:_shareText
//                                        imageUrl:_shareImageUrl
//                                     gifFilePath:_shareGifFilePath
//                                  viewController:viewController
//                                   completion:completion];;
            break;
        case BAKit_UMShareType_File:
            NSLog(@"分享失败：受 QQ 平台限制，不能分享文件到 QQ！");
            BAKit_ShowAlertWithMsg(@"分享失败：受 QQ 平台限制，不能分享文件到 QQ！");
            return;
//            [self ba_shareFileToPlatformType:UMSocialPlatformType_QQ
//                                       title:_shareTitle
//                                   shareText:_shareText
//                                    imageUrl:_shareImageUrl
//                                fileFilePath:_shareFileFilePath
//                           fileFileExtension:_shareFileFileExtension
//                              viewController:viewController
//                                   completion:completion];;
            break;
            
        default:
            break;
    }
}

#pragma mark Qzone分享
- (void)ba_qZoneShareWithShareType:(BAKit_UMShareType)shareType
                    viewController:(UIViewController *)viewController
                        completion:(UMSocialRequestCompletionHandler)completion
{
    switch (shareType) {
        case BAKit_UMShareType_Text:
            if ([BACommon ba_isNSStringNULL:_shareText])
            {
                NSLog(@"分享失败：纯文本分享中，文本内容不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：纯文本分享中，文本内容不能为空！");
                return;
            }
            [self ba_shareTextToPlatformType:UMSocialPlatformType_Qzone
                                   shareText:_shareText
                              viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Image:
            if ([BACommon ba_isNSStringNULL:_shareBigImage])
            {
                NSLog(@"分享失败：shareBigImage 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareBigImage 不能为空！" );
                return;
            }
            [self ba_shareImageToPlatformType:UMSocialPlatformType_Qzone
                                   thumbImage:nil
                                     bigImage:_shareBigImage
                               viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Image_Url:
            if ([BACommon ba_isNSStringNULL:_shareImageUrl])
            {
                NSLog(@"分享失败：shareImageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareImageUrl 不能为空！" );
                return;
            }
            [self ba_shareImageURLToPlatformType:UMSocialPlatformType_Qzone
                                      thumbImage:nil
                                        imageUrl:_shareImageUrl
                                  viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Web_Link:
            if ([BACommon ba_isNSStringNULL:_shareWebpageUrl])
            {
                NSLog(@"分享失败：shareWebpageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareWebpageUrl 不能为空！" );
                return;
            }
            [self ba_shareWebPageToPlatformType:UMSocialPlatformType_Qzone
                                          title:_shareTitle
                                      shareText:_shareText
                                       imageUrl:_shareImageUrl
                                     webpageUrl:_shareWebpageUrl
                                 viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Text_Image:
            /*! 注：友盟此方法暂时不能用 */
            if ([BACommon ba_isNSStringNULL:_shareImageUrl])
            {
                NSLog(@"分享失败：shareImageUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareImageUrl 不能为空！" );
                return;
            }
            [self ba_shareImageAndTextToPlatformType:UMSocialPlatformType_Qzone
                                           shareText:_shareText
                                          thumbImage:nil
                                            imageUrl:_shareImageUrl
                                      viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Music_Link:
            if ([BACommon ba_isNSStringNULL:_shareMusicUrl])
            {
                NSLog(@"分享失败：shareMusicUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareMusicUrl 不能为空！" );
                return;
            }
            [self ba_shareMusicToPlatformType:UMSocialPlatformType_Qzone
                                        title:_shareTitle
                                    shareText:_shareText
                                     imageUrl:_shareImageUrl
                                     musicUrl:_shareMusicUrl
                                 musicDataUrl:_shareMusicDataUrl
                               viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Video_Link:
            if ([BACommon ba_isNSStringNULL:_shareVideoUrl])
            {
                NSLog(@"分享失败：shareVideoUrl 不能为空！");
                BAKit_ShowAlertWithMsg(@"分享失败：shareVideoUrl 不能为空！" );
                return;
            }
            [self ba_shareVedioToPlatformType:UMSocialPlatformType_Qzone
                                        title:_shareTitle
                                    shareText:_shareText
                                     imageUrl:_shareImageUrl
                                     videoUrl:_shareVideoUrl
                               viewController:viewController
                                   completion:completion];;
            break;
        case BAKit_UMShareType_Gif:
            NSLog(@"分享失败：受 QQ空间 平台限制，不能分享 gif 动图到 QQ空间！");
            BAKit_ShowAlertWithMsg(@"分享失败：受 QQ空间 平台限制，不能分享 gif 动图到 QQ空间！");
            return;
            //            [self ba_shareEmoticonToPlatformType:UMSocialPlatformType_QQ
            //                                           title:_shareTitle
            //                                       shareText:_shareText
            //                                        imageUrl:_shareImageUrl
            //                                     gifFilePath:_shareGifFilePath
            //                                  viewController:viewController
//                                   completion:completion];;
            break;
        case BAKit_UMShareType_File:
            NSLog(@"分享失败：受 QQ空间 平台限制，不能分享文件到 QQ空间！");
            BAKit_ShowAlertWithMsg(@"分享失败：受 QQ空间 平台限制，不能分享文件到 QQ空间！");
            return;
            //            [self ba_shareFileToPlatformType:UMSocialPlatformType_QQ
            //                                       title:_shareTitle
            //                                   shareText:_shareText
            //                                    imageUrl:_shareImageUrl
            //                                fileFilePath:_shareFileFilePath
            //                           fileFileExtension:_shareFileFileExtension
            //                              viewController:viewController
//                                   completion:completion];;
            break;
            
        default:
            break;
    }
}

#pragma mark - 分享列表
- (void)ba_shareListWithShareType:(BAKit_UMShareType)shareType
                   viewController:(UIViewController *)viewController
                       completion:(UMSocialRequestCompletionHandler)completion
{
    BAUMSocialShareUIConfig.sharePageGroupViewConfig.sharePageGroupViewPostionType = UMSocialSharePageGroupViewPositionType_Bottom;
    BAUMSocialShareUIConfig.sharePageScrollViewConfig.shareScrollViewPageItemStyleType = UMSocialPlatformItemViewBackgroudType_IconAndBGRadius;
    BAUMSocialShareUIConfig.shareTitleViewConfig.shareTitleViewTitleString = @"抓娃娃分享";
    BAUMSocialShareUIConfig.shareTitleViewConfig.shareTitleViewTitleColor = [UIColor purpleColor];
    BAUMSocialShareUIConfig.shareCancelControlConfig.shareCancelControlText = @"取消分享";
    
    /*! 在这里预设自己需要分享的平台 */
    [UMSocialUIManager setPreDefinePlatforms:@[
                                            @(UMSocialPlatformType_WechatSession),
                                            @(UMSocialPlatformType_WechatTimeLine),
                                            ]];
    
    BAKit_WeakSelf
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        BAKit_StrongSelf
        if (platformType == UMSocialPlatformType_QQ)
        {
            [self ba_qqShareWithShareType:shareType
                               viewController:viewController
                                   completion:completion];;
        }
        else if (platformType == UMSocialPlatformType_Qzone)
        {
            [self ba_qZoneShareWithShareType:shareType
                                 viewController:viewController
                                   completion:completion];;
        }
        else if (platformType == UMSocialPlatformType_WechatSession)
        {
            [self ba_wechatShareWithShareType:shareType
                               viewController:viewController
                                   completion:completion];;
        }
        else if (platformType == UMSocialPlatformType_WechatTimeLine)
        {
            [self ba_wechatTimeLineShareWithShareType:shareType
                                   viewController:viewController
                                   completion:completion];;
        }
        else if (platformType == UMSocialPlatformType_Sina)
        {
            [self ba_sinaShareWithShareType:shareType
                                   viewController:viewController
                                   completion:completion];;
        }
    }];
}

#pragma mark - 友盟登录

#pragma mark 微信登录
- (void)ba_wechatLoginWithViewController:(UIViewController *)viewController
                   isGetAuthWithUserInfo:(BOOL)isGetAuthWithUserInfo
                           loginCallback:(BAUMLoginCallback)loginCallback
{
    [self ba_UMLoginWithPlatformType:UMSocialPlatformType_WechatSession
                      viewController:viewController
               isGetAuthWithUserInfo:isGetAuthWithUserInfo
                       loginCallback:loginCallback];
}

#pragma mark QQ登录
- (void)ba_qqLoginWithViewController:(UIViewController *)viewController
               isGetAuthWithUserInfo:(BOOL)isGetAuthWithUserInfo
                       loginCallback:(BAUMLoginCallback)loginCallback
{
    [self ba_UMLoginWithPlatformType:UMSocialPlatformType_QQ
                      viewController:viewController
               isGetAuthWithUserInfo:isGetAuthWithUserInfo
                       loginCallback:loginCallback];
}

#pragma mark QZone登录
- (void)ba_qZoneLoginWithViewController:(UIViewController *)viewController
                  isGetAuthWithUserInfo:(BOOL)isGetAuthWithUserInfo
                          loginCallback:(BAUMLoginCallback)loginCallback
{
    [self ba_UMLoginWithPlatformType:UMSocialPlatformType_Qzone
                      viewController:viewController
               isGetAuthWithUserInfo:isGetAuthWithUserInfo
                       loginCallback:loginCallback];
}

#pragma mark 微博登录
- (void)ba_sinaLoginWithViewController:(UIViewController *)viewController
                 isGetAuthWithUserInfo:(BOOL)isGetAuthWithUserInfo
                       loginCallback:(BAUMLoginCallback)loginCallback
{
    [self ba_UMLoginWithPlatformType:UMSocialPlatformType_Sina
                      viewController:viewController
               isGetAuthWithUserInfo:isGetAuthWithUserInfo
                       loginCallback:loginCallback];
}

//#pargma mark - 友盟登录列表
- (void)ba_loginListWithViewController:(UIViewController *)viewController
                 isGetAuthWithUserInfo:(BOOL)isGetAuthWithUserInfo
                         loginCallback:(BAUMLoginCallback)loginCallback{
    BAKit_WeakSelf
    BAUMSocialShareUIConfig.sharePageGroupViewConfig.sharePageGroupViewPostionType = UMSocialSharePageGroupViewPositionType_Bottom;
    BAUMSocialShareUIConfig.sharePageScrollViewConfig.shareScrollViewPageItemStyleType = UMSocialPlatformItemViewBackgroudType_IconAndBGRadius;
    BAUMSocialShareUIConfig.shareTitleViewConfig.shareTitleViewTitleString = @"第三方登录";
    BAUMSocialShareUIConfig.shareTitleViewConfig.shareTitleViewTitleColor = [UIColor redColor];
    BAUMSocialShareUIConfig.shareCancelControlConfig.shareCancelControlText = @"取消登录";
    /*! 在这里预设自己需要登录的平台 */
    [UMSocialUIManager setPreDefinePlatforms:@[
                                            @(UMSocialPlatformType_WechatSession)]];
    
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        
        BAKit_StrongSelf
        if (platformType == UMSocialPlatformType_QQ)
        {
            [self ba_qqLoginWithViewController:viewController
                             isGetAuthWithUserInfo:isGetAuthWithUserInfo
                                     loginCallback:loginCallback];
        }
        else if (platformType == UMSocialPlatformType_Qzone)
        {
            [self ba_qZoneLoginWithViewController:viewController
                                isGetAuthWithUserInfo:isGetAuthWithUserInfo
                                        loginCallback:loginCallback];
        }
        else if (platformType == UMSocialPlatformType_WechatSession)
        {
            [self ba_wechatLoginWithViewController:viewController
                                 isGetAuthWithUserInfo:isGetAuthWithUserInfo
                                         loginCallback:loginCallback];
        }
        else if (platformType == UMSocialPlatformType_Sina)
        {
            [self ba_sinaLoginWithViewController:viewController
                               isGetAuthWithUserInfo:isGetAuthWithUserInfo
                                       loginCallback:loginCallback];
        }
    }];
}

- (void)ba_UMLoginWithPlatformType:(UMSocialPlatformType)platformType
                    viewController:(UIViewController *)viewController
             isGetAuthWithUserInfo:(BOOL)isGetAuthWithUserInfo
                     loginCallback:(BAUMLoginCallback)loginCallback
{
    BAKit_WeakSelf
    if (isGetAuthWithUserInfo)
    {
        [BAUMSocialManager getUserInfoWithPlatform:platformType currentViewController:nil completion:^(id result, NSError *error) {
            BAKit_StrongSelf
            [self callbackWithResult:result
                                   error:error
                           loginCallback:loginCallback];
        }];
        
        
        
        
        
    }
    else
    {
        [BAUMSocialManager authWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
            [self callbackWithResult:result
                                   error:error
                           loginCallback:loginCallback];
        }];
    }
}

- (void)callbackWithResult:(id)result
                     error:(NSError *)error
             loginCallback:(BAUMLoginCallback)loginCallback
{
    NSString *message = nil;
    
    if (error) {
        message = @"登录失败，获取用户信息失败！";
        UMSocialLogInfo(@"登录失败，获取用户信息失败！error %@",error);
    }else{
        if ([result isKindOfClass:[UMSocialUserInfoResponse class]]) {
            
            UMSocialUserInfoResponse *resp = result;
            self.responseDic = resp;
            if (loginCallback)
            {
                loginCallback(resp);
            }
        }else{
            message = @"登录失败，获取用户信息失败！";
        }
    }
    
    if (message) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UserInfo"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"sure", @"确定")
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - 清除授权
- (void)ba_cancelAuthWithPlatformType:(UMSocialPlatformType)platformType
{
    BAKit_WeakSelf
    if (self.responseDic)
    {
        [BAUMSocialManager cancelAuthWithPlatform:platformType completion:^(id result, NSError *error) {
            self.responseDic = nil;
            if (self.authOpFinish)
            {
                self.authOpFinish();
            }
//            NSString *msg = [NSString stringWithFormat:@"清除授权成功！"];
//            BAKit_ShowAlertWithMsg(msg];
        }];
    }
    else
    {
        BAKit_ShowAlertWithMsg(@"您还没有授权信息，不能清除授权！");
    }
}

- (NSString *)authInfoString:(UMSocialUserInfoResponse *)resp
{
    NSMutableString *string = [NSMutableString new];
    if (resp.uid) {
        [string appendFormat:@"uid = %@\n", resp.uid];
    }
    if (resp.openid) {
        [string appendFormat:@"openid = %@\n", resp.openid];
    }
    if (resp.accessToken) {
        [string appendFormat:@"accessToken = %@\n", resp.accessToken];
    }
    if (resp.refreshToken) {
        [string appendFormat:@"refreshToken = %@\n", resp.refreshToken];
    }
    if (resp.expiration) {
        [string appendFormat:@"expiration = %@\n", resp.expiration];
    }
    if (resp.name) {
        [string appendFormat:@"name = %@\n", resp.name];
    }
    if (resp.iconurl) {
        [string appendFormat:@"iconurl = %@\n", resp.iconurl];
    }
    if (resp.gender) {
        [string appendFormat:@"gender = %@\n", resp.gender];
    }
    return string;
}



// 分享成功 调用linda的服务器
- (void)shareSuccussForServer
{
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970] * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f",a];
    
    NSString *postUrl = [NSString stringWithFormat:@"%@%@%@",BAUSER.server,@"HIService.y?cmd=shareSuccess&fromAuid=",BAUSER.auid];
    
    BAKit_WeakSelf
    BANewsNetManager *loginNetManager = [BANewsNetManager new];
    [loginNetManager ba_postStatusWithURL:postUrl parameters:nil success:^(id response) {
        BAKit_StrongSelf
        [BAKit_NotiCenter postNotificationName:@"SHARESUCCUSS" object:nil];
    } failure:^(NSError *error) {
    }];
}

@end

