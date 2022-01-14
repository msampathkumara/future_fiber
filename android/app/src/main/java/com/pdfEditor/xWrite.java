package com.pdfEditor;

import android.graphics.Bitmap;

public class xWrite extends xEdits {

    private final Bitmap bitmap;
    private final float canvasX;
    private final float canvasY;

    public xWrite(Bitmap bitmap, float translateX, float translateY, float canvasX, float canvasY, int page) {

        this.bitmap = bitmap;
        this.canvasX = canvasX;
        this.canvasY = canvasY;
        this.translateX = translateX;
        this.translateY = translateY;
        this.page = page;
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
