package com.pdfEditor.uploadEdits;

import java.util.ArrayList;

public class PdfEdit {
    public static final int TYPE_PATH = 1;
    public static final int TYPE_HIGHT_LIGHT = 2;
    public static final int TYPE_TEXT = 3;
    public static final int TYPE_RECTANGLE = 4;
    public static final int TYPE_CERCLE = 5;
    public static final int TYPE_TRIANGLE = 6;
    public static final int TYPE_IMAGE = 7;
    final int type;
    private final long id = System.currentTimeMillis();
    ArrayList<editPoint> pathPoints;
    editsPaint editsPaint;
    String pathSvg;
    String text;
    float positionX;
    float positionY;
    float textSize;
    float rect_width;
    float rect_height;
    float radius;
    String ImageBytes;
    boolean fill;
    boolean textBold;
    boolean textItelic;

    public PdfEdit(int type) {


        this.type = type;


    }

    public static int getTypePath() {
        return TYPE_PATH;
    }

    public String getImageBytes() {
        return ImageBytes;
    }

    public void setImageBytes(String imageBytes) {
        ImageBytes = imageBytes;
    }

    public float getRadius() {
        return radius;
    }

    public void setRadius(float radius) {
        this.radius = radius;
    }

    public boolean isFill() {
        return fill;
    }

    public void setFill(boolean fill) {
        this.fill = fill;
    }

    public float getRect_width() {
        return rect_width;
    }

    public void setRect_width(float rect_width) {
        this.rect_width = rect_width;
    }

    public float getRect_height() {
        return rect_height;
    }

    public void setRect_height(float rect_height) {
        this.rect_height = rect_height;
    }

    public float getTextSize() {
        return textSize;
    }

    public void setTextSize(float textSize) {
        this.textSize = textSize;
    }

    public boolean isTextBold() {
        return textBold;
    }

    public void setTextBold(boolean textBold) {
        this.textBold = textBold;
    }

    public boolean isTextItelic() {
        return textItelic;
    }

    public void setTextItelic(boolean textItelic) {
        this.textItelic = textItelic;
    }

    public float getPositionX() {
        return positionX;
    }

    public void setPositionX(float positionX) {
        this.positionX = positionX;
    }

    public float getPositionY() {
        return positionY;
    }

    public void setPositionY(float positionY) {
        this.positionY = positionY;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public long getId() {
        return id;
    }

    public int getType() {
        return type;
    }

    public ArrayList<editPoint> getPathPoints() {
        return pathPoints;
    }

    public void setPathPoints(ArrayList<editPoint> pathPoints) {
        this.pathPoints = pathPoints;
    }

    public com.pdfEditor.uploadEdits.editsPaint getEditsPaint() {
        return editsPaint;
    }

    public void setEditsPaint(com.pdfEditor.uploadEdits.editsPaint editsPaint) {
        this.editsPaint = editsPaint;
    }

    public String getPathSvg() {
        return pathSvg;
    }

    public void setPathSvg(String pathSvg) {
        this.pathSvg = pathSvg;
    }
}
