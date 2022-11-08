package com.pdfEditor;

import android.app.AlertDialog;
import android.content.Context;
import android.os.AsyncTask;

import com.sampathkumara.northsails.smartwind.R;
import com.tom_roush.pdfbox.multipdf.PDFMergerUtility;

import java.io.File;

public class margeTask extends AsyncTask<Void, Void, File> {

    private final Editor editor;
    final Ticket selected_ticket;
    final File currentFile;
    final File fileToMarge;
    final Context context;
    private AlertDialog pDialog;

    public margeTask(Editor editor, Ticket selected_ticket, File currentFile, File fileToMarge, Context context) {
        this.editor = editor;
        this.selected_ticket = selected_ticket;
        this.currentFile = currentFile;
        this.fileToMarge = fileToMarge;
        this.context = context;
    }


    @Override
    protected File doInBackground(Void... voids) {

        File file = null;
        try {
            PDFMergerUtility mergePdf = new PDFMergerUtility();

            mergePdf.addSource(currentFile);
            mergePdf.addSource(fileToMarge);
//                    file = FileManager.createFile(CurrentFile.getName(), getContext(), Environment.DIRECTORY_DOCUMENTS);
            file = selected_ticket.ticketFile;
            mergePdf.setDestinationFileName(file.getAbsolutePath());
//                    mergePdf.mergeDocuments(new MemoryUsageSetting(false,false,-1,-1));
            pDialog.dismiss();
            editor.file = file;
            editor.reloadFile();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return file;
    }

    @Override
    protected void onPreExecute() {
//        pDialog = ProgressDialog.show(context, "Please wait...", "Merging Files..", true);
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(context);
        builder.setCancelable(false);
        builder.setView(R.layout.layout_loading_dialog);
        pDialog = builder.create();
        pDialog.show();

        super.onPreExecute();
    }

    @Override
    protected void onPostExecute(File file) {

        pDialog.dismiss();
//                   finish();
    }
}

