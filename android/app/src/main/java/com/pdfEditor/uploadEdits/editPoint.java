package com.pdfEditor.uploadEdits;

public class editPoint {


    float x;
    float y;
    boolean curve = false;
    public float sp = 0;

    public editPoint(float x, float y, boolean curve) {
        this.x = x;
        this.y = y;
        this.curve = curve;
    }

    public editPoint(float x, float y, boolean curve, float sp) {
        this.x = x;
        this.y = y;
        this.curve = curve;
        this.sp = sp;
    }

    public boolean isCurve() {
        return curve;
    }

    public void setCurve(boolean curve) {
        this.curve = curve;
    }

    public float getX() {
        return x;
    }

    public void setX(float x) {
        this.x = x;
    }

    public float getY() {
        return y;
    }

    public void setY(float y) {
        this.y = y;
    }


}
