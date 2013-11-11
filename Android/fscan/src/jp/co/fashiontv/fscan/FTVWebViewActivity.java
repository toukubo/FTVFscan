package jp.co.fashiontv.fscan;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebView;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVShareWebClient;

/**
 * Created by Alsor Zhou on 13-11-9.
 */
public class FTVWebViewActivity extends Activity {
    WebView webView;
    String mUrl;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.layout_webview);


        Bundle extras = getIntent().getExtras();

        if (extras != null) {
            mUrl = extras.getString("url");
        }

        setupWebView();
    }

    private void setupWebView() {
        String url = FTVConstants.urlHome;

        if (mUrl != null && !mUrl.isEmpty()) {
            url = mUrl;
        }
        webView = (WebView) findViewById(R.id.webview);
        webView.loadUrl(url);
        webView.setWebViewClient(new FTVShareWebClient(this, webView));
    }

    /**
     * Load specific url
     *
     * @param url
     */
    public void loadUrl(String url) {
        if (webView != null) {
            webView.loadUrl(url);
        }
    }
}
