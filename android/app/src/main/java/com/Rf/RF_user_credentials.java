package com.Rf;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import com.NsFile.OnDetailsLoad;
import com.NsFile.updateData;
import com.google.android.material.textfield.TextInputLayout;
import com.sampathkumara.northsails.smartwind.R;

import org.json.JSONException;
import org.json.JSONObject;

public class RF_user_credentials extends AppCompatActivity {

    private TextInputLayout uname;
    private TextInputLayout pword;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rf_user_credentials);

        findViewById(R.id.loading).setVisibility(View.VISIBLE);
        findViewById(R.id.add).setVisibility(View.GONE);

        uname = findViewById(R.id.uname);
        pword = findViewById(R.id.pword);

        if (getIntent().hasExtra("setup")) {

            new updateData(new OnDetailsLoad() {
                @Override
                public void run(JSONObject jsonObject) {

                    System.out.println("_______________________________");
                    System.out.println(jsonObject);

                    if (jsonObject.has("uid")) {
                        try {
                            uname.getEditText().setText(jsonObject.has("uname") ? jsonObject.getString("uname") : "");
                            pword.getEditText().setText(jsonObject.has("pword") ? jsonObject.getString("pword") : "");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }

                    }

                    findViewById(R.id.loading).setVisibility(View.GONE);
                    findViewById(R.id.add).setVisibility(View.VISIBLE);


                }
            }).execute("/RF/getCredentials.php");


        } else {

            new updateData(new OnDetailsLoad() {
                @Override
                public void run(JSONObject jsonObject) {

                    System.out.println("_______________________________");
                    System.out.println(jsonObject);

                    if (jsonObject.has("uid")) {
                        System.out.println("NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN");
                        Intent resultIntent = new Intent();
                        resultIntent.putExtra("rf_user", jsonObject.toString());
                        setResult(Activity.RESULT_OK, resultIntent);
                        finish();
                    } else {
                        findViewById(R.id.loading).setVisibility(View.GONE);
                        findViewById(R.id.add).setVisibility(View.VISIBLE);
                    }


                }
            }).execute("/RF/getCredentials.php");
        }

        findViewById(R.id.save).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                String un = uname.getEditText().getText().toString();
                String pw = pword.getEditText().getText().toString();

                if (getIntent().hasExtra("setup")) {
                    findViewById(R.id.saving).setVisibility(View.VISIBLE);
                    findViewById(R.id.add).setVisibility(View.GONE);
                    findViewById(R.id.loading).setVisibility(View.GONE);
                } else {

                    findViewById(R.id.loading).setVisibility(View.VISIBLE);
                    findViewById(R.id.add).setVisibility(View.GONE);
                }
                new updateData(new OnDetailsLoad() {
                    @Override
                    public void run(JSONObject jsonObject) {

                        System.out.println("_______________________________");
                        System.out.println(jsonObject);

                        if (jsonObject.has("uid")) {
                            System.out.println("NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN");
                            Intent resultIntent = new Intent();
                            resultIntent.putExtra("rf_user", jsonObject.toString());
                            setResult(Activity.RESULT_OK, resultIntent);
                            finish();
                        } else {
                            findViewById(R.id.loading).setVisibility(View.GONE);
                            findViewById(R.id.add).setVisibility(View.VISIBLE);
                        }


                    }
                }).execute("/RF/putCredentials.php", "un=" + un + "&pw=" + pw);

            }
        });

    }
}
