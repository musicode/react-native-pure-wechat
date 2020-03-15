
import { NativeEventEmitter, NativeModules } from 'react-native'

const { RNTWechat } = NativeModules

const eventEmitter = new NativeEventEmitter(RNTWechat)

let resolveAuth
let resolveShare

eventEmitter.addListener('auth', function (data) {
  console.log('auth response', data)
  if (resolveAuth) {
    resolveAuth(data)
    resolveAuth = null
  }
})

eventEmitter.addListener('share', function (data) {
  console.log('share response', data)
  if (resolveShare) {
    resolveShare(data)
    resolveShare = null
  }
})

function shareMessage(promise) {
  return promise.then(data => {
    if (data.success) {
      return new Promise(resolve => {
        resolveShare = resolve
      })
    }
    return data
  })
}

// 分享给朋友
export const SCENE_SESSION = 0
// 分享到朋友圈
export const SCENE_TIMELINE = 1
// 分享到收藏
export const SCENE_FAVORITE = 0

export default {

  /**
   * 检查微信是否已被用户安装
   */
  isInstalled() {
    return RNTWechat.isInstalled()
  },

  /**
   * 判断当前微信的版本是否支持 Open Api
   */
  isSupportOpenApi() {
    return RNTWechat.isSupportOpenApi()
  },

  /**
   * 获取微信的 itunes 安装地址
   */
  getInstallUrl() {
    return RNTWechat.getInstallUrl()
  },

  /**
   * 获取当前微信 SDK 的版本号
   */
  getApiVersion() {
    return RNTWechat.getApiVersion()
  },

  /**
   * 打开微信
   */
  open() {
    return RNTWechat.open()
  },

  /**
   * 微信登录
   */
  sendAuthRequest(options) {
    return RNTWechat.sendAuthRequest(options)
      .then(data => {
        if (data.success) {
          return new Promise(resolve => {
            resolveAuth = resolve
          })
        }
        return data
      })
  },

  /**
   * 分享文本
   */
  shareText(options) {
    return shareMessage(
      RNTWechat.shareText(options)
    )
  },

  /**
   * 分享图片
   */
  shareImage(options) {
    return shareMessage(
      RNTWechat.shareImage(options)
    )
  },

  /**
   * 分享音频
   */
  shareAudio(options) {
    return shareMessage(
      RNTWechat.shareAudio(options)
    )
  },

  /**
   * 分享视频
   */
  shareVideo(options) {
    return shareMessage(
      RNTWechat.shareVideo(options)
    )
  },

  /**
   * 分享网页
   */
  sharePage(options) {
    return shareMessage(
      RNTWechat.sharePage(options)
    )
  },

  /**
   * 分享小程序
   */
  shareMiniProgram(options) {
    return shareMessage(
      RNTWechat.shareMiniProgram(options)
    )
  },

}
