package com.sampathkumara.northsails.smartwind

import android.content.Intent
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import com.pdfEditor.MainEditorActivity
import com.tom_roush.pdfbox.multipdf.Splitter
import com.tom_roush.pdfbox.pdmodel.PDDocument
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.apache.commons.io.FilenameUtils
import java.io.File
import java.io.IOException
import io.flutter.plugins.webviewflutter.FlutterWebView


class MainActivity : FlutterActivity() {



    private val editPdf: Int = 0
    private val CHANNEL = "editPdf"
    var editPdfResult: MethodChannel.Result? = null


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

                println("$fileID _$path _$ticket")


                val i = Intent(this, MainEditorActivity::class.java)
                i.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                i.putExtra("ticketId", fileID)
                i.putExtra("path", path)
                i.putExtra("ticket", ticket)
                startActivityForResult(i, editPdf)

            } else if ("splitPage" == call.method) {
                editPdfResult = result
                val filePath = call.argument<String>("path")
                val pageIndex = call.argument<Int>("page")
                println(" _$filePath _$pageIndex ")


                val splitter = Splitter()
                val out: File;
                try {
                    val document: PDDocument = PDDocument.load(File(filePath))
                    val pages: List<PDDocument> = splitter.split(document)
                    val pd = pages[pageIndex!!]
                    val parentFile = File(filePath).parentFile
                    val fileNameWithOutExt = FilenameUtils.removeExtension(filePath)
                    out = File(fileNameWithOutExt + "_" + pageIndex + ".pdf")
                    println(  fileNameWithOutExt + "_" + pageIndex + ".pdf");
                    println(out.absolutePath);
                    println("------------------------------------------------------------------------------------------------");
                    pd.save(out)
                    document.close()
                    result.success(out.absolutePath)
                } catch (e: IOException) {
                    e.printStackTrace()

                }


            }else if ("addWebViewFile" == call.method) {

                val filePath = call.argument<String>("path")




            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, @Nullable data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == editPdf && editPdfResult != null) {
            editPdfResult!!.success(data?.getBooleanExtra("edited", false))
        }
    }
}
