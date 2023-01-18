package com.pdfEditor.EditorTools.freehand;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.azeesoft.lib.colorpicker.ColorPickerDialog;
import com.pdfEditor.Editor;
import com.pdfEditor.PAGE;
import com.pdfviewer.PDFView;
import com.sampathkumara.northsails.smartwind.R;


public class p_drawing_view extends FrameLayout {

    @NonNull
    public final DrawingView drawingView;
    private final TextView t_size;
    private int STROKE;
    private boolean edited;


    final FrameLayout pane;

    public p_drawing_view(@NonNull Context context, PDFView pdfView, Editor editor) {
        super(context);
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.p_drowing_view, this);
        pane = findViewById(R.id.pane);
        drawingView = new DrawingView(context, pdfView, editor);

        pane.addView(drawingView);

//setBackgroundColor(Color.argb(200,50,50,50));

        SeekBar seekBar = view.findViewById(R.id.size);
        t_size = findViewById(R.id.t_size);
        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            final int min = 1;

            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                STROKE = min + i;
                drawingView.setStroke(STROKE);
                t_size.setText("" + STROKE);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        OnClickListener onColorSelect = v -> {
            int[] x = new int[]{R.id.b_color_blue, R.id.b_color_green, R.id.b_color_orange, R.id.b_color_red, R.id.b_color_yellow};

            for (int xx : x) {
                ImageButton btn = findViewById(xx);
                btn.setImageResource(R.drawable.transparent);
                if (xx == v.getId()) {
                    btn.setImageResource(R.drawable.ring);
                    drawingView.setColor(btn.getBackgroundTintList().getDefaultColor());
                }
            }
            if (v.getId() == R.id.color) {
                ColorPickerDialog colorPickerDialog = ColorPickerDialog.createColorPickerDialog(getContext(), R.style.CustomColorPicker);
                colorPickerDialog.setOnColorPickedListener((color, hexVal) -> {
                    System.out.println("Got color: " + color);
                    System.out.println("Got color in hex form: " + hexVal);
                    drawingView.setColor(color);
                });
                colorPickerDialog.show();
                colorPickerDialog.findViewById(R.id.hexVal).setVisibility(GONE);
            }
        };

        ImageButton color = findViewById(R.id.color);
        color.setOnClickListener(onColorSelect);
        ImageButton b_color_blue = findViewById(R.id.b_color_blue);
        b_color_blue.setOnClickListener(onColorSelect);
        ImageButton b_color_green = findViewById(R.id.b_color_green);
        b_color_green.setOnClickListener(onColorSelect);
        ImageButton b_color_orange = findViewById(R.id.b_color_orange);
        b_color_orange.setOnClickListener(onColorSelect);
        ImageButton b_color_red = findViewById(R.id.b_color_red);
        b_color_red.setOnClickListener(onColorSelect);
        ImageButton b_color_yellow = findViewById(R.id.b_color_yellow);
        b_color_yellow.setOnClickListener(onColorSelect);


    }


    public Bitmap getBitmap() {
        return drawingView.getBitmap();
    }

    public void setPage(PAGE page) {
        drawingView.setPage(page);
    }

    public void setEdited(boolean edited) {
//        drawingView.Editad=edited;
        drawingView.setEdited();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

    }
}
