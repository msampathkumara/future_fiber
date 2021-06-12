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

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.BitmapCompat;

import com.Dialogs.LoadingDialog;
import com.NsFile.NsFile;
import com.Server;
import com.pdfEditor.EditorTools.data;
import com.pdfviewer.util.SizeF;
import com.sampathkumara.northsails.smartwind.R;
import com.tom_roush.pdfbox.pdmodel.PDDocument;
import com.tom_roush.pdfbox.pdmodel.PDPage;
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream;
import com.tom_roush.pdfbox.pdmodel.graphics.image.PDImageXObject;

import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
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
    private final int rfResult = 222;
    public Editor pdfEditor;
    NsFile SELECTED_FILE;
    //    FloatingActionButton fab;
    int RequestedOrientation;
    private NsFile CURRENT_FOLDER;
    private boolean QA;
    private boolean FIELD_FORMS;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        setContentView(R.layout.activity_main_editor);


        SELECTED_FILE = new NsFile();
//        SELECTED_FILE.file = new File(getIntent().getExtras().getString("path"));
        FILE_PATH = getExternalFilesDir(null) + "/35874.pdf";
        System.out.println("------------------------------------------------------------------------");
        System.out.println(FILE_PATH);
        SELECTED_FILE.file = new File(FILE_PATH);
        SELECTED_FILE.name = "MO-0000";
        SELECTED_FILE.id = 1230;
        System.out.println("------------------------------------------------------------------------" + SELECTED_FILE.file.exists());


        View fab = findViewById(R.id.fab);
//
        fab.setOnClickListener(view -> {

            fab.setVisibility(View.GONE);
            loadFile(SELECTED_FILE.file);
        });


//        FILE_PATH = Environment.getExternalStorageDirectory().getAbsolutePath() + "/pdfEditor/";
//        SELECTED_FILE = (NsFile) getIntent().getExtras().get(FileBrowser.FILE);
//        System.out.println("FILE ID ==== " + SELECTED_FILE.fileId);
//
//
        loadEditor();
//        pdfEditor.showTools();
//        fab.setVisibility(View.GONE);
        loadFile(SELECTED_FILE.file);
//
//        FILE_NAME = SELECTED_FILE.getName();
//
//
//        getSupportActionBar().setTitle(FilenameUtils.removeExtension(SELECTED_FILE.getName()));
//        pdfEditor.showTools();

    }

//    public static <T> T copyObject(Object object) {
//        Gson gson = new Gson();
//        JsonObject jsonObject = gson.toJsonTree(object).getAsJsonObject();
//        return gson.fromJson(jsonObject, (Type) object.getClass());
//    }

//    public void loadFile(@NonNull NsFile mItem) {
//        SELECTED_FILE = mItem;
//        loadFile(mItem.getFile(MainEditorActivity.this));
//
//    }

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
    public void onSaveInstanceState(Bundle savedInstanceState) {
        super.onSaveInstanceState(savedInstanceState);
        savedInstanceState.putParcelable("x", new data(pdfEditor.editsList, pdfEditor.getImagesList(), pdfEditor.getPdfEditsList(), pdfEditor.getToolVisibility()));
        System.out.println("_____________________________________________________onSaveInstanceState");
        savedInstanceState.putString("xx", "Welcome back to Android");
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        System.out.println("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR ______ " + requestCode + " __  " + resultCode);

        int SAVE_FOLDER_SELECTED = 1;
        if (requestCode == rfResult) {
            if (resultCode == Activity.RESULT_OK) {
                onBackPressed();
            }
            if (resultCode == Activity.RESULT_CANCELED) {
                //Write your code if there's no result
            }
        }

//        else if (requestCode == SAVE_FOLDER_SELECTED) {
//            if (RESULT_OK == resultCode) {
//                System.out.println("+++++++++++++++++++++++++ SAVING ++++++++++++++++++++++++");
//                savePDF(data.getExtras().getString(FileBrowser.FOLDER), data.getExtras().getString(FileBrowser.FILE_NAME), false, new FileManager.RunAfterUpload() {
//                    @Override
//                    public void run(File file) {
//                    }
//
//                    @Override
//                    public void error(Exception exception) {
//
//                    }
//                });
//            }
//        } else if (requestCode == FileBrowser.OPEN) {
//            if (RESULT_OK == resultCode) {
//                CURRENT_FOLDER = (NsFile) data.getExtras().get(FileBrowser.FOLDER);
//                String filePath = data.getStringExtra(FileBrowser.FILE_PATH);
//                System.out.println(filePath);
//                System.out.println("CURRENT_FOLDER " + CURRENT_FOLDER);
////                File file = new File(filePath);
//                System.out.println("FILE HAVE ");
////                loadFile(file);
//                loadFile((NsFile) data.getExtras().get(FileBrowser.FILE));
//            }
//        } else if (requestCode == POOL_TICKET) {
//            if (RESULT_OK == resultCode) {
//                System.out.println("CURRENT_FOLDER " + CURRENT_FOLDER);
//                System.out.println("FILE HAVE ");
//                Intent i = new Intent(this, MainEditorActivity.class);
//                i.putExtra(FileBrowser.FILE, (NsFile) data.getExtras().get(FileBrowser.FILE));
//                i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//                startActivityForResult(i, 0);
//            }
//        }


    }

    @Override
    public void onBackPressed() {


//        if (pdfEditor.getToolVisibility() == View.VISIBLE) {
        if (pdfEditor.isEdited()) {

            RequestedOrientation = getResources().getConfiguration().orientation;
            if (RequestedOrientation == Configuration.ORIENTATION_LANDSCAPE) {
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            } else {
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            }

            pdfEditor.saveEdits();
            uploadPdfEdits(
                    new RunAfterUpload() {

                        @Override
                        public void run(File sourceFile) {
                            finish();
//                    new DownloadNsFile(SELECTED_FILE, MainEditorActivity.this, new DownloadNsFile.OnDownload() {
//
//
//                        @Override
//                        public void run(NsFile nsFile) {
//                            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR);
//                            System.out.println(RequestedOrientation + "**************************" + getResources().getConfiguration().orientation);
//                            if (RequestedOrientation == getResources().getConfiguration().orientation) {
//                                loadFile(nsFile);
//                            }
//
//                            pdfEditor.hideTools();
//                            pdfEditor.hideExtraTools();
//                            fab.setVisibility(View.VISIBLE);
//                        }
//
//                        @Override
//                        public void onProgressChange(int percentage, int bytes_total, int bytes_downloaded) {
//
//                        }
//                    }).execute();
                        }

                        @Override
                        public void error(Exception exception) {

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

    public void savePDF(String Folder, String filename, Boolean temp, RunAfterUpload runAfterUpload) {

        System.out.println("FOLDER ===================== " + Folder);

        new x(Folder, filename, runAfterUpload).execute(temp);
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
            pdfEditor.setToolVisibility(data.getToolVisibility());
            System.out.println(pdfEditor.editsList.size() + " ---------------------" + data.ssss);
//            fab.setVisibility(data.getToolVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
        }
        super.onRestoreInstanceState(savedInstanceState);
    }

//    @Override
//    public boolean onCreateOptionsMenu(Menu menu) {
//        if (!getIntent().getExtras().getBoolean(HIDE_TOP_BAR_MENU, false)) {
//            getMenuInflater().inflate(R.menu.pdf_editor_menu, menu);
//        }
//
//
//        return true;
//    }

//    @Override
//    public boolean onOptionsItemSelected(MenuItem item) {
//        // Handle item selection
//        Intent i;
//        switch (item.getItemId()) {
//            case R.id.mb_finish_job:
//                finishJob();
//                return true;
//            case R.id.mb_bluebook:
//                i = new Intent(MainEditorActivity.this, BlueBookWithTicket.class);
//                i.putExtra("url", "http://bluebook.northsails.com:8088/nsbb/app/blueBook.html");
//                i.putExtra(FileBrowser.FILE, SELECTED_FILE);
//                startActivity(i);
//                break;
//            case R.id.mb_other_apps:
//                Intent intent = new Intent(MainEditorActivity.this, OtherApps.class);
//                startActivity(intent);
//                break;
//            case R.id.mb_email:
//                startNewActivity("com.google.android.gm");
//                break;
//            case R.id.mb_pick_list:
//                i = new Intent(MainEditorActivity.this, ShortPickList.class);
//                i.putExtra(FileBrowser.FILE, SELECTED_FILE);
//                startActivity(i);
//                break;
//            case R.id.mb_report:
//                Intent x = new Intent(MainEditorActivity.this, webBrowser.class);
//                x.putExtra("url", Strings.getServerAddress() + "/FileBrowser/Report/index.php?file=" + SELECTED_FILE.getFileId() + "&mob=1");
//                startActivity(x);
//                break;
//            default:
//                return super.onOptionsItemSelected(item);
//        }
//        return true;
//    }

//    @Override
//    protected void onResume() {
//        System.out.println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ on resume main activity");
//        super.onResume();
//    }

    private void finishJob() {
        System.out.println("____________________________________ SAVING ___________________________");
        System.out.println("folder = " + SELECTED_FILE.getParent());
        if (pdfEditor.getToolVisibility() == View.VISIBLE) {
            if (pdfEditor.isEdited()) {
                pdfEditor.saveEdits();
                uploadPdfEdits(new RunAfterUpload() {
                    @Override
                    public void run(File sourceFile) {
//                        Intent i = new Intent(MainEditorActivity.this, qaCheckList.class);
//                        i.putExtra(FileBrowser.FILE, SELECTED_FILE);
//                        startActivityForResult(i, rfResult);
//                        finish();
                    }

                    @Override
                    public void error(Exception exception) {

                    }
                }, this);


            } else {
//                Intent i = new Intent(MainEditorActivity.this, qaCheckList.class);
//                i.putExtra(FileBrowser.FILE, SELECTED_FILE);
//                startActivityForResult(i, rfResult);
//                finish();
            }


        } else {
//            Intent i = new Intent(MainEditorActivity.this, qaCheckList.class);
//            i.putExtra(FileBrowser.FILE, SELECTED_FILE);
//            startActivityForResult(i, rfResult);
//            finish();
        }
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

    LoadingDialog loadingDialog = new LoadingDialog("Saving. Please wait...", true);


    static final int BUFFER = 2048;


    public void uploadPdfEdits(final RunAfterUpload runAfterUpload, Context context) {
        if (!loadingDialog.isVisible()) {
            loadingDialog.show(getSupportFragmentManager(), loadingDialog.getTag());
        }


//        final ProgressDialog dialog = new ProgressDialog(MainEditorActivity.this);
//        dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
//        dialog.setMessage("Saving. Please wait...");
//        dialog.setIndeterminate(true);
//        dialog.setCanceledOnTouchOutside(false);
//        dialog.show();

        pdfEditor.uploadEdits(new RunAfterSave() {

            @Override
            public void run(File sourceFile) {

            }


            @Override
            public void run(JSONObject value, NsFile SELECTED_NS_FILE) {
                System.out.println("-----------------------------------------------------------------------+++++++");
//                Zip zipFile = new Zip(getExternalFilesDir(null) + "/" + SELECTED_FILE.id + "/" + SELECTED_FILE.id + ".zip");
//                File svgFile = getSVGFile(value.toString());
//
//                zipFile.addFile(svgFile);
//
////                File dir = new File( getExternalFilesDir(null) + "/" + SELECTED_NS_FILE.id+"/images");
//
//                HashMap<String, ArrayList<File>> i = pdfEditor.getImages();
//
//                ArrayList<File> images = i.get("images[]");
//
//                for (File file : images) {
//                    System.out.println(file.getPath());
//                    System.out.println(file.exists());
//                    zipFile.addFile(file, "images");
//                }
////                zipFile.addFile(dir);
//                zipFile.closeZip();
//
                HashMap<String, String> vals = new HashMap();

                vals.put("type", "edits");

                vals.put("file", SELECTED_NS_FILE.getFileId() + "");
                vals.put("ticketId", SELECTED_NS_FILE.id + "");
                vals.put("svgs", value.toString());

                long sizeInBytes = value.toString().getBytes().length;

                System.out.println("____________SVG SIZE_________________" + (sizeInBytes / 1024));
                HashMap<String, ArrayList<File>> images = pdfEditor.getImages();

                String requestURL = Server.getServerApiPath("tickets/uploadEdits");
                uploadMultyParts(context, requestURL, images, vals, new RunAfterMultipartUpload() {
                    @Override
                    public void run() {

//                        dialog.dismiss();
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

    private File getSVGFile(String data) {
        File dir = new File(getExternalFilesDir(null) + "/" + SELECTED_FILE.id);
        dir.mkdirs();
        File file = new File(dir, "svg.svgdata");
        try {
            try (FileOutputStream stream = new FileOutputStream(file)) {
                stream.write(data.getBytes());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return file;
    }

    public static void uploadMultyParts(Context context, String requestURL, final HashMap<String, ArrayList<File>> sourceFiles, final HashMap<String, String> keyvalues, RunAfterMultipartUpload runAfterUpload) {
        try {

            String charset = "UTF-8";


            MultipartUtility multipart = new MultipartUtility(requestURL, charset, context);

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


    class x extends AsyncTask<Boolean, Boolean, Void> {
        final String folder;
        ProgressDialog savingDialog;
        boolean ERR = false;
        String fileName;
        boolean EDITED = false;
        RunAfterUpload runAfterUpload;

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
                                    } catch (FileNotFoundException e) {
                                        e.printStackTrace();
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
