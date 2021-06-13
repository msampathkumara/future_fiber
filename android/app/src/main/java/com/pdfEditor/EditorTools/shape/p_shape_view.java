package com.pdfEditor.EditorTools.shape;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;

import androidx.annotation.NonNull;

import com.azeesoft.lib.colorpicker.ColorPickerDialog;
import com.pdfEditor.Editor;
import com.pdfEditor.PAGE;
import com.pdfEditor.uploadEdits.PdfEdit;
import com.pdfEditor.uploadEdits.editsPaint;
import com.pdfviewer.PDFView;
import com.sampathkumara.northsails.smartwind.R;

//import com.flask.colorpicker.ColorPickerView;
//import com.flask.colorpicker.OnColorSelectedListener;
//import com.flask.colorpicker.builder.ColorPickerClickListener;
//import com.flask.colorpicker.builder.ColorPickerDialogBuilder;


public class p_shape_view extends FrameLayout {

    private final Rect rectf = new Rect();
    private final PDFView pdfView;
    @NonNull
    private final shape_container shapeC;
    @NonNull
    private final String TAG = "SHAPE VIEW";
    @NonNull
    Editor editor;
    private float Yposition;
    private Canvas mCanvas;
    private int pageNo;
    private int TEXT_X;
    private int TEXT_Y;
    private int deltaX_ = 0;
    private int deltaY_ = 0;

    public p_shape_view(@NonNull Context context, PDFView pdfView, Editor editor) {
        super(context);
        Context context1 = context;
        this.editor = editor;
        this.pdfView = pdfView;
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.p_shape_view, this);
        shapeC = new shape_container(context, pdfView);
        Button edit_menu_shapes = view.findViewById(R.id.edit_menu_shapes);
        RelativeLayout pane = findViewById(R.id.pane);
        pane.addView(shapeC);

        CheckBox fill = findViewById(R.id.fill);
        shapeC.setFill(fill.isChecked());
        fill.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                shapeC.setFill(b);
            }
        });
        edit_menu_shapes.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                final ShapeSelectDialog shapeSelectDialog = new ShapeSelectDialog(p_shape_view.this.getContext());

                shapeSelectDialog.show();
                shapeSelectDialog.setCancelable(true);
                shapeSelectDialog.setOnItemSelect(new OnClickListener() {
                    @Override
                    public void onClick(@NonNull View view) {
                        switch (view.getId()) {
                            case R.id.shape_rect:
                                shapeC.setShape(shape_container.RECTANGLE);
                                shapeSelectDialog.dismiss();
                                shapeC.setVisibility(VISIBLE);
                                break;
                            case R.id.shape_cercle:
                                shapeC.setShape(shape_container.CERCLE);
                                shapeSelectDialog.dismiss();
                                shapeC.setVisibility(VISIBLE);
                                break;
                            case R.id.shape_triangle:
                                shapeC.setShape(shape_container.TRIANGLE);
                                shapeSelectDialog.dismiss();
                                shapeC.setVisibility(VISIBLE);
                                break;
                        }
                    }
                });
            }
        });
        shapeC.setVisibility(GONE);
        shapeC.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View view, @NonNull MotionEvent event) {

                getGlobalVisibleRect(rectf);
                final int X = (int) event.getRawX() - rectf.left;
                final int Y = (int) event.getRawY() - rectf.top;
                RelativeLayout.LayoutParams lParams = (RelativeLayout.LayoutParams) shapeC.getLayoutParams();
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


        Button done = view.findViewById(R.id.done);
        done.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                save();
            }
        });

//        addView(shapeC);

        SeekBar seekBar = view.findViewById(R.id.size);
        shapeC.setStroke(10);
        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            final int min = 5;

            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                shapeC.setStroke(min + i);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        findViewById(R.id.color).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
//                ColorPickerDialogBuilder
//                        .with(getContext())
//                        .setTitle("Choose color")
//                        .wheelType(ColorPickerView.WHEEL_TYPE.FLOWER)
//                        .density(12)
//                        .setOnColorSelectedListener(new OnColorSelectedListener() {
//                            @Override
//                            public void onColorSelected(int selectedColor) {
////                                toast("onColorSelected: 0x" + Integer.toHexString(selectedColor));
//                            }
//                        })
//                        .setPositiveButton("ok", new ColorPickerClickListener() {
//                            @Override
//                            public void onClick(DialogInterface dialog, int selectedColor, Integer[] allColors) {
////                                changeBackgroundColor(selectedColor);
//                                shapeC.setColor(selectedColor);
//                            }
//                        })
//                        .setNegativeButton("cancel", new DialogInterface.OnClickListener() {
//                            @Override
//                            public void onClick(DialogInterface dialog, int which) {
//                            }
//                        })
//                        .build()
//                        .show();
                ColorPickerDialog colorPickerDialog = ColorPickerDialog.createColorPickerDialog(getContext(), R.style.CustomColorPicker);
                colorPickerDialog.setOnColorPickedListener(new ColorPickerDialog.OnColorPickedListener() {
                    @Override
                    public void onColorPicked(int color, String hexVal) {
                        System.out.println("Got color: " + color);
                        System.out.println("Got color in hex form: " + hexVal);
                        shapeC.setColor(color);
                        // Make use of the picked color here
                    }
                });

                colorPickerDialog.show();
                colorPickerDialog.findViewById(R.id.hexVal).setVisibility(GONE);
            }
        });

    }


    public void save() {
        System.out.println("SHAPE SAVE");

        float zoom = pdfView.getZoom();
//        float translateX = Math.abs(pdfView.getCurrentXOffset() / zoom);
//        float translateY = Math.abs((pdfView.getCurrentYOffset() / zoom)) - (Yposition);

        float translateX = Math.abs((pdfView.getCurrentXOffset()) / zoom) + (TEXT_X / zoom);
        float translateY = Math.abs(((pdfView.getCurrentYOffset()) / zoom)) - (Yposition) + (TEXT_Y / zoom);

//        final float translateX = Math.abs(pdfView.getCurrentXOffset() / zoom);
//        final float translateY = Math.abs((pdfView.getCurrentYOffset() / zoom)) - (Yposition);


        shape shape = shapeC.getShape();
        float dheight = (getHeight() - pdfView.pdfFile.getMaxPageHeight()) / 2;
        xShape xShape = new xShape(shape, translateX, translateY-dheight, (TEXT_X), (TEXT_Y), pageNo, pdfView.pdfFile.getMaxPageWidth(), pdfView.pdfFile.getMaxPageHeight(), zoom);

        editor.editsList.add(xShape);

        addToShapesList(xShape, translateX, translateY);


        editor.reDraw(pageNo);

    }

    private void addToShapesList(xShape xShape, float X, float Y) {
        PdfEdit pdfEdit = null;
        if (xShape.getShape() instanceof rectangle) {
            pdfEdit = new PdfEdit(PdfEdit.TYPE_RECTANGLE);
            pdfEdit.setRect_width(xShape.getShape().getWidth());
            pdfEdit.setRect_height(xShape.getShape().getHeight());
        }
        if (xShape.getShape() instanceof cercle) {
            pdfEdit = new PdfEdit(PdfEdit.TYPE_CERCLE);
            pdfEdit.setRadius(xShape.getShape().getRadius());
        }
        if (xShape.getShape() instanceof triangle) {
            pdfEdit = new PdfEdit(PdfEdit.TYPE_TRIANGLE);
            pdfEdit.setRect_width(xShape.getShape().getWidth());
            pdfEdit.setRect_height(xShape.getShape().getHeight());
        }

        editsPaint editsPaint = new editsPaint();
        editsPaint.setColor(xShape.getShape().getPaint().getColor());
        editsPaint.setStroke(xShape.getShape().getSTROKE());
        pdfEdit.setEditsPaint(editsPaint);
        pdfEdit.setPositionX(X);
        pdfEdit.setPositionY(Y);
        pdfEdit.setFill(xShape.isFill());

        if (xShape.getShape() instanceof rectangle) {

        }

        editor.getPdfEditsList().addEdit(pageNo, xShape.getId(), pdfEdit);
    }

//    public void reDraw() {
//        System.out.println("Redrawing........");
////        mBitmap.eraseColor(Color.TRANSPARENT);
//        for (xEdits kk : editor.editsList) {
//            if (kk.page == pageNo) {
//                if (kk instanceof xShape) {
//
//                    reDraw((xShape) kk);
//
////                    float x = pdfView.pdfFile.getMaxPageWidth() / (kk.getPageWidth());
////                    float y = pdfView.pdfFile.getMaxPageHeight() / kk.getPageHeight();
////                    x = x * (pdfView.getZoom() / k.getZoom());
////                    y = y * (pdfView.getZoom() / k.getZoom());
////
////                    Matrix scaleMatrix = new Matrix();
////                    scaleMatrix.setScale(x, y, 0, 0);
////
////
////                    float xx = ((k.translateX() * pdfView.getZoom()) + (pdfView.getCurrentXOffset()));
////                    float yy = ((k.translateY() * pdfView.getZoom()) + pdfView.getCurrentYOffset() + (Yposition * pdfView.getZoom()));
////
////                    mCanvas.translate(xx, yy);
////
//////                    mCanvas.translate(k.translateX() * x, k.translateY() * y);
////
//////                    mCanvas.drawBitmap(k.getBitmap(), scaleMatrix, null);
////
////                    mCanvas.restore();
////                    invalidate();
//
//                }
//            }
//        }
//    }

    public void reDraw(xShape kk) {
        xShape k = kk;
        shape shape = k.getShape();
        mCanvas.save();

        float x1 = pdfView.pdfFile.getMaxPageWidth() / (kk.getPageWidth());
        float y1 = pdfView.pdfFile.getMaxPageHeight() / kk.getPageHeight();

        System.out.println(x1 + "_x1__y1__" + y1);

        float x = x1 * (pdfView.getZoom() / k.getZoom());
        float y = y1 * (pdfView.getZoom() / k.getZoom());

        RectF rectF = new RectF(x, y, 0, 0);

        Matrix scaleMatrix = new Matrix();
        scaleMatrix.setScale(x, y, 0, 0);

        float xp = (k.translateX() / kk.getPageWidth()) * pdfView.pdfFile.getMaxPageWidth();
        float yp = (k.translateY() / kk.getPageHeight()) * pdfView.pdfFile.getMaxPageHeight();

        float xx = (((xp) * pdfView.getZoom()) + (pdfView.getCurrentXOffset()));
        float yy = (((yp) * pdfView.getZoom()) + pdfView.getCurrentYOffset() + (Yposition * pdfView.getZoom()));


        mCanvas.translate(xx, yy);


        if (shape instanceof triangle) {
            Paint p = new Paint(k.getShape().getPaint());
            p.setStrokeWidth(p.getStrokeWidth() * pdfView.getZoom());
            Path path = shape.getPath();
            path.computeBounds(rectF, true);
            path.transform(scaleMatrix);
            mCanvas.drawPath(path, p);
        } else if (shape instanceof cercle) {
            Paint p = new Paint(k.getShape().getPaint());
            p.setStrokeWidth(p.getStrokeWidth());
            mCanvas.scale(x, y, 0, 0);
            float r1 = shape.getRadius();
//                        mCanvas.drawCircle((r1 / 2) * pdfView.getZoom(), (r1 / 2) * pdfView.getZoom(), ((r1 - (shape.getSTROKE() * 2)) / 2) * pdfView.getZoom(), p);
            mCanvas.drawCircle((r1 / 2), (r1 / 2), ((r1 - (shape.getSTROKE() * 2)) / 2), p);
//                        mCanvas.drawArc(rectF, 0, (float) (2f * Math.PI), false, p);
        } else if (shape instanceof rectangle) {
            Paint p = new Paint(k.getShape().getPaint());
            p.setStrokeWidth(p.getStrokeWidth() * pdfView.getZoom());
            float r1 = shape.getRadius();
            mCanvas.scale(x, y, 0, 0);
            mCanvas.drawRect(2, 2, (shape.getWidth() - 2), (shape.getHeight() - 2), p);
        }


        mCanvas.restore();
        invalidate();


    }

    public void setPage(@NonNull PAGE page) {

        System.out.println(page.id + "____" + page.position);
        Yposition = page.position;
        Bitmap mBitmap = page.getBitmap();
        this.pageNo = page.id;
        mCanvas = new Canvas(mBitmap);
//        reDraw();
//        invalidate();
    }

    @Override
    protected void onDraw(@NonNull Canvas canvas) {
        super.onDraw(canvas);
        Rect clipBounds = canvas.getClipBounds();
    }

//    public void setEdited(boolean edited) {
//        reDraw();
////        invalidate();
//    }
}
