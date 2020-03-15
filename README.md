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

modify `AppDelegate.m`

```oc
#import <RNTDimension.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  ...
  // add this line
  [RNTDimension bind:rootView];
  return YES;
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
