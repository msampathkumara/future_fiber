package com.Rf;

import android.content.Intent;
import android.net.Uri;
import android.webkit.JavascriptInterface;
import android.widget.Toast;

public class JavaScriptInterface {
    private static final int RF_USER_CRED = 113;
    private final Rf activity;

    public JavaScriptInterface(Rf activity) {
        this.activity = activity;
    }

    @JavascriptInterface
    public void startVideo(String videoAddress) {
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setDataAndType(Uri.parse(videoAddress), "video/3gpp");
        activity.startActivity(intent);
    }

    @JavascriptInterface
    public void showUsernameInput() {
        Intent intent = new Intent(activity, RF_user_credentials.class);
        intent.putExtra("setup", true);
        activity.startActivityForResult(intent, RF_USER_CRED);
    }

    @JavascriptInterface
    public void showFinishButton() {
        System.out.println("________________________________dsfsdfsdFS_DFSDf_DSF_SDFSDFSDFSDFSD sdfSDFSDF SDFSdf");
        activity.showFinishButton();
    }

    @JavascriptInterface
    public void toast(final String s) {
        System.out.println("________________________________dsfsdfsdFS_DFSDf_DSF_SDFSDFSDFSDFSD sdfSDFSDF SDFSdf");
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(activity, s,
                        Toast.LENGTH_LONG).show();
            }
        });
    }
}