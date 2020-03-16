package com.github.musicode.wechat

import android.app.Application
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.graphics.Bitmap.CompressFormat
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.tencent.mm.opensdk.constants.Build
import com.tencent.mm.opensdk.constants.ConstantsAPI
import com.tencent.mm.opensdk.modelbase.BaseReq
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelmsg.*
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler
import com.tencent.mm.opensdk.openapi.WXAPIFactory
import java.io.ByteArrayOutputStream
import java.util.*


class RNTWechatModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext), IWXAPIEventHandler {

    companion object {

        private lateinit var api: IWXAPI

        private val wechatModules = arrayListOf<RNTWechatModule>()

        private var wechatLoadImage: ((String, (Bitmap?) -> Unit) -> Unit)? = null

        fun init(app: Application, appId: String, loadImage: (String, (Bitmap?) -> Unit) -> Unit) {

            wechatLoadImage = loadImage

            // 通过 WXAPIFactory 工厂，获取 IWXAPI 的实例
            api = WXAPIFactory.createWXAPI(app, appId, true)

            // 将应用的 appId 注册到微信
            api.registerApp(appId)

            // 建议动态监听微信启动广播进行注册到微信
            app.registerReceiver(object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    api.registerApp(appId)
                }
            }, IntentFilter(ConstantsAPI.ACTION_REFRESH_WXAPP))

        }

        fun handleIntent(intent: Intent) {
            for (module in wechatModules) {
                api.handleIntent(intent, module)
            }
        }

    }

    override fun getName(): String {
        return "RNTWechat"
    }

    override fun onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy()
        wechatModules.remove(this)
    }

    override fun initialize() {
        super.initialize()
        wechatModules.add(this)
    }

    @ReactMethod
    fun isInstalled(promise: Promise) {

        val map = Arguments.createMap()
        map.putBoolean("installed", api.isWXAppInstalled)

        promise.resolve(map)

    }

    @ReactMethod
    fun isSupportOpenApi(promise: Promise) {

        val map = Arguments.createMap()
        map.putBoolean("supported", api.wxAppSupportAPI >= Build.OPENID_SUPPORTED_SDK_INT)

        promise.resolve(map)

    }

    @ReactMethod
    fun open(promise: Promise) {

        val map = Arguments.createMap()
        map.putBoolean("success", api.openWXApp())

        promise.resolve(map)

    }

    @ReactMethod
    fun sendAuthRequest(options: ReadableMap, promise: Promise) {

        val req = SendAuth.Req()
        req.scope = options.getString("scope")

        if (options.hasKey("state")) {
            req.state = options.getString("state")
        }

        val map = Arguments.createMap()
        map.putBoolean("success", api.sendReq(req))

        promise.resolve(map)

    }

    @ReactMethod
    fun shareText(options: ReadableMap, promise: Promise) {

        val obj = WXTextObject()
        obj.text = options.getString("text")

        val msg = WXMediaMessage(obj)
        msg.description = options.getString("text")

        val req = SendMessageToWX.Req()
        req.transaction = createUUID()
        req.message = msg
        req.scene = options.getInt("scene")

        // 这个参数貌似是新版 SDK 加的，以前用的版本没传过这个参数
        if (options.hasKey("open_id")) {
            req.userOpenId = options.getString("open_id")
        }

        val map = Arguments.createMap()
        map.putBoolean("success", api.sendReq(req))

        promise.resolve(map)

    }

    @ReactMethod
    fun shareImage(options: ReadableMap, promise: Promise) {

        fun sendShareReq(bitmap: Bitmap?) {

            if (bitmap == null) {
                promise.reject("1", "image is not found.")
                return
            }

            val obj = WXImageObject(bitmap)

            val msg = WXMediaMessage(obj)
            msg.thumbData = null

            val req = SendMessageToWX.Req()
            req.transaction = createUUID()
            req.message = msg
            req.scene = options.getInt("scene")

            // 这个参数貌似是新版 SDK 加的，以前用的版本没传过这个参数
            if (options.hasKey("open_id")) {
                req.userOpenId = options.getString("open_id")
            }

            val map = Arguments.createMap()
            map.putBoolean("success", api.sendReq(req))

            promise.resolve(map)

        }

        val url = options.getString("image_url")!!

        wechatLoadImage?.invoke(url) {
            sendShareReq(it)
        }

    }

    @ReactMethod
    fun shareAudio(options: ReadableMap, promise: Promise) {

        fun sendShareReq(bitmap: Bitmap?) {

            if (bitmap == null) {
                promise.reject("1", "thumbnail is not found.")
                return
            }

            val obj = WXMusicObject()
            obj.musicUrl = options.getString("page_url")
            obj.musicLowBandUrl = obj.musicUrl
            obj.musicDataUrl = options.getString("audio_url")
            obj.musicLowBandDataUrl = obj.musicDataUrl

            val msg = WXMediaMessage(obj)
            msg.title = options.getString("title")
            msg.description = options.getString("description")
            msg.thumbData = bitmap2ByteArray(bitmap)

            val req = SendMessageToWX.Req()
            req.transaction = createUUID()
            req.message = msg
            req.scene = options.getInt("scene")

            // 这个参数貌似是新版 SDK 加的，以前用的版本没传过这个参数
            if (options.hasKey("open_id")) {
                req.userOpenId = options.getString("open_id")
            }

            val map = Arguments.createMap()
            map.putBoolean("success", api.sendReq(req))

            promise.resolve(map)

        }

        val url = options.getString("thumbnail_url")!!

        wechatLoadImage?.invoke(url) {
            sendShareReq(it)
        }

    }

    @ReactMethod
    fun shareVideo(options: ReadableMap, promise: Promise) {

        fun sendShareReq(bitmap: Bitmap?) {

            if (bitmap == null) {
                promise.reject("1", "thumbnail is not found.")
                return
            }

            val obj = WXVideoObject()
            obj.videoUrl = options.getString("video_url")
            obj.videoLowBandUrl = obj.videoUrl

            val msg = WXMediaMessage(obj)
            msg.title = options.getString("title")
            msg.description = options.getString("description")
            msg.thumbData = bitmap2ByteArray(bitmap)

            val req = SendMessageToWX.Req()
            req.transaction = createUUID()
            req.message = msg
            req.scene = options.getInt("scene")

            // 这个参数貌似是新版 SDK 加的，以前用的版本没传过这个参数
            if (options.hasKey("open_id")) {
                req.userOpenId = options.getString("open_id")
            }

            val map = Arguments.createMap()
            map.putBoolean("success", api.sendReq(req))

            promise.resolve(map)

        }

        val url = options.getString("thumbnail_url")!!

        wechatLoadImage?.invoke(url) {
            sendShareReq(it)
        }

    }

    @ReactMethod
    fun sharePage(options: ReadableMap, promise: Promise) {

        fun sendShareReq(bitmap: Bitmap?) {

            if (bitmap == null) {
                promise.reject("1", "thumbnail is not found.")
                return
            }

            val obj = WXWebpageObject()
            obj.webpageUrl = options.getString("page_url")

            val msg = WXMediaMessage(obj)
            msg.title = options.getString("title")
            msg.description = options.getString("description")
            msg.thumbData = bitmap2ByteArray(bitmap)

            val req = SendMessageToWX.Req()
            req.transaction = createUUID()
            req.message = msg
            req.scene = options.getInt("scene")

            // 这个参数貌似是新版 SDK 加的，以前用的版本没传过这个参数
            if (options.hasKey("open_id")) {
                req.userOpenId = options.getString("open_id")
            }

            val map = Arguments.createMap()
            map.putBoolean("success", api.sendReq(req))

            promise.resolve(map)

        }

        val url = options.getString("thumbnail_url")!!

        wechatLoadImage?.invoke(url) {
            sendShareReq(it)
        }

    }

    @ReactMethod
    fun shareMiniProgram(options: ReadableMap, promise: Promise) {

        fun sendShareReq(bitmap: Bitmap?) {

            if (bitmap == null) {
                promise.reject("1", "thumbnail is not found.")
                return
            }

            val obj = WXMiniProgramObject()
            obj.webpageUrl = options.getString("page_url")
            obj.userName = options.getString("mp_name")
            obj.path = options.getString("mp_path")
            obj.withShareTicket = options.getBoolean("with_share_ticket")
            obj.miniprogramType = options.getInt("mp_type")

            val msg = WXMediaMessage(obj)
            msg.title = options.getString("title")
            msg.description = options.getString("description")
            msg.thumbData = bitmap2ByteArray(bitmap)

            val req = SendMessageToWX.Req()
            req.transaction = createUUID()
            req.message = msg
            // 目前只支持会话
            req.scene = SendMessageToWX.Req.WXSceneSession

            // 这个参数貌似是新版 SDK 加的，以前用的版本没传过这个参数
            if (options.hasKey("open_id")) {
                req.userOpenId = options.getString("open_id")
            }

            val map = Arguments.createMap()
            map.putBoolean("success", api.sendReq(req))

            promise.resolve(map)

        }

        val url = options.getString("thumbnail_url")!!

        wechatLoadImage?.invoke(url) {
            sendShareReq(it)
        }

    }

    override fun onReq(baseReq: BaseReq?) {

    }

    override fun onResp(baseResp: BaseResp?) {

        if (baseResp == null) {
            return
        }

        val map = Arguments.createMap()
        map.putInt("err_code", baseResp.errCode)
        map.putString("err_str", baseResp.errStr)

        when (baseResp) {
            is SendAuth.Resp -> {
                val resp = baseResp as SendAuth.Resp
                if (resp.errCode == BaseResp.ErrCode.ERR_OK) {
                    map.putString("code", resp.code)
                    map.putString("state", resp.state)
                    map.putString("url", resp.url)
                    map.putString("lang", resp.lang)
                    map.putString("country", resp.country)
                }
                sendEvent("auth_response", map)
            }
            is SendMessageToWX.Resp -> {
                // 没啥新属性...
                sendEvent("message_response", map)
            }
            else -> {

            }
        }

    }

    private fun sendEvent(eventName: String, params: WritableMap) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                .emit(eventName, params)
    }

    private fun createUUID(): String {
        return UUID.randomUUID().toString()
    }

    private fun bitmap2ByteArray(bitmap: Bitmap): ByteArray {

        val output = ByteArrayOutputStream()
        bitmap.compress(CompressFormat.PNG, 100, output)
        bitmap.recycle()

        val result: ByteArray = output.toByteArray()
        try {
            output.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return result

    }

}