package com.pdfEditor.EditorTools.image;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;

import com.sampathkumara.northsails.smartwind.R;

public class image_container extends RelativeLayout {

    static image_container wc;
    private static image_container image_container;
    private static Bitmap bitmap;
    private final Rect rectf = new Rect();
    private final Rect rectf1 = new Rect();
    @NonNull
    private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private int deltaX_ = 0;
    private int deltaY_ = 0;
    private int firstWidth;
    private int firstHeigrt;

    public image_container(Context context) {
        super(context);
        this.setDrawingCacheEnabled(true);
        image_container = this;
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.image_container, this);


        setLayoutParams(new LayoutParams(100, 100));
        View b_resize = view.findViewById(R.id.resize);
        wc = this;

        b_resize.setOnTouchListener((view1, event) -> {

            getGlobalVisibleRect(rectf);
            view1.getGlobalVisibleRect(rectf1);
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
                case MotionEvent.ACTION_POINTER_UP:
                    break;
                case MotionEvent.ACTION_MOVE:

                    int w = firstWidth - (deltaX_ - X);
                    int h = firstHeigrt - (deltaY_ - Y);
                    if (h > 50 && w > 50) {

                        lParams.height = h;
                        lParams.width = w;
                        setLayoutParams(lParams);
                        invalidate();

                    }
                    break;
            }


            return true;
        });
        setBackgroundColor(Color.WHITE);
        getBackground().setAlpha(10);
        view.invalidate();
    }

    public static void setBitmap(Bitmap bitmap) {
        com.pdfEditor.EditorTools.image.image_container.bitmap = bitmap;

        int h = bitmap.getHeight();
        int w = bitmap.getWidth();
        long x;
        LayoutParams lParams = (LayoutParams) image_container.getLayoutParams();
        if (h > w) {
            x = h / w;
        } else {
            x = w / h;
        }
        x = x == 0 ? 1 : x;

        lParams.height = 200;
        lParams.width = (int) (200 * x);
        image_container.setLayoutParams(lParams);
        image_container.invalidate();
        image_container.setVisibility(GONE);
        image_container.setVisibility(VISIBLE);
        System.out.println("SET BITMAP");
        image_container.invalidate();
    }

    @Override
    protected void onDraw(@NonNull Canvas canvas) {
        System.out.println("DRRRRRRRR");
        try {
            setVisibility(VISIBLE);
            canvas.drawBitmap(bitmap, null, new RectF(0, 0, getWidth(), getHeight()), null);
        } catch (Exception e) {
            e.printStackTrace();
//setVisibility(GONE);
        }
        super.onDraw(canvas);
    }

    public Bitmap getImage() {
        return bitmap;
    }

    public void RotateBitmap(float angle) {
        Matrix matrix = new Matrix();
        matrix.postRotate(angle);
        Bitmap source = bitmap;
        bitmap = Bitmap.createBitmap(source, 0, 0, source.getWidth(), source.getHeight(), matrix, true);
        image_container.invalidate();
    }

    @Override
    public boolean performClick() {
        super.performClick();
        return true;
    }

}
