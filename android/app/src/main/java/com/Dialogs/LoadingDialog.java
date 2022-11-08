package com.Dialogs;

import static com.pdfEditor.BottomSheetsUtils.setupFullHeight;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.sampathkumara.northsails.smartwind.R;

import java.util.Objects;
import java.util.Timer;
import java.util.TimerTask;


public class LoadingDialog extends BottomSheetDialogFragment {


    String text;

    private boolean showButton;
    private final OnButtonClickCallBack onCancelClick = () -> System.out.println("no actions for OnButtonClickCallBack.onClick");
    private View errorView;
    private View loadView;
    private Button retryButton;
    private TextView errorMessage;

    public LoadingDialog() {

    }

    public LoadingDialog(String text, boolean showButton) {
        this.text = text;
        this.showButton = showButton;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);


    }


    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.setOnShowListener(dialogInterface -> {
            BottomSheetDialog bottomSheetDialog = (BottomSheetDialog) dialogInterface;
            setupFullHeight(bottomSheetDialog, requireActivity(), 0);
        });
        return dialog;
    }

    @Override
    public void onDismiss(@NonNull DialogInterface dialog) {
        super.onDismiss(dialog);
        T.cancel();
        try {
            onCancelClick.onClick();
        } catch (Exception ignored) {
        }
    }

    Timer T = new Timer();

    private void startTimer() {
        T = new Timer();

        T.scheduleAtFixedRate(new TimerTask() {
            int count = 1;

            @Override
            public void run() {
                requireActivity().runOnUiThread(() -> {
                    timerTv.setText(count + "");
                    count++;
                });
            }
        }, 1000, 1000);
    }

    TextView timerTv;

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.loading_dialog_box, container, false);
        Objects.requireNonNull(getDialog()).getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        timerTv = view.findViewById(R.id.timerV);
        startTimer();

        TextView text = view.findViewById(R.id.text);
        errorView = view.findViewById(R.id.errorView);
        loadView = view.findViewById(R.id.loadView);
        retryButton = view.findViewById(R.id.retryButton);
        errorMessage = view.findViewById(R.id.errorMessage);
        errorView.setVisibility(View.GONE);
        loadView.setVisibility(View.VISIBLE);


        if (showButton) {
            view.findViewById(R.id.btn_cancel).setOnClickListener(v -> onCancelClick.onClick());
        } else {
            view.findViewById(R.id.btn_cancel).setVisibility(View.GONE);
        }


        text.setText(this.text);

        view.setOnKeyListener((v, keyCode, event) -> {
            if (keyCode == KeyEvent.KEYCODE_BACK) {
                onCancelClick.onClick();
                return false;
            } else {
                return true;
            }


        });


        return view;
    }


    public void showRetry(String message, OnReteyClickCallBack onReteyClickCallBack) {
        T.cancel();
        errorView.setVisibility(View.VISIBLE);
        loadView.setVisibility(View.GONE);
        errorMessage.setText(message);
        retryButton.setOnClickListener(v -> {
            startTimer();
            errorView.setVisibility(View.GONE);
            loadView.setVisibility(View.VISIBLE);

            if (onReteyClickCallBack != null) {
                onReteyClickCallBack.onClick();
            }
        });

    }

    public interface OnButtonClickCallBack {
        void onClick();
    }

    public interface OnReteyClickCallBack {
        void onClick();
    }


}
