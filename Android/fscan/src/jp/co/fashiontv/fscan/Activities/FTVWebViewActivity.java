package jp.co.fashiontv.fscan.Activities;

import android.app.Activity;
import android.os.Bundle;
import android.view.Window;
import android.webkit.WebView;
import com.testflightapp.lib.TestFlight;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVNavbarWebClient;
import jp.co.fashiontv.fscan.R;

/**
 * Created by Alsor Zhou on 13-11-9.
 */
public class FTVWebViewActivity extends Activity {
    WebView webView;
    String mUrl;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.layout_webview);

        TestFlight.passCheckpoint("FTVWebViewActivity - onCreate");

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
        webView.getSettings().setJavaScriptEnabled(true);

        webView.setWebViewClient(new FTVNavbarWebClient(this, webView));
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        TestFlight.passCheckpoint("FTVWebViewActivity - onBackPressed");

        finish();
    }
}
