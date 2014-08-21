package jp.co.fashiontv.fscan.Activities;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Camera.CameraActivity;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVNavigatorWebClient;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView;

import com.jeremyfeinstein.slidingmenu.lib.SlidingMenu;
import com.testflightapp.lib.TestFlight;

/**
 * Created by Alsor Zhou on 13-11-9.
 */
public class FTVWebViewActivity extends BaseActivity {
	WebView webView;
	String mUrl;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// requestWindowFeature(Window.FEATURE_NO_TITLE);
		// setContentView(R.layout.layout_webview);

		TestFlight.passCheckpoint("FTVWebViewActivity - onCreate");

		Bundle extras = getIntent().getExtras();

		if (extras != null) {
			mUrl = extras.getString("url");
		}

		setUpSlidingView();

		ImageView ivHome = (ImageView) findViewById(R.id.home);
		ImageView camera = (ImageView) findViewById(R.id.camera);
		ivHome.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				moveToNextActivity(FTVConstants.urlHome);

			}
		});
		camera.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				startActivityCamera();
			}
		});

		setupWebView();
	}

	private void setUpSlidingView() {
		slidingMenu.setTouchModeAbove(SlidingMenu.TOUCHMODE_NONE);
		lvMenuDrawerItems.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {

				switch (position) {
				case 0:
					moveToNextActivity(tourUrl);
					slidingMenu.showContent();

					break;
				case 1:
					moveToNextActivity(histroryUrl);
					slidingMenu.showContent();
					break;

				case 2:
					// code to open gallery
					// moveToNextActivity(tourUrl);
					slidingMenu.showContent();
					break;

				case 3:

					moveToNextActivity(brandUrl);
					slidingMenu.showContent();
					break;

				default:
					break;
				}
			}

		});
	}

	private void moveToNextActivity(String url) {

		Intent intent = new Intent(FTVWebViewActivity.this,
				FTVMainActivity.class);
		intent.putExtra("url", url);
		startActivity(intent);
		finish();

	}

	private void setupWebView() {
		String url = FTVConstants.urlHome;

		if (mUrl != null && !mUrl.isEmpty()) {
			url = mUrl;
		}
		webView = (WebView) findViewById(R.id.webview);
		webView.loadUrl(url);
		webView.getSettings().setJavaScriptEnabled(true);
		webView.setWebViewClient(new FTVNavigatorWebClient(this, webView));
	}

	// @Override
	// public void onBackPressed() {
	// super.onBackPressed();
	// TestFlight.passCheckpoint("FTVWebViewActivity - onBackPressed");
	//
	// finish();
	// }
	@Override
	public void onBackPressed() {
		if (webView.canGoBack() == true) {
			webView.goBack();
		} else {
			super.onBackPressed();
		}
	}

	@Override
	public View getActivityLayout() {

		return getLayoutInflater().inflate(R.layout.layout_webview, null);
	}

	/**
	 * // * Start custom camera here //
	 */
	public void startActivityCamera() {
		TestFlight.passCheckpoint("FTVMainActivity - startActivityCamera");

		Intent intent = new Intent(this, CameraActivity.class);
		startActivityForResult(intent, FTVConstants.activityRequestCodeCamera);
	}

}
