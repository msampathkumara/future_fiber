package com.pdfEditor.uploadEdits;

import android.webkit.JavascriptInterface;

import org.json.JSONException;
import org.json.JSONObject;

public abstract class WebViewInterface {


    @JavascriptInterface
    public void SvgData(String value) {
        System.out.println(value);
        try {
            JSONObject j = new JSONObject(value);
//            System.out.println(j);
            onSvgData(j);
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    public abstract void onSvgData(JSONObject value);

    @JavascriptInterface
    public void Load() {
        onLoad();

    }

    public abstract void onLoad();


}
