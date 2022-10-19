package com;

import android.content.Context;
import android.os.Environment;

import androidx.fragment.app.Fragment;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public abstract class E extends Fragment {

    private runAfterLoad runAfterLoad;


    public File createImageFile() throws IOException {
        String timeStamp =
                new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(new Date());
        String imageFileName = "IMG_" + timeStamp + "_";
        File storageDir =
                getActivity().getExternalFilesDir(Environment.DIRECTORY_PICTURES);


        return File.createTempFile(
                imageFileName,  /* prefix */
                ".bmp",         /* suffix */
                storageDir      /* directory */
        );
    }

    public abstract void openCameraIntent(Context context);

    public abstract void browsImages(final Context context);

    public interface runAfterLoad {
        void run(E editor);
    }


}
