package com.pdfEditor;

import static android.app.Activity.RESULT_OK;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
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
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.StrictMode;
import android.provider.MediaStore;
import android.util.DisplayMetrics;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.Toast;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
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
import com.pdfviewer.listener.OnPageChangeListener;
import com.pdfviewer.util.FitPolicy;
import com.pdfviewer.util.SizeF;
import com.sampathkumara.northsails.smartwind.R;
import com.sampathkumara.northsails.smartwind.R.id;
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

    private ImageButton btnNextPage;
    private ImageButton btnPrevPage;
    private android.app.AlertDialog dialog;


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

    private runAfterLoad runAfterFileLoad;
    OnViewCreatedListner onViewCreatedListner;
    boolean XS = true;
//    ImageButton button_new_page;

    runAfterFileLoad runAfterNsFileLoad;
    private HashMap<Long, File> images = new HashMap<>();
    private WebView webView;
    public static List<PAGE> pages;
    private p_image_view imageView;
    private String imageFilePath;
    //    private final boolean button_arrow_clicked = false;
    File file;
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

    private FrameLayout pdfViewPerant;


    private boolean RELOAD;
    private Ticket SELECTED_Ticket;
    private EditsList pdfEditsList;
    private RunAfterSave runAfterSave;

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
            runAfterFileLoad = editor -> {
                PDFView.Configurator configurator = pdfView.fromFile(file);
                System.out.println("RUN AFTER LOAD 1");
                _set_pdfview_options(configurator).load();
//                    pdfView.findViewById(R.id.mb_freehand).performClick();

            };
        }


    }

    int page = 0;

    private PDFView.Configurator _set_pdfview_options(PDFView.Configurator pv) {


        System.out.println("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++_set_pdfview_options");
        DisplayMetrics displayMetrics = new DisplayMetrics();
        requireActivity().getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);


        if (!RELOAD) {
//            editsList = new ArrayList();

            getActivity().runOnUiThread(() -> {
                try {

                    android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(getActivity());
                    builder.setCancelable(false);
                    builder.setView(R.layout.layout_loading_dialog);
                    dialog = builder.create();
                    dialog.show();


//                    dialog = new ProgressDialog(getActivity());
//                    dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
//                    dialog.setMessage("Loading. Please wait...");
//                    System.out.println("Loading. Please wait...");
//                    dialog.setIndeterminate(true);
//                    dialog.setCanceledOnTouchOutside(false);
                    getActivity().isFinishing();//                            dialog.show();

                } catch (Exception e) {
                    e.printStackTrace();
                }
            });

        } else {
            unClickAllButtons();
        }

        btnNextPage.setOnClickListener(v -> {
            if (page >= pdfView.getPageCount()) {
                return;
            }
            page++;
            pdfView.jumpTo(page);


        });
        btnPrevPage.setOnClickListener(v -> {
//                if (page < 1) {
//                    return;
//                }
//                page--;
//                pdfView.jumpTo(page);


        });

//        pv.pages(1, 3);
        pv.onError(t -> {
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
                    .setNegativeButton("ok", (dialog, id) -> {
                        dialog.cancel();

                        assert CurrentFile != null;
                        CurrentFile.deleteOnExit();
                        new File(CurrentFile.getPath()).delete();
                        getActivity().finish();
                    });

            AlertDialog alertDialog = builder.create();
            alertDialog.show();
            dialog.dismiss();
        });
        pv.onDraw(this);
        pv.pageFitPolicy(FitPolicy.BOTH);


        pv.pageSnap(true);
        pv.pageFling(true);

        pv.fitEachPage(true);
        pv.autoSpacing(false);
        pv.spacing(500);
//        pv.pages(1);


        pv.onPageChange(this);
        pv.onLongPress(e -> System.out.println("LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL"));


        pv.onLoad(nbPages -> {
            System.out.println("ON______LOAD");
            if (RELOAD) {
                RELOAD = false;
//                return;
            }
            if (drawingView == null) {

                drawingView = new p_drawing_view(Editor.this.requireContext(), pdfView, Editor.this);

                textEditorView = new p_Text_Editor_view(Editor.this.requireContext(), pdfView, Editor.this, () -> visibleOnly(null, 0));


                highlighterView = new p_hightlight_view(Editor.this.requireContext(), pdfView, Editor.this);
                erasingView = new p_eraser_view(Editor.this.requireContext(), pdfView, Editor.this);
                imageView = new p_image_view(Editor.this.getContext(), pdfView, Editor.this, () -> visibleOnly(null, 0));

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
                PAGE pp = new PAGE(pdfView.pdfFile, pageYposition, i, pageSize);

                pp.dy = lastPageSp;
                lastPageSp = pdfView.pdfFile.getPageSpacing(i, 1);
                System.out.println(pp.dy + "*****" + (pdfView.pdfFile.getPageSpacing(i, 1) / 2) + "=====" + ((2 * i) - 1) + "-----" + i + " pageSpacingTot " + pageSpacingTot);

                pages.add(pp);
                pageYposition += (pageSize.getHeight() + (pdfView.getSpacingPx()));
                getPdfEditsList().getPage(i).setHeight(pageSize.getHeight());
                getPdfEditsList().getPage(i).setWidth(pageSize.getWidth());
            }


            requireActivity().runOnUiThread(() -> pdfView.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)));

            if (runAfterNsFileLoad != null) {
                runAfterNsFileLoad.run(Editor.this);
            }
            visibleOnly(drawingView, View.VISIBLE);
            new Handler().postDelayed(() -> visibleOnly(drawingView, View.GONE), 100);

        });


        pv.onDrawAll((canvas, pageWidth, pageHeight, displayedPage) -> {
            if (dialog != null && dialog.isShowing()) {
                dialog.dismiss();
            }
        });
        getActivity().runOnUiThread(() -> {
        });


        return pv;
    }


    public void unClickAllButtons() {
        if (is_text_editor_clicked) {
            assert textEditorView != null;
            textEditorView.saveText();
        }


        if (image_editor) {
            imageView.save();
        }

        assert drawingView != null;
        drawingView.setVisibility(View.GONE);
        assert textEditorView != null;
        textEditorView.setVisibility(View.GONE);
        assert highlighterView != null;
        highlighterView.setVisibility(View.GONE);
        assert erasingView != null;
        erasingView.setVisibility(View.GONE);


        imageView.setVisibility(View.GONE);


        is_text_editor_clicked = false;
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
    public void loadFile(@NonNull final Ticket file) {

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
            runAfterFileLoad = editor -> {
                System.out.println("run after load");
                PDFView.Configurator configurator = pdfView.fromFile(CurrentFile);
                System.out.println("_______ 4 ________");
                assert CurrentFile != null;
                System.out.println(CurrentFile.getPath());
                System.out.println(CurrentFile.exists());
                _set_pdfview_options(configurator).load();
            };
        }

    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);


        int OPEN_FILE_TO_MERGE = 111;
        if (requestCode == OPEN_FILE_TO_MERGE && resultCode == RESULT_OK && null != data) {

            Uri uri = data.getData();
            new File(requireContext().getFilesDir() + "/pdf.pdf").delete();
            try {
                Files.copy(getInputStreamForVirtualFile(uri),
                        Paths.get(requireContext().getFilesDir() + "/pdf.pdf"));
            } catch (IOException e) {
                e.printStackTrace();
            }

            System.out.println("Path  = " + uri.getPath());
            File pdf = new File(requireContext().getFilesDir(), "/pdf.pdf");

            Toast.makeText(requireContext(), pdf.exists() + "", Toast.LENGTH_LONG).show();


            marge(pdf);
        }
        if (requestCode == RESULT_LOAD_IMAGE && resultCode == RESULT_OK && null != data) {


            Uri selectedImage = data.getData();
            System.out.println("________________________________________________________________");
            System.out.println(selectedImage);
            String[] filePathColumn = {MediaStore.Images.Media.DATA};

            Cursor cursor = requireActivity().getContentResolver().query(selectedImage, filePathColumn, null, null, null);
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

        ContentResolver resolver = requireContext().getContentResolver();

        String[] openableMimeTypes = resolver.getStreamTypes(uri, "application/pdf");


        return resolver
                .openTypedAssetFileDescriptor(uri, openableMimeTypes[0], null)
                .createInputStream();
    }

    private void marge(final File fileToMarge) {
        new margeTask(this, SELECTED_Ticket, CurrentFile, fileToMarge, getContext()).execute();
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
                        assert data != null;
                        Uri selectedImage = data.getData();
                        System.out.println("________________________________________________________________");
                        System.out.println(selectedImage);
                        String[] filePathColumn = {MediaStore.Images.Media.DATA};

                        Cursor cursor = requireActivity().getContentResolver().query(selectedImage, filePathColumn, null, null, null);
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

        assert drawingView != null;
        drawingView.setVisibility(View.GONE);
        assert highlighterView != null;
        highlighterView.setVisibility(View.GONE);
        imageView.setVisibility(View.GONE);
        assert textEditorView != null;
        textEditorView.setVisibility(View.GONE);
        if (view == null) {
            return;
        }
        view.setVisibility(i);
    }

    @SuppressLint({"NonConstantResourceId", "RestrictedApi"})
    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {


        BottomNavigationView bottomNavigationView = view.findViewById(R.id.bottomNavigationView);
        bottomNavigationView.getMenu().getItem(0).setCheckable(false);
        bottomNavigationView.getMenu().getItem(1).setCheckable(false);
        bottomNavigationView.getMenu().getItem(2).setCheckable(false);
        bottomNavigationView.getMenu().getItem(3).setCheckable(false);

        bottomNavigationView.setOnItemSelectedListener(
                item -> {


                    switch (item.getItemId()) {
                        case id.tools_pen_1:
                            assert drawingView != null;
                            item.setCheckable(drawingView.getVisibility() != View.VISIBLE);
                            visibleOnly(drawingView, drawingView.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                            return drawingView.getVisibility() == View.VISIBLE;

                        case id.tools_highlighter_1:
                            assert highlighterView != null;
                            item.setCheckable(highlighterView.getVisibility() != View.VISIBLE);
                            visibleOnly(highlighterView, highlighterView.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                            return highlighterView.getVisibility() == View.VISIBLE;

                        case id.add_btn_text:
                            assert textEditorView != null;
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
                            popup.setOnMenuItemClickListener(item1 -> {
                                switch (item1.getItemId()) {
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

        pdfView = requireActivity().findViewById(R.id.pdfView);
        btnNextPage = requireActivity().findViewById(R.id.btnNextPage);
        btnPrevPage = requireActivity().findViewById(R.id.btnPrevPage);
        pdfViewPerant = requireActivity().findViewById(R.id.pdfViewPerant);


        pdfViewPerant.bringToFront();


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

                    requireActivity().runOnUiThread(Editor.this::reloadFile);
                } catch (IOException e) {
                    e.printStackTrace();
                }
                return null;
            }

            @Override
            protected void onPreExecute() {
                super.onPreExecute();

                android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(getActivity());
                builder.setCancelable(false);
                builder.setView(R.layout.layout_loading_dialog);
                dialog = builder.create();
                dialog.show();

//                dialog = new ProgressDialog(getContext());
//                dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
//                dialog.setMessage("Adding New Page... ");
//                dialog.setTitle("Please wait...");
//                dialog.setIndeterminate(true);
//                dialog.setCanceledOnTouchOutside(false);
//                dialog.show();
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


            assert drawingView != null;
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

        savedInstanceState.putParcelable("x", new data(editsList, images, pdfEditsList));
        System.out.println("_____________________________________________________onSaveInstanceState 1");

        // etc.


        savedInstanceState.putString("xx", "Welcome back to Android");
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
                requireActivity().getExternalFilesDir(Environment.DIRECTORY_PICTURES);


        return File.createTempFile(
                imageFileName,  /* prefix */
                ".bmp",         /* suffix */
                storageDir      /* directory */
        );
    }


    public void openCameraIntent(Context context) {
        System.out.println("openCameraIntent---------------------------");
        pictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

        if (pictureIntent.resolveActivity(requireActivity().getPackageManager()) != null) {
            File photoFile = null;
            try {
                photoFile = createImageFile();
                imageFilePath = photoFile.getAbsolutePath();
            } catch (IOException ignored) {
                ignored.printStackTrace();
            }
            if (photoFile != null) {
                System.out.println("-------------------3-----------------");
                Uri photoURI = FileProvider.getUriForFile(requireContext(), context.getApplicationContext().getPackageName() + ".provider", photoFile);
                pictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI);


                if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                    System.out.println("-------------------4-----------------");
                    if (ActivityCompat.shouldShowRequestPermissionRationale(Editor.this.requireActivity(), Manifest.permission.CAMERA)) {
                        System.out.println("-------------------6-----------------");
                    } else {
                        System.out.println("-------------------7-----------------");
                        ActivityCompat.requestPermissions(Editor.this.requireActivity(), new String[]{Manifest.permission.CAMERA}, 11);

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


    public HashMap<String, ArrayList<File>> getImages() {

        HashMap<String, ArrayList<File>> files = new HashMap<>();
        ArrayList<File> imagesList = new ArrayList<>();
        for (Map.Entry<Long, File> f : images.entrySet()) {
            imagesList.add(f.getValue());
        }
        files.put("image", imagesList);
        return files;

    }


    private void DrawBitmap(Canvas canvas, int pageId) {


//        Paint paint = new Paint();
//        paint.setColorFilter(new PorterDuffColorFilter(Color.argb(100, 255, 0, 0), PorterDuff.Mode.SRC_IN));

        PAGE page = pages.get(pageId);
        float w = (pdfView.getWidth() - page.getPageSize().getWidth()) / 2;
        assert drawingView != null;
        Bitmap bitMap = drawingView.getBitmap();
//        canvas.drawBitmap(bitMap, null, new RectF(w * pdfView.getZoom(), 0,
//                ((bitMap.getWidth() + w) * pdfView.getZoom()),
//                bitMap.getHeight() * pdfView.getZoom()), null);

//        canvas.drawBitmap(drawingView.getBitmap(), null, new RectF(0 , 0,
//                ((drawingView.getBitmap().getWidth()  ) * pdfView.getZoom()),
//                drawingView.getBitmap().getHeight() * pdfView.getZoom()), null);

//        canvas.drawBitmap(drawingView.getBitmap(), null, new RectF(0, 0,
//                (drawingView.getBitmap().getWidth() + w) * pdfView.getZoom(),
//                drawingView.getBitmap().getHeight() * pdfView.getZoom()), null);

        canvas.drawBitmap(drawingView.getBitmap(), null, new RectF(0, 0,
                (drawingView.getBitmap().getWidth()  ) * pdfView.getZoom(),
                drawingView.getBitmap().getHeight() * pdfView.getZoom()), null);

//        System.out.println(pdfView.pdfFile.getPageSize(pdfView.getCurrentPage()).getHeight() + "___________________________________________");
    }


    public void addImage(long id, Bitmap b1) {
        getImagesList().put(id, bitmapToFile(id, b1));
    }

    private File bitmapToFile(long id, Bitmap bitmap) {

        File dir = new File(requireContext().getExternalFilesDir(null) + "/" + SELECTED_Ticket.id + "/images");
        if (!dir.exists()) {
            dir.mkdirs();
        }
        File imageFile = new File(dir, id + ".png");
        OutputStream os;
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

        assert textEditorView != null;
        textEditorView.saveText();
        imageView.save();
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
        DrawBitmap(canvas, displayedPage);
        reDraw(displayedPage);
    }


    public interface runAfterLoad {
        void run(Editor editor);
    }

    public interface OnViewCreatedListner {
        void run(Editor editor);
    }

    public interface runAfterFileLoad {
        void run(Editor editor);
    }


}
