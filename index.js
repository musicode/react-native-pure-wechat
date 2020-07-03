
import { NativeEventEmitter, NativeModules } from 'react-native'

const { RNTWechat } = NativeModules

const eventEmitter = new NativeEventEmitter(RNTWechat)

let resolveAuth
let rejectAuth
let resolvePay
let rejectPay
let resolveMessage
let rejectMessage

eventEmitter.addListener('auth_response', function (data) {
  if (data.code === 0) {
    if (resolveAuth) {
      resolveAuth(data)
      resolveAuth = rejectAuth = undefined
    }
  }
  else if (rejectAuth) {
    rejectAuth(data)
    resolveAuth = rejectAuth = undefined
  }
})

eventEmitter.addListener('pay_response', function (data) {
  if (data.code === 0) {
    if (resolvePay) {
      resolvePay(data)
      resolvePay = rejectPay = undefined
    }
  }
  else if (rejectPay) {
    rejectPay(data)
    resolvePay = rejectPay = undefined
  }
})

eventEmitter.addListener('message_response', function (data) {
  if (data.code === 0) {
    if (resolveMessage) {
      resolveMessage(data)
      resolveMessage = rejectMessage = undefined
    }
  }
  else if (rejectMessage) {
    rejectMessage(data)
    resolveMessage = rejectMessage = undefined
  }
})

function shareMessage(promise) {
  return new Promise((resolve, reject) => {
    promise.then(data => {
      if (data.success) {
        resolveMessage = resolve
        rejectMessage = reject
      }
      else {
        reject(data)
      }
    })
  })
}

// 分享给朋友
export const SCENE_SESSION = 0
// 分享到朋友圈
export const SCENE_TIMELINE = 1
// 分享到收藏
export const SCENE_FAVORITE = 0

// 小程序类型 - 正式版
export const MP_TYPE_PROD = 0
// 小程序类型 - 测试版
export const MP_TYPE_TEST = 1
// 小程序类型 - 预览版
export const MP_TYPE_PREVIEW = 2

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
   * 打开微信
   */
  open() {
    return RNTWechat.open()
  },

  /**
   * 微信支付
   */
  pay(options) {
    return new Promise((resolve, reject) => {
      RNTWechat
        .pay(options)
        .then(data => {
          if (data.success) {
            resolvePay = resolve
            rejectPay = reject
          }
          else {
            reject(data)
          }
        })
    })
  },

  /**
   * 微信登录
   */
  sendAuthRequest(options) {
    return new Promise((resolve, reject) => {
      RNTWechat
        .sendAuthRequest(options)
        .then(data => {
          if (data.success) {
            resolveAuth = resolve
            rejectAuth = reject
          }
          else {
            reject(data)
          }
        })
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
