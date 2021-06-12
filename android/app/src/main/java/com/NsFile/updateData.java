package com.NsFile;

import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;
import android.webkit.CookieManager;

import org.apache.commons.io.IOUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.util.List;

public class updateData extends AsyncTask<String, String, JSONObject> {
    private static final String sessionCookie = "";
    OnDetailsLoad onDetailsLoad;
    String[] params;

    public updateData(OnDetailsLoad onDetailsLoad) {
        this.onDetailsLoad = onDetailsLoad;
    }

    @Override
    protected JSONObject doInBackground(String... params) {
        this.params = params;
//       if(Home.isInternetAvailable()){
//
//           onDetailsLoad. OnNoInternat();
//       }else {
        return load();
//       }
//        return null;
    }

    public JSONObject load() {


        HttpURLConnection conn = null;
        String content = "";
        try {
            URL url;
            url = new URL(params[0]);
            System.out.println(params[0]);
            conn = (HttpURLConnection) url.openConnection();
            conn.setReadTimeout(10000);
            conn.setConnectTimeout(15000);
            conn.setRequestMethod("POST");
            conn.setDoInput(true);
            conn.setDoOutput(true);


            CookieManager cookieManager = CookieManager.getInstance();
            String cookie = cookieManager.getCookie(conn.getURL().toString());
            if (cookie != null) {
                conn.setRequestProperty("Cookie", cookie);
            }
            if (1 >= params.length) {
                //index not exists
            } else {
                System.out.println("------------------------------------------------------------------------------------------");
                System.out.println(params[1]);
//                System.out.println(URLEncoder.encode(params[1], "UTF-8"));

                DataOutputStream wr = new DataOutputStream(conn.getOutputStream());
                wr.writeBytes(params[1]);
                wr.flush();
                wr.close();

            }

            if (conn.getResponseCode() == HttpURLConnection.HTTP_OK) {
                InputStream is = conn.getInputStream();
                if (is != null) {
                    content = IOUtils.toString(is);
                    System.out.println("CCCCCCCCCCCCCCCCCCCCCCCCCCCCC = " + content);
                }
            } else {
                InputStream err = conn.getErrorStream();
            }
            List<String> cookieList = conn.getHeaderFields().get("Set-Cookie");
            if (cookieList != null) {
                for (String cookieTemp : cookieList) {
                    cookieManager.setCookie(conn.getURL().toString(), cookieTemp);
                }
            }
            if (this.onDetailsLoad != null) {
                try {
                    Handler handler = new Handler(Looper.getMainLooper());
                    final String finalContent = content;
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                onDetailsLoad.run(new JSONObject(finalContent));
                            } catch (JSONException e) {
//                                e.printStackTrace();
                            }
                        }
                    });

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            System.out.println("_____________________________________________________________________________________________________");
            System.out.println(content);
            System.out.println("_____________________________________________________________________________________________________");
            return new JSONObject(content);

        } catch (SocketTimeoutException e) {
            try {
                onDetailsLoad.OnSocketTimeoutException(updateData.this);
            } catch (Exception ignored) {
            }
        } catch (IOException | JSONException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
        return null;
    }

    @Override
    protected void onPostExecute(JSONObject jsonObject) {

    }
}