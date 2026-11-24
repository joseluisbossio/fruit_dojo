package ar.abakos.fruit_dojo

import android.media.AudioAttributes
import android.media.SoundPool
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ar.abakos.fruit_dojo/audio"
    private var soundPool: SoundPool? = null
    private val soundMap = HashMap<String, Int>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_GAME)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        soundPool = SoundPool.Builder()
            .setMaxStreams(12)
            .setAudioAttributes(attrs)
            .build()

        loadSound("katana_slash", "assets/audio/katana_slash.wav")
        loadSound("fruit_splat", "assets/audio/fruit_splat.wav")
        loadSound("bomb_explode", "assets/audio/bomb_explode.wav")
        loadSound("combo", "assets/audio/combo.wav")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    val name = call.argument<String>("name")
                    val vol = (call.argument<Double>("volume") ?: 1.0).toFloat()
                    val soundId = soundMap[name]
                    if (soundId != null && soundId != 0 && soundPool != null) {
                        soundPool?.play(soundId, vol, vol, 1, 0, 1.0f)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun loadSound(key: String, assetName: String) {
        try {
            val loader = FlutterInjector.instance().flutterLoader()
            val assetPath = loader.getLookupKeyForAsset(assetName)
            val afd = assets.openFd(assetPath)
            val soundId = soundPool?.load(afd, 1) ?: 0
            soundMap[key] = soundId
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        soundPool?.release()
        soundPool = null
        super.onDestroy()
    }
}
