package jp.co.fashiontv.fscan.Activities;

import jp.co.fashiontv.fscan.Common.*;
import jp.co.fashiontv.fscan.ImgProc.FTVImageProcEngine;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Utils.DeviceUtil;
import jp.co.fashiontv.fscan.Utils.FTVUtil;
import org.apache.http.Header;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Menu;
import android.view.Window;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings.PluginState;
import android.webkit.WebView;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;


public class MainActivity extends Activity {

    private static String TAG = "MainActivity";

    private Context mContext;
    private WebView mainWebView = null;
    private FTVNavbarWebClient webViewClient = null;
    private ProgressDialog progressDialog;
    private Uri fileUri;

    private int stage = 0;
    public void setStage(int s) {
        this.stage = s;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);

        setContentView(R.layout.activity_main);

        mContext = this;

        // assets/dic/subordinates is arrangement in local
        FTVUtil.assets2Local(this);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    private void setupWebView() {
        mainWebView = (WebView) findViewById(R.id.main);
        mainWebView.setWebViewClient(new FTVMainWebClient(this));
        mainWebView.getSettings().setJavaScriptEnabled(true);
        mainWebView.getSettings().setPluginState(PluginState.ON);
        mainWebView.setWebChromeClient(new WebChromeClient());

        WebView tabbarWebView = (WebView) findViewById(R.id.navigation);
        tabbarWebView.setInitialScale(100);
        tabbarWebView.setScrollBarStyle(WebView.SCROLLBARS_INSIDE_OVERLAY);
        tabbarWebView.getSettings().setJavaScriptEnabled(true);
        webViewClient = new FTVNavbarWebClient(this, mainWebView);
        tabbarWebView.setWebViewClient(webViewClient);
        tabbarWebView.setWebChromeClient(new WebChromeClient());


        webViewClient.shouldOverrideUrlLoading(tabbarWebView, "http://zxc.cz/fscan-local-ui/navigation.html");
        webViewClient.shouldOverrideUrlLoading(mainWebView, FTVConstants.urlHome);

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

// FIXME: test purpose
//                    startActivityCamera();
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

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d(TAG, "REQUEST CODE - " + requestCode);
        if (requestCode == FTVConstants.activityRequestCodeCamera) {
            // return from camera
            if (resultCode == RESULT_OK) {
                if (fileUri != null) {
                    new CommonProcessTask().execute(new GaziruSearchParams(this, fileUri));
                }
            } else if (resultCode == RESULT_CANCELED) {
                Log.d(TAG, "camera cancelled");
                // on camera screen, if you push the back hardware button, then the brands page should be displays.
                webViewClient.shouldOverrideUrlLoading(mainWebView, FTVConstants.urlBrands);
            } else {
                Log.e(TAG, "CAMERA - SHOULD NEVER REACH");
            }
        } else if (requestCode == FTVConstants.activityRequestCodeGallery) {
            // return from gallery
            if (resultCode == RESULT_OK) {
                fileUri = data.getData();
                if (fileUri != null) {
                    new CommonProcessTask().execute(new GaziruSearchParams(this, fileUri));
                }
            } else if (resultCode == RESULT_CANCELED) {
                Log.d(TAG, "gallery cancelled");
                // on camera screen, if you push the back hardware button, then the brands page should be displays.
                webViewClient.shouldOverrideUrlLoading(mainWebView, FTVConstants.urlBrands);
            } else {
                Log.e(TAG, "GALLERY - SHOULD NEVER REACH");
            }
        } else {
            // never reach
            Log.e(TAG, "onActivityResult SHOULD NEVER REACH");
        }

        super.onActivityResult(requestCode, resultCode, data);
    }


    @Override
    protected void onResume() {
        Log.d(TAG, "onResume");

        super.onResume();

        if (stage == FTVConstants.activityRequestCodeCamera || stage == FTVConstants.activityRequestCodeGallery) {
            Log.d(TAG, "return from camera/gallery");
        } else {
            Log.d(TAG, "need register check");
            checkLoginCredential();
        }
    }

    private void showRegisterActivity() {
        String registerUrl = String.format("%s%s%s%s", FTVConstants.baseUrl,
            "registration/index.php?deviceid=", FTVUser.getID(), "&device_type=android");

        Intent intent = new Intent(mContext, FTVWebViewActivity.class);
        intent.putExtra("url", registerUrl);
        startActivity(intent);
    }


    public void startActivityGallery() {
        Intent intent = new Intent();
        intent.setType("image/*");
        intent.setAction(Intent.ACTION_GET_CONTENT);

        setStage(FTVConstants.activityRequestCodeGallery);
        startActivityForResult(intent, FTVConstants.activityRequestCodeGallery);
    }

    public void startActivityCamera() {
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        fileUri = DeviceUtil.getOutputMediaFileUri(DeviceUtil.MEDIA_TYPE_IMAGE);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri);

        setStage(FTVConstants.activityRequestCodeCamera);
        startActivityForResult(intent, FTVConstants.activityRequestCodeCamera);
    }

    /**
     * Gaziru : image search task should never be executed from ui thread. Library has enabled the STRICT_MODE.
     */
    private class CommonProcessTask extends AsyncTask<GaziruSearchParams, Void, Void> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            // TODO: show HUD or whatever to tell user progress
        }

        /**
         * The system calls this to perform work in a worker thread and delivers
         * it the parameters given to AsyncTask.execute()
         */
        protected Void doInBackground(GaziruSearchParams... params) {
            return FTVImageProcEngine.commonProcess(params[0]);
        }

        /**
         * The system calls this to perform work in the UI thread and delivers
         * the result from doInBackground()
         */
        protected void onPostExecute() {
            // TODO: dismiss HUD or whatever to tell user progress
        }
    }
}
