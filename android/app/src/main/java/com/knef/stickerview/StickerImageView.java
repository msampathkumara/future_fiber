package com.knef.stickerview;


import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;

import androidx.annotation.NonNull;


public class StickerImageView extends StickerView {

    private String owner_id;
    private ImageView iv_main;

    public StickerImageView(@NonNull Context context) {
        super(context);
    }

    public StickerImageView(@NonNull Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public StickerImageView(@NonNull Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    public View getMainView() {
        if (this.iv_main == null) {
            this.iv_main = new ImageView(getContext());
            this.iv_main.setScaleType(ImageView.ScaleType.FIT_XY);
        }
        return iv_main;
    }


}
