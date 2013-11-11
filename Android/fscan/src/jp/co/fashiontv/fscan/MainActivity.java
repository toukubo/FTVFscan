package jp.co.fashiontv.fscan;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.Window;
import android.webkit.WebView;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVMainWebClient;
import jp.co.fashiontv.fscan.Common.FTVNavbarWebClient;
import jp.co.fashiontv.fscan.Common.FTVUser;
import org.apache.http.Header;

public class MainActivity extends Activity {

    private static String TAG = "MainActivity";

    private Context mContext;

    WebView mainWebView = null;
    FTVNavbarWebClient webViewClient = null;
    private ProgressDialog progressDialog;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);

        setContentView(R.layout.activity_main);

        mContext = this;

        checkLoginCredential();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    private void setupWebView() {
        mainWebView = (WebView) findViewById(R.id.main);
        mainWebView.loadUrl(FTVConstants.urlHome);
        mainWebView.setWebViewClient(new FTVMainWebClient());

        WebView tabbarWebView = (WebView) findViewById(R.id.navigation);
        tabbarWebView.setInitialScale(100);
        tabbarWebView.setScrollBarStyle(WebView.SCROLLBARS_INSIDE_OVERLAY);
        tabbarWebView.getSettings().setJavaScriptEnabled(true);
        webViewClient = new FTVNavbarWebClient(this, mainWebView);
        tabbarWebView.setWebViewClient(webViewClient);

        webViewClient.shouldOverrideUrlLoading(tabbarWebView, "http://zxc.cz/fscan-local-ui/navigation.html");

        Log.d(TAG, "UUID - " + FTVUser.getID());
    }

    private boolean checkLoginCredential() {
        String url = String.format("%s%s%s", FTVConstants.baseUrl, "registration/isRegistered.php?deviceid=", FTVUser.getID());

        // start the progress dialog
        progressDialog = new ProgressDialog(this);
        progressDialog.setTitle(getString(R.string.info_title_check_credential));
        progressDialog.setMessage(getString(R.string.info_check_credential));
        progressDialog.setIndeterminate(true);
        progressDialog.setCancelable(false);

        // start another thread to check credential
        AsyncHttpClient client = new AsyncHttpClient();
        client.setTimeout(FTVConstants.httpTimeout);
        client.get(url, new AsyncHttpResponseHandler() {
            @Override
            public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                super.onSuccess(statusCode, headers, responseBody);

                progressDialog.dismiss();

                String resp = new String(responseBody);
                if (resp != null && resp.equals("true")) {
                    Log.d(TAG, "Device already registered!!");
                    setupWebView();

//                    new MethodCall("FTVCameraActivity", MainActivity.this);
                } else {
                    showRegisterActivity();
                }
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {
                super.onFailure(statusCode, headers, responseBody, error);

                Log.d(TAG, "check credential failed");

                progressDialog.dismiss();
            }
        });

        return true;
    }

    private void showRegisterActivity() {
        String registerUrl = String.format("%s%s%s%s", FTVConstants.baseUrl, "registration/index.php?deviceid=", FTVUser.getID(), "&device_type=android");

        Intent intent = new Intent(mContext, FTVWebViewActivity.class);
        intent.putExtra("url", registerUrl);
        startActivity(intent);
    }
}
