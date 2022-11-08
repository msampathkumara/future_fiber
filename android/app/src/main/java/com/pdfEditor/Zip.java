package com.pdfEditor;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class Zip {
    static final int BUFFER = 2048;

    final ZipOutputStream out;
    final byte[] data;

    public Zip(String name) {
        FileOutputStream dest = null;
        try {
            dest = new FileOutputStream(name);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        out = new ZipOutputStream(new BufferedOutputStream(dest));
        data = new byte[BUFFER];
    }


    public void addFile(File file, String folderName) {
        FileInputStream fi;
        try {
            fi = new FileInputStream(file.getPath());
            BufferedInputStream origin = new BufferedInputStream(fi, BUFFER);
            ZipEntry entry = new ZipEntry(folderName + "/" + file.getName());
            out.putNextEntry(entry);
            int count;
            while ((count = origin.read(data, 0, BUFFER)) != -1) {
                out.write(data, 0, count);
            }
            origin.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    public void addFile(File file) {
        FileInputStream fi;
        try {
            fi = new FileInputStream(file.getPath());
            BufferedInputStream origin = new BufferedInputStream(fi, BUFFER);
            ZipEntry entry = new ZipEntry(file.getName());
            out.putNextEntry(entry);
            int count;
            while ((count = origin.read(data, 0, BUFFER)) != -1) {
                out.write(data, 0, count);
            }
            origin.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    public void closeZip() {
        try {
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
