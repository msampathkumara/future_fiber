package com.pdfEditor.uploadEdits;

import java.util.ArrayList;

public class PdfEdit {
    public static final int TYPE_PATH = 1;
    public static final int TYPE_HIGHT_LIGHT = 2;
    public static final int TYPE_TEXT = 3;
    public static final int TYPE_IMAGE = 7;
    final int type;
    private final long id = System.currentTimeMillis();
    ArrayList<editPoint> pathPoints;
    editsPaint editsPaint;

    String text;
    float positionX;
    float positionY;
    float textSize;
    float rect_width;
    float rect_height;
    boolean textBold;
    boolean textItelic;

    public PdfEdit(int type) {


        this.type = type;


    }





    public void setRect_width(float rect_width) {
        this.rect_width = rect_width;
    }



    public void setRect_height(float rect_height) {
        this.rect_height = rect_height;
    }



    public void setTextSize(float textSize) {
        this.textSize = textSize;
    }



    public void setTextBold(boolean textBold) {
        this.textBold = textBold;
    }



    public void setTextItelic(boolean textItelic) {
        this.textItelic = textItelic;
    }



    public void setPositionX(float positionX) {
        this.positionX = positionX;
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



    public void setPathPoints(ArrayList<editPoint> pathPoints) {
        this.pathPoints = pathPoints;
    }



    public void setEditsPaint(com.pdfEditor.uploadEdits.editsPaint editsPaint) {
        this.editsPaint = editsPaint;
    }




}
