package jp.co.fashiontv.fscan;

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
import android.webkit.WebView;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import jp.co.fashiontv.fscan.Common.*;
import jp.co.fashiontv.fscan.ImgProc.FTVImageProcEngine;
import org.apache.http.Header;


public class MainActivity extends Activity {

    private static String TAG = "MainActivity";

    private Context mContext;
    private WebView mainWebView = null;
    private FTVNavbarWebClient webViewClient = null;
    private ProgressDialog progressDialog;
    private Uri fileUri;

    private int stage = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);

        setContentView(R.layout.activity_main);

        mContext = this;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    private void setupWebView() {
        mainWebView = (WebView) findViewById(R.id.main);
//        mainWebView.loadUrl(FTVConstants.urlHome);
        mainWebView.setWebViewClient(new FTVMainWebClient(this));
        mainWebView.getSettings().setJavaScriptEnabled(true);
        WebView tabbarWebView = (WebView) findViewById(R.id.navigation);
        tabbarWebView.setInitialScale(100);
        tabbarWebView.setScrollBarStyle(WebView.SCROLLBARS_INSIDE_OVERLAY);
        tabbarWebView.getSettings().setJavaScriptEnabled(true);
        webViewClient = new FTVNavbarWebClient(this, mainWebView);
        tabbarWebView.setWebViewClient(webViewClient);

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

                    startActivityCamera();
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
//                    FTVImageProcEngine.commonProcess(this, fileUri);
                    new CommonProcessTask().execute(new SearchParams(this, fileUri));
                }
            } else if (resultCode == RESULT_CANCELED) {
                //TODO: what should do when user cancelled the camera
                Log.d(TAG, "camera cancelled");
            } else {
                Log.e(TAG, "CAMERA - SHOULD NEVER REACH");
            }
        } else if (requestCode == FTVConstants.activityRequestCodeGallery) {
            // return from gallery
            if (resultCode == RESULT_OK) {
                fileUri = data.getData();
                if (fileUri != null) {
//                    FTVImageProcEngine.commonProcess(this, fileUri);
                    new CommonProcessTask().execute(new SearchParams(this, fileUri));
                }
            } else if (resultCode == RESULT_CANCELED) {
                //TODO: what should do when user cancelled the gallery
                Log.d(TAG, "gallery cancelled");
            } else {
                Log.e(TAG, "GALLERY - SHOULD NEVER REACH");
            }
        } else {
            // never reach
        }

        super.onActivityResult(requestCode, resultCode, data);
    }


    @Override
    protected void onResume() {
        super.onResume();

        if (stage == FTVConstants.activityRequestCodeCamera || stage == FTVConstants.activityRequestCodeGallery) {
            Log.d(TAG, "return from camera/gallery");
        } else {
            Log.d(TAG, "need register check");
            checkLoginCredential();
        }

        Log.d(TAG, "onResume");
    }

    private void showRegisterActivity() {
        String registerUrl = String.format("%s%s%s%s", FTVConstants.baseUrl,
            "registration/index.php?deviceid=", FTVUser.getID(), "&device_type=android");

        Intent intent = new Intent(mContext, FTVWebViewActivity.class);
        intent.putExtra("url", registerUrl);
        startActivity(intent);
    }

    public void setStage(int s) {
        this.stage = s;
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

    private class CommonProcessTask extends AsyncTask<SearchParams, Void, Void> {
        /**
         * The system calls this to perform work in a worker thread and delivers
         * it the parameters given to AsyncTask.execute()
         */
        protected Void doInBackground(SearchParams... params) {
            return FTVImageProcEngine.commonProcess(params[0]);
        }


        /**
         * The system calls this to perform work in the UI thread and delivers
         * the result from doInBackground()
         */
        protected void onPostExecute() {
        }
    }
}
