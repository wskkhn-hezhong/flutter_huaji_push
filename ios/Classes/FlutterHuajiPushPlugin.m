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

/// ?????????????????????????????????????????????startXg????????????????????????
- (void)configureClusterDomainName:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    [[XGPush defaultManager] configureClusterDomainName:configurationInfo[@"domainStr"]];
}


/// ??????APPID/APPKEY????????????
- (void)startXg:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    [[XGPush defaultManager] startXGWithAccessID:(uint32_t)[configurationInfo[@"accessId"] integerValue] accessKey:configurationInfo[@"accessKey"] delegate:self];
}

/// ??????Debug
- (void)setEnableDebug:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    [[XGPush defaultManager] setEnableDebug:[configurationInfo[@"enableDebug"] boolValue]];
}

/**===================================V1.0.4????????????????????????===================================*/

/// ????????????
- (void)setAccount:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    [[XGPushTokenManager defaultTokenManager] upsertAccountsByDict:@{ @([self getAccountType:configurationInfo[@"accountType"]]):configurationInfo[@"account"] }];
}

/// ??????????????????
- (void)deleteAccount:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    NSSet *accountsKeys = [[NSSet alloc] initWithObjects:@([self getAccountType:configurationInfo[@"accountType"]]), nil];
    [[XGPushTokenManager defaultTokenManager] delAccountsByKeys:accountsKeys];
}

/// ????????????
- (void)addTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray *tags = call.arguments;
    [[XGPushTokenManager defaultTokenManager] appendTags:tags];
}

/// ????????????(???????????????????????????)
- (void)setTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray *tags = call.arguments;
    [[XGPushTokenManager defaultTokenManager] clearAndAppendTags:tags];
}

/// ??????????????????
- (void)deleteTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray *tags = call.arguments;
    [[XGPushTokenManager defaultTokenManager] delTags:tags];
}

/**===============================V1.0.4?????????????????????????????????===============================*/

/**===================================V1.0.4????????????????????????===================================*/


/**==========================================================================*/


/// ??????????????????TPNS?????????
- (void)setBadge:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *configurationInfo = call.arguments;
    [[XGPush defaultManager] setBadge:[configurationInfo[@"badgeSum"] integerValue]];
}

/// ??????????????????
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
        resultStr = @"????????????";
    }
    [_channel invokeMethod:@"unRegistered" arguments:resultStr];
}

/// ??????????????????????????????
/// @param deviceToken APNs ?????????Device Token
/// @param xgToken TPNS ????????? Token???????????????????????????????????????TPNS ???????????????APNs ??? Device Token???????????????
/// @param error ??????????????????error???nil???????????????????????????
- (void)xgPushDidRegisteredDeviceToken:(nullable NSString *)deviceToken xgToken:(nullable NSString *)xgToken  error:(nullable NSError *)error {
    if (!error) {
        [_channel invokeMethod:@"onRegisteredDone" arguments:deviceToken];
        [[XGPushTokenManager defaultTokenManager] setDelegate:self];
    } else {
        NSString *describeStr = [NSString stringWithFormat:@"TPNS token:%@ error:%@", xgToken, error.description];
        [_channel invokeMethod:@"onRegisteredDeviceToken" arguments:describeStr];
    }
}

/// ???????????????????????????
/// @param notification ????????????(???2?????????NSDictionary???UNNotification??????????????????????????????)
/// @note ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
/// ???????????????????????????xg????????????msgtype???1?????????????????????msgtype???2?????????????????????
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
        /// ????????????????????????
        [_channel invokeMethod:@"onReceiveNotificationResponse" arguments:notificationDic];
    } else {
        /// ????????????
        [_channel invokeMethod:@"onReceiveMessage" arguments:notificationDic];
    }
}

/// ??????????????????
/// @param response ??????iOS 10+/macOS 10.14+??????UNNotificationResponse???????????????????????????NSDictionary
- (void)xgPushDidReceiveNotificationResponse:(nonnull id)response withCompletionHandler:(nonnull void (^)(void))completionHandler {
    NSDictionary *notificationDic = nil;
    if ([response isKindOfClass:[UNNotificationResponse class]]) {
        /// iOS10+???????????????
        notificationDic = ((UNNotificationResponse *)response).notification.request.content.userInfo;
    } else if ([response isKindOfClass:[NSDictionary class]]) {
        /// <IOS10???????????????
        notificationDic = response;
    }
    
    NSLog(@"[TPNS Demo] click notification %@", notificationDic);
    
    [_channel invokeMethod:@"xgPushClickAction" arguments:notificationDic];
    completionHandler();
}

- (void)xgPushDidSetBadge:(BOOL)isSuccess error:(NSError *)error {
    NSString *argumentDescribe = @"??????????????????";
    if (error) {
        argumentDescribe = [NSString stringWithFormat:@"?????????????????????%@",error.description];
    }
    [_channel invokeMethod:@"xgPushDidSetBadge" arguments:argumentDescribe];
}


#pragma mark - XGPushTokenManagerDelegate

/**===============================V1.0.12??????===============================*/

- (void)xgPushDidUpsertAccountsByDict:(NSDictionary *)accountsDict error:(NSError *)error {
    NSString *resultStr = error == nil ? @"??????????????????" : [NSString stringWithFormat:@"?????????????????????error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidBindWithIdentifier" arguments:resultStr];
}
- (void)xgPushDidDelAccountsByKeys:(NSSet<NSNumber *> *)accountsKeys error:(NSError *)error {
    NSString *resultStr = error == nil ? @"??????????????????" : [NSString stringWithFormat:@"?????????????????????error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidUnbindWithIdentifier" arguments:resultStr];
}

- (void)xgPushDidClearAccountsError:(NSError *)error {
    NSString *resultStr = error == nil ? @"??????????????????" : [NSString stringWithFormat:@"?????????????????????error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidClearAllIdentifiers" arguments:resultStr];
}

- (void)xgPushDidAppendTags:(NSArray<NSString *> *)tags error:(NSError *)error {
    NSString *resultStr = error == nil ? @"??????????????????" : [NSString stringWithFormat:@"?????????????????????error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidBindWithIdentifier" arguments:resultStr];
}
- (void)xgPushDidDelTags:(NSArray<NSString *> *)tags error:(NSError *)error {
    NSString *resultStr = error == nil ? @"??????????????????" : [NSString stringWithFormat:@"?????????????????????error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidUnbindWithIdentifier" arguments:resultStr];
}
- (void)xgPushDidClearAndAppendTags:(NSArray<NSString *> *)tags error:(NSError *)error {
    NSString *resultStr = error == nil ? @"??????????????????" : [NSString stringWithFormat:@"?????????????????????error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidUpdatedBindedIdentifier" arguments:resultStr];
}

- (void)xgPushDidClearTagsError:(NSError *)error {
    NSString *resultStr = error == nil ? @"??????????????????" : [NSString stringWithFormat:@"?????????????????????error:%@", error.description];
    [_channel invokeMethod:@"xgPushDidClearAllIdentifiers" arguments:resultStr];
}

/**=======================================================================*/

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
      /// ????????????APNs??????
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (!remoteNotification) {
        /// ????????????TPNS??????
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
