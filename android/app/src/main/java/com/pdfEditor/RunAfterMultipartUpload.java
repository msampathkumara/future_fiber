package com.pdfEditor;

public interface RunAfterMultipartUpload {
    void run();

    void onError(Exception e);
}
