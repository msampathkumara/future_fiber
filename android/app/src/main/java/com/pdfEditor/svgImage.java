package com.pdfEditor;

import android.graphics.Bitmap;
import android.os.Environment;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

class svgImage {

    private long imageId;
    private File imageFile;

    public svgImage(long id, Bitmap bitmap, String fileId) {
        File direct = new File(Environment.getExternalStorageDirectory() + "/PdfEdits/" + fileId);
        if (!direct.exists()) {
            direct.mkdirs();
        }

        this.imageId = id;
        imageFile = new File(direct, id + ".png");
        OutputStream os = null;
        try {
            os = new BufferedOutputStream(new FileOutputStream(imageFile));
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, os);
            os.flush();
            os.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public File getImageFile() {
        return imageFile;
    }

    public void setImageFile(File imageFile) {
        this.imageFile = imageFile;
    }

    public long getImageId() {
        return imageId;
    }

    public void setImageId(long imageId) {
        this.imageId = imageId;
    }


}
