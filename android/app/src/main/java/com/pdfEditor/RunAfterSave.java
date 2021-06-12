package com.pdfEditor;

import com.NsFile.NsFile;

import org.json.JSONObject;

import java.io.File;

public abstract   class RunAfterSave {


    public abstract void run(File sourceFile);

    public abstract void run(JSONObject value, NsFile nsFile);

    public abstract void error(Exception exception);
}
