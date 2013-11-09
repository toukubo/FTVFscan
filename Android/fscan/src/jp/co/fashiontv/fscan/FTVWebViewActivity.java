package jp.co.fashiontv.fscan;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebView;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVShareWebClient;

/**
 * Created by veiz on 13-11-9.
 */
public class FTVWebViewActivity extends Activity {
    WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.layout_webview);

        setupWebView();
    }

    private void setupWebView() {
        webView = (WebView) findViewById(R.id.webview);
        webView.loadUrl(FTVConstants.urlHome);

        webView.setWebViewClient(new FTVShareWebClient(this, webView));
    }
}
