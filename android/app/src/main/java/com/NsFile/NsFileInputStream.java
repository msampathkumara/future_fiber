package com.NsFile;

import androidx.annotation.NonNull;

import java.io.FileInputStream;
import java.io.FileNotFoundException;

public class NsFileInputStream extends FileInputStream {
    public NsFileInputStream(@NonNull String name) throws FileNotFoundException {
        super(name);
    }


}
