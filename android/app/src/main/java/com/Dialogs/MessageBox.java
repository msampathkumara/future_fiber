package com.Dialogs;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.content.DialogInterface;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.sampathkumara.northsails.smartwind.R;

import static com.pdfEditor.BottomSheetsUtils.setupFullHeight;


public class MessageBox extends BottomSheetDialogFragment {

    int icon;
    int iconBackColor;
    String topic;
    String text;


    public MessageBox(int icon, int iconBackColor, String topic, String text) {
        this.icon = icon;
        this.iconBackColor = iconBackColor;
        this.topic = topic;
        this.text = text;

    }

    public MessageBox() {

    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);


    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.setOnShowListener(new DialogInterface.OnShowListener() {
            @Override
            public void onShow(DialogInterface dialogInterface) {
                BottomSheetDialog bottomSheetDialog = (BottomSheetDialog) dialogInterface;
                setupFullHeight(bottomSheetDialog, getActivity(), 0);
            }
        });
        return dialog;
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.message_box, container, false);
        getDialog().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);

        TextView title = view.findViewById(R.id.title);
        TextView text = view.findViewById(R.id.text);
        ImageView imageView = view.findViewById(R.id.imageView4);

        Drawable background = getResources().getDrawable(R.drawable.bottom_sheet_dialog_icon_area_back);
        background.setColorFilter(this.iconBackColor, PorterDuff.Mode.SRC_IN);
        view.findViewById(R.id.icon_back).setBackground(background);


        title.setText("" + this.topic);
        text.setText("" + this.text);


        imageView.setImageResource(this.icon);


        return view;
    }


}
