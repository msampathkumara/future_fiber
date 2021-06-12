package com.pdfEditor.EditorTools;

import android.os.Parcel;
import android.os.Parcelable;

import com.NsFile.NsFile;
import com.pdfEditor.uploadEdits.EditsList;
import com.pdfEditor.xEdits;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class data implements Parcelable {
    public static Creator<data> CREATOR = new Creator<data>() {

        @Override
        public data createFromParcel(Parcel source) {
            return new data(source);
        }

        @Override
        public data[] newArray(int size) {
            return new data[size];
        }

    };
    public String ssss;
    EditsList pdfEditsList = new EditsList();
    List<xEdits> editsList = new ArrayList<>();
    HashMap<Long, File> images = new HashMap<>();
    NsFile fileldForm;
    NsFile ticket;
    NsFile emptyForm;
    private int toolVisibility;

    public data(List<xEdits> editsList, HashMap<Long, File> images, EditsList pdfEditsList, int toolVisibility) {
        ssss = "**********************************************************************     DATA SETED";
        this.editsList = new ArrayList<>(editsList);
        this.images = new HashMap<>(images);
        this.pdfEditsList = pdfEditsList;
        this.toolVisibility = toolVisibility;
        System.out.println(this.editsList.size() + ".........");
    }

    public data(Parcel source) {
//        this.editsList = source.readArrayList(null);
    }

    public int getToolVisibility() {
        return toolVisibility;
    }

    public void setToolVisibility(int toolVisibility) {
        this.toolVisibility = toolVisibility;
    }

    public NsFile getEmptyForm() {
        return emptyForm;
    }

    public void setEmptyForm(NsFile emptyForm) {
        this.emptyForm = emptyForm;
    }

    public NsFile getFileldForm() {
        return fileldForm;
    }

    public void setFileldForm(NsFile fileldForm) {
        this.fileldForm = fileldForm;
    }

    public NsFile getTicket() {
        return ticket;
    }

    public void setTicket(NsFile ticket) {
        this.ticket = ticket;
    }

    public EditsList getPdfEditsList() {
        return pdfEditsList;
    }

    public void setPdfEditsList(EditsList pdfEditsList) {
        this.pdfEditsList = pdfEditsList;
    }

    public List<xEdits> getEditsList() {

        return editsList;
    }

    public void setEditsList(List<xEdits> editsList) {
        this.editsList = editsList;
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

    private HashMap<String, File> getImages() {

        HashMap<String, File> files = new HashMap<>();
        for (Map.Entry<Long, File> f : images.entrySet()) {
            files.put("images[]", f.getValue());
        }

        return files;

    }


}