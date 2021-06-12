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

//    public static NsFile fromPath(String pathToFile) throws FileNotFoundException {
//
////        super(pathToFile);
//        System.out.println(pathToFile);
//        if (pathToFile.endsWith("/")) {
//            pathToFile = pathToFile.substring(0, pathToFile.length() - 1);
//        }
//        if (!pathToFile.trim().startsWith(".")) {
//            pathToFile = "." + pathToFile;
//        }
//        System.out.println(pathToFile);
//        System.out.println("SELECT * FROM files where `path`='" + pathToFile + "'");
//        Cursor c = LiteDb.getDB().rawQuery("SELECT * FROM files where `path`='" + pathToFile + "'", null);
////        Cursor c = LiteDb.getDB().rawQuery("SELECT * FROM files ", null);
//        System.out.println("C =" + c);
//        boolean b = c.moveToFirst();
//        if (c.getCount() > 0) {
//
//            return loadNsFile(c);
//
//        } else {
//
//            throw new FileNotFoundException();
//        }
//
//    }

//    public static NsFile fromId(int fileId) throws FileNotFoundException {
//        System.out.println(fileId);
//        Cursor c = LiteDb.getDB().rawQuery("SELECT * FROM files where `fileID`='" + fileId + "'", null);
//        System.out.println("C =" + c);
//        boolean b = c.moveToFirst();
//        if (c.getCount() > 0) {
//            return loadNsFile(c);
//        } else {
//            throw new FileNotFoundException();
//        }
//    }
//
//    private static NsFile loadNsFile(Cursor c) {
//
//        return LiteDb.getClass(c, NsFile.class);
//    }

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

//    public NsFile[] listFiles(boolean ALL_FILES, NsFileNameFilter nsFilenameFilter) {
//        ArrayList<NsFile> nsFiles = new ArrayList<>();
//        List<NsFile> nsFiles1 = listFiles(ALL_FILES);
//        for (NsFile file : nsFiles1) {
//            if (nsFilenameFilter.accept(file, file.getName())) {
//                nsFiles.add(file);
//            }
//        }
//
//        return nsFiles.toArray(new NsFile[0]);
//    }

//    public List<NsFile> listFiles(boolean ALL_FILES) {
//        String af = "";
//        if (!ALL_FILES) {
//            af = " and `canopen`='1' ";
//        }
//        List<NsFile> nsFiles;
//        System.out.println(getPath());
//        Cursor c = LiteDb.getDB().rawQuery("SELECT * FROM files where `path` like '" + getPath() + "/%'  " + af + "  ORDER BY `isdir` DESC", null);
//        System.out.println("____________________________________________________ COUNT __ " + c.getCount());
//        nsFiles = getFileList(c);
//        return nsFiles;
//    }

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

//    public List<NsFile> getFileList(Cursor c) {
//        return LiteDb.getList(c, NsFile[].class);
//    }

    public boolean isFile() {
        return !isDirectory();
    }

    public boolean isDirectory() {
        return isdir == 1;
    }

//    public InputStream getInputStream() {
//        return null;
//    }
//
//    public boolean exists() {
//        return false;
//    }
//
//    public boolean mkdirs() {
//
//        return false;
//    }
//
//    public boolean delete() {
//
//        return false;
//    }

    public String getLastModified() {
        return uptime;
    }

//    public long length() {
//        return 0;
//    }

    public int getMimeType() {
        return isDirectory() ? FILE_TYPE_FOLDR : FILE_TYPE_PDF;
    }

    public boolean isRedFlaged() {
        return red == 1;
    }

//    public String getDownloadUrl() {
//        return URLS.TicketDownloadPath + "?file=" + getFileId();
//    }

    public int getFileId() {
        return fileId;
    }

    public void setFileId(int file_id) {
        fileId = file_id;
    }

//    public File getFile(Context context) {
//        if (file == null) {
//            file = new File(String.valueOf(App.getAppContext().getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS + "/" + getParent())), getName());
////            file = new File(String.valueOf(App.getAppContext().getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS + "/Tickets")), getFileId() + "");
//
//        }
//        return file;
//    }

//    public File getFile() {
//        if (file == null) {
//            file = new File(String.valueOf(App.getAppContext().getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS + "/" + getParent())), getName());
////            file = new File(String.valueOf(App.getAppContext().getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS + "/Tickets")), getFileId() + "");
//        }
//        return file;
//    }

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


//    public ArrayList<NsFile> listFiles(boolean ALL_FILES, int sortBy, int orderBy, NsFileNameFilter nsFilenameFilter) {
//        ArrayList<NsFile> nsFiles = new ArrayList<>();
//        List<NsFile> nsFiles1 = listFiles(ALL_FILES, sortBy, orderBy);
//        for (NsFile file : nsFiles1) {
//            if (nsFilenameFilter.accept(file, file.getName())) {
//                nsFiles.add(file);
//            }
//        }
//
//        return nsFiles;
//    }

//    public List<NsFile> listFiles(boolean ALL_FILES, int sortBy, int Order) {
//        String af = "";
//        if (!ALL_FILES) {
//            af = " and `canopen`='1' ";
//        }
//        String sb = sort_by_list[sortBy];
//        String b = "";
//        if (Order == DESC) {
//            b = "DESC";
//        } else if (Order == ASC) {
//            b = "ASC";
//        }
//
//
//        System.out.println(sb + "_______");
//        Cursor c = LiteDb.getDB().rawQuery("SELECT * FROM files where `path` like '" + getPath() + "/%'   " + af + " ORDER BY `isdir`  DESC , `" + sb + "` " + b, null);
//        System.out.println("____________________________________________________ COUNT __ " + c.getCount());
////        nsFiles = getFileList(c);
//
//        return getFileList(c);
//    }

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
