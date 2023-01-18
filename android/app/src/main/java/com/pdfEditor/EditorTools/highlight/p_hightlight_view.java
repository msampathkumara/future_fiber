package com.pdfEditor.EditorTools.highlight;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.SeekBar;

import androidx.annotation.ColorInt;
import androidx.annotation.NonNull;

import com.azeesoft.lib.colorpicker.ColorPickerDialog;
import com.pdfEditor.Editor;
import com.pdfEditor.PAGE;
import com.pdfviewer.PDFView;
import com.sampathkumara.northsails.smartwind.R;


public class p_hightlight_view extends FrameLayout {

    @NonNull
    private final Highlighter highlighter;
    private int STROKE;

    public p_hightlight_view(@NonNull Context context, PDFView pdfView, Editor editor) {
        super(context);
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.p_hightlight_view, this);
        FrameLayout pane = findViewById(R.id.pane);
        highlighter = new Highlighter(context, pdfView, editor);
        pane.addView(highlighter);


        SeekBar seekBar = view.findViewById(R.id.size);
        highlighter.setStroke(15);
        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            final int min = 5;

            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                STROKE = min + i;
                highlighter.setStroke(STROKE);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        seekBar.setProgress(15);

        OnClickListener onColorSelect = v -> {
            int[] x = new int[]{R.id.b_color_blue, R.id.b_color_green, R.id.b_color_orange, R.id.b_color_red, R.id.b_color_yellow};

            for (int xx : x) {
                ImageButton btn = findViewById(xx);
                btn.setImageResource(R.drawable.transparent);
                if (xx == v.getId()) {
                    btn.setImageResource(R.drawable.ring);
                    highlighter.setColor(getTransparentColor(btn.getBackgroundTintList().getDefaultColor()));
                }
            }
            if (v.getId() == R.id.color) {
                ColorPickerDialog colorPickerDialog = ColorPickerDialog.createColorPickerDialog(getContext(), R.style.CustomColorPicker);
                colorPickerDialog.setOnColorPickedListener((color, hexVal) -> {
                    System.out.println("Got color: " + color);
                    System.out.println("Got color in hex form: " + hexVal);
                    highlighter.setColor(color);
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

    private int getTransparentColor(int color) {
        int alpha = Color.alpha(color);
        int red = Color.red(color);
        int green = Color.green(color);
        int blue = Color.blue(color);

        // Set alpha based on your logic, here I'm making it 25% of it's initial value.
        alpha *= 0.5;

        return Color.argb(alpha, red, green, blue);
    }

    @ColorInt
    private static int adjustAlpha(@ColorInt int color) {
        int alpha = Math.round(Color.alpha(color) * (float) 0.5);
//        alpha = 50;
        System.out.println("alpha " + alpha);
        int red = Color.red(color);
        int green = Color.green(color);
        int blue = Color.blue(color);
        return Color.argb(alpha, red, green, blue);
    }

    public Bitmap getBitmap() {
        return highlighter.getBitmap();

    }

    public void setPage(@NonNull PAGE page) {
        highlighter.setPage(page);
    }


}
