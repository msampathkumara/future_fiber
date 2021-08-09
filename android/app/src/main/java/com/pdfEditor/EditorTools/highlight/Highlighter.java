package com.pdfEditor.EditorTools.highlight;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.pdfEditor.Editor;
import com.pdfEditor.EditorTools.freehand.xPath;
import com.pdfEditor.PAGE;
import com.pdfEditor.uploadEdits.PdfEdit;
import com.pdfEditor.uploadEdits.editPoint;
import com.pdfEditor.uploadEdits.editsPaint;
import com.pdfviewer.PDFView;

import java.util.ArrayList;
import java.util.List;

public class Highlighter extends FrameLayout {

    private static final float TOUCH_TOLERANCE = 4;
    @NonNull
    private final Path mPath;
    @NonNull
    private final Paint circlePaint;
    @NonNull
    private final Path circlePath;
    @NonNull
    private final ScaleGestureDetector mScaleDetector;
    private final PDFView pdfView;
    private final Path path = new Path();
    private final Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Editor editor;
    //        private Canvas mCanvas;
    public int width;
    //        private Bitmap mBitmap;
    public int height;
    ArrayList<editPoint> points = new ArrayList<>();
    float firstY;
    private boolean scaling;
    private int mcolor = Color.argb(100, 66, 244, 104);
    private Bitmap mBitmap;
    private float startY1;
    private float startSp;
    private float startY;
    private float Yposition = 0;
    private float mScaleFactor = 1.f;
    private Canvas mCanvas;
    private float mY;
    private float mX;
    private boolean isErasing;
    private float mX1;
    private float mY1;
    private int stroke = 15;
    private int pageNo;


    public Highlighter(@NonNull Context c, PDFView pdfView, Editor editor) {
        super(c);
        this.editor = editor;
        this.pdfView = pdfView;
        Context context = c;
        mPath = new Path();
        Paint mBitmapPaint = new Paint(Paint.DITHER_FLAG);
        circlePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        circlePath = new Path();
        circlePaint.setAntiAlias(true);
        circlePaint.setColor(mcolor);
        circlePaint.setStyle(Paint.Style.STROKE);
        circlePaint.setStrokeJoin(Paint.Join.MITER);
        circlePaint.setStrokeWidth(stroke);
        circlePaint.setColor(Color.argb(100, 0, 0, 0));

        mScaleDetector = new ScaleGestureDetector(context, new ScaleListener());

        setBackgroundColor(Color.argb(5, 0, 0, 0));

        p.setAntiAlias(true);
        p.setDither(true);
        p.setStyle(Paint.Style.STROKE);
        p.setStrokeJoin(Paint.Join.ROUND);
        p.setStrokeCap(Paint.Cap.ROUND);


    }

    @Override
    public boolean onTouchEvent(@NonNull MotionEvent event) {
        mScaleDetector.onTouchEvent(event);
//        float x = event.getX() / pdfView.getZoom() + clipBounds.left;
//        float y = event.getY() / pdfView.getZoom() + clipBounds.top;

        float x = event.getX();
        float y = event.getY();

        float x1 = event.getX();
        float y1 = event.getY();
        float zoom = pdfView.getZoom();
        float sp = (((pdfView.pdfFile.getPageSpacing(pdfView.getCurrentPage(), zoom) / 2) * (2*(pdfView.getCurrentPage()+1)-1 )) / pdfView.pdfFile.getMaxPageHeight());

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                if (!scaling) {
                    touch_start(x, y);
                    touch_start1(x1, y1,sp,zoom);
                    invalidate();
                }
                break;
            case MotionEvent.ACTION_MOVE:
                if (!scaling) {
                    touch_move(x);
                    touch_move1(x1);
                    invalidate();
                }
                break;
            case MotionEvent.ACTION_UP:
                if (!scaling) {
                    touch_up(x, y,sp,zoom);
                    touch_up1( );

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


        p.setStrokeWidth(stroke * pdfView.getZoom());
//        p.setStrokeWidth(stroke);
        p.setColor(mcolor);
        canvas.drawPath(path, p);
        canvas.drawPath(circlePath, circlePaint);
        //        Bitmap bitmap;
        Rect clipBounds = canvas.getClipBounds();

    }

    private void touch_start(float x, float y) {
        startY = y;
        mPath.reset();
        mPath.moveTo(x, y);
        mX = x;
        mY = y;
        System.out.println(x + " " + y);

    }

    private void touch_start1(float x, float y,float sp,float zoom) {
        startY1 = y;
        startSp = sp;
        path.reset();
        path.moveTo(x, y);
        mX1 = x;
        mY1 = y;



//        y=y-(pdfView.pdfFile.getPageSpacing(pdfView.getCurrentPage(),zoom)/2);

        System.out.println("YYYYYYYY -- "+y+"**" );


        points.add(new editPoint(((x / zoom) / pdfView.pdfFile.getMaxPageWidth()), (((y / zoom) / pdfView.pdfFile.getMaxPageHeight())), false,startSp));
        firstY = y;
    }

    private void touch_move(float x) {
        float y = startY;
        float dx = Math.abs(x - mX);
        float dy = Math.abs(y - mY);
        if (dx >= TOUCH_TOLERANCE || dy >= TOUCH_TOLERANCE) {
            mPath.quadTo(mX, mY, (x + mX) / 2, (y + mY) / 2);
            mX = x;
            mY = startY;


            float zoom = pdfView.getZoom();
//            points.add(new editPoint(((x / zoom) / pdfView.pdfFile.getMaxPageWidth()), (((y / zoom) / pdfView.pdfFile.getMaxPageHeight())), true));

//            circlePath.reset();
//            circlePath.addCircle(mX, mY, 30, Path.Direction.CW);
        }

    }

    private void touch_move1(float x) {

        float y = startY1;
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

    private void touch_up(float x, float y,float sp,float zoom){
        System.out.println(mX + " " + mY);
        System.out.println(mX1 + " " + mY1);
        Paint p = new Paint(Paint.DITHER_FLAG);
        p.setAntiAlias(true);
        p.setDither(true);
        p.setStyle(Paint.Style.STROKE);
        p.setStrokeJoin(Paint.Join.ROUND);
        p.setStrokeCap(Paint.Cap.ROUND);

        p.setStrokeWidth(stroke);
        p.setColor(mcolor);


        mPath.lineTo(mX, mY);
        System.out.println("startSp = "+startSp+" sp ="+sp);

        points.add(new editPoint(((x / zoom) / pdfView.pdfFile.getMaxPageWidth()), (((firstY / zoom) / pdfView.pdfFile.getMaxPageHeight())), false,startSp));


        circlePath.reset();

        if (isErasing)
            p.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.CLEAR));
        else
            p.setXfermode(null);


        float translateX = Math.abs(pdfView.getCurrentXOffset() / zoom);
        float translateY = Math.abs((pdfView.getCurrentYOffset() / zoom)) - (Yposition);

        for (int i = 0; i < points.size(); i++) {
            editPoint editPoint = points.get(i);
            editPoint.setX(editPoint.getX() + ((translateX) / (pdfView.pdfFile.getMaxPageWidth())));
            editPoint.setY(editPoint.getY() + ((translateY) / (pdfView.pdfFile.getMaxPageHeight())) - (editPoint.sp));
        }

        float dheight = (getHeight() - pdfView.pdfFile.getMaxPageHeight()) / 2;
        final xPath xpath = new xPath(new Path(mPath), p, translateX, translateY - dheight, pageNo, pdfView.pdfFile.getMaxPageWidth(), pdfView.pdfFile.getMaxPageHeight(), zoom);

        editor.editsList.add(xpath);
        mPath.reset();
        editor.reDraw(pageNo);

        editsPaint editsPaint = new editsPaint();
        editsPaint.setColor(p.getColor());
        editsPaint.setStroke(stroke);
        editsPaint.setOpacity(0.5f);


        final PdfEdit pdfEdit = new PdfEdit(PdfEdit.TYPE_HIGHT_LIGHT);
        pdfEdit.setEditsPaint(editsPaint);
        pdfEdit.setPathPoints(points);
        editor.getPdfEditsList().addEdit(pageNo, xpath.getId(), pdfEdit);
        points = new ArrayList<>();

    }

    private void touch_up1() {
        path.lineTo(mX1, startY1);
        path.reset();
        circlePath.reset();
    }

    public Bitmap getBitmap() {
        if (mBitmap == null) {
            mBitmap = Bitmap.createBitmap((int) pdfView.pdfFile.getMaxPageWidth(), (int) pdfView.pdfFile.getMaxPageHeight(), Bitmap.Config.ARGB_8888);
            mCanvas = new Canvas(mBitmap);
        }
        return mBitmap;
    }

    public void setPage(@NonNull PAGE page) {
        System.out.println(page.id + "____" + page.position);
        Yposition = page.position;
        mBitmap = page.getBitmap();
        List<xPath> pathMap = page.paths;
        this.pageNo = page.id;
        mCanvas = new Canvas(mBitmap);

    }

    public void setEditText(boolean editText) {
        boolean EDITH_TEXT = editText;
    }

    public void setColor(int color) {
        this.mcolor = color;
    }

    public void setStroke(int stroke) {
        this.stroke = stroke;
    }

    public void setEdited(boolean edited) {
        //        reDraw();
//        invalidate();
    }

//    public void reDraw() {
//        System.out.println("REDDDDDDDDDDDD");
//        for (xEdits kk : editor.editsList) {
//            System.out.println(kk.page + "^^^^^^^" + this.pageNo);
//            if (kk.page == this.pageNo) {
//                if (kk instanceof xPath) {
//                    xPath k = (xPath) kk;
//                    System.out.println("KKKKKKKKJHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH");
//                    Path path = new Path(k.getPath());
//
//                    mCanvas.save();
//                    float x = pdfView.pdfFile.getMaxPageWidth() / (kk.getPageWidth());
//                    float y = pdfView.pdfFile.getMaxPageHeight() / kk.getPageHeight();
//                    x = x * (pdfView.getZoom() / k.getZoom());
//                    y = y * (pdfView.getZoom() / k.getZoom());
//
//                    Matrix scaleMatrix = new Matrix();
//                    RectF rectF = new RectF();
//                    path.computeBounds(rectF, true);
//                    scaleMatrix.setScale(x, y, 0, 0);
//                    path.transform(scaleMatrix);
//
//                    float xp = (k.translateX() / kk.getPageWidth()) * pdfView.pdfFile.getMaxPageWidth();
//                    float yp = (k.translateY() / kk.getPageHeight()) * pdfView.pdfFile.getMaxPageHeight();
//
//                    float xx = (((xp) * pdfView.getZoom()) + (pdfView.getCurrentXOffset()));
//                    float yy = (((yp) * pdfView.getZoom()) + pdfView.getCurrentYOffset() + (Yposition * pdfView.getZoom()));
//                    mCanvas.translate(xx, yy);
//
//                    Paint p = new Paint(k.getPaint());
//                    p.setStrokeWidth(p.getStrokeWidth() * pdfView.getZoom());
//                    mCanvas.drawPath(path, p);
//
//                    mCanvas.restore();
//                    invalidate();
//
//                }
//            }
//        }
//    }

    private class ScaleListener extends ScaleGestureDetector.SimpleOnScaleGestureListener {
        @Override
        public boolean onScale(@NonNull ScaleGestureDetector detector) {
            mScaleFactor *= detector.getScaleFactor();

            // Don't let the object get too small or too large.
            mScaleFactor = Math.max(0.1f, Math.min(mScaleFactor, 5.0f));
            scaling = true;
            System.out.println("xxxxxxxxxxxxxxxxxxxxxxxxxxxxx__ " + mScaleFactor);
//            frameLayout.setScaleX(mScaleFactor);
//            frameLayout.setScaleY(mScaleFactor);
//            invalidate();
//            dv.setVisibility(View.GONE);
            return false;
        }
    }
}
