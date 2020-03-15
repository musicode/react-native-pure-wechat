/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import {
  SafeAreaView,
  StyleSheet,
  ScrollView,
  Button,
  StatusBar,
} from 'react-native';

import {
  Colors,
} from 'react-native/Libraries/NewAppScreen';

import Wechat, {
  SCENE_SESSION,
  SCENE_TIMELINE,
  SCENE_FAVORITE,
} from 'react-native-pure-wechat'

const App: () => React$Node = () => {
  return (
    <>
      <StatusBar barStyle="dark-content" />
      <SafeAreaView>
        <ScrollView>
          <Button
            title="isInstalled"
            onPress={() => {
              Wechat.isInstalled().then(data => {
                console.log('isInstalled', data)
              })
            }}
          />
          <Button
            title="isSupportOpenApi"
            onPress={() => {
              Wechat.isSupportOpenApi().then(data => {
                console.log('isSupportOpenApi', data)
              })
            }}
          />
          <Button
            title="getInstallUrl"
            onPress={() => {
              Wechat.getInstallUrl().then(data => {
                console.log('getInstallUrl', data)
              })
            }}
          />
          <Button
            title="getApiVersion"
            onPress={() => {
              Wechat.getApiVersion().then(data => {
                console.log('getApiVersion', data)
              })
            }}
          />
          <Button
            title="open"
            onPress={() => {
              Wechat.open().then(data => {
                console.log('open', data)
              })
            }}
          />
          <Button
            title="sendAuthRequest"
            onPress={() => {
              Wechat.sendAuthRequest({
                scope: 'snsapi_userinfo'
              }).then(data => {
                console.log('sendAuthRequest', data)
              })
            }}
          />
          <Button
            title="shareText session"
            onPress={() => {
              Wechat.shareText({
                text: '你好哈哈哈',
                scene: SCENE_SESSION,
              }).then(data => {
                console.log('shareText', data)
              })
            }}
          />
          <Button
            title="shareText timeline"
            onPress={() => {
              Wechat.shareText({
                text: '你好哈哈哈',
                scene: SCENE_TIMELINE,
              }).then(data => {
                console.log('shareText', data)
              })
            }}
          />
          <Button
            title="shareText favorite"
            onPress={() => {
              Wechat.shareText({
                text: '你好哈哈哈',
                scene: SCENE_FAVORITE,
              }).then(data => {
                console.log('shareText', data)
              })
            }}
          />
          <Button
            title="shareImage session"
            onPress={() => {
              Wechat.shareImage({
                image_url: 'https://xxx',
                scene: SCENE_SESSION,
              }).then(data => {
                console.log('shareImage', data)
              })
            }}
          />
          <Button
            title="shareImage timeline"
            onPress={() => {
              Wechat.shareImage({
                image_url: 'https://xxx',
                scene: SCENE_TIMELINE,
              }).then(data => {
                console.log('shareImage', data)
              })
            }}
          />
          <Button
            title="shareImage favorite"
            onPress={() => {
              Wechat.shareImage({
                image_url: 'https://xxx',
                scene: SCENE_FAVORITE,
              }).then(data => {
                console.log('shareImage', data)
              })
            }}
          />

        </ScrollView>
      </SafeAreaView>
    </>
  );
};

const styles = StyleSheet.create({
  scrollView: {
    backgroundColor: Colors.lighter,
  },
  engine: {
    position: 'absolute',
    right: 0,
  },
  body: {
    backgroundColor: Colors.white,
  },
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
    color: Colors.black,
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
    color: Colors.dark,
  },
  highlight: {
    fontWeight: '700',
  },
  footer: {
    color: Colors.dark,
    fontSize: 12,
    fontWeight: '600',
    padding: 4,
    paddingRight: 12,
    textAlign: 'right',
  },
});

export default App;
