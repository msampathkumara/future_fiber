package com.Rf;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.View;
import android.webkit.JsResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.NsFile.OnDetailsLoad;
import com.NsFile.updateData;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.ChecksumException;
import com.google.zxing.FormatException;
import com.google.zxing.LuminanceSource;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.NotFoundException;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.Reader;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import com.pdfEditor.Ticket;
import com.pdfviewer.PDFView;
import com.pdfviewer.listener.OnLoadCompleteListener;
import com.sampathkumara.northsails.smartwind.R;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;

public class Rf extends AppCompatActivity {
    PDFView pdfView;
    String CURRENT_SECTION;
    TextView txt_mo;
    String rf_user;
    private WebView webView;
    private ImageButton selectBtn;
    private Button finishBtn;
    private Ticket SELECTED_FILE;
    private int OP_MAX;
    private int OP_MIN;
    private boolean _OP_MAX = false;
    private boolean _OP_MIN = false;
    private String rf_pword;

    public static Bitmap loadBitmapFromView(View v, int x, int y, int width, int height) {
        Bitmap bitmap;
        v.setDrawingCacheEnabled(true);
        bitmap = Bitmap.createBitmap(v.getDrawingCache());
        v.setDrawingCacheEnabled(false);
        System.out.println(" XX " + x + " YY " + y + " WW " + width + " HH " + height);
        height = y < 0 ? height + y : height;
        x = Math.max(x, 0);
        y = Math.max(y, 0);
        System.out.println("___ XX " + x + " YY " + y + " WW " + width + " HH " + height);

        bitmap = Bitmap.createBitmap(bitmap, x, y, width, height);
        return bitmap;
    }

    public void showFinishButton() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                finishBtn.setVisibility(View.VISIBLE);

            }
        });
        System.out.println("________________________________dsfsdfsdFS_DFSDf_DSF_SDFSDFSDFSDFSD sdfSDFSDF SDFSdf");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rf);

        pdfView = findViewById(R.id.ticketPdfView);
        webView = findViewById(R.id.webView);
        selectBtn = findViewById(R.id.selectBtn);
        ImageButton openFile = findViewById(R.id.openFile);
        finishBtn = findViewById(R.id.finishBtn);
        txt_mo = findViewById(R.id.txt_mo);

        SELECTED_FILE = new Ticket();
        CURRENT_SECTION = getIntent().getStringExtra("CURRENT_SECTION");
        try {
            JSONObject user = new JSONObject(getIntent().getStringExtra("rf_user"));
            rf_user = user.getString("uname");
            rf_pword = user.getString("pword");
        } catch (JSONException e) {
            e.printStackTrace();
        }


        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setJavaScriptCanOpenWindowsAutomatically(true);
        JavaScriptInterface jsInterface = new JavaScriptInterface(this);

        webView.addJavascriptInterface(jsInterface, "java");


        finishBtn.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {

//                final ProgressDialog dialog = Dialogs.ShowLoadingDialog(Rf.this);
                new updateData(new OnDetailsLoad() {
                    @Override
                    public void run(JSONObject jsonObject) {

                        System.out.println(jsonObject);
                        try {
                            Intent intent = new Intent();
                            intent.putExtra("result", "done");
                            setResult(RESULT_OK, intent);
                            System.out.println("________________" + jsonObject.getString("d"));
//                            dialog.dismiss();
                            finish();

                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                }).execute("/FileBrowser/Files/finish.php?file=" + SELECTED_FILE.getId());

            }
        });


        final DragRectView dragRectView = findViewById(R.id.dragRect);

        selectBtn.setOnClickListener(new View.OnClickListener() {
            @SuppressLint("ResourceType")
            @Override
            public void onClick(View view) {
                if (dragRectView.getVisibility() == View.VISIBLE) {
                    dragRectView.setVisibility(View.GONE);
                    selectBtn.setColorFilter(Color.argb(255, 190, 192, 196));
                } else {
                    dragRectView.setVisibility(View.VISIBLE);
                    selectBtn.setColorFilter(Color.argb(255, 105, 150, 239));
                }
            }
        });

        dragRectView.setVisibility(View.GONE);
        selectBtn.setColorFilter(Color.argb(255, 190, 192, 196));
        openFile.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

            }
        });
        if (null != dragRectView) {
            dragRectView.setOnUpCallback(new DragRectView.OnUpCallback() {
                @Override
                public void onRectFinished(final Rect rect, int width, int height) {
                    try {
                        Bitmap bitmap = loadBitmapFromView(pdfView, rect.left, rect.top, width, height);
                        scanImage(bitmap);

                    } catch (IllegalArgumentException e) {

                    }
                }
            });
        }

        webView.setWebViewClient(new WebViewClient() {


            @Override
            public boolean shouldOverrideUrlLoading(final WebView view, final String url) {
                webView.loadUrl(url);
                return true;
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                System.out.println("PAGE LOAD FINISHED");
                String javaScript = "javascript:" + setupData(LoadData("js1.txt"));


                webView.loadUrl(javaScript);
                System.out.println("PAGE LOADED");
            }
        });
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onJsAlert(WebView view, String url, String message, JsResult result) {

                return super.onJsAlert(view, url, message, result);
            }
        });


        if (getIntent().getExtras() != null) {

            SELECTED_FILE = Ticket.formJsonString(getIntent().getExtras().getString("ticket"));

            loadFile(SELECTED_FILE);
            getCurrentOp(SELECTED_FILE);
        } else {
        }

        webView.loadUrl("http://10.200.4.31/webclient/");

        onConfigurationChanged(getResources().getConfiguration());
    }

    private void scanImage(Bitmap bMap) {

        String contents = null;

        int[] intArray = new int[bMap.getWidth() * bMap.getHeight()];
//copy pixel data from the Bitmap into the 'intArray' array
        bMap.getPixels(intArray, 0, bMap.getWidth(), 0, 0, bMap.getWidth(), bMap.getHeight());

        LuminanceSource source = new RGBLuminanceSource(bMap.getWidth(), bMap.getHeight(), intArray);
        BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));

        Reader reader = new MultiFormatReader();
        Result result = null;
        try {
            result = reader.decode(bitmap);
        } catch (NotFoundException | ChecksumException | FormatException e) {
            e.printStackTrace();
        }
        try {
            contents = result.getText();
            System.out.println("xx " + contents);
            ClipboardManager clipboard = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
            ClipData clip = ClipData.newPlainText("barcode", contents);
            clipboard.setPrimaryClip(clip);
            Toast.makeText(getApplicationContext(), " Barcode " + contents + "\n Copied to  Clipboard", Toast.LENGTH_LONG).show();

            Toast.makeText(getApplicationContext(), OP_MAX + " __  " + OP_MIN, Toast.LENGTH_LONG).show();
//            if (contents.equals(CURRENT_OPERATION)) {
            if ((OP_MAX + "").equals(contents.trim())) {
                _OP_MAX = true;
                Toast.makeText(getApplicationContext(), " max ", Toast.LENGTH_LONG).show();
//                finishBtn.setVisibility(View.VISIBLE);
            }
            if ((OP_MIN + "").equals(contents.trim())) {
                _OP_MIN = true;
                Toast.makeText(getApplicationContext(), " min ", Toast.LENGTH_LONG).show();
//                finishBtn.setVisibility(View.VISIBLE);
            }
            if (_OP_MAX && _OP_MIN) {

                finishBtn.setVisibility(View.VISIBLE);

            }


        } catch (NullPointerException e) {
            Toast.makeText(getApplicationContext(), " Barcode Not Found", Toast.LENGTH_LONG).show();
        }
    }

    private String setupData(String loadData) {

        loadData = loadData.replace("@@user", rf_user);
        loadData = loadData.replace("@@pass", rf_pword);
        loadData = loadData.replace("@@mo", SELECTED_FILE.getMo());
        loadData = loadData.replace("@@low", OP_MIN + "");
        loadData = loadData.replace("@@max", OP_MAX + "");


        return loadData;
    }

    public String LoadData(String inFile) {
        String tContents = "";

        try {
            InputStream stream = getAssets().open(inFile);

            int size = stream.available();
            byte[] buffer = new byte[size];
            stream.read(buffer);
            stream.close();
            tContents = new String(buffer);
        } catch (IOException e) {
            // Handle exceptions here
        }

        return tContents;

    }

    public void loadFile(@NonNull Ticket ticket) {

        pdfView.fromFile(ticket.getTicketFile()).onLoad(new OnLoadCompleteListener() {
            @Override
            public void loadComplete(int nbPages) {
                txt_mo.setText(SELECTED_FILE.getMo());
                txt_mo.setOnClickListener(v -> {
                    System.out.println("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                    webView.evaluateJavascript("var FunctionOne = function () {"
                            + "  try{document.getElementById('txt').value = '" + SELECTED_FILE.getMo() + "';}catch(e){}"
                            + "};FunctionOne();", null);
                });
            }
        }).load();


    }

    private void getCurrentOp(Ticket ticket) {

        new updateData(new OnDetailsLoad() {
            @Override
            public void run(JSONObject jsonObject) {

                System.out.println(jsonObject);


                try {
                    if (!jsonObject.isNull("err") && jsonObject.getBoolean("err")) {
                        runOnUiThread(() -> {
//                                finishBtn.setVisibility(View.VISIBLE);
                        });
                    } else {
                        OP_MAX = jsonObject.getInt("max");
                        OP_MIN = jsonObject.getInt("min");
                        TextView msg = findViewById(R.id.msg);
                        msg.setText("Please Scan Barcodes " + OP_MIN + " and " + OP_MAX);
//                    System.out.println("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF = " + CURRENT_OPERATION);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }).execute("/FileBrowser/Files/checkOpNo.php?fid=" + ticket.getId());
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
//        setContentView(R.layout.activity_rf);
        LinearLayout l = findViewById(R.id.cont);
        LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)
                webView.getLayoutParams();


        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            System.out.println("Configuration.ORIENTATION_LANDSCAPE");
            params.weight = 5;
            l.setOrientation(LinearLayout.HORIZONTAL);
        } else {
            System.out.println("Configuration.PPPPPPPPPPPPPPP");
            params.weight = 6;
            l.setOrientation(LinearLayout.VERTICAL);
        }
        webView.setLayoutParams(params);
        float weight = 10 - params.weight;
        LinearLayout l1 = findViewById(R.id.pdfv);
        params = (LinearLayout.LayoutParams) l1.getLayoutParams();
        params.weight = (weight);
        l1.setLayoutParams(params);

        super.onConfigurationChanged(newConfig);

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        super.onActivityResult(requestCode, resultCode, data);
        int fileOpener = 1;
        if (requestCode == fileOpener) {
            if (resultCode == Activity.RESULT_OK) {
                SELECTED_FILE = Ticket.formJsonString(getIntent().getExtras().getString("ticket"));
                loadFile(SELECTED_FILE);
                getCurrentOp(SELECTED_FILE);
            }

        }

    }


}
