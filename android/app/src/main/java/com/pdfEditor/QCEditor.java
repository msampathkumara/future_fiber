package com.pdfEditor;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.StrictMode;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.Dialogs.LoadingDialog;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.pdfEditor.EditorTools.data;
import com.sampathkumara.northsails.smartwind.R;
import com.tom_roush.pdfbox.pdmodel.PDDocument;
import com.tom_roush.pdfbox.pdmodel.PDPage;
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream;

import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


public class QCEditor extends AppCompatActivity {

    public static String FILE_NAME;
    static String FILE_PATH;
    public Editor pdfEditor;
    Ticket SELECTED_FILE;
    int RequestedOrientation;
    boolean isQc = false;
    private String serverUrl;
    private String sectionId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        StrictMode.ThreadPolicy policy;
        policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        setContentView(R.layout.activity_main_editor);


        findViewById(R.id.doneButton).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onBackPressed();
            }
        });
        findViewById(R.id.closeButton).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });


        FILE_PATH = createNewPDFFile();

        if (getIntent().getExtras() != null) {
            System.out.println("--------------------------------------------------------- getExtras");
            System.out.println(getIntent().getExtras().getString("ticket"));
            SELECTED_FILE = Ticket.formJsonString(getIntent().getExtras().getString("ticket"));
            isQc = (getIntent().getExtras().getBoolean("qc"));
            serverUrl = (getIntent().getExtras().getString("serverUrl"));
            sectionId = (getIntent().getExtras().getString("sectionId"));
            System.out.println("---------------------------------------------------------");
            System.out.println(SELECTED_FILE.id);
        } else {
            SELECTED_FILE = Ticket.formJsonString("{oe: cat-001, finished: 0, uptime: 1628192673367, file: 1, sheet: 0, dir: 20218, id: 40913, isRed: 0, isRush: 1, isSk: 0, inPrint: 0, isGr: 0, isError: 0, canOpen: 1, isSort: 0, isHold: 0, fileVersion: 1628192673126, progress: 0, completed: 0, nowAt: 0, crossPro: 0}");
            serverUrl = "http://192.168.0.101:3000/api/tickets/qc/uploadEdits";
        }


        SELECTED_FILE.ticketFile = new File(FILE_PATH);
        loadEditor();
        loadFile(SELECTED_FILE.ticketFile);

    }

    private String createNewPDFFile() {
        PDDocument doc = new PDDocument();
        PDPage page = new PDPage();
        doc.addPage(page);
        PDPageContentStream contentStream;
        String path = "";
        try {
            contentStream = new PDPageContentStream(doc, page);
            contentStream.close();
            path = this.getExternalFilesDir("Files").getPath() + "/QAtemplate.pdf";
            doc.save(path);
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.println(path);
        System.out.println(new File(path).exists());
        return path;
    }

    private void loadEditor() {
        pdfEditor = new Editor();

        getSupportFragmentManager().beginTransaction().replace(R.id.editorPerant, pdfEditor).commit();
        pdfEditor.loadFile(SELECTED_FILE, true);

    }

    private void loadFile(File file) {
        FILE_NAME = file.getName();
        pdfEditor.setRunAfterNsFileLoad(new Editor.runAfterFileLoad() {
            @Override
            public void run(Editor editor) {
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR);

            }
        });


        pdfEditor.loadFile(file);
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle savedInstanceState) {
        super.onSaveInstanceState(savedInstanceState);
        savedInstanceState.putParcelable("x", new data(pdfEditor.editsList, pdfEditor.getImagesList(), pdfEditor.getPdfEditsList(), 1));
        System.out.println("_____________________________________________________onSaveInstanceState 3");
        savedInstanceState.putString("xx", "Welcome back to Android");
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        System.out.println("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR ______ " + requestCode + " __  " + resultCode);


        int rfResult = 222;
        if (requestCode == rfResult) {
            if (resultCode == Activity.RESULT_OK) {
                onBackPressed();
            }

        }


    }

    @Override
    public void onBackPressed() {


//        if (pdfEditor.getToolVisibility() == View.VISIBLE) {
        if (pdfEditor.isEdited()) {

            RequestedOrientation = getResources().getConfiguration().orientation;
            if (RequestedOrientation == Configuration.ORIENTATION_LANDSCAPE) {
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            } else {
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
            }

            pdfEditor.saveEdits();
            uploadPdfEdits(
                    new RunAfterUpload() {

                        @Override
                        public void run(File sourceFile) {
                            Intent data = new Intent();
                            data.putExtra("saved", true);
                            setResult(Activity.RESULT_OK, data);
//                            finish();

                        }

                    }, this
            );


        } else {
            finish();
        }

        try {
            pdfEditor.unClickAllButtons();
        } catch (Exception ignored) {
        }


    }


    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {

        System.out.println("**************************************************** ON CREATE ");
        if (savedInstanceState != null) {
            System.out.println("SAVED STATE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + savedInstanceState.getString("xx"));
            data data = savedInstanceState.getParcelable("x");
            pdfEditor.editsList = data.getEditsList();
            pdfEditor.setImagesList(data.getImagesList());
            pdfEditor.setPdfEditsList(data.getPdfEditsList());

            System.out.println(pdfEditor.editsList.size() + " ---------------------" + data.ssss);
//            fab.setVisibility(data.getToolVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
        }
        super.onRestoreInstanceState(savedInstanceState);
    }


    final LoadingDialog loadingDialog = new LoadingDialog("Saving. Please wait...", true);


    public void uploadPdfEdits(final RunAfterUpload runAfterUpload, Context context) {
        if (!loadingDialog.isVisible()) {
            loadingDialog.show(getSupportFragmentManager(), loadingDialog.getTag());
        }


        pdfEditor.uploadEdits(new RunAfterSave() {

            @Override
            public void run(File sourceFile) {

            }


            @Override
            public void run(JSONObject value, Ticket SELECTED_NS_FILE) {

                System.out.println("-----------------------------------------------------------------------+++++++");
                HashMap<String, String> vals = new HashMap<>();

                vals.put("file", SELECTED_FILE.id + "");
                vals.put("sectionId", sectionId);
                vals.put("ticketId", SELECTED_FILE.id + "");
                vals.put("svgs", value.toString());
                vals.put("type", isQc ? "qc" : "qa");

                System.out.println(vals);

                long sizeInBytes = value.toString().getBytes().length;

                System.out.println("____________SVG SIZE_________________" + (sizeInBytes / 1024));
                HashMap<String, ArrayList<File>> images = pdfEditor.getImages();
//                String requestURL = serverUrl.concat("/api/tickets/qc/uploadEdits");
                String requestURL = serverUrl;
                uploadMultyParts(context, requestURL, images, vals, new RunAfterMultipartUpload() {
                    @Override
                    public void run() {

                        loadingDialog.dismiss();
                        pdfEditor.resetEdits();
                        runAfterUpload.run(null);
                    }

                    @Override
                    public void onError(Exception exception) {
                        exception.printStackTrace();
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                loadingDialog.showRetry(exception.getLocalizedMessage(), new LoadingDialog.OnReteyClickCallBack() {
                                    @Override
                                    public void onClick() {
                                        uploadPdfEdits(runAfterUpload, context);
                                    }
                                });
                            }
                        });
                    }
                });
            }

            @Override
            public void error(Exception exception) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        loadingDialog.showRetry(exception.getLocalizedMessage(), new LoadingDialog.OnReteyClickCallBack() {
                            @Override
                            public void onClick() {
                                uploadPdfEdits(runAfterUpload, context);
                            }
                        });
                    }
                });
            }


        });
    }


    public static void uploadMultyParts(Context context, String requestURL, final HashMap<String, ArrayList<File>> sourceFiles, final HashMap<String, String> keyvalues, RunAfterMultipartUpload runAfterUpload) {

        FirebaseAuth mAuth = FirebaseAuth.getInstance();
        FirebaseUser user = mAuth.getCurrentUser();
        user.getIdToken(true).addOnSuccessListener(new OnSuccessListener<GetTokenResult>() {
            @Override
            public void onSuccess(@NonNull GetTokenResult getTokenResult) {
                System.out.println("getTokenResult.getToken()");
                System.out.println(getTokenResult.getToken());

                try {

                    String charset = "UTF-8";


                    MultipartUtility multipart = new MultipartUtility(requestURL, charset, context, getTokenResult.getToken());

                    int xx = 0;
                    for (String key : sourceFiles.keySet()) {
                        for (File f : sourceFiles.get(key)) {
                            multipart.addFilePart("image" + xx++, f);
                        }
                    }

                    for (String key : keyvalues.keySet()) {
                        multipart.addFormField(key, keyvalues.get(key));
                    }

                    List<String> response = multipart.finish();

                    Log.v("rht", "SERVER REPLIED:");

                    for (String line : response) {
//                Log.v("rht", "Line : " + line);
                        System.out.println("____" + line);
                    }


                    runAfterUpload.run();

                } catch (Exception e) {
                    runAfterUpload.onError(e);
                }
            }

        });


    }


}
