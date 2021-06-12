package com.pdfEditor.uploadEdits;

import com.google.gson.Gson;

import java.util.HashMap;

public class PdfPage {
    private final HashMap<Long, PdfEdit> edits = new HashMap<>();
    float width;
    float height;
    String Svg;

    public float getWidth() {
        return width;
    }

    public void setWidth(float width) {
        this.width = width;
    }

    public float getHeight() {
        return height;
    }

    public void setHeight(float height) {
        this.height = height;
    }

    public String getSvg() {
        return Svg;
    }

    public void setSvg(String svg) {
        Svg = svg;
    }

    public HashMap<Long, PdfEdit> getEdits() {
        return edits;
    }

    public void addEdit(long id, PdfEdit pdfEdit) {
        edits.put(id, pdfEdit);
        System.out.println("edits have " + edits.size() + " Edits");
    }


    public String toJson() {
        Gson gson = new Gson();
        String jsonString = gson.toJson(this);
        return jsonString;
    }


}
