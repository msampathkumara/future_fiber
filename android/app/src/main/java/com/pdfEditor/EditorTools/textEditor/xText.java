package com.pdfEditor.EditorTools.textEditor;


import android.graphics.Paint;

import com.pdfEditor.xEdits;

public class xText extends xEdits {
    private final float canvasX;
    private final float canvasY;
    private String Text;

    public xText(String Text, Paint paint, float translateX, float translateY, float canvasX, float canvasY, int page, float PageWidth, float PageHeight, float zoom) {

        this.Text = Text;
        this.paint = paint;
        this.canvasX = canvasX;
        this.canvasY = canvasY;
        this.translateX = translateX;
        this.translateY = translateY;
        this.page = page;
        setPageWidth(PageWidth);
        setPageHeight(PageHeight);
        setZoom(zoom);
    }

    public float getCanvasX() {
        return canvasX;
    }

    public float getCanvasY() {
        return canvasY;
    }

    public String getText() {
        return Text;
    }

    public void setText(String text) {
        Text = text;
    }
}
