package com;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.Map;

public class Super {
    @Override
    public String toString() {
        Gson gson = new Gson();
        return gson.toJson(this);
    }

    public Map toHashMap() {
        Type type = new TypeToken<Map>() {
        }.getType();
        Gson gson = new Gson();
        String jsonString = gson.toJson(this);

        return gson.fromJson(jsonString, type);
    }
}
