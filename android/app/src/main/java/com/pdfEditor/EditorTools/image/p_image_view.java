package com.pdfEditor.EditorTools.image;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.os.Build;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageButton;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.pdfEditor.Editor;
import com.pdfEditor.PAGE;
import com.pdfEditor.uploadEdits.PdfEdit;
import com.pdfviewer.PDFView;
import com.sampathkumara.northsails.smartwind.R;

public class p_image_view extends RelativeLayout {


    @NonNull
    public static image_container shapeC;
    private static float Yposition;
    private static Bitmap mBitmap;
    private static Canvas mCanvas;
    private final ImageButton done;
    private final Editor editor;
    private final Rect rectf = new Rect();
    private final PDFView pdfView;
    @NonNull
    private final String TAG = "TEXT EDITOR";
    RelativeLayout pane;
    private View window;
    private int TEXT_X;
    private int TEXT_Y;
    private int deltaX_ = 0;
    private int deltaY_ = 0;
    private int pageNo;


    public p_image_view(final Context context, final PDFView pdfView, final Editor editor, Editor.RunAfterDone runAfterDone) {
        super(context);
        this.pdfView = pdfView;
        this.editor = editor;
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.p_image_view, this);


        pane = findViewById(R.id.pane);
        ImageButton b_new = view.findViewById(R.id.b_new);
        done = view.findViewById(R.id.done);
        ImageButton b_cancel = view.findViewById(R.id.b_cancel);
        b_cancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                resetImageBox();
                runAfterDone.run();
            }
        });
        done.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                save();
                runAfterDone.run();
            }
        });

        resetImageBox();

        ImageButton b_rotate_left = findViewById(R.id.b_rotate_left);
        b_rotate_left.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                shapeC.RotateBitmap(-90);
            }
        });
        ImageButton b_rotate_right = findViewById(R.id.b_rotate_right);
        b_rotate_right.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                shapeC.RotateBitmap(90);
            }
        });


        b_new.setOnClickListener(new OnClickListener() {
            @RequiresApi(api = Build.VERSION_CODES.O)
            @Override
            public void onClick(View view) {
                done.callOnClick();
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    editor.browsImages(context);
                }

            }
        });


    }

    public void save() {
        if (shapeC.getVisibility() == GONE) {
            return;
        }
        mCanvas = new Canvas(mBitmap);
        float zoom = pdfView.getZoom();
        final float translateX = Math.abs(pdfView.getCurrentXOffset() / zoom);
        final float translateY = Math.abs((pdfView.getCurrentYOffset() / zoom)) - (Yposition) + 34;

        mCanvas.save();
//        mCanvas.translate(translateX, translateY);
        final Bitmap b = Bitmap.createScaledBitmap(shapeC.getImage(), (shapeC.getWidth()), (shapeC.getHeight()), false);
        final Bitmap b1 = Bitmap.createScaledBitmap(shapeC.getImage(), (shapeC.getWidth()), (shapeC.getHeight()), false);
//        mCanvas.drawBitmap(b, (TEXT_X) / zoom, (TEXT_Y) / zoom, null);

//        float dheight = (getHeight() - pdfView.pdfFile.getMaxPageHeight()) / 2;
        float dheight = (((getHeight() - pdfView.pdfFile.getPageSize(pdfView.getCurrentPage()).getHeight())) / 2);
        final xImage xImage = new xImage(b, translateX, translateY - dheight, (TEXT_X), (TEXT_Y),
                pageNo, pdfView.pdfFile.getMaxPageWidth(), pdfView.pdfFile.getMaxPageHeight(), zoom);
        editor.editsList.add(xImage);
//        mCanvas.restore();
        shapeC.setVisibility(GONE);
        editor.reDraw(pageNo);


        PdfEdit pdfEdit = new PdfEdit(PdfEdit.TYPE_IMAGE);
//        pdfEdit.setImageBytes(ImageUtil.convert(b1));
        pdfEdit.setRect_width((shapeC.getWidth() / zoom) / pdfView.pdfFile.getMaxPageWidth());
        pdfEdit.setRect_height((shapeC.getHeight() / zoom) / pdfView.pdfFile.getMaxPageHeight());

        pdfEdit.setPositionX((translateX + (TEXT_X / zoom)) / pdfView.pdfFile.getMaxPageWidth());
        pdfEdit.setPositionY((translateY + (TEXT_Y / zoom)) / pdfView.pdfFile.getMaxPageHeight());
        editor.getPdfEditsList().addEdit(pageNo, xImage.getId(), pdfEdit);

        editor.addImage(xImage.getId(), b1);
    }

    public void resetImageBox() {
        pane.removeView(shapeC);
        shapeC = new image_container(getContext());
        pane.addView(shapeC);
        shapeC.setVisibility(GONE);
        shapeC.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View view, @NonNull MotionEvent event) {

                getGlobalVisibleRect(rectf);
//                view.getGlobalVisibleRect(rectf1);
                final int X = (int) event.getRawX() - rectf.left;
                final int Y = (int) event.getRawY() - rectf.top;
//                final int X = (int) event.getRawX()   ;
//                final int Y = (int) event.getRawY()  ;
                LayoutParams lParams = (LayoutParams) shapeC.getLayoutParams();
                System.out.println(X + "_____" + Y);
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        deltaX_ = (int) event.getX();
                        deltaY_ = (int) event.getY();
                        System.out.println("_____________________________________" + deltaX_ + "__" + deltaY_);
                        break;
                    case MotionEvent.ACTION_UP:
                    case MotionEvent.ACTION_POINTER_UP:
                        break;
                    case MotionEvent.ACTION_MOVE:
                        lParams.leftMargin = X - deltaX_;
                        lParams.topMargin = Y - deltaY_;
                        TEXT_X = X - deltaX_;
                        TEXT_Y = Y - deltaY_;
//                    System.out.println(deltaX_ + "   " + deltaY_);
                        shapeC.setLayoutParams(lParams);
                        break;
                }


                return true;
            }
        });
    }

//    public void reDraw() {
//        System.out.println("Redrawing........");
////        mBitmap.eraseColor(Color.TRANSPARENT);
//        for (xEdits kk : editor.editsList) {
//            if (kk.page == this.pageNo) {
//                if (kk instanceof xImage) {
//                    reDraw((xImage)  kk);
//                }
//            }
//        }
//    }

    public void setPage(@NonNull PAGE page) {

        System.out.println(page.id + "____" + page.position);
        Yposition = page.position;
        mBitmap = page.getBitmap();
        mCanvas = new Canvas(mBitmap);
        pageNo = page.id;
//        reDraw();
//        invalidate();
    }

    @Override
    protected void onDraw(@NonNull Canvas canvas) {
        super.onDraw(canvas);

    }

    public void setEdited(boolean edited) {
        editor.reDraw(pageNo);
        invalidate();
    }

    public void reDraw(xImage kk) {

        mCanvas.save();
        float x = pdfView.pdfFile.getMaxPageWidth() / (kk.getPageWidth());
        float y = pdfView.pdfFile.getMaxPageHeight() / kk.getPageHeight();
        x = x * (pdfView.getZoom() / kk.getZoom());
        y = y * (pdfView.getZoom() / kk.getZoom());


//                    float x = pdfView.pdfFile.getMaxPageWidth() / (kk.getPageWidth());
//                    float y = pdfView.pdfFile.getMaxPageHeight() / kk.getPageHeight();

        Matrix scaleMatrix = new Matrix();
        scaleMatrix.setScale(x, y, 0, 0);
        scaleMatrix.postTranslate(kk.getCanvasX() * x, kk.getCanvasY() * y);

        float xp = (kk.translateX() / kk.getPageWidth()) * pdfView.pdfFile.getMaxPageWidth();
        float yp = (kk.translateY() / kk.getPageHeight()) * pdfView.pdfFile.getMaxPageHeight();

        float xx = (((xp) * pdfView.getZoom()) + (pdfView.getCurrentXOffset()));
        float yy = (((yp) * pdfView.getZoom()) + pdfView.getCurrentYOffset() + (Yposition * pdfView.getZoom()));


        mCanvas.translate(xx, yy);

//                    mCanvas.translate(k.translateX() * x, k.translateY() * y);

        mCanvas.drawBitmap(kk.getBitmap(), scaleMatrix, null);

        mCanvas.restore();
        invalidate();
    }

 
}
 

