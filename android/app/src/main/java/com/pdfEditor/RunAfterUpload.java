package com.pdfEditor;

import java.io.File;

public abstract   class RunAfterUpload {


    public abstract void run(File sourceFile);

    public abstract void error(Exception exception);

}
