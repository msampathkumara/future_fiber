package com.pdfEditor.EditorTools.freehand;

import android.graphics.Paint;
import android.graphics.Path;

import com.pdfEditor.xEdits;


public class xPath extends xEdits {
    private Path path;


    public xPath(Path path, Paint paint, float translateX, float translateY, int page, float PageWidth, float PageHeight, float zoom) {

        this.path = path;
        this.paint = paint;
        this.translateX = translateX;
        this.translateY = translateY;
        this.page = page;
        this.pageSize = pageSize;
        setPageWidth(PageWidth);
        setPageHeight(PageHeight);
        setZoom(zoom);

    }

    public Path getPath() {
        return path;
    }

    public void setPath(Path path) {
        this.path = path;
    }


}
