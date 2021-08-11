package com.pdfEditor;

import android.app.Activity;
import android.util.DisplayMetrics;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.fragment.app.FragmentActivity;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.sampathkumara.northsails.smartwind.R;

import java.util.Objects;


public class BottomSheetsUtils {
    public static void setupFullHeight(BottomSheetDialog bottomSheetDialog, Activity context, int margineTop) {
        FrameLayout bottomSheet = bottomSheetDialog.findViewById(R.id.design_bottom_sheet);
        BottomSheetBehavior behavior = BottomSheetBehavior.from(Objects.requireNonNull(bottomSheet));
        ViewGroup.LayoutParams layoutParams = bottomSheet.getLayoutParams();
        int statusBarHeight = (int) Math.ceil(25 * context.getResources().getDisplayMetrics().density);
        int windowHeight = getWindowHeight(context);
        if (layoutParams != null) {
            layoutParams.height = windowHeight - statusBarHeight - margineTop;
        }
        bottomSheet.setLayoutParams(layoutParams);
        behavior.setState(BottomSheetBehavior.STATE_EXPANDED);
        behavior.setPeekHeight(Objects.requireNonNull(layoutParams).height);
    }

    public static int getWindowHeight(Activity context) {
        // Calculate window height for fullscreen use
        DisplayMetrics displayMetrics = new DisplayMetrics();
        context.getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        return displayMetrics.heightPixels;
    }

    public static int getWindowWidth(FragmentActivity activity) {
        DisplayMetrics displayMetrics = new DisplayMetrics();
        activity.getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        return displayMetrics.widthPixels;
    }
}
