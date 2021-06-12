package com.pdfEditor.EditorTools.image;

import android.graphics.Bitmap;

import com.pdfEditor.xEdits;

public class xImage extends xEdits {

    private final Bitmap bitmap;
    private final float canvasX;
    private final float canvasY;

    public xImage(Bitmap bitmap, float translateX, float translateY, float canvasX, float canvasY, int page, float PageWidth, float PageHeight, float zoom) {

        this.bitmap = bitmap;
        this.canvasX = canvasX;
        this.canvasY = canvasY;
        this.translateX = translateX;
        this.translateY = translateY;
        this.page = page;
        setPageWidth(PageWidth);
        setPageHeight(PageHeight);
        setZoom(zoom);
    }

    public Bitmap getBitmap() {
        return bitmap;
    }

    public float getCanvasX() {
        return canvasX;
    }

    public float getCanvasY() {
        return canvasY;
    }
}
