package com.pdfEditor;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.os.StrictMode;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.BitmapCompat;

import com.Dialogs.LoadingDialog;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.pdfEditor.EditorTools.data;
import com.pdfviewer.util.SizeF;
import com.sampathkumara.northsails.smartwind.R;
import com.tom_roush.pdfbox.pdmodel.PDDocument;
import com.tom_roush.pdfbox.pdmodel.PDPage;
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream;
import com.tom_roush.pdfbox.pdmodel.graphics.image.PDImageXObject;

import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;


public class MainEditorActivity extends AppCompatActivity {

    public static String FILE_NAME;
    static String FILE_PATH;
    public Editor pdfEditor;
    public static Ticket SELECTED_FILE;
    int RequestedOrientation;
    public static Ticket ticket;
    private String serverUrl;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
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

        if (getIntent().getExtras() != null) {
            SELECTED_FILE = Ticket.formJsonString(getIntent().getExtras().getString("ticket"));
            FILE_PATH = getIntent().getExtras().getString("path");
            SELECTED_FILE.id = getIntent().getExtras().getInt("ticketId");
            ticket = Ticket.formJsonString(getIntent().getExtras().getString("ticket"));
            serverUrl = (getIntent().getExtras().getString("serverUrl"));

            System.out.println("--------------------------------------------------------------------------------------------------------");
            System.out.println(getIntent().getExtras().getString("ticket"));
            System.out.println((getIntent().getExtras().getString("path")));
            System.out.println(getIntent().getExtras().getInt("ticketId"));
            System.out.println(getIntent().getExtras().getString("serverUrl"));

        } else {

            String t = "{mo: MO-00332444, oe: OAU112630-001Fs, finished: 0, uptime: 1646755954799, file: 1, sheet: 1, dir: 202110, id: 39923, isRed: 0, isRush: 1, isSk: 0, inPrint: 0, isGr: 1, isError: 0, canOpen: 0, isSort: 0, isHold: 0, fileVersion: 1646755954551, progress: 0, completed: 0, nowAt: 17, crossPro: 1, deliveryDate: 2021-02-17, production: OD}";
            SELECTED_FILE = Ticket.formJsonString(t);
            FILE_PATH = "/storage/emulated/0/Android/data/com.sampathkumara.northsails.smartwind/files/39923.pdf";
            SELECTED_FILE.id = 39923;
            ticket = Ticket.formJsonString(t);
            serverUrl = "https://smartwind.nsslsupportservices.com/api/tickets/uploadEdits";
            serverUrl = "https://192.168.0.100:3000/api";
        }
        SELECTED_FILE.ticketFile = new File(FILE_PATH);


        loadEditor();
        loadFile(SELECTED_FILE.ticketFile);

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
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

            }
        });


        pdfEditor.loadFile(file);
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle savedInstanceState) {
        super.onSaveInstanceState(savedInstanceState);
        savedInstanceState.putParcelable("x", new data(pdfEditor.editsList, pdfEditor.getImagesList(), pdfEditor.getPdfEditsList(), 1));
        System.out.println("_____________________________________________________onSaveInstanceState 2");
        savedInstanceState.putString("xx", "Welcome back to Android");

    }

    @Override
    public void onConfigurationChanged(@NotNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        Toast.makeText(this, "onConfigurationChanged", Toast.LENGTH_SHORT).show();
        // Checks the orientation of the screen
        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            Toast.makeText(this, "landscape", Toast.LENGTH_SHORT).show();
        } else if (newConfig.orientation == Configuration.ORIENTATION_PORTRAIT) {
            Toast.makeText(this, "portrait", Toast.LENGTH_SHORT).show();
        }


    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        System.out.println("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR ______ " + requestCode + " __  " + resultCode);

        int SAVE_FOLDER_SELECTED = 1;
        int rfResult = 222;
        if (requestCode == rfResult) {
            if (resultCode == Activity.RESULT_OK) {
                onBackPressed();
            }
            if (resultCode == Activity.RESULT_CANCELED) {
                //Write your code if there's no result
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
                            data.putExtra("edited", true);
                            setResult(Activity.RESULT_OK, data);
                            finish();

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



    private void showDialog() {
        System.out.println("show Dialog");
        AlertDialog.Builder builder = new AlertDialog.Builder(this);

        builder.setTitle("Error");

        builder.setMessage("Access is denied")
                .setCancelable(false)
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    public void onClick(@NonNull DialogInterface dialog, int id) {
                        dialog.cancel();
                    }
                });

        AlertDialog alertDialog = builder.create();
        alertDialog.show();
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


    private void startNewActivity(@NonNull String packageName) {
        Intent intent = getPackageManager().getLaunchIntentForPackage(packageName);
        if (intent == null) {
            // Bring user to the market or let them choose an app?
            intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse("market://details?id=" + packageName));
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    final LoadingDialog loadingDialog = new LoadingDialog("Saving. Please wait...", true);


    static final int BUFFER = 2048;


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

                vals.put("type", "edits");

                vals.put("file", SELECTED_NS_FILE.id + "");
                vals.put("ticketId", SELECTED_NS_FILE.id + "");
                vals.put("svgs", value.toString());

                long sizeInBytes = value.toString().getBytes().length;

                System.out.println("____________SVG SIZE_________________" + (sizeInBytes / 1024));
                HashMap<String, ArrayList<File>> images = pdfEditor.getImages();
//                String requestURL = Server.getServerApiPath("tickets/uploadEdits");
                String requestURL = serverUrl;
                System.out.println("********************************************serverUrl");
                System.out.println(serverUrl);

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


    class x extends AsyncTask<Boolean, Boolean, Void> {
        final String folder;
        ProgressDialog savingDialog;
        final boolean ERR = false;
        String fileName;
        boolean EDITED = false;
        final RunAfterUpload runAfterUpload;

        x(String folder, String fileName, RunAfterUpload runAfterUpload) {
            this.folder = folder;
            this.fileName = fileName;
            this.runAfterUpload = runAfterUpload;
        }

        @Nullable
        @Override
        protected Void doInBackground(Boolean... b) {
            System.out.println("started");

            savePDF(b[0]);

            return null;
        }

        @Override
        protected void onPreExecute() {

//            runOnUiThread(new Runnable() {
//                @Override
//                public void run() {
            savingDialog = new ProgressDialog(MainEditorActivity.this);
            savingDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
            savingDialog.setMessage("Saving.. Please wait...");
            savingDialog.setIndeterminate(true);
            savingDialog.setCanceledOnTouchOutside(false);
            savingDialog.show();
//                }
//            });
            super.onPreExecute();
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
            System.out.println("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
            savingDialog.dismiss();

            if (ERR) {
                showDialog();
            }
        }

        private void savePDF(boolean temp) {
            final long x = System.currentTimeMillis();

            try {
                final File FILE = pdfEditor.getFile();
                File outFile;
                if (!fileName.toLowerCase().endsWith(".pdf")) {
                    fileName += ".pdf";
                }
                new File(getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS) + "/Edits").mkdirs();
                outFile = new File(getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS) + "/Edits", fileName);

                System.out.println("FILE NAME = " + outFile);
                System.out.println("FILE NAME = " + folder + fileName);
                PDDocument doc = null;
                try {
                    doc = PDDocument.load(FILE);

                } catch (IOException e) {
                    e.printStackTrace();
                }


                ExecutorService es = Executors.newCachedThreadPool();
                for (int i = 0; i < pdfEditor.pdfView.getPageCount(); ++i) {

                    final PDDocument finalDoc = doc;
                    final int finalI = i;
                    final int finalI1 = i;
                    es.execute(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                File imageFile = new File(Environment.getExternalStorageDirectory()
                                        .getAbsolutePath() + "/" + FILE.getName(), finalI1 + ".png");
                                PAGE page = pdfEditor.getPages().get(finalI);
                                if (page.hasBitmap()) {
                                    EDITED = true;
                                    System.out.println("Page " + finalI + " saving...\n page position = " + page.position);
                                    SizeF pageSize = pdfEditor.pdfView.getPageSize(finalI);

                                    PDPage p = finalDoc.getPage(finalI);
                                    System.out.println("PAGE ROTATION = " + p.getRotation());
                                    try {
                                        page.getBitmap().compress(Bitmap.CompressFormat.PNG, 100, new FileOutputStream(imageFile));
                                        System.out.println("image saved " + (System.currentTimeMillis() - x));
                                        PDImageXObject pdImage = PDImageXObject.createFromFile(imageFile, finalDoc);
                                        System.out.println("image PDImageXObject " + (System.currentTimeMillis() - x));
                                        PDPageContentStream contentStream = new PDPageContentStream(finalDoc, p, true, true, true);
                                        contentStream.drawImage(pdImage, 0, 0, p.getMediaBox().getWidth(), p.getMediaBox().getHeight());
                                        System.out.println("drowing  " + (System.currentTimeMillis() - x));
                                        contentStream.close();
                                        System.out.println("close " + (System.currentTimeMillis() - x));
                                    } catch (IOException e) {
                                        e.printStackTrace();
                                    }
                                    System.out.println("Image size = " + BitmapCompat.getAllocationByteCount(page.getBitmap()) / 8);
                                    System.out.println("Page " + finalI + " savied...");
                                    page.setBitmap(null);
                                } else {
                                    System.out.println("Skiped page " + finalI);
                                }
                                System.out.println("FILE PATH === " + imageFile.getAbsolutePath());
//                                imageFile.delete();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            System.out.println("TASK " + finalI + " Added");
                        }
                    });

                }
                System.out.println("_________________________________________shutdoun");
                es.shutdown();
                boolean finshed = es.awaitTermination(1, TimeUnit.MINUTES);
                if (EDITED) {
                    doc.save(outFile);
                    long y = System.currentTimeMillis();
                    System.out.println("saved to local............." + (y - x));
                    doc.close();
//                    in.close();
                    if (outFile.exists()) {
//                        FileManager.uploadFile(outFile, folder, temp, runAfterUpload);
                    }
//                    outFile.delete();

                    System.out.println("saved to server............." + (System.currentTimeMillis() - y));
                    System.out.println("total time............." + (System.currentTimeMillis() - x));
//                    dialog.dismiss();
                }

            } catch (InterruptedException | IOException e) {
                e.printStackTrace();
            }
        }


    }
}
