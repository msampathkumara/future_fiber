package com.sampathkumara.northsails.smartwind

import com.tom_roush.pdfbox.multipdf.Splitter
import com.tom_roush.pdfbox.pdmodel.PDDocument
import org.apache.commons.io.FilenameUtils
import java.io.File
import java.io.IOException

class SplitPage {
    var document: PDDocument? = null
    fun split(filePath: String?, pageId: Int) {
        val splitter = Splitter()
        var pages: List<PDDocument>? = null
        try {
            document = PDDocument.load(File(filePath))
            pages = splitter.split(document)
            val pd = pages[pageId]
            val parentFile = File(filePath).parentFile
            val fileNameWithOutExt = FilenameUtils.removeExtension(filePath)
            val out = File(parentFile.toString() + "/" + fileNameWithOutExt + "_" + pageId)
            pd.save(out)
            document!!.close()
            out.deleteOnExit()
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }
}