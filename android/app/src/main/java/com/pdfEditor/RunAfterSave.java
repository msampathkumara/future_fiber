package com.pdfEditor;

import org.json.JSONObject;

import java.io.File;

public abstract   class RunAfterSave {


    public abstract void run(File sourceFile);

    public abstract void run(JSONObject value, Ticket ticket);

    public abstract void error(Exception exception);
}
