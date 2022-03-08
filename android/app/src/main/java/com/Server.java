package com;

public class Server {
  public  static boolean local = true;

    public static String getServerAddress() {
        if (local) {
            return "http://192.168.0.100:3000/";
        } else {
            return "http://smartwind.nsslsupportservices.com/";
        }

    }


    public static String getServerApiPath(String url) {

        return getServerAddress() + "api/" + url;

    }
}
