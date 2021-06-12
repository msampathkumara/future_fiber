package com.pdfEditor.uploadEdits;

import com.google.gson.Gson;

import java.util.HashMap;

public class EditsList {

    HashMap<Integer, PdfPage> pageList = new HashMap<>();

    public String getList() {
        Gson gson = new Gson();
        String jsonString = gson.toJson(EditsList.this);
        return jsonString;
    }

    public void removeEdit(int page, long id) {
        pageList.get(page).getEdits().remove(id);
    }

    public void addEdit(int pageNo, long id, PdfEdit pdfEdit) {
        getPage(pageNo).addEdit(id, pdfEdit);
    }

    public PdfPage getPage(int index) {
        if (pageList.get(index) == null) {
            pageList.put(index, new PdfPage());
        }
        return pageList.get(index);
    }

    public PdfEdit getEditById(long id) {
        for (int i : pageList.keySet()) {
            PdfPage pdfPage = pageList.get(i);
            PdfEdit pdfEdit = pdfPage.getEdits().get(id);
            if (pdfEdit != null) {
                return pdfEdit;
            }
        }
        return null;
    }


}


