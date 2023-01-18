package com.pdfEditor;

import android.util.Log;

import androidx.annotation.Keep;

import com.google.gson.Gson;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;

@Keep
public class Ticket {
    String mo;
    String oe;
    int finished = 0;
    long uptime = 0;
    int file = 0;
    int sheet = 0;
    int dir = 0;
    int id = 0;
    int isRed = 0;
    int isRush = 0;
    int isSk = 0;
    int inPrint = 0;
    int isGr = 0;
    int isError = 0;
    int canOpen = 1;
    int isSort = 0;
    int isHold = 0;
    long fileVersion = 0;
    String production;
    double progress = 0.0;
    File ticketFile;

    public File getTicketFile() {
        return ticketFile;
    }

    public void setTicketFile(File ticketFile) {
        this.ticketFile = ticketFile;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMo() {
        return mo;
    }

    public static Ticket formJsonString(String ticketJsonString) {
        try {
            JSONObject jsonObject = new JSONObject(ticketJsonString);
            Gson gson = new Gson();
            return gson.fromJson(jsonObject.toString(), Ticket.class);
        } catch (JSONException err) {
            Log.d("Error", err.toString());
            err.printStackTrace();
        }

        System.out.println("****************************************************************************** err");

        return null;
    }
}
