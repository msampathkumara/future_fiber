package com.sampathkumara.northsails.smartwind

import android.content.Intent
import android.webkit.CookieManager
import com.pdfEditor.MainEditorActivity
import com.pdfEditor.QCEditor
import com.Rf.Rf
import com.tom_roush.pdfbox.multipdf.Splitter
import com.tom_roush.pdfbox.pdmodel.PDDocument
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.apache.commons.io.FilenameUtils
import java.io.File
import java.io.IOException


class MainActivity : FlutterActivity() {


    private val editPdf: Int = 0
    private val qaEdit: Int = 1
    private val rf: Int = 2
    private val _CHANNEL = "editPdf"
    private var editPdfResult: MethodChannel.Result? = null


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        CookieManager.getInstance().setAcceptCookie(true)
        super.configureFlutterEngine(flutterEngine)
        println("ccccccccccccccccccccccccccccccccccccccccccccccc")
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, _CHANNEL).setMethodCallHandler { call, result ->


            when (call.method) {
                "editPdf" -> {
                    editPdfResult = result
                    val fileID = call.argument<Int>("fileID")
                    val path = call.argument<String>("path")
                    val ticket = call.argument<String>("ticket")
                    val serverUrl = call.argument<String>("serverUrl")
                    val userCurrentSection = call.argument<String>("userCurrentSection")

                    println("$fileID _$path _$ticket")


                    val i = Intent(this, MainEditorActivity::class.java)
                    i.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                    i.putExtra("ticketId", fileID)
                    i.putExtra("path", path)
                    i.putExtra("ticket", ticket)
                    i.putExtra("serverUrl", serverUrl)
                    i.putExtra("userCurrentSection", userCurrentSection)
                    startActivityForResult(i, editPdf)

                }
                "splitPage" -> {
                    editPdfResult = result
                    val filePath = call.argument<String>("path")
                    val pageIndex = call.argument<Int>("page")
                    println(" _$filePath _$pageIndex ")


                    val splitter = Splitter()
                    val out: File
                    try {
                        val document: PDDocument = PDDocument.load(File(filePath))
                        val pages: List<PDDocument> = splitter.split(document)
                        val pd = pages[pageIndex!!]

                        val fileNameWithOutExt = FilenameUtils.removeExtension(filePath)
                        out = File(fileNameWithOutExt + "_" + pageIndex + ".pdf")
                        pd.save(out)
                        document.close()
                        result.success(out.absolutePath)
                    } catch (e: IOException) {
                        e.printStackTrace()

                    }


                }
                "qcEdit" -> {

                    editPdfResult = result
                    val ticket = call.argument<String>("ticket")
                    val qc = call.argument<Boolean>("qc")
                    val serverUrl = call.argument<String>("serverUrl")
                    val sectionId = call.argument<String>("sectionId")
                    val userCurrentSection = call.argument<String>("userCurrentSection")

                    println(" $qc---------------------------------- _$ticket")
                    println("----sectionId------------------------------ _$sectionId")


                    val i = Intent(this, QCEditor::class.java)
                    i.putExtra("ticket", ticket)
                    i.putExtra("qc", qc)
                    i.putExtra("serverUrl", serverUrl)
                    i.putExtra("sectionId", sectionId)
                    i.putExtra("userCurrentSection", userCurrentSection)
                    startActivityForResult(i, qaEdit)


                }
                "rf" -> {

//                    editPdfResult = result
//                    val ticket = call.argument<String>("ticket")
//                    val qc = call.argument<Boolean>("qc")
//                    val serverUrl = call.argument<String>("serverUrl")
//                    val sectionId = call.argument<String>("sectionId")
//                    val userCurrentSection = call.argument<String>("userCurrentSection")
//
//                    println(" $qc---------------------------------- _$ticket")
//                    println("----sectionId------------------------------ _$sectionId")

                    println("=========================================>> RF")

                    val i = Intent(this, Rf::class.java)
                    i.putExtra("rf_user", "{uname:'MalithG',pword:'abc@123'}")
                    i.putExtra("ticket", "{id:1,mo:'mo-12345'}")
//                    i.putExtra("qc", qc)
//                    i.putExtra("serverUrl", serverUrl)
//                    i.putExtra("sectionId", sectionId)
//                    i.putExtra("userCurrentSection", userCurrentSection)
                    startActivityForResult(i, rf)


                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == editPdf && editPdfResult != null) {
            editPdfResult!!.success(data?.getBooleanExtra("edited", false))
        } else if (requestCode == qaEdit && editPdfResult != null) {
            editPdfResult!!.success(data?.getBooleanExtra("edited", true))
        }
    }
}
