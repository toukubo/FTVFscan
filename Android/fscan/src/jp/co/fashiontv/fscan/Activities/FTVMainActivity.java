package jp.co.fashiontv.fscan.Activities;

import java.io.IOException;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Camera.CameraActivity;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVNavigatorWebClient;
import jp.co.fashiontv.fscan.Common.FTVUser;
import jp.co.fashiontv.fscan.Common.PageFinishedEvent;
import jp.co.fashiontv.fscan.Common.PageStartedEvent;
import jp.co.fashiontv.fscan.Common.ReceivedErrorEvent;
import jp.co.fashiontv.fscan.Gaziru.GaziruSearchParams;
import jp.co.fashiontv.fscan.ImgProc.FTVImageProcEngine;
import jp.co.fashiontv.fscan.Utils.FTVUtil;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings.PluginState;
import android.webkit.WebView;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.testflightapp.lib.TestFlight;
import com.todddavies.components.progressbar.ProgressWheel;

//import com.todddavies.components.progressbar.ProgressWheel;

/**
 * Core business logic
 * <p/>
 * provide the universal webview for all of the web part display.
 */
public class FTVMainActivity extends BaseActivity {

	GaziruSearchParams gaziruSearchParams;

	ProgressWheel progressWheel;

	RelativeLayout maskView;

	private static String TAG = "FTVMainActivity";

	private Context mContext;
	private WebView mainWebView = null;
	private FTVNavigatorWebClient webViewClient = null;
	private ProgressDialog progressDialog;
	private Uri fileUri;

	private int stage = 0;

	public void setStage(int s) {
		this.stage = s;
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		String url = intent.getStringExtra("url");
		if (url!= null) {
			webViewClient.shouldOverrideUrlLoading(mainWebView, url);	
			//	showToast("onNewIntent");
		}


	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// requestWindowFeature(Window.FEATURE_NO_TITLE);

		//  setContentView(R.layout.activity_main);

		TestFlight.passCheckpoint("FTVMainActivity - onCreate");

		mContext = this;

		// assets/dic/subordinates is arrangement in local
		FTVUtil.assets2Local(this);


		setupWebView();
		setUpHeaderView();
		maskView = (RelativeLayout) findViewById(R.id.maskView);
		progressWheel = (ProgressWheel) findViewById(R.id.progressBar);
	}




	private void setUpHeaderView() {

		ImageView ivHome = (ImageView)findViewById(R.id.home);
		ImageView ivCamera  = (ImageView)findViewById(R.id.camera);


		ivCamera.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
			/*	Intent cameraIntent = new Intent(FTVMainActivity.this, CameraActivity.class);
				startActivity(cameraIntent);
*/
				startActivityCamera();
				
			}
		});

		ivHome.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {

				mainWebView.clearHistory();
				mainWebView.clearCache(true);
				webViewClient.shouldOverrideUrlLoading(mainWebView, FTVConstants.urlHome);

			}
		});



		lvMenuDrawerItems.setOnItemClickListener(new OnItemClickListener() {



			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position,
					long id) {

				switch (position) {
				case 0:

					webViewClient.shouldOverrideUrlLoading(mainWebView, tourUrl);
					slidingMenu.showContent();


					break;
				case 1:

					webViewClient.shouldOverrideUrlLoading(mainWebView, histroryUrl);
					slidingMenu.showContent();
					break;

				case 2:
					// code to open gallery


					Intent galleryIntent = new Intent(
							Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
					startActivityForResult(galleryIntent, FTVConstants.activityRequestCodeGallery);

					//startActivity(galleryIntent);
					slidingMenu.showContent();
					break;

				case 3:
					slidingMenu.showContent();
					webViewClient.shouldOverrideUrlLoading(mainWebView, brandUrl);
					break;
				default:
					break;
				}
			}



		});
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	private void setupWebView() {
		TestFlight.passCheckpoint("FTVMainActivity - setupWebView");
		Log.d(TAG, "UUID - " + FTVUser.getID());

		mainWebView = (WebView) findViewById(R.id.mainWebView);
		mainWebView.setInitialScale(100);
		mainWebView.setScrollBarStyle(WebView.SCROLLBARS_INSIDE_OVERLAY);
		mainWebView.getSettings().setJavaScriptEnabled(true);
		mainWebView.getSettings().setPluginState(PluginState.ON);
		webViewClient = new FTVNavigatorWebClient(this, mainWebView);
		mainWebView.setWebViewClient(webViewClient);
		mainWebView.setWebChromeClient(new WebChromeClient());
		webViewClient.shouldOverrideUrlLoading(mainWebView, FTVConstants.urlHome);
	}

	//    private boolean checkLoginCredential() {
	//        TestFlight.passCheckpoint("FTVMainActivity - checkLoginCredential");
	//
	//        String url = String.format("%s%s%s", FTVConstants.baseUrl, "registration/isRegistered.php?deviceid=", FTVUser.getID());
	//
	//        // start the progress dialog
	//        progressDialog = new ProgressDialog(this);
	//        progressDialog.setTitle(getString(R.string.info_title_check_credential));
	//        progressDialog.setMessage(getString(R.string.info_check_credential));
	//        progressDialog.setIndeterminate(true);
	//        progressDialog.setCancelable(false);
	//
	//        // start another thread to check credential
	//        AsyncHttpClient client = new AsyncHttpClient();
	//        client.setTimeout(FTVConstants.httpTimeout);
	//        client.get(url, new AsyncHttpResponseHandler() {
	//            @Override
	//            public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
	//                super.onSuccess(statusCode, headers, responseBody);
	//
	//                progressDialog.dismiss();
	//
	//                String resp = new String(responseBody);
	//                if (resp != null && resp.equals("true")) {
	//                    Log.d(TAG, "Device already registered!!");
	//                    setupWebView();
	//
	////                    startActivityCamera();
	//                } else {
	//                    showRegisterActivity();
	//                }
	//            }
	//
	//            @Override
	//            public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {
	//                super.onFailure(statusCode, headers, responseBody, error);
	//
	//                Log.d(TAG, "check credential failed");
	//
	//                progressDialog.dismiss();
	//            }
	//        });
	//
	//        return true;
	//    }

	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.d(TAG, "REQUEST CODE - " + requestCode);
		if (requestCode == FTVConstants.activityRequestCodeCamera) {
			// return from camera
			if (resultCode == RESULT_OK) {
				//Uri imageUri = data.getData();
				//String uri = getPath(imageUri);
				Bundle extras = data.getExtras();
				String uri = extras.getString("imageUri");
				gaziruSearchParams = new GaziruSearchParams(this, uri, null);
				if (uri != null) {
					new ImageSearchTask().execute(gaziruSearchParams);
				}
				// TODO: finish the camera activity
			} else if (resultCode == RESULT_CANCELED) {
				Log.d(TAG, "camera cancelled");
				// on camera screen, if you push the back hardware button, then the brands page should be displays.
				webViewClient.shouldOverrideUrlLoading(mainWebView, FTVConstants.urlBrands);
			} else {
				Log.e(TAG, "CAMERA - SHOULD NEVER REACH");
			}
		} else {
			
			if (requestCode == FTVConstants.activityRequestCodeGallery) {
				// return from camera
				if (resultCode == RESULT_OK) {
					Uri imageUri = data.getData();
					String systemIamgePath  = getPath(imageUri);
					String uri = null;
					try {
						uri = resizeImage(systemIamgePath);
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				
					gaziruSearchParams = new GaziruSearchParams(this, uri, null);
					if (uri != null) {
						new ImageSearchTask().execute(gaziruSearchParams);
					}
					// TODO: finish the camera activity
				} else if (resultCode == RESULT_CANCELED) {
					Log.d(TAG, "camera cancelled");
					// on camera screen, if you push the back hardware button, then the brands page should be displays.
				//	webViewClient.shouldOverrideUrlLoading(mainWebView, FTVConstants.urlBrands);
				} else {
					Log.e(TAG, "CAMERA - SHOULD NEVER REACH");
				}
			}
			// never reach
			
			
			Log.e(TAG, "onActivityResult SHOULD NEVER REACH");
		}

		super.onActivityResult(requestCode, resultCode, data);
	}


	@Override
	protected void onResume() {
		Log.d(TAG, "onResume");
		TestFlight.passCheckpoint("FTVMainActivity - onResume");

		super.onResume();

		//        if (stage == FTVConstants.activityRequestCodeCamera || stage == FTVConstants.activityRequestCodeGallery) {
		//            Log.d(TAG, "return from camera/gallery");
		//        } else {
		//            Log.d(TAG, "need register check");
		//            checkLoginCredential();
		//        }
	}
	
	
	


	/* @Override
    public void onBackPressed() {
        super.onBackPressed();

        Toast.makeText(FTVMainActivity.this, "back", Toast.LENGTH_SHORT).show();
    }
	 */

	// code for handling the back button

	

	// changes by ashu starts
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (event.getAction() == KeyEvent.ACTION_DOWN) {

			switch (keyCode) {
			case KeyEvent.KEYCODE_BACK:
				TestFlight.passCheckpoint("FTVWebViewActivity - onBackPressed");
				if (mainWebView.canGoBack() == true) {
					mainWebView.goBack();
				} else {
					finish();
				}
				return true;
			}

		}


		return super.onKeyDown(keyCode, event);
	}
	// changes by ashu ends

	/**
	 * @param event
	 */
	public void onPageStartedEvent(PageStartedEvent event) {
		Log.d(TAG, "onPageStartedEvent");
		maskView.setVisibility(View.VISIBLE);
		progressWheel.spin();
	}

	public void onPageFinishedEvent(PageFinishedEvent event) {
		Log.d(TAG, "onPageFinishedEvent");
		progressWheel.stopSpinning();
		maskView.setVisibility(View.GONE);
	}

	public void onReceivedErrorEvent(ReceivedErrorEvent event) {
		Log.d(TAG, "onReceivedErrorEvent");
		progressWheel.stopSpinning();
		maskView.setVisibility(View.GONE);
	}

	/**
	 * TODO: show register activity
	 */
	private void showRegisterActivity() {
		TestFlight.passCheckpoint("FTVMainActivity - showRegisterActivity");

		String registerUrl = String.format("%s%s%s%s", FTVConstants.baseUrl,
				"registration/index.php?deviceid=", FTVUser.getID(), "&device_type=android");

		Intent intent = new Intent(mContext, FTVWebViewActivity.class);
		intent.putExtra("url", registerUrl);
		startActivity(intent);
	}

	/**
	 * TODO: start custom camera here
	 */
	public void startActivityCamera() {
		TestFlight.passCheckpoint("FTVMainActivity - startActivityCamera");

		//        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
		//        fileUri = DeviceUtil.getOutputMediaFileUri(DeviceUtil.MEDIA_TYPE_IMAGE);
		//        intent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri);
		//
		//        setStage(FTVConstants.activityRequestCodeCamera);
		//        startActivityForResult(intent, FTVConstants.activityRequestCodeCamera);

		Intent intent = new Intent(this, CameraActivity.class);
		startActivityForResult(intent, FTVConstants.activityRequestCodeCamera);
	}

	// -------------------------- Async Task --------------------------

	/**
	 * Gaziru : image search task should never be executed from ui thread. Library has enabled the STRICT_MODE.
	 */
	private class ImageSearchTask extends AsyncTask<GaziruSearchParams, Void, String> {
		@Override
		protected void onPreExecute() {
			super.onPreExecute();

			maskView.setVisibility(View.VISIBLE);
			progressWheel.spin();
		}

		/**
		 * The system calls this to perform work in a worker thread and delivers
		 * it the parameters given to AsyncTask.execute()
		 */
		protected String doInBackground(GaziruSearchParams... params) {
			return FTVImageProcEngine.imageSearchProcess(params[0]);
		}

		/**
		 * The system calls this to perform work in the UI thread and delivers
		 * the result from doInBackground()
		 */
		protected void onPostExecute(String brandSlug) {
			progressWheel.stopSpinning();
			maskView.setVisibility(View.INVISIBLE);

			// exeute image post
			if (brandSlug != null) {
				Log.d(TAG, "Post image with brand slug - " + brandSlug);
				gaziruSearchParams.brandSlug = brandSlug;

				if (brandSlug == null || brandSlug.equals("failure")) {
					// show search form
					Intent is = new Intent(mContext, FTVWebViewActivity.class);
					String urlSearch = String.format("%s%s", FTVConstants.baseUrl, FTVConstants.urlSearch);
					is.putExtra("url", urlSearch);
					mContext.startActivity(is);
				} else {
					new ImagePostTask().execute(gaziruSearchParams);
				}
			}
		}
	}

	/**
	 * Gaziru : image search task should never be executed from ui thread. Library has enabled the STRICT_MODE.
	 */
	private class ImagePostTask extends AsyncTask<GaziruSearchParams, Void, Void> {
		@Override
		protected void onPreExecute() {
			super.onPreExecute();
			maskView.setVisibility(View.VISIBLE);
			progressWheel.spin();
		}

		/**
		 * The system calls this to perform work in a worker thread and delivers
		 * it the parameters given to AsyncTask.execute()
		 */
		protected Void doInBackground(GaziruSearchParams... params) {
			return FTVImageProcEngine.imagePostProcess(params[0]);
		}

		/**
		 * The system calls this to perform work in the UI thread and delivers
		 * the result from doInBackground()
		 */
		protected void onPostExecute() {
			progressWheel.stopSpinning();
			maskView.setVisibility(View.GONE);
		}
	}

	@Override
	public View getActivityLayout() {

		return getLayoutInflater().inflate(R.layout.activity_main, null);
	}
}
