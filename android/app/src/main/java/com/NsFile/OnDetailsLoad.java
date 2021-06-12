package com.NsFile;

import android.content.DialogInterface;

import com.sampathkumara.northsails.smartwind.MainActivity;

import org.json.JSONObject;


public abstract class OnDetailsLoad {
    public abstract void run(JSONObject jsonObject);

    public void OnSocketTimeoutException(updateData updateData) {
        updateData.load();
    }


}