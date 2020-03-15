# react-native-pure-wechat

This is a module which help you get screen wechat info.

## Installation

```
npm i react-native-pure-wechat
// link below 0.60
react-native link react-native-pure-wechat
```

## Setup

### iOS

在 [微信开放平台](https://open.weixin.qq.com/) 获取 `appId`，并配置 `universalLink`。

在 `Xcode` 中，选择你的工程设置项，选中 `TARGETS` 一栏，在 `Info` 标签栏的`URL Types` 添加 `URL Scheme` 为你所注册的 `appId`。

![](https://res.wx.qq.com/op_res/ohBULcCbr3PPan9SwnrNM6fEr-4kGDn98NenybClk1-fZE2rRYqU6xJCyVIMoFo9)

在 `Xcode` 中，选择你的工程设置项，选中 `TARGETS` 一栏，在 `Info` 标签栏的`LSApplicationQueriesSchemes` 添加 `weixin` 和 `weixinULAPI`。

![](https://res.wx.qq.com/op_res/jck8iqKH85F0BaUWOT3GsSNmuGiOajiC-0bUWehibxED9c4JCauEun6UAZFh3HdO)

最后修改 `AppDelegate.m`：

```oc
// 导入库
#import <RNTWechat.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  ...
  // 初始化
  [RNTWechat init:@"appId" universalLink:@"universalLink" loadImage:^(NSString *url, void (^ completion)(UIImage *)) {

    // 加载网络图片
    // 加载成功后调用 completion

  }];
  return YES;
}

// 添加此方法
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options {
  return [RNTWechat handleOpenURL:application openURL:url options:options];
}

// 添加此方法
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
  return [RNTWechat handleOpenUniversalLink:userActivity];
}
```

### Android

`android/build.gradle` add the umeng maven repo.

```
allprojects {
    repositories {
        // add this line
        maven { url 'https://dl.bintray.com/umsdk/release' }
    }
}
```

## Usage

```js
import wechat from 'react-native-pure-wechat'

```
