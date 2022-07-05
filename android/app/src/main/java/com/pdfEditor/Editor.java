package com.pdfEditor;

import static android.app.Activity.RESULT_OK;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.ContentResolver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.RectF;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.StrictMode;
import android.provider.MediaStore;
import android.util.DisplayMetrics;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.view.menu.MenuBuilder;
import androidx.appcompat.widget.PopupMenu;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;

import com.E;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.pdfEditor.EditorTools.data;
import com.pdfEditor.EditorTools.freehand.p_drawing_view;
import com.pdfEditor.EditorTools.freehand.xPath;
import com.pdfEditor.EditorTools.highlight.p_hightlight_view;
import com.pdfEditor.EditorTools.image.image_container;
import com.pdfEditor.EditorTools.image.p_image_view;
import com.pdfEditor.EditorTools.image.xImage;
import com.pdfEditor.EditorTools.textEditor.p_Text_Editor_view;
import com.pdfEditor.EditorTools.textEditor.xText;
import com.pdfEditor.uploadEdits.EditsList;
import com.pdfEditor.uploadEdits.WebViewInterface;
import com.pdfviewer.PDFView;
import com.pdfviewer.listener.OnDrawListener;
import com.pdfviewer.listener.OnErrorListener;
import com.pdfviewer.listener.OnLoadCompleteListener;
import com.pdfviewer.listener.OnLongPressListener;
import com.pdfviewer.listener.OnPageChangeListener;
import com.pdfviewer.util.FitPolicy;
import com.pdfviewer.util.SizeF;
import com.sampathkumara.northsails.smartwind.R;
import com.sampathkumara.northsails.smartwind.R.id;
import com.tom_roush.pdfbox.multipdf.PDFMergerUtility;
import com.tom_roush.pdfbox.pdmodel.PDDocument;
import com.tom_roush.pdfbox.pdmodel.PDPage;

import org.json.JSONObject;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;


public class Editor extends E implements OnDrawListener, OnPageChangeListener {

    public interface RunAfterDone {
        void run();
    }

    private static final int RESULT_LOAD_IMAGE = 12345;
    private static final int RESULT_CAMERA_LOAD_IMAGE = 123;
    static int x = 0;
    public ArrayList<xEdits> editsList = new ArrayList<>();
    public PDFView pdfView;
    @Nullable

    public File CurrentFile;
    private Intent pictureIntent;
    private boolean FragmentLoaded = false;
    private runAfterLoad runAfterLoad;
    private runAfterLoad runAfterFileLoad;
    OnViewCreatedListner onViewCreatedListner;
    boolean XS = true;
//    ImageButton button_new_page;

    runAfterFileLoad runAfterNsFileLoad;
    private HashMap<Long, File> images = new HashMap<>();
    private WebView webView;
    @Nullable
    private OnFragmentInteractionListener mListener;
    public static List<PAGE> pages;
    private p_image_view imageView;
    private String imageFilePath;
    //    private final boolean button_arrow_clicked = false;
    private File file;
    @Nullable
    private p_drawing_view drawingView;
    @Nullable
    private p_Text_Editor_view textEditorView;
    @Nullable
    private p_hightlight_view highlighterView;
    @Nullable
    private p_eraser_view erasingView;

    private boolean is_text_editor_clicked;
    private boolean image_editor;
    private ProgressDialog dialog;
    private FrameLayout pdfViewPerant;

    private LinearLayout toolset;
    private LinearLayout extraTools;
    private boolean RELOAD;
    private OnPrint onPrint;
    private Ticket SELECTED_Ticket;
    private EditsList pdfEditsList;
    private RunAfterSave runAfterSave;
    private BottomNavigationView bottomNavigationView;

    public Editor() {
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        // Required empty public constructor

        getActivity();

    }


    public PDFView getPdfView() {
        return pdfView;
    }


    public boolean isEdited() {

        return editsList.size() > 0;

    }

    public void setBitmap(Bitmap bitmap) {
        PAGE page = getPages().get(0);
        page.setBitmap(bitmap);
        onPageChanged(0, 0);

    }

    public List<PAGE> getPages() {
        if (pages == null) {
            pages = new ArrayList<>();
        }
        return pages;
    }

    public static PAGE currentPage;

    @Override
    public void onPageChanged(final int page, int pageCount) {
        System.out.println("PAGE CHANGED");
        System.out.println(pdfView.getCurrentYOffset());
        System.out.println(pdfView.pdfFile.getMaxPageHeight());

        currentPage = pages.get(page);


        assert drawingView != null;
        drawingView.setPage(pages.get(page));
        assert textEditorView != null;
        textEditorView.setPage(pages.get(page));
        assert highlighterView != null;
        highlighterView.setPage(pages.get(page));
        assert erasingView != null;
        erasingView.setPage(pages.get(page));
        imageView.setPage(pages.get(page));

        reDraw(page);

    }

    public void reDraw(int page) {
        PAGE page1 = pages.get(page);
        page1.getBitmap().eraseColor(Color.TRANSPARENT);


        for (xEdits kk : editsList) {

            if (kk.page == pdfView.getCurrentPage()) {

                if (kk instanceof xPath) {
                    assert drawingView != null;
                    drawingView.drawingView.reDraw((xPath) kk);
                } else if (kk instanceof xImage) {
                    imageView.reDraw((xImage) kk);
                } else if (kk instanceof xText) {
                    assert textEditorView != null;
                    textEditorView.textEditor.reDraw((xText) kk);
                }


            }

        }


    }


    public void loadFile(@NonNull final File file) {
        System.out.println("LOAD FILE 1");

        pages = new ArrayList<>();

        CurrentFile = file;
        setFile(file);
        System.out.println("FFFFFFFFF = " + file.getName());
        if (pdfView != null) {
            PDFView.Configurator configurator = pdfView.fromFile(file);
            System.out.println("_______ 1 ________");
            _set_pdfview_options(configurator).load();
        } else {
            runAfterFileLoad = new runAfterLoad() {
                @Override
                public void run(Editor editor) {
                    PDFView.Configurator configurator = pdfView.fromFile(file);
                    System.out.println("RUN AFTER LOAD 1");
                    _set_pdfview_options(configurator).load();
//                    pdfView.findViewById(R.id.mb_freehand).performClick();
                }
            };
        }

    }

    private PDFView.Configurator _set_pdfview_options(PDFView.Configurator pv) {


        System.out.println("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++_set_pdfview_options");
        DisplayMetrics displayMetrics = new DisplayMetrics();
        getActivity().getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);


        if (!RELOAD) {
//            editsList = new ArrayList();

            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        dialog = new ProgressDialog(getActivity());
                        dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
                        dialog.setMessage("Loading. Please wait...");
                        System.out.println("Loading. Please wait...");
                        dialog.setIndeterminate(true);
                        dialog.setCanceledOnTouchOutside(false);
                        getActivity().isFinishing();//                            dialog.show();

                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });

        } else {
            unClickAllButtons();
        }


        pv.onError(new OnErrorListener() {
            @Override
            public void onError(@NonNull Throwable t) {
                System.out.println("ERR");
                t.printStackTrace();
                AlertDialog.Builder builder = new AlertDialog.Builder(Editor.this.requireContext());

                builder.setTitle("Error");

                String message = t.getMessage() + "\n\n" + "Try to reopen file";

                if (t instanceof FileNotFoundException) {
                    message = "Ticket Not Found";
                }

                builder.setMessage(message)
                        .setCancelable(false)
                        .setNegativeButton("ok", new DialogInterface.OnClickListener() {
                            public void onClick(@NonNull DialogInterface dialog, int id) {
                                dialog.cancel();

                                CurrentFile.deleteOnExit();
                                new File(CurrentFile.getPath()).delete();
                                getActivity().finish();
                            }
                        });

                AlertDialog alertDialog = builder.create();
                alertDialog.show();
                dialog.dismiss();
            }
        });
        pv.onDraw(this);
        pv.pageFitPolicy(FitPolicy.BOTH);


        pv.pageSnap(true);
        pv.pageFling(true);

        pv.fitEachPage(true);
        pv.autoSpacing(true);
//        pv.pages(1);


        pv.onPageChange(this);
        pv.onLongPress(new OnLongPressListener() {
            @Override
            public void onLongPress(MotionEvent e) {
                System.out.println("LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL");
            }
        });
//        pv.spacing(20);

        pv.onLoad(new OnLoadCompleteListener() {


            @Override
            public void loadComplete(int nbPages) {
                System.out.println("ON______LOAD");
                if (RELOAD) {
                    RELOAD = false;
//                return;
                }
                if (drawingView == null) {

                    drawingView = new p_drawing_view(Editor.this.getContext(), pdfView, Editor.this);

                    textEditorView = new p_Text_Editor_view(Editor.this.getContext(), pdfView, Editor.this, new RunAfterDone() {
                        @Override
                        public void run() {
                            visibleOnly(null, 0);
                        }
                    });


                    highlighterView = new p_hightlight_view(Editor.this.getContext(), pdfView, Editor.this);
                    erasingView = new p_eraser_view(Editor.this.getContext(), pdfView, Editor.this);
                    imageView = new p_image_view(Editor.this.getContext(), pdfView, Editor.this, new RunAfterDone() {
                        @Override
                        public void run() {
                            visibleOnly(null, 0);
                        }
                    });

                    pdfViewPerant.addView(drawingView);
                    pdfViewPerant.addView(textEditorView);
                    pdfViewPerant.addView(highlighterView);
                    pdfViewPerant.addView(erasingView);


                    pdfViewPerant.addView(imageView);

                }
                drawingView.setVisibility(View.GONE);
                Objects.requireNonNull(textEditorView).setVisibility(View.GONE);


                assert highlighterView != null;
                highlighterView.setVisibility(View.GONE);
                assert erasingView != null;
                erasingView.setVisibility(View.GONE);

                imageView.setVisibility(View.GONE);

                drawingView.getLayoutParams().width = ViewGroup.LayoutParams.MATCH_PARENT;
                drawingView.getLayoutParams().height = ViewGroup.LayoutParams.MATCH_PARENT;
                drawingView.setTop(0);

                drawingView.getLayoutParams().width = ViewGroup.LayoutParams.MATCH_PARENT;
                drawingView.getLayoutParams().height = ViewGroup.LayoutParams.MATCH_PARENT;
                drawingView.setTop(0);
                drawingView.setLeft(0);

                System.out.println("PAGE COUNT  " + pdfView.getPageCount());
                float pageYposition = 0;
                float pageSpacingTot = 0;
                float lastPageSp = 0;
                for (int i = 0; i < pdfView.getPageCount(); ++i) {
                    SizeF pageSize = pdfView.getPageSize(i);
                    PAGE pp = new PAGE(pdfView.pdfFile, pageYposition, i);

                    pageSpacingTot = ((pdfView.pdfFile.getPageSpacing(i, 1) / 2) * ((2 * i) - 1));

                    pp.pageSpacingTot = pageSpacingTot;

                    pp.dy = (pageYposition - pageSpacingTot) - lastPageSp;
                    lastPageSp = (pageYposition - pageSpacingTot);
                    System.out.println(pp.dy + "*****" + (pdfView.pdfFile.getPageSpacing(i, 1) / 2) + "=====" + ((2 * i) - 1) + "-----" + i + " pageSpacingTot " + pageSpacingTot);

                    pages.add(pp);
                    pageYposition += (pageSize.getHeight() + (pdfView.getSpacingPx()));


//                    System.out.println(pageSize.getHeight() + "________HHHHHHHHHHHHHH_______________" + pdfView.pdfFile.getMaxPageHeight());

                    getPdfEditsList().getPage(i).setHeight(pageSize.getHeight());
                    getPdfEditsList().getPage(i).setWidth(pageSize.getWidth());
                }


                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        pdfView.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

                    }
                });

                if (runAfterNsFileLoad != null) {
                    runAfterNsFileLoad.run(Editor.this);
                }
            }
        });
//      pv.autoSpacing(true);


        pv.onDrawAll(new OnDrawListener() {
            @Override
            public void onLayerDrawn(Canvas canvas, float pageWidth, float pageHeight, int displayedPage) {
                if (dialog != null && dialog.isShowing()) {
                    dialog.dismiss();
                }
            }

        });
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
            }
        });
        return pv;
    }


    public void unClickAllButtons() {
        if (is_text_editor_clicked) {
            textEditorView.saveText();
        }


        if (image_editor) {
            imageView.save();
        }

        drawingView.setVisibility(View.GONE);
        textEditorView.setVisibility(View.GONE);
        highlighterView.setVisibility(View.GONE);
        erasingView.setVisibility(View.GONE);


        imageView.setVisibility(View.GONE);


        is_text_editor_clicked = false;
        boolean writebox_editor = Boolean.FALSE;
        boolean shape_editor = false;
        boolean button_drawingView_clicked = false;
        boolean button_erasingView_clicked = false;
        boolean button_highlighter_clicked = false;
        image_editor = false;


    }

    public EditsList getPdfEditsList() {
        if (pdfEditsList == null) {
            pdfEditsList = new EditsList();
        }
        return pdfEditsList;
    }

    public void setPdfEditsList(EditsList pdfEditsList) {
        this.pdfEditsList = pdfEditsList;
    }

    public void setRunAfterNsFileLoad(Editor.runAfterFileLoad runAfterNsFileLoad) {
        this.runAfterNsFileLoad = runAfterNsFileLoad;
    }

    //    public void loadFile(@NonNull final NsFile file, final boolean editable) {
    public void loadFile(@NonNull final Ticket file, final boolean editable) {

        SELECTED_Ticket = file;
//        CurrentFile = file.getFile(getContext());
        CurrentFile = file.ticketFile;
        setFile(CurrentFile);
        pages = new ArrayList<>();
        if (pdfView != null) {
            PDFView.Configurator configurator = pdfView.fromFile(CurrentFile);
            System.out.println("_______ 3 ________");
            _set_pdfview_options(configurator).load();
//                pdfView.findViewById(R.id.mb_freehand).performClick();

        } else {
            runAfterFileLoad = new runAfterLoad() {
                @Override
                public void run(Editor editor) {
                    System.out.println("run after load");
                    PDFView.Configurator configurator = pdfView.fromFile(CurrentFile);
                    System.out.println("_______ 4 ________");
                    System.out.println(CurrentFile.getPath());
                    System.out.println(CurrentFile.exists());
                    _set_pdfview_options(configurator).load();
                }
            };
        }

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);


        int OPEN_FILE_TO_MERGE = 111;
        if (requestCode == OPEN_FILE_TO_MERGE && resultCode == RESULT_OK && null != data) {

            Uri uri = data.getData();
            new File(getContext().getFilesDir() + "/pdf.pdf").delete();
            try {
                Files.copy(getInputStreamForVirtualFile(uri),
                        Paths.get(getContext().getFilesDir() + "/pdf.pdf"));
            } catch (IOException e) {
                e.printStackTrace();
            }

            System.out.println("Path  = " + uri.getPath());
            File pdf = new File(getContext().getFilesDir(), "/pdf.pdf");

            Toast.makeText(getContext(), pdf.exists() + "", Toast.LENGTH_LONG).show();


            marge(pdf);
        }
        if (requestCode == RESULT_LOAD_IMAGE && resultCode == RESULT_OK && null != data) {


            Uri selectedImage = data.getData();
            System.out.println("________________________________________________________________");
            System.out.println(selectedImage);
            String[] filePathColumn = {MediaStore.Images.Media.DATA};

            Cursor cursor = getActivity().getContentResolver().query(selectedImage, filePathColumn, null, null, null);
            cursor.moveToFirst();

            int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
            String picturePath = cursor.getString(columnIndex);
            cursor.close();

            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;
            Bitmap bitmap1 = BitmapFactory.decodeFile(picturePath, options);
            imageView.resetImageBox();
            image_container.setBitmap(bitmap1);


        }
        if (requestCode == RESULT_CAMERA_LOAD_IMAGE && resultCode == RESULT_OK) {

            System.out.println("DATA======= " + new File(imageFilePath).exists());
            System.out.println(data);

            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;
            Bitmap bitmap1 = BitmapFactory.decodeFile(imageFilePath, options);
            imageView.resetImageBox();
            image_container.setBitmap(bitmap1);


        }
    }

    private InputStream getInputStreamForVirtualFile(Uri uri)
            throws IOException {

        ContentResolver resolver = getContext().getContentResolver();

        String[] openableMimeTypes = resolver.getStreamTypes(uri, "application/pdf");


        return resolver
                .openTypedAssetFileDescriptor(uri, openableMimeTypes[0], null)
                .createInputStream();
    }

    private void marge(final File fileToMarge) {
        new AsyncTask<Void, Void, File>() {
            ProgressDialog pDialog;

            @Override
            protected File doInBackground(Void... voids) {
                File file = null;
                try {
                    PDFMergerUtility mergePdf = new PDFMergerUtility();

                    mergePdf.addSource(CurrentFile);
                    mergePdf.addSource(fileToMarge);
//                    file = FileManager.createFile(CurrentFile.getName(), getContext(), Environment.DIRECTORY_DOCUMENTS);
                    file = SELECTED_Ticket.ticketFile;
                    mergePdf.setDestinationFileName(file.getAbsolutePath());
//                    mergePdf.mergeDocuments(new MemoryUsageSetting(false,false,-1,-1));
                    pDialog.dismiss();
                    Editor.this.file = file;
                    Editor.this.reloadFile();
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return file;
            }

            @Override
            protected void onPreExecute() {
                pDialog = ProgressDialog.show(getContext(), "Please wait...", "Merging Files..", true);

                super.onPreExecute();
            }

            @Override
            protected void onPostExecute(File file) {

                pDialog.dismiss();
//                   finish();
            }
        }.execute();
    }

    public void reloadFile() {

        System.out.println("______________________________________________________________________________RELOAD FILE");

        RELOAD = true;
//        Home.home.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

        setFile(file);
        pages = new ArrayList<>();
        System.out.println("_______ 5________");
        _set_pdfview_options(pdfView.fromFile(file)).load();


    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 11) {// If request is cancelled, the result arrays are empty.
            if (grantResults.length > 0
                    && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                Editor.this.startActivityForResult(pictureIntent, RESULT_CAMERA_LOAD_IMAGE);
            } else {

                // permission denied, boo! Disable the
                // functionality that depends on this permission.
                Toast.makeText(Editor.this.getContext(), "Permission denied to Open Camera", Toast.LENGTH_SHORT).show();
            }
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        }
        webView = new WebView(context);
        webView.getSettings().setJavaScriptEnabled(true);
        webView.loadUrl("file:///android_asset/path_maker/pathmaker.html");
        webView.addJavascriptInterface(new WebViewInterface() {
            @Override
            public void onSvgData(JSONObject value) {
                runAfterSave.run(value, SELECTED_Ticket);

            }

            @Override
            public void onLoad() {


            }
        }, "java");
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {


        return inflater.inflate(R.layout.pdf_editor, container, false);
    }

    private void updateNavigationBarState(int actionId) {
        Menu menu = bottomNavigationView.getMenu();

        for (int i = 0, size = menu.size(); i < size; i++) {
            MenuItem item = menu.getItem(i);
            item.setChecked(item.getItemId() == actionId);

        }
    }

    private final ActivityResultLauncher<String> imageChooserActivityStoragePermissions = registerForActivityResult(
            new ActivityResultContracts.RequestPermission(),
            new ActivityResultCallback<Boolean>() {
                @Override
                public void onActivityResult(Boolean result) {
                    if (result) {
                        Intent pickPhoto = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
                        imageChooserActivity.launch(pickPhoto);
                        visibleOnly(imageView, View.VISIBLE);
                    }
                }
            });

    private final ActivityResultLauncher<String> cmeraActivityStoragePermissions = registerForActivityResult(
            new ActivityResultContracts.RequestPermission(),
            new ActivityResultCallback<Boolean>() {
                @Override
                public void onActivityResult(Boolean result) {
                    if (result) {
                        visibleOnly(imageView, View.VISIBLE);
                        openCameraIntent(getContext());

                    }
                }
            });

    final ActivityResultLauncher<Intent> imageChooserActivity = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            new ActivityResultCallback<ActivityResult>() {
                @Override
                public void onActivityResult(ActivityResult result) {
                    if (result.getResultCode() == Activity.RESULT_OK) {
                        Intent data = result.getData();
                        Uri selectedImage = data.getData();
                        System.out.println("________________________________________________________________");
                        System.out.println(selectedImage);
                        String[] filePathColumn = {MediaStore.Images.Media.DATA};

                        Cursor cursor = getActivity().getContentResolver().query(selectedImage, filePathColumn, null, null, null);
                        cursor.moveToFirst();

                        int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
                        String picturePath = cursor.getString(columnIndex);
                        cursor.close();

                        BitmapFactory.Options options = new BitmapFactory.Options();
                        options.inPreferredConfig = Bitmap.Config.ARGB_8888;
                        Bitmap bitmap1 = BitmapFactory.decodeFile(picturePath, options);
                        imageView.resetImageBox();
                        image_container.setBitmap(bitmap1);
                    } else {
                        visibleOnly(null, 0);
                    }
                }
            });

    private void visibleOnly(View view, int i) {

        drawingView.setVisibility(View.GONE);
        highlighterView.setVisibility(View.GONE);
        imageView.setVisibility(View.GONE);
        textEditorView.setVisibility(View.GONE);
        if (view == null) {
            return;
        }
        view.setVisibility(i);
    }

    @SuppressLint({"NonConstantResourceId", "RestrictedApi"})
    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {


        bottomNavigationView = view.findViewById(R.id.bottomNavigationView);
        bottomNavigationView.getMenu().getItem(0).setCheckable(false);
        bottomNavigationView.getMenu().getItem(1).setCheckable(false);
        bottomNavigationView.getMenu().getItem(2).setCheckable(false);
        bottomNavigationView.getMenu().getItem(3).setCheckable(false);

        bottomNavigationView.setOnNavigationItemSelectedListener(
                item -> {


                    switch (item.getItemId()) {
                        case id.tools_pen_1:
                            item.setCheckable(drawingView.getVisibility() != View.VISIBLE);
                            visibleOnly(drawingView, drawingView.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                            return drawingView.getVisibility() == View.VISIBLE;

                        case id.tools_highlighter_1:
                            item.setCheckable(highlighterView.getVisibility() != View.VISIBLE);
                            visibleOnly(highlighterView, highlighterView.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                            return highlighterView.getVisibility() == View.VISIBLE;

                        case id.add_btn_text:
                            item.setCheckable(textEditorView.getVisibility() != View.VISIBLE);
                            visibleOnly(textEditorView, textEditorView.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                            return textEditorView.getVisibility() == View.VISIBLE;

                        case id.tools_add_picture_1:

                            Context wrapper = new ContextThemeWrapper(getContext(), R.style.popupOverflowMenu);
                            PopupMenu popup = new PopupMenu(wrapper, view.findViewById(id.tools_add_picture_1));
                            MenuBuilder menuBuilder = (MenuBuilder) popup.getMenu();
                            menuBuilder.setOptionalIconsVisible(true);
                            MenuInflater inflater = popup.getMenuInflater();
                            inflater.inflate(R.menu.add_menu, popup.getMenu());
                            popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                                @RequiresApi(api = Build.VERSION_CODES.O)
                                @Override
                                public boolean onMenuItemClick(MenuItem item) {
                                    switch (item.getItemId()) {
                                        case id.add_btn_photo_gallery:
                                            imageChooserActivityStoragePermissions.launch(Manifest.permission.READ_EXTERNAL_STORAGE);
                                            return true;

                                        case id.add_btn_photo_camera:
                                            cmeraActivityStoragePermissions.launch(Manifest.permission.CAMERA);
                                            return true;

                                        case id.add_btn_text:
                                            visibleOnly(textEditorView, View.VISIBLE);
                                            return true;

                                        case id.add_btn_page:
                                            addNewPage();
                                            return true;

                                    }


                                    return false;
                                }
                            });
                            popup.show();
                            return false;

                        case id.tools_undo_1:
                            undo();
                            break;
                        default:
                            break;
                    }
                    return false;
                });

        bottomNavigationView.setElevation(5);

        pdfView = getActivity().findViewById(R.id.pdfView);

        pdfViewPerant = getActivity().findViewById(R.id.pdfViewPerant);


        pdfViewPerant.bringToFront();

        if (runAfterLoad != null) {
            runAfterLoad.run(Editor.this);
        }
        FragmentLoaded = true;

        if (onViewCreatedListner != null) {
            onViewCreatedListner.run(Editor.this);
        }
        System.out.println("created >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 3");
        super.onViewCreated(view, savedInstanceState);
    }

    @SuppressLint("StaticFieldLeak")
    private void addNewPage() {
        new AsyncTask<Void, Void, Void>() {

            @Override
            protected Void doInBackground(Void... voids) {
                try {
                    PDDocument doc = PDDocument.load(Editor.this.getFile());
                    PDPage p = doc.getPage(doc.getPages().getCount() - 1);
                    System.out.println(p.getMediaBox().getHeight());
                    System.out.println(p.getMediaBox().getWidth());

//                            PDPage page = new PDPage(PDRectangle.A4);

                    PDPage page = new PDPage(p.getMediaBox());
                    doc.addPage(page);
                    doc.save(Editor.this.getFile());
                    doc.close();
                    System.out.println("FILE SAVED");

                    getActivity().runOnUiThread(new Runnable() {

                        @Override
                        public void run() {

                            Editor.this.reloadFile();

                        }
                    });
                } catch (IOException e) {
                    e.printStackTrace();
                }
                return null;
            }

            @Override
            protected void onPreExecute() {
                super.onPreExecute();
                dialog = new ProgressDialog(getContext());
                dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
                dialog.setMessage("Adding New Page... ");
                dialog.setTitle("Please wait...");
                dialog.setIndeterminate(true);
                dialog.setCanceledOnTouchOutside(false);
                dialog.show();
            }
        }.execute();

    }

    private void undo() {
        try {
            xEdits x = editsList.get(editsList.size() - 1);
            editsList.remove(editsList.size() - 1);
            pdfEditsList.removeEdit(x.getPage(), x.getId());
            getImagesList().remove(x.getId());
            pages.get(x.page).getBitmap().eraseColor(Color.TRANSPARENT);
            Canvas c = new Canvas(pages.get(x.page).getBitmap());
            System.out.println(x);
            reDraw(x.page);


            int visibility = drawingView.getVisibility();
            drawingView.setVisibility(View.VISIBLE);
            drawingView.invalidate();
            drawingView.setVisibility(visibility);


            pages.get(x.page).setEdited(true);

        } catch (Exception ignored) {

        }
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {

        System.out.println("**************************************************** ON CREATE " + x);
        if (savedInstanceState != null) {
            System.out.println("SAVED STATE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + savedInstanceState.getString("xx"));
            data data = savedInstanceState.getParcelable("x");
            editsList = data.getEditsList();
            images = data.getImagesList();
            pdfEditsList = data.getPdfEditsList();
            System.out.println(editsList.size() + " ---------------------" + data.ssss);
        }
        super.onActivityCreated(savedInstanceState);
        x++;
    }


    @Override
    public void onStart() {
        super.onStart();
        if (runAfterFileLoad != null) {
            if (XS) {
                XS = false;
                runAfterFileLoad.run(Editor.this);
            }
        }
    }

    @Override
    public void onResume() {
        System.out.println("______________________________________________________________onResume Caled");
        super.onResume();
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle savedInstanceState) {
        super.onSaveInstanceState(savedInstanceState);
        // Save UI state changes to the savedInstanceState.
        // This bundle will be passed to onCreate if the process is
        // killed and restarted.

        savedInstanceState.putParcelable("x", new data(editsList, images, pdfEditsList, 1));
        System.out.println("_____________________________________________________onSaveInstanceState 1");

        // etc.


        savedInstanceState.putString("xx", "Welcome back to Android");
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }


    public HashMap<Long, File> getImagesList() {
        if (images == null) {
            images = new HashMap<>();
        }
        return images;
    }


    public void setImagesList(HashMap<Long, File> imagesList) {
        images = imagesList;
    }

    public File getFile() {
        return file;
    }

    private void setFile(File file) {
        this.file = file;

    }

    public File createImageFile() throws IOException {
        String timeStamp =
                new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(new Date());
        String imageFileName = "IMG_" + timeStamp + "_";
        File storageDir =
                getActivity().getExternalFilesDir(Environment.DIRECTORY_PICTURES);


        return File.createTempFile(
                imageFileName,  /* prefix */
                ".bmp",         /* suffix */
                storageDir      /* directory */
        );
    }


    public void openCameraIntent(Context context) {
        System.out.println("openCameraIntent---------------------------");
        pictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

        if (pictureIntent.resolveActivity(getActivity().getPackageManager()) != null) {
            File photoFile = null;
            try {
                photoFile = createImageFile();
                imageFilePath = photoFile.getAbsolutePath();
            } catch (IOException ignored) {
                ignored.printStackTrace();
            }
            if (photoFile != null) {
                System.out.println("-------------------3-----------------");
                Uri photoURI = FileProvider.getUriForFile(getContext(), context.getApplicationContext().getPackageName() + ".provider", photoFile);
                pictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI);


                if (ContextCompat.checkSelfPermission(getContext(), Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                    System.out.println("-------------------4-----------------");
                    if (ActivityCompat.shouldShowRequestPermissionRationale(Editor.this.getActivity(), Manifest.permission.CAMERA)) {
                        System.out.println("-------------------6-----------------");
                    } else {
                        System.out.println("-------------------7-----------------");
                        ActivityCompat.requestPermissions(Editor.this.getActivity(), new String[]{Manifest.permission.CAMERA}, 11);

                    }
                } else {
                    System.out.println("-------------------5-----------------");
                    Editor.this.startActivityForResult(pictureIntent, RESULT_CAMERA_LOAD_IMAGE);
                }
            } else {
                System.out.println("-------------------2-----------------");
            }
        } else {
            System.out.println("-------------------1-----------------");
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    public void browsImages(final Context context) {

        View gallerySelect = getLayoutInflater().inflate(R.layout.dialog_media_select, null);

        final AlertDialog.Builder adb = new AlertDialog.Builder(Editor.this.getContext(), R.style.MyDialogTheme);

        adb.setView(gallerySelect);


        adb.setNegativeButton("Cancel", null);
        adb.setTitle("Which one?");
        final AlertDialog ad = adb.show();
        Button nbutton = ad.getButton(DialogInterface.BUTTON_NEGATIVE);
//        nbutton.setBackgroundColor(getResources().getColor(R.color.btn1));
        nbutton.setBackgroundColor(ContextCompat.getColor(context, R.color.btn1));

        gallerySelect.findViewById(R.id.cam).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                openCameraIntent(context);
                ad.dismiss();
            }
        });

        gallerySelect.findViewById(R.id.gal).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent pickPhoto = new Intent(Intent.ACTION_PICK,
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
//                Editor.this.startActivityForResult(pickPhoto, RESULT_LOAD_IMAGE);

                registerForActivityResult(
                        new ActivityResultContracts.StartActivityForResult(),
                        new ActivityResultCallback<ActivityResult>() {
                            @Override
                            public void onActivityResult(ActivityResult result) {
                                if (result.getResultCode() == Activity.RESULT_OK) {
                                    Intent data = result.getData();
                                    Uri selectedImage = data.getData();
                                    System.out.println("________________________________________________________________");
                                    System.out.println(selectedImage);
                                    String[] filePathColumn = {MediaStore.Images.Media.DATA};

                                    Cursor cursor = getActivity().getContentResolver().query(selectedImage, filePathColumn, null, null, null);
                                    cursor.moveToFirst();

                                    int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
                                    String picturePath = cursor.getString(columnIndex);
                                    cursor.close();

                                    BitmapFactory.Options options = new BitmapFactory.Options();
                                    options.inPreferredConfig = Bitmap.Config.ARGB_8888;
                                    Bitmap bitmap1 = BitmapFactory.decodeFile(picturePath, options);
                                    imageView.resetImageBox();
                                    image_container.setBitmap(bitmap1);
                                }
                            }
                        }).launch(pickPhoto);


                ad.dismiss();
            }
        });

    }


    public HashMap<String, ArrayList<File>> getImages() {

        HashMap<String, ArrayList<File>> files = new HashMap<>();
        ArrayList<File> imagesList = new ArrayList<>();
        for (Map.Entry<Long, File> f : images.entrySet()) {
            imagesList.add(f.getValue());
        }
        files.put("image", imagesList);
        return files;

    }


    private void DrawBitmap(Canvas canvas) {


//        float dheight = (((canvas.getHeight() - pdfView.pdfFile.getPageSize(pdfView.getCurrentPage()).getHeight()))/2) * nthOdd(pdfView.getCurrentPage() + 1);
        float dheight = (((canvas.getHeight() - pdfView.pdfFile.getPageSize(pdfView.getCurrentPage()).getHeight()))) * pdfView.getCurrentPage() * pdfView.getZoom();
        dheight = pdfView.getCurrentPage() == 0 ? 0 : dheight;


        canvas.drawBitmap(drawingView.getBitmap(), null, new RectF(0, 0,
                drawingView.getBitmap().getWidth() * pdfView.getZoom(),
                drawingView.getBitmap().getHeight() * pdfView.getZoom()), null);

//        System.out.println(pdfView.pdfFile.getPageSize(pdfView.getCurrentPage()).getHeight() + "___________________________________________");
    }

    public void setOnViewCreated(OnViewCreatedListner onViewCreatedListner) {
        this.onViewCreatedListner = onViewCreatedListner;
    }


    public void addImage(long id, Bitmap b1) {
        getImagesList().put(id, bitmapToFile(id, b1, String.valueOf(SELECTED_Ticket.id)));
    }

    private File bitmapToFile(long id, Bitmap bitmap, String fileId) {

//        File direct = new File(Environment.getExternalStorageDirectory() + "/Documents/PdfEdits/" + fileId);
        File dir = new File(getContext().getExternalFilesDir(null) + "/" + SELECTED_Ticket.id + "/images");
        if (!dir.exists()) {
            dir.mkdirs();
        }
        File imageFile = new File(dir, id + ".png");
        OutputStream os = null;
        try {
            os = new BufferedOutputStream(new FileOutputStream(imageFile));
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, os);
            os.flush();
            os.close();
            imageFile.deleteOnExit();
            dir.deleteOnExit();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return imageFile;
    }

    public void saveEdits() {
//        if (is_text_editor_clicked) {
        assert textEditorView != null;
        textEditorView.saveText();
//        }


//        if (image_editor) {
        imageView.save();
//        }

        System.out.println("saveEdits saveEdits saveEdits saveEditssaveEditssaveEditssaveEditssaveEdits");

    }


    public void uploadEdits(RunAfterSave afterSaveToServer) {
        runAfterSave = afterSaveToServer;
        System.out.println(getPdfEditsList().getList());
        webView.evaluateJavascript("getSvgList(" + getPdfEditsList().getList() + " );", null);
//        System.out.println("__3 __"+new Date());

    }

    void resetEdits() {
        pdfEditsList = new EditsList();
        images = new HashMap<>();
        editsList = new ArrayList<>();
    }

    @Override
    public void onLayerDrawn(Canvas canvas, float pageWidth, float pageHeight, int displayedPage) {
        DrawBitmap(canvas);
        reDraw(displayedPage);
    }


    public interface AfterSaveToServer {
        void run();

        void onError(Exception e);
    }

    private interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        void onFragmentInteraction(Uri uri);
    }

    public interface runAfterLoad {
        void run(Editor editor);
    }

    public interface OnSaveListener {
        void run(Editor editor);
    }

    public interface OnViewCreatedListner {
        void run(Editor editor);
    }

    public interface OnPrint {
        void run(Editor editor);
    }

    public interface runAfterFileLoad {
        void run(Editor editor);
    }

    public interface RunAfterEditorLoad {
        void run();
    }


}
