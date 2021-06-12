package com.pdfEditor.EditorTools.shape;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;

import com.sampathkumara.northsails.smartwind.R;


class ShapeSelectDialog extends Dialog implements View.OnClickListener {

    private View shape_rect;
    private View shape_cercle;
    private View shape_triangle;

    public ShapeSelectDialog(@NonNull Context context) {
        super(context);

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.dialog_shape_select);
        shape_rect = findViewById(R.id.shape_rect);
        shape_cercle = findViewById(R.id.shape_cercle);
        shape_triangle = findViewById(R.id.shape_triangle);
        setTitle("Select Shape");
        setCanceledOnTouchOutside(true);
    }

    @Override
    public void onClick(View view) {

    }

    public void setOnItemSelect(View.OnClickListener onClickListener) {
        shape_rect.setOnClickListener(onClickListener);
        shape_cercle.setOnClickListener(onClickListener);
        shape_triangle.setOnClickListener(onClickListener);
    }
}
