package com.pdfEditor.uploadEdits;

import android.graphics.Color;

public class editsPaint {

    String color;
    float stroke;
    float opacity;

    public float getOpacity() {
        return opacity;
    }

    public void setOpacity(float opacity) {
        this.opacity = opacity;
    }

    public float getStroke() {
        return stroke;
    }

    public void setStroke(float stroke) {
        this.stroke = stroke;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public void setColor(int color) {
        color = Color.rgb(Color.red(color), Color.green(color), Color.blue(color));
        this.color = "rgb(" + Color.red(color) + "," + Color.green(color) + "," + Color.blue(color) + ")";
        setOpacity(Color.alpha(color));
    }
}
