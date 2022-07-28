#import "FlutterHuajiPushPlugin.h"
#import <TPNS-iOS/XGPush.h>
#import <TPNS-iOS/XGPushPrivate.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface  FlutterHuajiPushPlugin()<XGPushDelegate, XGPushTokenManagerDelegate>

@end

@implementation FlutterHuajiPushPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
   FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_huaji_push"
            binaryMessenger:[registrar messenger]];
  FlutterHuajiPushPlugin* instance = [[FlutterHuajiPushPlugin alloc] init];
  instance.channel = channel;
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"xgSdkVersion" isEqualToString:call.method]) {
    result([[XGPush defaultManager] sdkVersion]);
  } else if([@"xgToken" isEqualToString:call.method]) {
      result([[XGPushTokenManager defaultTokenManager] xgTokenString]);
  } else if([@"startXg" isEqualToString:call.method]) {
      [self startXg:call result:result];
  } else if([@"setEnableDebug" isEqualToString:call.method]) {
      [self setEnableDebug:call result:result];
  } else if([@"setAccount" isEqualToString:call.method]) {
      [self setAccount:call result:result];
  } else if([@"deleteAccount" isEqualToString:call.method]) {
      [self deleteAccount:call result:result];
  } else if([@"cleanAccounts" isEqualToString:call.method]) {
      [[XGPushTokenManager defaultTokenManager] clearAccounts];
  } else if([@"addTags" isEqualToString:call.method]) {
      [self addTags:call result:result];
  } else if([@"setTags" isEqualToString:call.method]) {
      [self setTags:call result:result];
  } else if([@"deleteTags" isEqualToString:call.method]) {
      [self deleteTags:call result:result];
  } else if([@"cleanTags" isEqualToString:call.method]) {
      [[XGPushTokenManager defaultTokenManager] clearTags];
  } else if([@"setBadge" isEqualToString:call.method]) {
      [self setBadge:call result:result];
  } else if([@"setAppBadge" isEqualToString:call.method]) {
      [self setAppBadge:call result:result];
  } else if([@"stopXg" isEqualToString:call.method]) {
      [[XGPush defaultManager] stopXGNotification];
  } else if([@"configureClusterDomainName" isEqualToString:call.method]) {
      [self configureClusterDomainName:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSUInteger)getAccountType:(NSString *)typeStr {
    return 0;
}

/// 集群域名配置（非广州集群需要在startXg之前调用此函数）
- (void)configureClusterDomainName:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    [[XGPush defaultManager] configureClusterDomainName:configurationInfo[@"domainStr"]];
}


/// 使用APPID/APPKEY启动信鸽
- (void)startXg:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    [[XGPush defaultManager] startXGWithAccessID:(uint32_t)[configurationInfo[@"accessId"] integerValue] accessKey:configurationInfo[@"accessKey"] delegate:self];
}

/// 设置Debug
- (void)setEnableDebug:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    [[XGPush defaultManager] setEnableDebug:[configurationInfo[@"enableDebug"] boolValue]];
}

/**===================================V1.0.4新增账号标签接口===================================*/

/// 绑定账号
- (void)setAccount:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    [[XGPushTokenManager defaultTokenManager] upsertAccountsByDict:@{ @([self getAccountType:configurationInfo[@"accountType"]]):configurationInfo[@"account"] }];
}

/// 删除指定账号
- (void)deleteAccount:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    NSSet *accountsKeys = [[NSSet alloc] initWithObjects:@([self getAccountType:configurationInfo[@"accountType"]]), nil];
    [[XGPushTokenManager defaultTokenManager] delAccountsByKeys:accountsKeys];
}

/// 追加标签
- (void)addTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray *tags = call.arguments;
    [[XGPushTokenManager defaultTokenManager] appendTags:tags];
}

/// 覆盖标签(清除所有标签再追加)
- (void)setTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray *tags = call.arguments;
    [[XGPushTokenManager defaultTokenManager] clearAndAppendTags:tags];
}

/// 删除指定标签
- (void)deleteTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray *tags = call.arguments;
    [[XGPushTokenManager defaultTokenManager] delTags:tags];
}

/**===============================V1.0.4请使用以上账号标签接口===============================*/

/**===================================V1.0.4废弃账号标签接口===================================*/


/**==========================================================================*/


/// 同步角标值到TPNS服务器
- (void)setBadge:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    [[XGPush defaultManager] setBadge:[configurationInfo[@"badgeSum"] integerValue]];
}

/// 设置应用角标
- (void)setAppBadge:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    dispatch_async(dispatch_get_main_queue(), ^{
        [XGPush defaultManager].xgApplicationBadgeNumber = [configurationInfo[@"badgeSum"] integerValue];
    });
}

#pragma mark - XGPushDelegate
- (void)xgPushDidFinishStart:(BOOL)isSuccess error:(NSError *)error {
    NSLog(@"%s, result %@, error %@", __FUNCTION__, isSuccess?@"OK":@"NO", error);
}

- (void)xgPushDidFinishStop:(BOOL)isSuccess error:(NSError *)error {
    NSString *resultStr = @"";
    if (error) {
        resultStr = [error domain];
    } else {
        resultStr = @"注销完成";
    }
    [_channel invokeMethod:@"unRegistered" arguments:resultStr];
}

/// 注册推送服务成功回调
/// @param deviceToken APNs 生成的Device Token
/// @param xgToken TPNS 生成的 Token，推送消息时需要使用此值。TPNS 维护此值与APNs 的 Device Token的映射关系
/// @param error 错误信息，若error为nil则注册推送服务成功
- (void)xgPushDidRegisteredDeviceToken:(nullable NSString *)deviceToken xgToken:(nullable NSString *)xgToken  error:(nullable NSError *)error {
    if (!error) {
        [_channel invokeMethod:@"onRegisteredDone" arguments:deviceToken];
        [[XGPushTokenManager defaultTokenManager] setDelegate:self];
    } else {
        NSString *describeStr = [NSString stringWithFormat:@"TPNS token:%@ error:%@", xgToken, error.description];
        [_channel invokeMethod:@"onRegisteredDeviceToken" arguments:describeStr];
    }
}

/// 统一接收消息的回调
/// @param notification 消息对象(有2种类型NSDictionary和UNNotification具体解析参考示例代码)
/// @note 此回调为前台收到通知消息及所有状态下收到静默消息的回调（消息点击需使用统一点击回调）
/// 区分消息类型说明：xg字段里的msgtype为1则代表通知消息msgtype为2则代表静默消息
- (void)xgPushDidReceiveRemoteNotification:(nonnull id)notification withCompletionHandler:(nullable void (^)(NSUInteger))completionHandler {
    NSDictionary *notificationDic = nil;
    if ([notification isKindOfClass:[UNNotification class]]) {
        notificationDic = ((UNNotification *)notification).request.content.userInfo;
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    } else if ([notification isKindOfClass:[NSDictionary class]]) {
        notificationDic = notification;
        completionHandler(UIBackgroundFetchResultNewData);
    }
    
    NSLog(@"[TPNS Demo] receive notification %@", notificationDic);
    
    NSDictionary *tpnsInfo = notificationDic[@"xg"];
    NSNumber *msgType = tpnsInfo[@"msgtype"];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive && msgType.integerValue == 1) {
        /// 前台收到通知消息
        [_channel invokeMethod:@"onReceiveNotificationResponse" arguments:notificationDic];
    } else {
        /// 静默消息
        [_channel invokeMethod:@"onReceiveMessage" arguments:notificationDic];
    }
}

/// 统一点击回调
/// @param response 如果iOS 10+/macOS 10.14+则为UNNotificationResponse，低于目标版本则为NSDictionary
- (void)xgPushDidReceiveNotificationResponse:(nonnull id)response withCompletionHandler:(nonnull void (^)(void))completionHandler {
    NSDictionary *notificationDic = nil;
    if ([response isKindOfClass:[UNNotificationResponse class]]) {
        /// iOS10+消息体获取
        notificationDic = ((UNNotificationResponse *)response).notification.request.content.userInfo;
    } else if ([response isKindOfClass:[NSDictionary class]]) {
        /// <IOS10消息体获取
        notificationDic = response;
    }
    
    NSLog(@"[TPNS Demo] click notification %@", notificationDic);
    
    [_channel invokeMethod:@"xgPushClickAction" arguments:notificationDic];
    completionHandler();
}

- (void)xgPushDidSetBadge:(BOOL)isSuccess error:(NSError *)error {
    NSString *argumentDescribe = @"设置角标成功";
    if (error) {
        argumentDescribe = [NSString stringWithFormat:@"设置角标失败：%@",error.description];
    }
    [_channel invokeMethod:@"xgPushDidSetBadge" arguments:argumentDescribe];
}


#pragma mark - XGPushTokenManagerDelegate

/**===============================V1.0.12新增===============================*/

- (void)xgPushDidUpsertAccountsByDict:(NSDictionary *)accountsDict error:(NSError *)error {
    NSString *resultStr = error == nil ? @"设置账号成功" : [NSString stringWithFormat:@"设置账号失败，error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidBindWithIdentifier" arguments:resultStr];
}
- (void)xgPushDidDelAccountsByKeys:(NSSet<NSNumber *> *)accountsKeys error:(NSError *)error {
    NSString *resultStr = error == nil ? @"删除账号成功" : [NSString stringWithFormat:@"删除账号失败，error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidUnbindWithIdentifier" arguments:resultStr];
}

- (void)xgPushDidClearAccountsError:(NSError *)error {
    NSString *resultStr = error == nil ? @"清除账号成功" : [NSString stringWithFormat:@"清除账号失败，error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidClearAllIdentifiers" arguments:resultStr];
}

- (void)xgPushDidAppendTags:(NSArray<NSString *> *)tags error:(NSError *)error {
    NSString *resultStr = error == nil ? @"设置标签成功" : [NSString stringWithFormat:@"设置标签失败，error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidBindWithIdentifier" arguments:resultStr];
}
- (void)xgPushDidDelTags:(NSArray<NSString *> *)tags error:(NSError *)error {
    NSString *resultStr = error == nil ? @"删除标签成功" : [NSString stringWithFormat:@"删除标签失败，error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidUnbindWithIdentifier" arguments:resultStr];
}
- (void)xgPushDidClearAndAppendTags:(NSArray<NSString *> *)tags error:(NSError *)error {
    NSString *resultStr = error == nil ? @"更新标签成功" : [NSString stringWithFormat:@"更新标签失败，error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidUpdatedBindedIdentifier" arguments:resultStr];
}

- (void)xgPushDidClearTagsError:(NSError *)error {
    NSString *resultStr = error == nil ? @"清除标签成功" : [NSString stringWithFormat:@"清除标签失败，error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidClearAllIdentifiers" arguments:resultStr];
}

/**=======================================================================*/

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
      /// 远程通知APNs通道
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (!remoteNotification) {
        /// 远程通知TPNS通道
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotification && [localNotification isKindOfClass:[UILocalNotification class]]) {
        NSDictionary *tpnsInfo = [localNotification.userInfo objectForKey:@"xg"];
        if (tpnsInfo && [tpnsInfo isKindOfClass:[NSDictionary class]]) {
            NSNumber *msgType = [tpnsInfo objectForKey:@"msgtype"];
            if (msgType && [msgType isKindOfClass:[NSNumber class]] && msgType.intValue == 1) {
                remoteNotification = localNotification.userInfo;
            }
        }
#pragma clang diagnostic pop
    }
    }
    if (remoteNotification && [remoteNotification isKindOfClass:[NSDictionary class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_channel invokeMethod:@"xgPushClickAction" arguments:remoteNotification];
        });
    }
    return YES;
}
@end
