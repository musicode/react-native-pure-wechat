# react-native-pure-wechat

封装微信 SDK，支持 `微信登录` 和 `微信分享`。

SDK 版本：

* ios: 1.8.6
* android: 最新版（写文档此刻是 5.5.8）

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

在 [微信开放平台](https://open.weixin.qq.com/) 获取 `appId`。

在你的包名相应目录下新建一个 `wxapi` 目录，并在该 `wxapi` 目录下新增一个 `WXEntryActivity` 类，该类继承自 `Activity`。

```kotlin
package your-package-name.wxapi

import android.app.Activity
import android.os.Bundle

import com.theweflex.react.RNTWeChatModule

class WXEntryActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        RNTWeChatModule.handleIntent(this.intent)
        finish()
    }

}
```

在 `manifest` 文件里面加上 `exported`、`taskAffinity` 及 `launchMode` 属性，其中 `exported` 设置为 `true`， `taskAffinity` 设置为你的包名，`launchMode` 设置为 `singleTask`：

```xml
<activity
    android:name=".wxapi.WXEntryActivity"
    android:label="@string/app_name"
    android:theme="@android:style/Theme.Translucent.NoTitleBar"
    android:exported="true"
    android:taskAffinity="填写你的包名"
    android:launchMode="singleTask">
</activity>
```

最后，在 `MainApplication` 的 `onCreate` 方法进行初始化：

```kotlin
override fun onCreate() {
  RNTWechatModule.init(
    this,
    "appId",
    (url: String, completion: (String) -> Unit) {
      // 加载网络图片
      // 加载成功后调用 completion
    }
  )
}
```

## Usage

```js

import wechat, {
  // 分享给朋友
  SCENE_SESSION,
  // 分享到朋友圈
  SCENE_TIMELINE,
  // 分享到收藏
  SCENE_FAVORITE,
} from 'react-native-pure-wechat'

// 微信登录
wechat.sendAuthRequest({
  scope: 'snsapi_userinfo'
})
.then(response => {
  response.code
})

// 分享文本
wechat.shareText({
  text: 'xxxxx',
  scene: SCENE_SESSION,
})

// 分享图片
wechat.shareImage({
  image_url: 'https://xxx',
  scene: SCENE_SESSION,
})

// 分享音频
wechat.shareAudio({
  // 音频网页地址
  page_url: 'https://xxx',
  // 音频地址
  audio_url: 'https://xxx',
  // 缩略图地址，支持网络图片和本地图片
  thumbnail_url: 'https://xxx',
  title: '',
  description: '',
  scene: SCENE_SESSION,
})

// 分享视频
wechat.shareVideo({
  // 视频地址
  video_url: 'https://xxx',
  // 缩略图地址，支持网络图片和本地图片
  thumbnail_url: 'https://xxx',
  title: '',
  description: '',
  scene: SCENE_SESSION,
})

// 分享网页
wechat.sharePage({
  // 网页地址
  page_url: 'https://xxx',
  // 缩略图地址，支持网络图片和本地图片
  thumbnail_url: 'https://xxx',
  title: '',
  description: '',
  scene: SCENE_SESSION,
})

```
