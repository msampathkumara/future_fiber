package com.pdfEditor.EditorTools.textEditor;

import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.graphics.drawable.DrawableCompat;

import com.pdfEditor.Editor;
import com.pdfEditor.EditorTools.ColorSelector;
import com.pdfEditor.PAGE;
import com.pdfviewer.PDFView;
import com.sampathkumara.northsails.smartwind.R;


public class p_Text_Editor_view extends FrameLayout {


    private final TextView t_size;
    private final Button b_bold;
    private final Button b_italic;
    @NonNull
    public final TextEditor textEditor;
    private boolean isbold = false;
    private int STROKE;
    private boolean isItalic;
    Editor.RunAfterDone runAfterDone = new Editor.RunAfterDone() {
        @Override
        public void run() {

        }
    };

    public p_Text_Editor_view(@NonNull Context context, PDFView pdfView, Editor editor, Editor.RunAfterDone runAfterDone) {
        super(context);

        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.p_text_editor, this);
        FrameLayout pane = findViewById(R.id.pane);
        textEditor = new TextEditor(context, pdfView, editor);
        pane.addView(textEditor);

        ColorSelector colorSelector = view.findViewById(R.id.colorSelector);

        colorSelector.setOnColorSelect(new ColorSelector.OnColorSelectListener() {
            @Override
            public void OnColorSelect(int color) {
                textEditor.setColor(color);
            }
        });


        SeekBar seekBar = view.findViewById(R.id.size);
        seekBar.getProgressDrawable().setColorFilter(Color.WHITE, PorterDuff.Mode.MULTIPLY);
        textEditor.setSize(15);
        t_size = view.findViewById(R.id.t_size);
        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            final int min = 5;

            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                STROKE = min + i;
                textEditor.setSize(STROKE);
                t_size.setText(STROKE + "");
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        seekBar.setProgress(15);


        b_bold = findViewById(R.id.b_bold);
        b_bold.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                isbold = !isbold;
                textEditor.setBold(isbold);
                b_bold.setTextColor(isbold ? Color.BLACK : Color.GRAY);
                setBackgroundTint(b_bold, isbold ? Color.BLACK : Color.GRAY);
            }
        });

        b_italic = findViewById(R.id.b_italic);
        b_italic.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                isItalic = !isItalic;
                textEditor.setItalic(isItalic);
                b_italic.setTextColor(isItalic ? Color.BLACK : Color.GRAY);
                setBackgroundTint(b_italic, isItalic ? Color.BLACK : Color.GRAY);
            }
        });

        findViewById(R.id.done).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                runAfterDone.run();
                saveText();
                textEditor.reset();
            }
        });
        findViewById(R.id.b_cancel).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                runAfterDone.run();
                textEditor.reset();
            }
        });

    }

    public void setBackgroundTint(View view, int color) {
        Drawable buttonDrawable = view.getBackground();
        buttonDrawable = DrawableCompat.wrap(buttonDrawable);
        DrawableCompat.setTint(buttonDrawable, color);
        view.setBackground(buttonDrawable);
    }

    public void setPage(@NonNull PAGE page) {
        textEditor.setPage(page);
    }

    public void saveText() {
        textEditor.save();
    }


    public void reDraw() {
        textEditor.reDraw();
    }


}
