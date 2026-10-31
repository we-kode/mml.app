package de.wekode.mml_app

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import com.ryanheise.audioservice.AudioServiceActivity
import android.net.Uri
import android.util.Log
import java.io.ByteArrayOutputStream

class MainActivity: AudioServiceActivity() {
    private val CHANNEL = "de.wekode.mml"

    var content: String? = null
    private var error: String? = null
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getOpenFileUrl" -> {
                    val code = error
                    if (code != null) {
                        result.error(code, null, MAX_FILE_SIZE / (1024 * 1024))
                    } else {
                        result.success(content)
                    }
                    content = null
                    error = null
                }
                "mapUri" -> {
                    var path: String = call.arguments as String
                    result.success(AlbumArtContentProvider.mapUri(Uri.parse(path)).toString())
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleOpenFileUrl(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleOpenFileUrl(intent)
    }

    private fun handleOpenFileUrl(intent: Intent?) {
        val path = intent?.data ?: return
        content = null
        error = null
        try {
            context.contentResolver.openInputStream(path)?.use { inputStream ->
                val bytes = ByteArrayOutputStream()
                val buffer = ByteArray(DEFAULT_BUFFER_SIZE)
                var read = inputStream.read(buffer)
                while (read != -1) {
                    if (bytes.size() + read > MAX_FILE_SIZE) {
                        Log.w(TAG, "Opened file exceeds $MAX_FILE_SIZE bytes and is ignored.")
                        error = "fileTooLarge"
                        return
                    }
                    bytes.write(buffer, 0, read)
                    read = inputStream.read(buffer)
                }
                content = bytes.toString(Charsets.UTF_8.name())
            }
        } catch (e: Exception) {
            Log.w(TAG, "Opened file could not be read.", e)
            error = "fileNotReadable"
        }
    }

    companion object {
        private const val TAG = "MainActivity"
        private const val MAX_FILE_SIZE = 100 * 1024 * 1024
    }
}
