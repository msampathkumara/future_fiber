package com.pdfEditor.EditorTools;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;

import com.azeesoft.lib.colorpicker.ColorPickerDialog;
import com.sampathkumara.northsails.smartwind.R;

public class ColorSelector extends LinearLayout {

    public interface OnColorSelectListener {
        void OnColorSelect(int color);
    }

    OnColorSelectListener onColorSelectListener = color -> {

    };

    public void setOnColorSelect(OnColorSelectListener onColorSelectListener) {
        this.onColorSelectListener = onColorSelectListener;
    }


    public ColorSelector(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    private void init(Context context) {
        inflate(context, R.layout.color_selector, this);

        OnClickListener onColorSelect = v -> {
            int[] x = new int[]{R.id.b_color_blue, R.id.b_color_green, R.id.b_color_orange, R.id.b_color_red, R.id.b_color_yellow};

            for (int xx : x) {
                ImageButton btn = findViewById(xx);
                btn.setImageResource(R.drawable.transparent);
                if (xx == v.getId()) {
                    btn.setImageResource(R.drawable.ring);
                    onColorSelectListener.OnColorSelect(btn.getBackgroundTintList().getDefaultColor());
                }
            }
            if (v.getId() == R.id.color) {
                ColorPickerDialog colorPickerDialog = ColorPickerDialog.createColorPickerDialog(getContext(), R.style.CustomColorPicker);
                colorPickerDialog.setOnColorPickedListener((color, hexVal) -> onColorSelectListener.OnColorSelect(color));
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


}
