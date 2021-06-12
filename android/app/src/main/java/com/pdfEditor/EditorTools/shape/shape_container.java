package com.pdfEditor.EditorTools.shape;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;

import com.pdfviewer.PDFView;
import com.sampathkumara.northsails.smartwind.R;

public class shape_container extends RelativeLayout {
    public static final int RECTANGLE = 1;
    public static final int CERCLE = 2;
    public static final int TRIANGLE = 3;
    private final Rect rectf = new Rect();
    private final Rect rectf1 = new Rect();
    int TEXT_X, TEXT_Y;
    Path triangle;
    PDFView pdfView;
    private int deltaX_ = 0;
    private int deltaY_ = 0;
    private int SHAPE;
    private int STROKE = 4;
    private boolean FILL = false;
    private Bitmap bm;
    private Canvas mCanvas;
    @NonNull
    private Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private int firstWidth;
    private int firstHeigrt;
    private int color = Color.BLACK;

    public shape_container(Context context, PDFView pdfView) {
        super(context);
        this.pdfView = pdfView;
        this.setDrawingCacheEnabled(true);
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.shape_container, this);

        setLayoutParams(new LayoutParams(100, 100));
        View b_resize = view.findViewById(R.id.resize);
        bm = Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888);
        mCanvas = new Canvas(bm);
        b_resize.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(@NonNull View view, @NonNull MotionEvent event) {

                getGlobalVisibleRect(rectf);
                view.getGlobalVisibleRect(rectf1);
                final int X = (int) event.getRawX();
                final int Y = (int) event.getRawY();
                LayoutParams lParams = (LayoutParams) getLayoutParams();
//                System.out.println(X + "_____" + Y);
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        getGlobalVisibleRect(rectf);
                        firstWidth = lParams.width;
                        firstHeigrt = lParams.height;
                        deltaX_ = X;
                        deltaY_ = Y;
                        System.out.println(X + "__" + Y + "___(" + lParams.width + "______________" + lParams.height + "_)_________________" + deltaX_ + "__" + deltaY_);
                        break;
                    case MotionEvent.ACTION_UP:
                        bm = Bitmap.createBitmap(lParams.width, lParams.height, Bitmap.Config.ARGB_8888);
                        mCanvas = new Canvas(bm);
                        break;
                    case MotionEvent.ACTION_POINTER_UP:
                        break;
                    case MotionEvent.ACTION_MOVE:

                        int w = firstWidth - (deltaX_ - X);
                        int h = firstHeigrt - (deltaY_ - Y);
                        if (h > 50 && w > 50) {
                            if (SHAPE == CERCLE) {
                                if (h >= w) {
                                    w = h;
                                } else {
                                    h = w;
                                }
                            }

                            lParams.height = h;
                            lParams.width = w;
                            setLayoutParams(lParams);
                            invalidate();

                        }
                        break;
                }


                return true;
            }
        });
        setBackgroundColor(Color.WHITE);
        getBackground().setAlpha(10);
        view.invalidate();
    }

    @Override
    protected void onDraw(@NonNull Canvas canvas) {
        super.onDraw(canvas);
        paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(color);
        paint.setStrokeWidth(STROKE);

        if (FILL) {
            paint.setStyle(Paint.Style.FILL);
        } else {
            paint.setStyle(Paint.Style.STROKE);
        }
        Rect r = new Rect();
        getDrawingRect(r);


        if (SHAPE == RECTANGLE) {
            System.out.println("_____________________________________________________________________RECTANGLE__" + FILL);
            canvas.drawRect(2, 2, getWidth() - 2, getHeight() - 2, paint);
            mCanvas.drawRect(2, 2, getWidth() - 2, getHeight() - 2, paint);


//            canvas.drawRect(2, 2, 100, 100, paint);
//            mCanvas.drawRect(2, 2, 100, 100, paint);
        } else if (SHAPE == CERCLE) {
            int r1 = getWidth() < getHeight() ? getWidth() : getHeight();
            canvas.drawCircle(r1 / 2, r1 / 2, (r1 - (STROKE * 2)) / 2, paint);
            mCanvas.drawCircle(r1 / 2, r1 / 2, (r1 - (STROKE * 2)) / 2, paint);

        } else if (SHAPE == TRIANGLE) {
            triangle = new Path();

            triangle.moveTo(getWidth() / 2, (getHeight() - STROKE / 2));
            triangle.lineTo(getWidth(), (getHeight() - STROKE / 2)); // right
            triangle.lineTo(getWidth() / 2, STROKE); // top
            triangle.lineTo(STROKE, (getHeight() - STROKE / 2)); //left
            triangle.lineTo(getWidth() / 2, (getHeight() - STROKE / 2));

            this.paint.setColor(this.color);
            this.paint.setColor(color);
            this.paint.setStrokeWidth(STROKE);
            canvas.drawPath(triangle, paint);
            mCanvas.drawPath(triangle, paint);
        }
    }


    public Bitmap getImage() {
        System.out.println("GET IMAGE");
        LayoutParams lParams = (LayoutParams) getLayoutParams();
        Bitmap bm = Bitmap.createBitmap((lParams.width), (lParams.height), Bitmap.Config.ARGB_8888);
        Canvas mCanvas = new Canvas(bm);
        this.paint.setStrokeWidth(STROKE / pdfView.getZoom());
        if (SHAPE == RECTANGLE) {
            System.out.println("RECTANGLE");
            mCanvas.drawRect(2, 2, (getWidth() - 2) / pdfView.getZoom(), (getHeight() - 2) / pdfView.getZoom(), paint);
        } else if (SHAPE == CERCLE) {
            System.out.println("CERCLE");
            int r1 = getWidth() < getHeight() ? getWidth() : getHeight();
            mCanvas.drawCircle((r1 / 2) / pdfView.getZoom(), (r1 / 2) / pdfView.getZoom(), ((r1 - (STROKE * 2)) / 2) / pdfView.getZoom(), paint);
        } else if (SHAPE == TRIANGLE) {
            System.out.println("TRIANGLE");
            mCanvas.drawPath(triangle, paint);
        }
        return bm;
    }


    public void setFill(boolean checked) {
        FILL = checked;
        invalidate();
    }

    public void setStroke(int stroke) {
        STROKE = stroke;
        invalidate();
//        RelativeLayout.LayoutParams Params = (RelativeLayout.LayoutParams) getLayoutParams();
//        Params.height+=stroke/2+5;
//        Params.width+=stroke/2+5;
//        setLayoutParams(Params);

    }

    public void setColor(int color) {
        this.color = color;
        invalidate();
    }

    public void setEdited(boolean edited) {
    }

    public shape getShape() {
        System.out.println("GET IMAGE");
        LayoutParams lParams = (LayoutParams) getLayoutParams();
        Bitmap bm = Bitmap.createBitmap((lParams.width), (lParams.height), Bitmap.Config.ARGB_8888);
        Canvas mCanvas = new Canvas(bm);
        this.paint.setStrokeWidth(STROKE / pdfView.getZoom());
        if (SHAPE == RECTANGLE) {

            System.out.println("RECTANGLE " + getHeight());
            mCanvas.drawRect(0, 0, (getWidth()) / pdfView.getZoom(), (getHeight()) / pdfView.getZoom(), paint);
            rectangle rectangle = new rectangle(getWidth() / pdfView.getZoom(), getHeight() / pdfView.getZoom(), new Paint(paint), STROKE);
            rectangle.setFill(FILL);
            return rectangle;

        } else if (SHAPE == CERCLE) {
            System.out.println("CERCLE");
            int r1 = getWidth() < getHeight() ? getWidth() : getHeight();
//            mCanvas.drawCircle((r1 / 2) / pdfView.getZoom(), (r1 / 2) / pdfView.getZoom(), ((r1 - (STROKE * 2)) / 2), paint);
//            mCanvas.drawCircle((r1 / 2)  , (r1 / 2)  , ((r1 - (STROKE * 2)) / 2), paint);
            cercle cercle = new cercle(r1, new Paint(paint), STROKE);
            cercle.setFill(FILL);
            return cercle;
        } else if (SHAPE == TRIANGLE) {
            System.out.println("TRIANGLE");
            mCanvas.drawPath(triangle, paint);
            com.pdfEditor.EditorTools.shape.triangle triangle = new triangle(new Path(this.triangle), new Paint(paint), STROKE);
            triangle.setWidth(getWidth() / pdfView.getZoom());
            triangle.setHeight(getHeight() / pdfView.getZoom());
            triangle.setFill(FILL);
            return triangle;
        }

        return null;
    }

    public void setShape(int shape) {
        SHAPE = shape;
        invalidate();
    }
}
