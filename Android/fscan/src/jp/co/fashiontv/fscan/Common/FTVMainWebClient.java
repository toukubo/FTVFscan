package jp.co.fashiontv.fscan.Common;

import android.net.Uri;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * Created by Alsor Zhou on 13-11-11.
 */

/**
 * Application view was mainly divided to two parts - Main View, and Navbar View (tab bar)
 *
 * This class controls the main view web url redirection
 */
public class FTVMainWebClient extends WebViewClient {
    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        if (shouldNavigateInApp(url)) {
            // Do not override; let WebView load the page
            return false;
        }

        return true;
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
