package com.pdfEditor.EditorTools.shape;

import android.graphics.Paint;
import android.graphics.Path;

public class shape {
    boolean fill;
    private float height;
    private float width;
    private Path path;
    private Paint paint;
    private float radius;
    private int STROKE;

    public boolean isFill() {
        return fill;
    }

    public void setFill(boolean fill) {
        this.fill = fill;
    }

    public int getSTROKE() {
        return STROKE;
    }

    public void setSTROKE(int STROKE) {
        this.STROKE = STROKE;
    }

    public float getHeight() {
        return height;
    }

    public void setHeight(float height) {
        System.out.println("SET HEIIIIIIII " + height);
        this.height = height;
    }

    public float getWidth() {
        return width;
    }

    public void setWidth(float width) {
        this.width = width;
    }

    public Path getPath() {
        return new Path(path);
    }

    public void setPath(Path path) {
        this.path = path;
    }

    public Paint getPaint() {
        return new Paint(paint);
    }

    public void setPaint(Paint paint) {
        this.paint = paint;
    }

    public float getRadius() {
        return radius;
    }

    public void setRadius(float radius) {
        this.radius = radius;
    }
}

class cercle extends shape {


    public cercle(float radius, Paint paint, int STROKE) {
        this.setRadius(radius);
        this.setPaint(paint);
        this.setSTROKE(STROKE);
    }
}

class rectangle extends shape {

    public rectangle(float width, float height, Paint paint, int STROKE) {
        this.setHeight(height);
        this.setWidth(width);
        this.setSTROKE(STROKE);
        this.setPaint(paint);
    }
}

class triangle extends shape {


    public triangle(Path path, Paint paint, int STROKE) {
        setPath(path);
        setPaint(paint);
        setSTROKE(STROKE);
//        this.path = path;
//        this.paint = paint;
    }
}