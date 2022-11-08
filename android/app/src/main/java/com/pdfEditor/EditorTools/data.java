package com.pdfEditor.EditorTools;

import android.os.Parcel;
import android.os.Parcelable;

import com.pdfEditor.uploadEdits.EditsList;
import com.pdfEditor.xEdits;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class data implements Parcelable {
    public static Creator<data> CREATOR = new Creator<data>() {

        @Override
        public data createFromParcel(Parcel source) {
            return new data();
        }

        @Override
        public data[] newArray(int size) {
            return new data[size];
        }

    };
    public String ssss;
    EditsList pdfEditsList = new EditsList();
    ArrayList<xEdits> editsList = new ArrayList<>();
    HashMap<Long, File> images = new HashMap<>();

    public data(List<xEdits> editsList, HashMap<Long, File> images, EditsList pdfEditsList) {
        ssss = "**********************************************************************     DATA SETED";
        this.editsList = new ArrayList<>(editsList);
        this.images = new HashMap<>(images);
        this.pdfEditsList = pdfEditsList;
        System.out.println(this.editsList.size() + ".........");
    }

    public data() {
//        this.editsList = source.readArrayList(null);
    }


    public EditsList getPdfEditsList() {
        return pdfEditsList;
    }


    public ArrayList<xEdits> getEditsList() {

        return editsList;
    }


    public HashMap<Long, File> getImagesList() {
        return images;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
//        dest.writeList(editsList);
    }


}