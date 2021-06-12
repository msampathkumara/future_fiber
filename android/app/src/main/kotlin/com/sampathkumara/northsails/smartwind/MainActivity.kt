package com.sampathkumara.northsails.smartwind

import android.content.Intent
import androidx.annotation.NonNull
import com.pdfEditor.MainEditorActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "editPdf"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        println("ccccccccccccccccccccccccccccccccccccccccccccccc")
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            println("method callllllllll0000000==" + call.method);
//            val fileID = call.argument<Int>("fileID")

            if ("editPdf" == call.method) {

                val fileID = call.argument<Int>("fileID")
                val path = call.argument<String>("path")


                val i = Intent(this, MainEditorActivity::class.java)
                i.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                i.putExtra("ticketId", fileID)
                i.putExtra("path", path)
                startActivityForResult(i, 0)
            }
        }
    }
}
