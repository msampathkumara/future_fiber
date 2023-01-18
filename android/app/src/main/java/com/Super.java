package com;

import com.google.gson.Gson;

public class Super {
    @Override
    public String toString() {
        Gson gson = new Gson();
        return gson.toJson(this);
    }


}
