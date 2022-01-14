package com.knef.stickerview;


import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.knef.stickerview.util.AutoResizeTextView;

/**
 * Created by cheungchingai on 6/15/15.
 */
public class StickerTextView extends StickerView {
    private AutoResizeTextView tv_main;

    public StickerTextView(@NonNull Context context) {
        super(context);
    }

    public StickerTextView(@NonNull Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public StickerTextView(@NonNull Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    public static float pixelsToSp(Context context, float px) {
        float scaledDensity = context.getResources().getDisplayMetrics().scaledDensity;
        return px / scaledDensity;
    }

    @Override
    public View getMainView() {
        if (tv_main != null)
            return tv_main;

        tv_main = new AutoResizeTextView(getContext());
        //tv_main.setTextSize(22);
        tv_main.setTextColor(Color.WHITE);
        tv_main.setGravity(Gravity.CENTER);
        tv_main.setTextSize(400);
        tv_main.setShadowLayer(4, 0, 0, Color.BLACK);
        tv_main.setMaxLines(1);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
        );
        params.gravity = Gravity.CENTER;
        tv_main.setLayoutParams(params);
        if (getImageViewFlip() != null)
            getImageViewFlip().setVisibility(View.GONE);
        return tv_main;
    }

    @Override
    protected void onScaling(boolean scaleUp) {
        super.onScaling(scaleUp);
    }

    @Nullable
    public String getText() {
        if (tv_main != null)
            return tv_main.getText().toString();

        return null;
    }

    public void setText(String text) {
        if (tv_main != null)
            tv_main.setText(text);
    }
}
