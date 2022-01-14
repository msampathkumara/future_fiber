package com.pdfEditor;

import android.graphics.Paint;

import com.pdfviewer.util.SizeF;

public class xEdits {
    private final long id = System.currentTimeMillis();
    public float translateX;
    public float translateY;
    public int page;
    public SizeF pageSize;
    public Paint paint;
    float zoom;
    float pageHeight;
    float pageWidth;
    float spacing;

    public float getSpacing() {
        return spacing;
    }

    public void setSpacing(float spacing) {
        this.spacing = spacing;
    }

    public long getId() {
        return id;
    }


    public float getZoom() {
        return zoom;
    }

    public void setZoom(float zoom) {
        this.zoom = zoom;
    }

    public float getPageHeight() {
        return pageHeight;
    }

    public void setPageHeight(float pageHeight) {
        this.pageHeight = pageHeight;
    }

    public float getPageWidth() {
        return pageWidth;
    }

    public void setPageWidth(float pageWidth) {
        this.pageWidth = pageWidth;
    }

    public Paint getPaint() {

        return paint;
    }


    public void setPaint(Paint paint) {
        this.paint = paint;
    }

    public float translateX() {
        return translateX;
    }

    public void translateX(float translateX) {
        this.translateX = translateX;
    }

    public float translateY() {
        return translateY;
    }

    public void translateY(float translateY) {
        this.translateY = translateY;
    }

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }
}
