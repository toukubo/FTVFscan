package jp.co.fashiontv.fscan.Common;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;
import android.view.KeyEvent;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import jp.co.fashiontv.fscan.Utils.MethodCall;
import org.apache.commons.io.IOUtils;

import java.io.IOException;
import java.io.InputStream;
import java.util.Hashtable;
import java.util.Iterator;

public class FTVShareWebClient extends WebViewClient {
    private String TAG = "FTVShareWebClient";

    String hash = "jio00f7z";
    Activity activity = null;
    WebView webView;
    public static final int REQUEST_CODE = 0;
    public static final int QR_REQUEST_CODE = 1;

    private Hashtable<String, String> attributeSet = new Hashtable<String, String>();


    public FTVShareWebClient(Activity activity, WebView webView) {
        this.activity = activity;
        this.webView = webView;
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            String contents = data.getStringExtra("SCAN_RESULT");
        }
    }

    @Override
    public void onScaleChanged(WebView view, float oldScale, float newScale) {
        // TODO : zoom changed
        super.onScaleChanged(view, oldScale, newScale);
    }

    @Override
    public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
        // TODO : connection error
        super.onReceivedError(view, errorCode, description, failingUrl);
    }

    @Override
    public void onPageFinished(WebView view, String url) {
        // TODO : end hud
        super.onPageFinished(view, url);
    }

    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
        // TODO: show hud
        view.requestFocus();

        super.onPageStarted(view, url, favicon);

    }

    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
//        if (shouldNavigateInApp(url)) {
//            // Do not override; let WebView load the page
//            return false;
//        }
        if (url.startsWith("inapp-http")) {
            String uri = url.replaceAll("inapp-http://", "");
            if (uri.startsWith("local/")) {
                webView.loadUrl("file:///android_asset/" + uri.replaceAll("local/", ""));
            } else {
                String tmpUrl = "http://" + uri;
                webView.loadUrl(tmpUrl);

                return false;
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

            if (action.equals("Camera")) action = "FTVCameraActivity";
            if (action.equals("Gallery")) action = "FTVGalleryActivity";

            new MethodCall(action, activity);

            Log.v(TAG, "URL LOADED: E" + url);
        } else if (url.contains(".ahtml")) {
            String thefile = url.replace(".ahtml", "");
            thefile = thefile.replaceAll("file:///android_asset/", "");

            try {
                setData(thefile);
                InputStream is = this.activity.getAssets().open(thefile + ".ahtml");
                String thehtml = IOUtils.toString(is);
                for (Iterator iterator = this.attributeSet.keySet().iterator(); iterator.hasNext(); ) {
                    String key = (String) iterator.next();
                    String value = this.attributeSet.get(key);
                    thehtml = thehtml.replaceAll("\\$\\{" + key + "\\}", value);
                }
                view.loadDataWithBaseURL("file:///android_asset/", thehtml, "text/html", "UTF-8", null);

                return true;
            } catch (IOException e) {
                e.printStackTrace();
            }
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

    /**
     * Define if the url should be navigate inside app
     *
     * @param url destination url
     * @return true if navigate in app
     */
    private boolean shouldNavigateInApp(String url) {
        /**
         * http://developer.android.com/guide/webapps/webview.html
         *
         * Now when the user clicks a link, the system calls shouldOverrideUrlLoading(), which
         * checks whether the URL host matches a specific domain (as defined above). If it does match,
         * then the method returns false in order to not override the URL loading (it allows the WebView to
         * load the URL as usual). If the URL host does not match, then an Intent is created to launch the
         * default Activity for handling URLs (which resolves to the user's default web browser).
         * */
        // TODO: update the rules based on demand
        return Uri.parse(url).getHost().equals(FTVConstants.host);
    }

}


