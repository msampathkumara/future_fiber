package com.pdfEditor.EditorTools.highlight;

import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;

import androidx.annotation.ColorInt;

import com.pdfEditor.xEdits;


public class xHighlight extends xEdits {
    private Path path;


//    public xHighlight(Path path, Paint paint, float translateX, float translateY, int page) {
//        this.path = path;
//        this.paint = paint;
//        this.translateX = translateX;
//        this.translateY = translateY;
//        this.page = page;
//    }

    public xHighlight(Path path, Paint paint, float translateX, float translateY, int page, float PageWidth, float PageHeight, float zoom) {

        this.path = path;
        this.paint = paint;
        this.translateX = translateX;
        this.translateY = translateY;
        this.page = page;
        setPageWidth(PageWidth);
        setPageHeight(PageHeight);
        setZoom(zoom);
    }

    @ColorInt
    private static int adjustAlpha(@ColorInt int color) {
        int alpha = Math.round(Color.alpha(color) * (float) 0.5);
//        alpha = 50;
        System.out.println("alpha " + alpha);
        int red = Color.red(color);
        int green = Color.green(color);
        int blue = Color.blue(color);
        return Color.argb(alpha, red, green, blue);
    }

    public Path getPath() {
        return path;
    }

//    @Override
//    public Paint getPaint() {
//        paint.getColor();
//        Paint p = new Paint(paint);
//        p.setColor(adjustAlpha(p.getColor()));
//        return p;
//    }

    public void setPath(Path path) {
        this.path = path;
    }
}
