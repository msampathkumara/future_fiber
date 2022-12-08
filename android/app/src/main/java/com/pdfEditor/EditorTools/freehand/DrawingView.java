package com.pdfEditor.EditorTools.freehand;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import android.util.DisplayMetrics;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.pdfEditor.Editor;
import com.pdfEditor.PAGE;
import com.pdfEditor.uploadEdits.PdfEdit;
import com.pdfEditor.uploadEdits.editPoint;
import com.pdfEditor.uploadEdits.editsPaint;
import com.pdfviewer.PDFView;

import java.util.ArrayList;

public class DrawingView extends FrameLayout {


    private static final float TOUCH_TOLERANCE = 1;
    private final Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    @NonNull
    private final Path mPath;
    @NonNull
    private final Path circlePath;
    @NonNull
    private final ScaleGestureDetector mScaleDetector;
    private final PDFView pdfView;
    private final Path path = new Path();
    public int width;
    public int height;
    final Editor editor;
    ArrayList<editPoint> points = new ArrayList<>();

    private boolean scaling;
    private int STROKE = 1;
    private Bitmap mBitmap;
    private Rect clipBounds;
    private float Yposition = 0;
    private int mcolor = Color.BLACK;
    private float mScaleFactor = 1.f;
    private Canvas mCanvas;
    private float mY;
    private float mX;
    private boolean isErasing;
    private float mX1;
    private float mY1;
    private int pageNo;


    public DrawingView(@NonNull Context c, PDFView pdfView, final Editor editor) {
        super(c);
        this.pdfView = pdfView;
        this.editor = editor;

        invalidate();

        mPath = new Path();
        Paint circlePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        circlePath = new Path();
        circlePaint.setAntiAlias(true);
        circlePaint.setColor(mcolor);
        circlePaint.setStyle(Paint.Style.STROKE);
        circlePaint.setStrokeJoin(Paint.Join.MITER);
        circlePaint.setStrokeWidth(1f);
        circlePaint.setColor(Color.argb(50, 0, 0, 0));
        mScaleDetector = new ScaleGestureDetector(c, new ScaleListener());
        setBackgroundColor(Color.argb(5, 0, 0, 0));

        p.setAntiAlias(true);
        p.setDither(true);
        p.setStyle(Paint.Style.STROKE);
        p.setStrokeJoin(Paint.Join.ROUND);
        p.setStrokeCap(Paint.Cap.ROUND);
        setColor(Color.rgb(32, 97, 201));

//        setBackgroundColor(Color.argb(100, 32, 97, 201));

    }

    public void setColor(int color) {
        this.mcolor = color;
    }

    @Override
    public boolean onTouchEvent(@NonNull MotionEvent event) {
        mScaleDetector.onTouchEvent(event);
        float zoom = pdfView.getZoom();
        float x = (event.getX() / zoom + clipBounds.left);
        float y = (event.getY() / zoom + clipBounds.top);

        System.out.println(clipBounds.left + "====" + zoom);

        float x1 = event.getX();
        float y1 = event.getY();

        x = event.getX();
        y = event.getY();

        float sp = (((pdfView.pdfFile.getPageSpacing(pdfView.getCurrentPage(), zoom) / 2) * (2 * (pdfView.getCurrentPage() + 1) - 1)) / getCurrentPageHeight());


        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                if (!scaling) {
                    touch_start(x, y);
                    touch_start1(x1, y1, sp);
                    invalidate();

                }
                break;
            case MotionEvent.ACTION_MOVE:
                if (!scaling) {
                    touch_move(x, y, sp);
                    touch_move1(x1, y1);
                    invalidate();
                }
                break;
            case MotionEvent.ACTION_UP:
                if (!scaling) {
                    touch_up(x, y, sp);
                    touch_up1();

                    invalidate();
                }

                scaling = false;
                break;
        }

        return true;
    }

    @Override
    protected void onDraw(@NonNull Canvas canvas) {
        super.onDraw(canvas);
        p.setStrokeWidth(STROKE * pdfView.getZoom());
        p.setColor(mcolor);
        canvas.drawPath(path, p);
//        canvas.drawPath(circlePath, circlePaint);
        clipBounds = canvas.getClipBounds();

//        System.out.println(canvas.getDensity() + ">>>>>>>>>>>>>>>>>>>>>>>>>>>>" + mCanvas.getDensity() + " >>>> " + DisplayMetrics.DENSITY_DEFAULT);
        mCanvas.setDensity(DisplayMetrics.DENSITY_DEFAULT);
    }


    private void touch_start(float x, float y) {

        mPath.reset();
        mPath.moveTo(x, y);
        mX = x;
        mY = y;

    }

    private void touch_start1(float x, float y, float sp) {
        float zoom = pdfView.getZoom();

        points = new ArrayList<>();
        path.reset();
        path.moveTo(x, y);
        mX1 = x;
        mY1 = y;


        points.add(new editPoint(((x / zoom) / getCurrentPageWidth()), (((y / zoom) / getCurrentPageHeight())), false, sp));

    }

    private void touch_move(float x, float y, float sp) {
        float zoom = pdfView.getZoom();

        float dx = Math.abs(x - mX);
        float dy = Math.abs(y - mY);
        if (dx >= TOUCH_TOLERANCE || dy >= TOUCH_TOLERANCE) {
            mPath.quadTo(mX, mY, (x + mX) / 2, (y + mY) / 2);


            points.add(new editPoint(((x / zoom) / getCurrentPageWidth()), (((y / zoom) / getCurrentPageHeight())), true, sp));

            mX = x;
            mY = y;
        }

    }

    private void touch_move1(float x, float y) {
        float dx = Math.abs(x - mX1);
        float dy = Math.abs(y - mY1);
        if (dx >= TOUCH_TOLERANCE || dy >= TOUCH_TOLERANCE) {
            path.quadTo(mX1, mY1, (x + mX1) / 2, (y + mY1) / 2);
            mX1 = x;
            mY1 = y;

            circlePath.reset();
            circlePath.addCircle(mX1, mY1, 30, Path.Direction.CW);
        }
    }

    private void touch_up(float x, float y, float sp) {
        float zoom = pdfView.getZoom();

        System.out.println(mX + " " + mY);
        System.out.println(mX1 + " " + mY1);
        Paint p = new Paint(Paint.DITHER_FLAG);
        p.setAntiAlias(true);
        p.setDither(true);
        p.setStyle(Paint.Style.STROKE);
        p.setStrokeJoin(Paint.Join.ROUND);
        p.setStrokeCap(Paint.Cap.ROUND);

        p.setStrokeWidth(STROKE);
        p.setColor(mcolor);


        mPath.lineTo(mX, mY);


        points.add(new editPoint(((x / zoom) / getCurrentPageWidth()), ((((y) / zoom) / getCurrentPageHeight())), false, sp));


        circlePath.reset();

        if (isErasing)
//            p.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.CLEAR));
            p.setColor(Color.WHITE);
        else
            p.setXfermode(null);


//        float translateX = Math.abs(pdfView.getCurrentXOffset() / zoom);
        float translateX = (pdfView.getCurrentXOffset() / zoom) * -1;
//        float translateY = Math.abs((pdfView.getCurrentYOffset() / zoom)) - (Yposition)  ;
        float translateY = ((pdfView.getCurrentYOffset() / zoom) * -1) - (Yposition);


//        float translateY = Math.abs((pdfView.getCurrentYOffset() / zoom));

        float dheight = (((getHeight() - pdfView.pdfFile.getPageSize(pdfView.getCurrentPage()).getHeight())) / 2);
        float h = (pdfView.getHeight() - (page.getPageSize().getHeight())) / 2;
        float w = (pdfView.getWidth() - (page.getPageSize().getWidth())) / 2;

        System.out.println("------------------------Yposition----__" + Yposition + "___" + h + "___________" + pdfView.getCurrentYOffset());

        for (int i = 0; i < points.size(); i++) {
            editPoint editPoint = points.get(i);
//            System.out.println("88888888888888888888888888888888__" + Yposition + " ==== " + editPoint.getY() + "    ____   " + ((translateY) + " --- " + (getCurrentPageHeight())) + "   **-**   " + editPoint.sp);

            System.out.println("xxxxxxxxxxxx == " + translateX + " === " + editPoint.getX() + " **** " + getCurrentPageWidth());

            editPoint.setX(editPoint.getX() + ((translateX - w) / (getCurrentPageWidth())));
//            editPoint.setY(editPoint.getY() + ((translateY) / (getCurrentPageHeight())) - (editPoint.sp));
            editPoint.setY((editPoint.getY()) + ((translateY) / (getCurrentPageHeight())));

        }


        final xPath xpath = new xPath(new Path(mPath), p, translateX - w, (translateY - dheight), pageNo, getCurrentPageWidth(), getCurrentPageHeight(), zoom);
        editor.editsList.add(xpath);
        mPath.reset();
        editor.reDraw(pageNo);

        editsPaint editsPaint = new editsPaint();
        editsPaint.setColor(p.getColor());
        editsPaint.setStroke(STROKE);
        editsPaint.setOpacity(p.getAlpha() / 255f);


        final PdfEdit pdfEdit = new PdfEdit(PdfEdit.TYPE_PATH);
        pdfEdit.setEditsPaint(editsPaint);
        pdfEdit.setPathPoints(points);
        editor.getPdfEditsList().addEdit(pageNo, xpath.getId(), pdfEdit);


        points = new ArrayList<>();

//        System.out.println("page.getMatrix().getTranslateX()");
//        System.out.println(pdfView.getCurrentXOffset());
//        System.out.println(pdfView.getCurrentYOffset());
//        System.out.println(pdfView.getSpacingPx());
//        System.out.println(translateX);
//        System.out.println(translateY);

    }

    private float getCurrentPageHeight() {
        return pdfView.pdfFile.getPageSize(pdfView.getCurrentPage()).getHeight();
    }

    private float getCurrentPageWidth() {
        return pdfView.pdfFile.getPageSize(pdfView.getCurrentPage()).getWidth();
    }

//    static int nthOdd(int n) {
//        return (2 * n - 1);
//    }

    private void touch_up1() {
        path.lineTo(mX1, mY1);
        path.reset();
        circlePath.reset();
    }


    public Bitmap getBitmap() {
        if (mBitmap == null) {

            mBitmap = Bitmap.createBitmap((int) getCurrentPageWidth(), (int) getCurrentPageHeight(), Bitmap.Config.ARGB_8888);
            System.out.println("getCurrentPageWidth()");
            System.out.println(getCurrentPageWidth());
            mCanvas = new Canvas(mBitmap);
        }
        return mBitmap;

    }

    PAGE page;

    public void setPage(PAGE page) {
        this.page = page;
//        System.out.println("********************" + page.getBBox().getHeight() + "--" + getHeight());

        System.out.println(page.id + "____" + page.position);


        Yposition = page.position;
        mBitmap = page.getBitmap();
        mCanvas = new Canvas(mBitmap);
        pageNo = page.id;


    }

    public void setStroke(int position) {
        STROKE = position;
    }

    public void setEraser(boolean eraser) {
        this.isErasing = eraser;
    }

    public void setEdited() {
        invalidate();
    }

    public void reDraw(xPath k) {

        Path path = new Path(k.getPath());

        mCanvas.save();


        float x1 = (getCurrentPageWidth() / (k.getPageWidth()));
        float y1 = (getCurrentPageHeight() / k.getPageHeight());


        float x = x1 * (pdfView.getZoom() / k.getZoom());
        float y = y1 * (pdfView.getZoom() / k.getZoom());


        Matrix scaleMatrix = new Matrix();

        RectF rectF = new RectF();
        path.computeBounds(rectF, true);
        scaleMatrix.setScale(x / pdfView.getZoom(), y / pdfView.getZoom(), 0, 0);
        path.transform(scaleMatrix);

        float xp = (k.translateX() / k.getPageWidth()) * getCurrentPageWidth();
        float yp = ((k.translateY() / k.getPageHeight()) * getCurrentPageHeight());

        float h = (getHeight() - k.getPageHeight());

//        System.out.println("------------------------------------------------------------------");
//        System.out.println(" redraw --|" + k.translateY() + " ==== " + k.getPageHeight() + " === " + getCurrentPageHeight());
//        System.out.println(" redraw --|" + xp + "----|" + yp + "---|" + Yposition + "-----|" + page.dy + "----|" + pdfView.getCurrentPage());
//        System.out.println("------------------------------------------------------------------");
//        mCanvas.translate(xp, yp - Yposition + (page.dy * pdfView.getCurrentPage()));
        mCanvas.translate(xp, yp + (h / 2));


        Paint p = new Paint(k.getPaint());
        p.setStrokeWidth(p.getStrokeWidth());
        mCanvas.drawPath(path, p);

        mCanvas.restore();
        invalidate();
    }

    private class ScaleListener extends ScaleGestureDetector.SimpleOnScaleGestureListener {
        @Override
        public boolean onScale(@NonNull ScaleGestureDetector detector) {
            mScaleFactor *= detector.getScaleFactor();

            // Don't let the object get too small or too large.
            mScaleFactor = Math.max(0.1f, Math.min(mScaleFactor, 5.0f));
            scaling = true;
            return false;
        }
    }
}
