package com.sampathkumara.northsails.smartwind

import android.content.Intent
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import com.pdfEditor.MainEditorActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val editPdf: Int = 0
    private val CHANNEL = "editPdf"
       var   editPdfResult : MethodChannel.Result? =null


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        println("ccccccccccccccccccccccccccccccccccccccccccccccc")
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

//            startActivityForResult( { result: ActivityResult ->
//            if (result.resultCode == Activity.RESULT_OK) {
//                val intent = result.intent
//                // Handle the Intent
//            }
//        }

            if ("editPdf" == call.method) {

                editPdfResult = result
                val fileID = call.argument<Int>("fileID")
                val path = call.argument<String>("path")
                val ticket = call.argument<String>("ticket")


                val i = Intent(this, MainEditorActivity::class.java)
                i.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                i.putExtra("ticketId", fileID)
                i.putExtra("path", path)
                i.putExtra("ticket", ticket)
                startActivityForResult(i, editPdf)


            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, @Nullable data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == editPdf && editPdfResult!=null) {
            editPdfResult!!.success(data?.getBooleanExtra("edited", false))
        }
    }
}
