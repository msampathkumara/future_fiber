package com.pdfEditor;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.StrictMode;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.Dialogs.LoadingDialog;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.pdfEditor.EditorTools.data;
import com.sampathkumara.northsails.smartwind.R;

import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;


public class MainEditorActivity extends AppCompatActivity {

    public static String FILE_NAME;
    static String FILE_PATH;
    public Editor pdfEditor;
    public static Ticket SELECTED_FILE;
    int RequestedOrientation;
    public static Ticket ticket;
    private String serverUrl;
    private String userCurrentSection;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        setContentView(R.layout.activity_main_editor);

        findViewById(R.id.doneButton).setOnClickListener(view -> onBackPressed());
        findViewById(R.id.closeButton).setOnClickListener(view -> finish());
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(getBaseContext());
        SharedPreferences.Editor editor = preferences.edit();

        if (getIntent().getExtras() != null) {

            extras = getIntent().getExtras();

            editor.putString("ticket", extras.getString("ticket"));
            editor.putString("path", extras.getString("path"));
            editor.putInt("ticketId", extras.getInt("ticketId"));
            editor.putString("ticket", extras.getString("ticket"));
            editor.putString("serverUrl", extras.getString("serverUrl"));
            editor.putString("userCurrentSection", extras.getString("userCurrentSection"));


            SELECTED_FILE = Ticket.formJsonString(extras.getString("ticket"));
            FILE_PATH = extras.getString("path");
            SELECTED_FILE.id = extras.getInt("ticketId");
            ticket = Ticket.formJsonString(extras.getString("ticket"));
            serverUrl = (extras.getString("serverUrl"));
            userCurrentSection = (extras.getString("userCurrentSection"));

            System.out.println("--------------------------------------------------------------------------------------------------------");
            System.out.println(extras.getString("ticket"));
            System.out.println((extras.getString("path")));
            System.out.println(extras.getInt("ticketId"));
            System.out.println(extras.getString("serverUrl"));
            editor.apply();

        } else {


            SELECTED_FILE = Ticket.formJsonString("{mo: MO-00478052, oe: OUS150144-001Fs, uptime: 1667585663345, file: 1, sheet: 1, dir: 202210, id: 2135, isRed: 0, isRush: 1, isSk: 0, inPrint: 0, isGr: 0, isError: 0, canOpen: 0, isSort: 0, isHold: 0, fileVersion: 1667585662133, progress: 11, completed: 0, nowAt: 4, shipDate: 2022-12-31, deliveryDate: 2022-10-04, isQc: 0, isQa: 1, isStarted: 1, haveComments: 0, openAny: 0, kit: 0, cpr: 0, haveKit: 1, haveCpr: 0, cprReport: []}");
            FILE_PATH = "/storage/emulated/0/Android/data/com.sampathkumara.northsails.smartwind.debug/files/2135.pdf";
            assert SELECTED_FILE != null;
            SELECTED_FILE.id = 2135;
            ticket = SELECTED_FILE;
            serverUrl = "http://192.168.0.100:3000/api/tickets/uploadEdits";
            userCurrentSection = preferences.getString("userCurrentSection", "");

            System.out.println("load from SharedPreferences ");
            System.out.println(preferences.getString("ticket", "{}"));


        }
        SELECTED_FILE.ticketFile = new File(FILE_PATH);


        loadEditor();
        loadFile(SELECTED_FILE.ticketFile);

    }


    public static Bundle extras;

    private void loadEditor() {
        pdfEditor = new Editor();

        getSupportFragmentManager().beginTransaction().replace(R.id.editorPerant, pdfEditor).commit();
        pdfEditor.loadFile(SELECTED_FILE);

    }

    private void loadFile(File file) {
        FILE_NAME = file.getName();
        pdfEditor.setRunAfterNsFileLoad(editor -> setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT));


        pdfEditor.loadFile(file);
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle savedInstanceState) {
        super.onSaveInstanceState(savedInstanceState);
        savedInstanceState.putParcelable("x", new data(pdfEditor.editsList, pdfEditor.getImagesList(), pdfEditor.getPdfEditsList()));
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

        int rfResult = 222;
        if (requestCode == rfResult) {
            if (resultCode == Activity.RESULT_OK) {
                onBackPressed();
            }

        }


    }

    @Override
    public void onBackPressed() {

        pdfEditor.saveEdits();
        if (pdfEditor.isEdited()) {

            RequestedOrientation = getResources().getConfiguration().orientation;
            if (RequestedOrientation == Configuration.ORIENTATION_LANDSCAPE) {
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            } else {
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
            }

//            pdfEditor.saveEdits();
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

                vals.put("type", "edits");

                vals.put("file", SELECTED_NS_FILE.id + "");
                vals.put("ticketId", SELECTED_NS_FILE.id + "");
                vals.put("svgs", value.toString());
                vals.put("userCurrentSection", userCurrentSection);

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
                        runOnUiThread(() -> loadingDialog.showRetry(exception.getLocalizedMessage(), () -> uploadPdfEdits(runAfterUpload, context)));
                    }
                });
            }

            @Override
            public void error(Exception exception) {
                runOnUiThread(() -> loadingDialog.showRetry(exception.getLocalizedMessage(), () -> uploadPdfEdits(runAfterUpload, context)));
            }


        });
    }


    public static void uploadMultyParts(Context context, String requestURL, final HashMap<String, ArrayList<File>> sourceFiles, final HashMap<String, String> keyvalues, RunAfterMultipartUpload runAfterUpload) {

        FirebaseAuth mAuth = FirebaseAuth.getInstance();
        FirebaseUser user = mAuth.getCurrentUser();
        assert user != null;
        user.getIdToken(true).addOnSuccessListener(getTokenResult -> {
            System.out.println("getTokenResult.getToken()");
            System.out.println(getTokenResult.getToken());

            try {

                String charset = "UTF-8";


                MultipartUtility multipart = new MultipartUtility(requestURL, charset, context, getTokenResult.getToken());

                int xx = 0;
                for (String key : sourceFiles.keySet()) {
                    for (File f : Objects.requireNonNull(sourceFiles.get(key))) {
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
        });


    }


}
