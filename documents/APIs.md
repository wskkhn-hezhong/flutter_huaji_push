## 通用 API 接口说明

#### 1. 注册推送服务
      /// iOS需传accessId和accessKey
      /// android不需要传参数
```dart
      void startXg(String accessId, String accessKey);
```

#### 2. 注销推送服务
```dart
      void stopXg();
```

#### 3. 设置debug模式
```dart
      void setEnableDebug(bool enableDebug);
```

#### 4. 账号类型枚举
      /// UNKNOWN 未知类型，单账号绑定默认使用
      /// CUSTOM 自定义
      /// IDFA 广告唯一标识，iOS 专用，安卓侧默认为UNKNOWN类型
      /// PHONE_NUMBER 手机号码
      /// WX_OPEN_ID 微信 OPENID
      /// QQ_OPEN_ID QQ OPENID
      /// EMAIL 邮箱
      /// SINA_WEIBO 新浪微博
      /// ALIPAY 支付宝
      /// TAOBAO 淘宝
      /// DOUBAN 豆瓣
      /// BAIDU 百度
      /// JINGDONG 京东
      /// IMEI 安卓手机标识，安卓专用，iOS默认为UNKNOWN类型
```dart
      enum AccountType { UNKNOWN, CUSTOM, IDFA, PHONE_NUMBER, WX_OPEN_ID, QQ_OPEN_ID, EMAIL, SINA_WEIBO, ALIPAY, TAOBAO, DOUBAN, FACEBOOK, TWITTER, GOOGLE, BAIDU, JINGDONG, LINKEDIN, IMEI }
```

#### 5. 设置账号
      /// account 账号标识
      /// accountType 账号类型枚举
```dart
      void setAccount(String account, AccountType accountType);
```

#### 6. 删除指定账号
      /// account 账号标识
      /// accountType 账号类型枚举
```dart
      void deleteAccount(String account, AccountType accountType);
```

#### 7. 删除所有账号
```dart
      void cleanAccounts();
```

####  8. 追加标签
      /// tags 标签字符串数组(标签字符串不允许有空格或者是tab字符)
```dart
      void addTags(List<String> tags);
```

#### 9. 覆盖标签(清除所有标签再追加)
      /// tags 标签字符串数组(标签字符串不允许有空格或者是tab字符)
```dart
      void setTags(List<String> tags);
```

#### 10. 删除指定标签
      /// tags 标签字符串数组(标签字符串不允许有空格或者是tab字符)
```dart
      void deleteTags(List<String> tags);
```

#### 11. 清除所有标签
```dart
      void cleanTags();
```

#### 12. 同步角标（同步角标值到TPNS，仅iOS）
      /// badgeSum 角标值
```dart
      void setBadge(int badgeSum);
```

#### 13. 设置应用角标（同步到TPNS成功后用于设置应用角标数，仅iOS）
      /// badgeSum 角标值
```dart
      void setAppBadge(int badgeSum);
```

#### 14. 获取 XgAndroidApi
    /// 获取 XgAndroidApi 调用Android里的api接口
```dart
    XgAndroidApi getXgAndroidApi();
```

## 安卓端 XgAndroidApi 接口说明

> 说明：XgAndroidApi 为针对安卓独立接口的内部再次封装，可以通过 `FlutterHuajiPush.xgApi` 直接访问，例如：
> ```dart
>     // 调用示例：开启厂商其他推送接口
>     FlutterHuajiPushPlugin.xgApi.enableOtherPush()
> ```

#### 1  开启其他推送
```dart
    enableOtherPush();
```

#### 2  设置小米推送的APP_ID
```dart
    setMiPushAppId({String appId});
```

#### 3  设置小米推送的APP_KEY
```dart
    setMiPushAppKey({String appKey});
```

#### 4  设置魅族推送所需appID
```dart
    setMzPushAppId({String appId});
```

#### 5  设置魅族推送所需appKey
```dart
    setMzPushAppKey({String appKey});
```

#### 6  开启Oppo通知
```dart
    enableOppoNotification();
```

#### 7  设置Oppo推送ID
```dart
    setOppoPushAppId({String appId});
```

#### 8  设置Oppo推送Key
```dart
     setOppoPushAppKey({String appKey});
```


##  安卓端回调接口说明

#### 1 透传消息、回调接口
```dart
    _onReceiveMessage 数据类型 Map<String, Object> para:
        key:
            title:标题
            content：消息文本
            customMessage：自定义 key-value
            pushChannel：推送通道
```

#### 2 收到通知消息回调
```dart
    _onReceiveNotificationResponse    数据类型 Map<String, Object> para = new HashMap<>()
         key：
             title:标题
             content：消息文本
             customMessage：自定义 key-value
             pushChannel：推送通道
             notifactionId：通知ID
             msgId：消息ID
             activity：活动
             notifactionActionType：通知类型
```

#### 3 通知点击回调
```dart
    _xgPushClickAction   数据类型 Map<String, Object> para:
        kay：
            title:标题
            content：消息文本
            customMessage：自定义 key-value
            msgId：消息ID
            notifactionActionType：通知ID
            activityName：活动名称
            actionType：类型
```

#### 4 注册完成回调
```dart
    _onRegisteredDone   数据类型 String para: 注册成功或者失败信息
```

#### 5 注册完成获取token回调(只有当注册成功获取到token时才会回调)
```dart
    _onRegisteredDeviceToken   数据类型 String para: token
```

#### 6 注销完成的回调
```dart
   _unRegistered   数据类型 String para:  操作成功或者失败信息
```

#### 7 绑定账号和标签回调
```dart
   _xgPushDidBindWithIdentifier   数据类型 String para:  操作成功或者失败信息
```

#### 8 解绑账号和标签回调
```dart
   _xgPushDidUnbindWithIdentifier   数据类型 String para:  操作成功或者失败信息
```

#### 9 清除所有账号和标签回调
```dart
   _xgPushDidClearAllIdentifiers   数据类型 String para:  操作成功或者失败信息
```