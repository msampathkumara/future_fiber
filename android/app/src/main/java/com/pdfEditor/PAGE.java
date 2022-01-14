package com.pdfEditor;

import android.graphics.Bitmap;

import androidx.annotation.NonNull;

import com.pdfEditor.EditorTools.freehand.xPath;
import com.pdfEditor.EditorTools.image.xImage;
import com.pdfEditor.EditorTools.textEditor.xText;
import com.pdfviewer.PdfFile;
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
    public float dheight;
    public float pageSpacingTot;
    public float dy;
    //    private   SizeF pageSize;
    float maxPageWidth;
    float maxPageHeight;
    final PdfFile pdfFile;
    //    private SizeF oldPageSize;
    private Bitmap bitmap;
    private boolean edited;
    private xImage image;


    public PAGE(PdfFile pdfFile, float pageYposition, int id) {
        this.position = pageYposition;
//            bitmap = Bitmap.createBitmap((int) pdfView.pdfFile.getMaxPageWidth(), (int) pdfView.pdfFile.getMaxPageHeight(), Bitmap.Config.ARGB_8888);
        this.id = id;
        paths = new ArrayList<>();
        textMap = new ArrayList<>();

        this.pdfFile = pdfFile;
    }


    public float getPosition() {
        return position;
    }

    public Bitmap getBitmap() {
        if (bitmap == null) {

             bitmap = Bitmap.createBitmap((int) pdfFile.getMaxPageWidth(), (int) pdfFile.getMaxPageHeight(), Bitmap.Config.ARGB_8888);

        }
//        System.out.println("__________________________________________GET BITMAP____________________");
        return bitmap;
    }

    public void setBitmap(Bitmap bitmap) {
        this.bitmap = bitmap;
    }

    public void setLargeBitMap() {
        bitmap = Bitmap.createBitmap((int) pdfFile.getMaxPageWidth(), (int) pdfFile.getMaxPageHeight(), Bitmap.Config.ARGB_8888);
    }

    public boolean hasBitmap() {
        if (bitmap == null) {
            return false;
        }
        Bitmap emptyBitmap = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), bitmap.getConfig());
        return !bitmap.sameAs(emptyBitmap);
    }

    public boolean isEdited() {
        return edited;
    }

    public void setEdited(boolean edited) {
        this.edited = edited;
    }

    public xImage getImage() {
        return image;
    }

    public void setImage(xImage image) {
        this.image = image;
    }
}
