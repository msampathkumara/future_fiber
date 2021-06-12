package com.pdfEditor.EditorTools.shape;

import com.pdfEditor.xEdits;

public class xShape extends xEdits {

    private final shape shape;
    private final float canvasX;
    private final float canvasY;


    int left;
    int top;
    int radius;

    boolean fill;

    public xShape(com.pdfEditor.EditorTools.shape.shape shape, float translateX, float translateY, float canvasX, float canvasY, int page, float PageWidth, float PageHeight, float zoom) {

        this.shape = shape;
        this.canvasX = canvasX;
        this.canvasY = canvasY;
        this.translateX = translateX;
        this.translateY = translateY;
        this.page = page;
        setPageWidth(PageWidth);
        setPageHeight(PageHeight);
        setZoom(zoom);
        setFill(shape.isFill());
    }

    public boolean isFill() {
        return fill;
    }

    public void setFill(boolean fill) {
        this.fill = fill;
    }

    public com.pdfEditor.EditorTools.shape.shape getShape() {
        return shape;
    }

    public float getCanvasX() {
        return canvasX;
    }

    public float getCanvasY() {
        return canvasY;
    }
}
