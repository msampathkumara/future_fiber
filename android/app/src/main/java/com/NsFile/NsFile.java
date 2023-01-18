package com.NsFile;

import android.content.Context;
import android.os.Environment;

import com.Super;

import java.io.File;
import java.io.Serializable;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;

public class NsFile extends Super implements Serializable {
    public static final int DESC = 1;
    public static final int ASC = 2;
    public static final int SORT_BY_NAME = 0;
    public static final int SORT_BY_DATE = 1;
    public static final int SORT_BY_SIZE = 2;
    public static final int SORT_BY_TYPE = 3;
    public static final int SORT_BY_CHECKOUT_DATE = 11;
    public final static int FILE_TYPE_FOLDR = 0;
    public final static int FILE_TYPE_PDF = 2;
    //    public final static String[] sort_by_list = {"fname", "uptime", "size", "red", "hold", "rush", "sk", "gr", "sort", "errout", "out_date"};
    public final static String[] sort_by_list = {"uptime", "name", "red", "hold", "rush", "sk", "gr", "sort", "errout", "inprint"};
    public int in_to = 0;
    public String holdComment;
    public int hold = 0;
    public int inprint = 0;
    public String name;
    public String path;
    public int isdir;
    public String uptime;
    public String out_date;
    public File file;
    public int red;
    public int rush;
    public int change;
    public String redComment;
    public String grComment;
    public int fileId;
    public String parent = null;
    public int sk;
    public int gr;
    public int sort;
    public int errOut;
    public int id;

    public String getRedComment() {
        return redComment;
    }

    public void setRedComment(String redComment) {
        this.redComment = redComment;
    }

    public NsFile() {
    }

    public String getGrComment() {
        return grComment;
    }

    public void setGrComment(String grComment) {
        this.grComment = grComment;
    }

    public boolean isSk() {
        return sk == 1;
    }

    public boolean isGr() {
        return gr == 1;
    }

    public boolean isSort() {
        return sort == 1;
    }

    public boolean isErrOut() {
        return errOut == 1;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public boolean isFile() {
        return !isDirectory();
    }

    public boolean isDirectory() {
        return isdir == 1;
    }

    public String getLastModified() {
        return uptime;
    }

    public int getMimeType() {
        return isDirectory() ? FILE_TYPE_FOLDR : FILE_TYPE_PDF;
    }

    public boolean isRedFlaged() {
        return red == 1;
    }

    public int getFileId() {
        return fileId;
    }

    public void setFileId(int file_id) {
        fileId = file_id;
    }

    public String getFilePath() {
        return Environment.DIRECTORY_DOCUMENTS + "/" + getParent();
//        return Environment.DIRECTORY_DOCUMENTS + "/Tickets";
    }

    public void setPerant(String parent) {
        this.parent = parent;
    }

    public String getParent() {
        if (parent != null) {
            return parent;
        }
        String fileOrDirPath = getPath();
        boolean endsWithSlash = fileOrDirPath.endsWith(File.separator);
        parent = fileOrDirPath.substring(0, fileOrDirPath.lastIndexOf(File.separatorChar,
                endsWithSlash ? fileOrDirPath.length() - 2 : fileOrDirPath.length() - 1));
        return parent;

    }

    public void setLocalFile(File file) {
        this.file = file;
    }


    public boolean isHold() {
        return hold == 1;
    }

    public String getHoldComment() {

        try {
            return java.net.URLDecoder.decode(holdComment, String.valueOf(StandardCharsets.UTF_8));
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return "";
    }


    public boolean isInPrint() {

        return inprint == 1;
    }

    public void setInPrint(boolean b) {
        inprint = b ? 1 : 0;
    }


    public String getOutDate() {
        return out_date;
    }

    public void setOutDate(String outDate) {
        this.out_date = outDate;
    }

    public int getCheckInTo() {
        return in_to;
    }


    public boolean isRush() {
        return rush == 1;
    }


    public void setChange(boolean change) {
        this.change = change ? 1 : 0;
    }

    public String getOnlyName() {
        String name = getName();
        if (name.indexOf(".") > 0) {
            name = name.substring(0, name.lastIndexOf("."));
        }

        return name;
    }


    public File getFile(Context context) {
        return file;
    }
}
