package com.pdfEditor;

import android.graphics.RectF;
import android.os.Environment;

import androidx.annotation.NonNull;

import com.tom_roush.pdfbox.pdmodel.PDDocument;
import com.tom_roush.pdfbox.pdmodel.PDPage;
import com.tom_roush.pdfbox.text.PDFTextStripperByArea;

import java.io.File;
import java.io.IOException;


class SearchInPdf {

    private static long x;

    public SearchInPdf() throws IOException {
        File f = new File(Environment.getExternalStorageDirectory()
                .getAbsolutePath(), "X.pdf");
        PDDocument document = PDDocument.load(f);
        try {
            System.out.println(search("Type", document));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static int search(String name, @NonNull PDDocument document) throws IOException {

        x = System.currentTimeMillis();
        int page = 0;
        int y = 826; // start searching from top of pdf
//        while (y>0) {
        int[] cb = {20, 100, 700, 160}; // her I just searching in a culomn of 70
        String text = getData(page, cb, document); // her I get the text
//        text = text.replaceAll(" ", "").toLowerCase();
        System.out.println(text);
        String data = text.substring(0, Math.min(text.length(), 4));// Get first 4 chars in text
        if (data.equals(name)) {// test if it's egal to the word I want

//                break;
        }
        y -= 10;
        System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzz____" + (System.currentTimeMillis() - x));
//        }
        return y;
    }

    private static String getData(int page, int[] cord, PDDocument document) throws IOException {
        PDFTextStripperByArea textStripper = new PDFTextStripperByArea();
        System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzz__1__" + (System.currentTimeMillis() - x));
        RectF rect = new RectF(105, 190, 80, 10);
        System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzz___2_" + (System.currentTimeMillis() - x));
        textStripper.addRegion("region", rect);
        System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzz__3__" + (System.currentTimeMillis() - x));
        textStripper.setSortByPosition(true);
        PDPage docPage = document.getPage(page);
        System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzz__4__" + (System.currentTimeMillis() - x));
        textStripper.extractRegions(docPage);
        System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzz__5__" + (System.currentTimeMillis() - x));
        String textForRegion = textStripper.getTextForRegion("region");
        System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzz__6__" + (System.currentTimeMillis() - x));
        textForRegion = textForRegion.replaceAll("^\\s+|\\s+$", "");
        System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzz___7_" + (System.currentTimeMillis() - x));
        return textForRegion;
    }

    public static void main(String[] args) {


    }


}
