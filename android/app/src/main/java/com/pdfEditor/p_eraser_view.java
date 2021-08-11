package com.pdfEditor;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.pdfEditor.EditorTools.freehand.DrawingView;
import com.pdfviewer.PDFView;
import com.sampathkumara.northsails.smartwind.R;


public class p_eraser_view extends FrameLayout {

    @NonNull
    private final DrawingView drawingView;
    private final TextView t_size;
    private int STROKE;

    public p_eraser_view(@NonNull Context context, PDFView pdfView, Editor editor) {
        super(context);
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.p_eraser_view, this);
        FrameLayout pane = findViewById(R.id.pane);
        drawingView = new DrawingView(context, pdfView, editor);
        pane.addView(drawingView);

        SeekBar seekBar = view.findViewById(R.id.size);
        t_size = view.findViewById(R.id.t_size);

        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            final int min = 10;

            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                STROKE = min + i;
                drawingView.setStroke(STROKE);
                t_size.setText(STROKE + "");
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        seekBar.setProgress(5);
        drawingView.setEraser(true);


    }

    public Bitmap getBitmap() {
        return drawingView.getBitmap();
    }

    public void setPage(@NonNull PAGE page) {
        drawingView.setPage(page);
    }

    public void setEdited(boolean edited) {
        drawingView.setEdited(edited);
    }
}
