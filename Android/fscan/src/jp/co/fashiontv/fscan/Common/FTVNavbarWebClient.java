package jp.co.fashiontv.fscan.Common;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.view.KeyEvent;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import jp.co.fashiontv.fscan.Activities.MainActivity;
import org.apache.commons.io.IOUtils;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Hashtable;
import java.util.Iterator;

/**
 * Application view was mainly divided to two parts - Main View, and Navbar View (tab bar)
 * <p/>
 * This class controls the Navbar View web url redirection
 */
public class FTVNavbarWebClient extends WebViewClient {
    private String TAG = "FTVNavbarWebClient";

    String hash = "jio00f7z";
    Activity activity = null;
    WebView webView;
    public static final int REQUEST_CODE = 0;
    public static final int QR_REQUEST_CODE = 1;

    private Hashtable<String, String> attributeSet = new Hashtable<String, String>();

    public FTVNavbarWebClient(Activity activity, WebView webView) {
        this.activity = activity;
        this.webView = webView;
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            String contents = data.getStringExtra("SCAN_RESULT");
        }
    }

    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        Log.d(TAG, "TAB BAR URL - " + url);

        if (url.contains("target=_blank")) {
            openExternalBrowser(this.activity, url);
        } else if (url.startsWith("inapp-http")) {
            String uri = url.replaceAll("inapp-http://", "");
            if (uri.startsWith("local/")) {
                webView.loadUrl("file:///android_asset/" + uri.replaceAll("local/", ""));
            } else {
                /** @TODO this code, is NOT tested and being commited. */
                if (url.contains("scan/list.php")) {
                    webView.loadUrl("http://" + uri + "?deviceid=" + FTVUser.getID());
//                    view.requestFocus();
                } else {
                    webView.loadUrl("http://" + uri);
                }
            }
        } else if (url.contains(".action")) {
            String[] paramsets = url.split("\\?");
            String actionuri = paramsets[0];
            String file = "";
            for (int i = 1; i < paramsets.length; i++) {
                String name = paramsets[i].split("=")[0];
                String value = paramsets[i].split("=")[1];
                if (name.equals("file")) {
                    file = value;
                }
            }

            String action = actionuri.replace(".action", "");
            action = action.split("/")[url.split("/").length - 1];
            action = action.replaceAll("file:///android_asset/", "");

            if (action.equals("Camera")) {
                ((MainActivity) activity).startActivityCamera();
            }
            if (action.equals("Gallery")) {
                ((MainActivity) activity).startActivityGallery();
            }

            Log.v(TAG, "URL LOADED: E" + url);
        } else if (url.contains(".ahtml")) {
            URL urlObject = null;
            try {
                urlObject = new URL(url);
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
            InputStream is = null;
            try {
                is = urlObject.openStream();
            } catch (IOException e) {
                e.printStackTrace();
            }
            String thehtml = null;
            try {
                thehtml = IOUtils.toString(is);
            } catch (IOException e) {
                e.printStackTrace();
            }

            for (Iterator iterator = this.attributeSet.keySet().iterator(); iterator.hasNext(); ) {
                String key = (String) iterator.next();
                String value = this.attributeSet.get(key);
                thehtml = thehtml.replaceAll("\\$\\{" + key + "\\}", value);
            }
            view.loadDataWithBaseURL("file:///android_asset/", thehtml, "text/html", "UTF-8", null);

            return true;

        } else {
            view.loadUrl(url);
            view.requestFocus();
        }

        return true;
    }

    public boolean shouldOverrideKeyEvent(WebView view, KeyEvent event) {
        Log.v(TAG, String.valueOf(event.getKeyCode()));
        return true;
    }

    public void setData(String action) {
        if (action.equals("score")) {
        }
    }

    public void setAttribute(String string, String string2) {
        Hashtable<String, String> hashtable = this.attributeSet;
        hashtable.put(string, string2);
    }

    public static void openExternalBrowser(Context context, String url) {
        Uri uri = Uri.parse(url);
        Intent i = new Intent(Intent.ACTION_VIEW, uri);
        context.startActivity(i);
    }
}


