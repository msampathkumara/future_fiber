package com.NsFile;

import org.json.JSONObject;


public abstract class OnDetailsLoad {
    public abstract void run(JSONObject jsonObject);

    public void OnSocketTimeoutException(updateData updateData) {
        updateData.load();
    }


}