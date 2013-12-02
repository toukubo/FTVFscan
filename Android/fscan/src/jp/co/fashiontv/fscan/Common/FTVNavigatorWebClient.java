package jp.co.fashiontv.fscan.Common;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;
import android.view.KeyEvent;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import com.squareup.otto.Bus;
import com.testflightapp.lib.TestFlight;
import jp.co.fashiontv.fscan.Activities.FTVMainActivity;
import jp.co.fashiontv.fscan.Injector;

import javax.inject.Inject;
import java.util.Hashtable;

/**
 * Application view was mainly divided to two parts - Main View, and Navbar View (tab bar)
 * This class controls the Navbar View web url redirection
 */
public class FTVNavigatorWebClient extends WebViewClient {
    @Inject
    Bus BUS;

    private String TAG = "FTVNavigatorWebClient";

    Activity activity = null;
    WebView webView;
    public static final int REQUEST_CODE = 0;

    private Hashtable<String, String> attributeSet = new Hashtable<String, String>();
    public boolean needShowResultPage = false;

    public FTVNavigatorWebClient(Activity activity, WebView webView) {
        this.activity = activity;
        this.webView = webView;

        Injector.inject(this);

        BUS.register(this); //FIXME: when should we unregister this, might leak?
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            String contents = data.getStringExtra("SCAN_RESULT");
        }
    }

    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
        super.onPageStarted(view, url, favicon);

        BUS.post(new PageStartedEvent());
    }

    @Override
    public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);

        BUS.post(new PageFinishedEvent());
    }


    @Override
    public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
        super.onReceivedError(view, errorCode, description, failingUrl);

        BUS.post(new ReceivedErrorEvent());
    }

    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String urlString) {
        Log.d(TAG, "TAB BAR URL - " + urlString);

        if (urlString.contains("target=_blank")) {
            openExternalBrowser(this.activity, urlString);
            return true;
        } else if (urlString.startsWith("inapp-http")) {
            String uri = urlString.replaceAll("inapp-http://", "");
            if (uri.startsWith("local/")) {
                webView.loadUrl("file:///android_asset/" + uri.replaceAll("local/", ""));
            } else {
                if (urlString.contains("scan/list.php")) {
                    webView.loadUrl("http://" + uri + "?deviceid=" + FTVUser.getID());
//                    view.requestFocus();
                } else {
                    webView.loadUrl("http://" + uri);
                }
            }
        } else if (urlString.contains(".action")) {
            if (urlString.contains("Camera")) {
                ((FTVMainActivity) activity).startActivityCamera();
            } else if (urlString.contains("Gallery")) {
                ((FTVMainActivity) activity).startActivityGallery();
            }
            return true;
        } else {
            // web client navigation
            if (urlString.equals(FTVConstants.urlHome)) {
//                [super setTitleNavigation:self];
                if (needShowResultPage) {
//                    [super setHomeCameraMenuNavigations:self];
                }
            } else if (urlString.indexOf(FTVConstants.urlCategoryNews) >= 0) {
//                [super setHomeCameraNavigations:self];
            } else if (urlString.indexOf(FTVConstants.urlCategoryMovie) >= 0) {
//                [super setHomeCameraNavigations:self];
            } else if (urlString.indexOf(FTVConstants.urlCategoryTopic) >= 0) {
//                [super setHomeCameraNavigations:self];
            } else if (urlString.indexOf(FTVConstants.urlFormSearch) >= 0) {
//                [super setHomeCameraMenuNavigations:self];
            } else {
                if (needShowResultPage) {
//                    [super setHomeCameraMenuNavigations:self];
                } else {
//                    [super setBackCameraNavigations:self];
                }
            }

            TestFlight.passCheckpoint(String.format("FTVNavigatorWebClient - redirect to %s", urlString));
            webView.loadUrl(urlString);
        }

        return false;
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


