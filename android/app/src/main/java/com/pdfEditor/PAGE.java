package com.pdfEditor;

import android.graphics.Bitmap;

import androidx.annotation.NonNull;

import com.pdfEditor.EditorTools.freehand.xPath;
import com.pdfEditor.EditorTools.image.xImage;
import com.pdfEditor.EditorTools.textEditor.xText;
import com.pdfviewer.PdfFile;
import com.pdfviewer.util.SizeF;
import com.tom_roush.pdfbox.pdmodel.PDPage;

import java.util.ArrayList;
import java.util.List;

//import com.tom_roush.pdfbox.pdmodel.PDPage;

public class PAGE extends PDPage {

    public final float position;

    public final int id;
    @NonNull
    public final List<xPath> paths;
    @NonNull
    final List<xText> textMap;
    //    public float dheight;
    public float pageSpacingTot;
    public float dy;
    private final SizeF pageSize;

    public SizeF getPageSize() {
        return pageSize;
    }

    float maxPageWidth;
    float maxPageHeight;
    final PdfFile pdfFile;
    //    private SizeF oldPageSize;
    private Bitmap bitmap;
    private boolean edited;
    private xImage image;


    public PAGE(PdfFile pdfFile, float pageYposition, int id, SizeF pageSize) {
        this.position = pageYposition;
//            bitmap = Bitmap.createBitmap((int) pdfView.pdfFile.getMaxPageWidth(), (int) pdfView.pdfFile.getMaxPageHeight(), Bitmap.Config.ARGB_8888);
        this.id = id;
        paths = new ArrayList<>();
        textMap = new ArrayList<>();
        this.pageSize = pageSize;
        this.pdfFile = pdfFile;
    }


    public Bitmap getBitmap() {

        if (bitmap == null) {


            bitmap = Bitmap.createBitmap((int) pageSize.getWidth(), (int) pageSize.getHeight(), Bitmap.Config.ARGB_8888);

        }
        System.out.println("__________________________________________GET BITMAP____________________");
        System.out.println(pageSize);
        System.out.println(pdfFile.getPageSize(id));
        return bitmap;
    }

    public void setBitmap(Bitmap bitmap) {
        this.bitmap = bitmap;
    }


    public void setEdited(boolean edited) {
        this.edited = edited;
    }

}
