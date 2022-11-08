package com.pdfEditor.EditorTools.textEditor;

import static android.graphics.Typeface.BOLD;
import static android.graphics.Typeface.ITALIC;
import static android.graphics.Typeface.NORMAL;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.text.TextPaint;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.EditText;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;

import com.pdfEditor.Editor;
import com.pdfEditor.PAGE;
import com.pdfEditor.uploadEdits.PdfEdit;
import com.pdfEditor.uploadEdits.editsPaint;
import com.pdfEditor.xEdits;
import com.pdfviewer.PDFView;
import com.sampathkumara.northsails.smartwind.R;

public class TextEditor extends RelativeLayout {


    private static float Yposition;
    private static Canvas mCanvas;
    private static int pageNo;
    private final PDFView pdfView;
    private final EditText textFld;
    private final View window;
    private final Rect rectf = new Rect();
    @NonNull
    private final String TAG = "TEXT EDITOR";
    private final Editor editor;
    private int TEXT_X;
    private int TEXT_Y;
    private int deltaX_ = 0;
    private int deltaY_ = 0;
    private int color = Color.BLACK;
    private int size = 15;
    private boolean bold;
    private boolean italic;

    public TextEditor(Context context, PDFView pdfView, Editor editor) {
        super(context);
        this.pdfView = pdfView;
        this.editor = editor;
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.text_editor, this);


        textFld = view.findViewById(R.id.editText);
        window = view.findViewById(R.id.window);

        //                    if (!textFld.getText().toString().trim().isEmpty()) {
        OnTouchListener mTouchListener = (view12, event) -> {
            getGlobalVisibleRect(rectf);
            final int X = (int) event.getRawX() - rectf.left;
            final int Y = (int) event.getRawY() - rectf.top;
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    LayoutParams lParams = (LayoutParams) window.getLayoutParams();
                    TEXT_X = lParams.leftMargin + 5;
                    TEXT_Y = lParams.topMargin + window.getHeight();
                    invalidate();
//                    if (!textFld.getText().toString().trim().isEmpty()) {
                    save();
                    lParams.leftMargin = X - 5;
                    lParams.topMargin = Y - window.getHeight() - 10;
                    System.out.println(deltaX_ + "   " + deltaY_);
                    window.setLayoutParams(lParams);
                    textFld.requestFocus();
                    textFld.setText("");


                    break;
                case MotionEvent.ACTION_MOVE:
                case MotionEvent.ACTION_UP:
                    break;
            }

            return true;
        };
        setOnTouchListener(mTouchListener);
        //                    System.out.println(deltaX_ + "   " + deltaY_);
        OnTouchListener mTouchListener1 = (view1, event) -> {

            getGlobalVisibleRect(rectf);
            final int X = (int) event.getRawX() - rectf.left;
            final int Y = (int) event.getRawY() - rectf.top;
            LayoutParams lParams = (LayoutParams) view1.getLayoutParams();
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    deltaX_ = (int) event.getX();
                    deltaY_ = (int) event.getY();
                    break;
                case MotionEvent.ACTION_UP:
                case MotionEvent.ACTION_POINTER_UP:
                    break;
                case MotionEvent.ACTION_MOVE:
                    lParams.leftMargin = X - deltaX_;
                    lParams.topMargin = Y - deltaY_;
                    TEXT_X = X - deltaX_ + 5;
                    TEXT_Y = Y - deltaY_ - 10;
//                    System.out.println(deltaX_ + "   " + deltaY_);
                    view1.setLayoutParams(lParams);
                    break;
            }
            return true;
        };
        window.setOnTouchListener(mTouchListener1);
        textFld.setTextColor(color);
        textFld.setTextSize(size);
//        setBackgroundColor(Color.RED);

    }

    public void save() {
        if (textFld.getText().toString().trim().isEmpty()) {
            return;
        }
        LayoutParams lParams = (LayoutParams) window.getLayoutParams();

        TEXT_X = lParams.leftMargin;
        TEXT_Y = lParams.topMargin + window.getHeight() - (size / 2);
        invalidate();

        float zoom = pdfView.getZoom();
        TextPaint paint = new TextPaint(TextPaint.ANTI_ALIAS_FLAG);
        paint.setColor(color);


        paint.setTextSize(textFld.getTextSize() / zoom);
        paint.setTypeface(Typeface.create(Typeface.DEFAULT, getTypeFace()));

        float translateX = (pdfView.getCurrentXOffset() / zoom) * -1;
        float translateY = ((pdfView.getCurrentYOffset() / zoom) * -1) - (Yposition);

        float dheight = (getHeight() - pdfView.pdfFile.getMaxPageHeight()) / 2;
        xText xText = new xText(textFld.getText().toString(), paint, translateX, translateY - dheight, (TEXT_X) / zoom, (TEXT_Y) / zoom, pageNo, pdfView.pdfFile.getMaxPageWidth(), pdfView.pdfFile.getMaxPageHeight(), zoom);
        editor.editsList.add(xText);

        reDraw();


        editsPaint editsPaint = new editsPaint();
        editsPaint.setColor(paint.getColor());
        editsPaint.setOpacity(paint.getAlpha() / 255f);


        final PdfEdit pdfEdit = new PdfEdit(PdfEdit.TYPE_TEXT);
        String text = textFld.getText().toString();

        pdfEdit.setText(text);
        pdfEdit.setEditsPaint(editsPaint);
        float sp = ((((pdfView.pdfFile.getPageSpacing(pdfView.getCurrentPage(), zoom) / 2) / zoom) * (2 * (pdfView.getCurrentPage() + 1) - 1)));
        pdfEdit.setPositionX((translateX + ((TEXT_X) / zoom)) / (pdfView.pdfFile.getMaxPageWidth()));
        pdfEdit.setPositionY((translateY + ((TEXT_Y) / zoom) - sp) / (pdfView.pdfFile.getMaxPageHeight()));
        pdfEdit.setTextBold(bold);
        pdfEdit.setTextItelic(italic);
        pdfEdit.setTextSize(size);
        editor.getPdfEditsList().addEdit(pageNo, xText.getId(), pdfEdit);

    }

    private int getTypeFace() {

        if (bold & italic) {
            return Typeface.BOLD_ITALIC;
        } else if (bold) {
            return BOLD;
        } else if (italic) {
            return ITALIC;
        } else {
            return NORMAL;
        }
    }

    public void reDraw() {
        textFld.setTextSize(size * pdfView.getZoom());
        System.out.println("Redrawing........");
//        mBitmap.eraseColor(Color.TRANSPARENT);
        for (xEdits kk : editor.editsList) {
            if (kk.page == pageNo) {
                if (kk instanceof xText) {

                    reDraw((xText) kk);

                }
            }
        }
    }

    public void reDraw(xText kk) {

        mCanvas.save();

        Paint p = new Paint(kk.getPaint());
        p.setTextSize(p.getTextSize());

        float xp = (kk.translateX() / kk.getPageWidth()) * pdfView.pdfFile.getMaxPageWidth();
        float yp = (kk.translateY() / kk.getPageHeight()) * pdfView.pdfFile.getMaxPageHeight();


//        mCanvas.translate(xp, yp - Yposition + (page.dy * pdfView.getCurrentPage()));

        float h = (getHeight() - kk.getPageHeight()) / 2;
        mCanvas.translate(xp, (yp + h));

        String[] lines = kk.getText().split("\n");

        if (lines.length > 1) {
            for (int i = 0; i < lines.length; i++) {
                mCanvas.drawText(lines[i], kk.getCanvasX(), kk.getCanvasY() + (p.getTextSize() * (i)) - p.getTextSize(), p);
            }
        } else {
            mCanvas.drawText(kk.getText(), kk.getCanvasX(), kk.getCanvasY(), p);
        }


//

        mCanvas.restore();
        invalidate();

    }

    PAGE page;

    public void setPage(PAGE page) {

        System.out.println(page.id + "____" + page.position);
        Yposition = page.position;
        Bitmap mBitmap = page.getBitmap();
        mCanvas = new Canvas(mBitmap);
        pageNo = page.id;
        this.page = page;
    }

    @Override
    protected void onDraw(@NonNull Canvas canvas) {
        super.onDraw(canvas);
    }

    public void setColor(int color) {
        this.color = color;
        textFld.setTextColor(color);

    }

    public void setSize(int size) {
        this.size = size;
        textFld.setTextSize(size);
    }

    public void setBold(boolean bold) {
        this.bold = bold;
        textFld.setTypeface(null, getTypeFace());
    }

    public void setItalic(boolean italic) {
        this.italic = italic;
        textFld.setTypeface(null, getTypeFace());
    }


    public void reset() {
        textFld.setText("");

    }
}
