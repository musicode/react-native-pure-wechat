
import { NativeEventEmitter, NativeModules } from 'react-native'

const { RNTUmengPush } = NativeModules

const eventEmitter = new NativeEventEmitter(RNTUmengPush)

export default {

  setAdvanced(options) {
    RNTUmengPush.setAdvanced(options)
  },

  start() {
    RNTUmengPush.start()
  },

  addEventListener(type, listener) {
    return eventEmitter.addListener(type, listener)
  }

}
