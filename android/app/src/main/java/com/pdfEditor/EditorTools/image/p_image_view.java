package com.pdfEditor.EditorTools.image;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageButton;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;

import com.pdfEditor.Editor;
import com.pdfEditor.PAGE;
import com.pdfEditor.uploadEdits.PdfEdit;
import com.pdfviewer.PDFView;
import com.sampathkumara.northsails.smartwind.R;

public class p_image_view extends RelativeLayout {


    public p_image_view(Context context) {
        super(context);
    }

    public p_image_view(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public static image_container shapeC;
    private static float Yposition;
    private static Bitmap mBitmap;
    private static Canvas mCanvas;
    private Editor editor;
    private final Rect rectf = new Rect();
    private PDFView pdfView;

    RelativeLayout pane;

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
//        ImageButton b_new = view.findViewById(R.id.b_new);
        ImageButton done = view.findViewById(R.id.done);
        ImageButton b_cancel = view.findViewById(R.id.b_cancel);
        b_cancel.setOnClickListener(view1 -> {
            resetImageBox();
            runAfterDone.run();
        });
        done.setOnClickListener(view12 -> {
            save();
            runAfterDone.run();
        });

        resetImageBox();

        ImageButton b_rotate_left = findViewById(R.id.b_rotate_left);
        b_rotate_left.setOnClickListener(v -> shapeC.RotateBitmap(-90));
        ImageButton b_rotate_right = findViewById(R.id.b_rotate_right);
        b_rotate_right.setOnClickListener(v -> shapeC.RotateBitmap(90));


    }

    public void save() {
        if (shapeC.getVisibility() == GONE) {
            return;
        }
        mCanvas = new Canvas(mBitmap);
        float zoom = pdfView.getZoom();
        final float translateX = Math.abs(pdfView.getCurrentXOffset() / zoom);
        final float translateY = Math.abs((pdfView.getCurrentYOffset() / zoom)) - (Yposition);

        mCanvas.save();
//        mCanvas.translate(translateX, translateY);
        final Bitmap b = Bitmap.createScaledBitmap(shapeC.getImage(), (shapeC.getWidth()), (shapeC.getHeight()), false);
        final Bitmap b1 = Bitmap.createScaledBitmap(shapeC.getImage(), (shapeC.getWidth()), (shapeC.getHeight()), false);

        float sp = ((((pdfView.pdfFile.getPageSpacing(pdfView.getCurrentPage(), zoom) / 2) / zoom) * (2 * (pdfView.getCurrentPage() + 1) - 1)));

        float dheight = (((getHeight() - pdfView.pdfFile.getPageSize(pdfView.getCurrentPage()).getHeight())) / 2);
        final xImage xImage = new xImage(b, translateX, translateY - dheight, (TEXT_X / zoom), (TEXT_Y / zoom),
                pageNo, getCurrentPageWidth(), getCurrentPageHeight(), zoom);
        editor.editsList.add(xImage);
//        mCanvas.restore();
        shapeC.setVisibility(GONE);
        editor.reDraw(pageNo);


        PdfEdit pdfEdit = new PdfEdit(PdfEdit.TYPE_IMAGE);
//        pdfEdit.setImageBytes(ImageUtil.convert(b1));
        pdfEdit.setRect_width((shapeC.getWidth() / zoom) / getCurrentPageWidth());
        pdfEdit.setRect_height((shapeC.getHeight() / zoom) / getCurrentPageHeight());

        pdfEdit.setPositionX((translateX + (TEXT_X / zoom)) / getCurrentPageWidth());
        pdfEdit.setPositionY((translateY + (TEXT_Y / zoom) - sp) / getCurrentPageHeight());
        editor.getPdfEditsList().addEdit(pageNo, xImage.getId(), pdfEdit);

        editor.addImage(xImage.getId(), b1);
    }

    public void resetImageBox() {
        pane.removeView(shapeC);
        shapeC = new image_container(getContext());
        pane.addView(shapeC);
        shapeC.setVisibility(GONE);
        shapeC.setOnTouchListener((view, event) -> {

            getGlobalVisibleRect(rectf);
//                view.getGlobalVisibleRect(rectf1);
            final int X = (int) event.getRawX() - rectf.left;
            final int Y = (int) event.getRawY() - rectf.top;
            LayoutParams lParams = (LayoutParams) shapeC.getLayoutParams();
            System.out.println(X + "_____" + Y);
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    deltaX_ = (int) event.getX();
                    deltaY_ = (int) event.getY();
                    System.out.println("_____________________________________" + deltaX_ + "__" + deltaY_);
                    view.performClick();
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
        });
    }

    PAGE page;

    public void setPage(@NonNull PAGE page) {

        System.out.println(page.id + "____" + page.position);
        Yposition = page.position;
        mBitmap = page.getBitmap();
        mCanvas = new Canvas(mBitmap);
        pageNo = page.id;
        this.page = page;
    }

    @Override
    protected void onDraw(@NonNull Canvas canvas) {
        super.onDraw(canvas);

    }

//    public void setEdited(boolean edited) {
//        editor.reDraw(pageNo);
//        invalidate();
//    }

    public void reDraw(xImage kk) {

        mCanvas.save();
        float x = getCurrentPageWidth() / (kk.getPageWidth());
        float y = getCurrentPageHeight() / kk.getPageHeight();
        x = x * (pdfView.getZoom() / kk.getZoom());
        y = y * (pdfView.getZoom() / kk.getZoom());


        Matrix scaleMatrix = new Matrix();
        scaleMatrix.setScale(x / pdfView.getZoom(), y / pdfView.getZoom(), 0, 0);
        scaleMatrix.postTranslate(kk.getCanvasX(), kk.getCanvasY());

//        float xp = (kk.translateX() / kk.getPageWidth()) * getCurrentPageWidth();
//        float yp = (kk.translateY() / kk.getPageHeight()) * getCurrentPageHeight();

        float xp = (kk.translateX() / kk.getPageWidth()) * getCurrentPageWidth();
        float yp = ((kk.translateY() / kk.getPageHeight()) * getCurrentPageHeight());

        float h = (getHeight() - kk.getPageHeight()) / 2;

//        mCanvas.translate(xp, (yp - Yposition + (page.dy * pdfView.getCurrentPage())));
        mCanvas.translate(xp, (yp + h));

        mCanvas.drawBitmap(kk.getBitmap(), scaleMatrix, null);

        mCanvas.restore();
        invalidate();
    }

    private float getCurrentPageWidth() {
        return pdfView.pdfFile.getPageSize(pdfView.getCurrentPage()).getWidth();
    }

    private float getCurrentPageHeight() {
        return pdfView.pdfFile.getPageSize(pdfView.getCurrentPage()).getHeight();
    }

}
 

