package jp.co.fashiontv.fscan.Activities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.webkit.WebView;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.AdapterView.OnItemClickListener;

import com.testflightapp.lib.TestFlight;

import jp.co.fashiontv.fscan.Camera.CameraActivity;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVNavigatorWebClient;
import jp.co.fashiontv.fscan.R;

/**
 * Created by Alsor Zhou on 13-11-9.
 */
public class FTVWebViewActivity extends BaseActivity {
    WebView webView;
    String mUrl;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //requestWindowFeature(Window.FEATURE_NO_TITLE);
        //setContentView(R.layout.layout_webview);

        TestFlight.passCheckpoint("FTVWebViewActivity - onCreate");

        Bundle extras = getIntent().getExtras();

        if (extras != null) {
            mUrl = extras.getString("url");
        }
        
        setUpSlidingView();

        ImageView ivHome = (ImageView)findViewById(R.id.home);
        ivHome.setOnClickListener(new OnClickListener() {
		 
        	@Override
			public void onClick(View v) {
				moveToNextActivity(FTVConstants.urlHome);
 
			}
		});
        
        
        
       setupWebView();
    }

    
    
    private void setUpSlidingView() {
    	lvMenuDrawerItems.setOnItemClickListener(new OnItemClickListener() {

			
			 
			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position,
					long id) {
				 
				switch (position) {
				case 0:
					moveToNextActivity(tourUrl);
					break;
				case 1:
					moveToNextActivity(histroryUrl);
					break;

				case 2:
					 // code to open gallery
					//moveToNextActivity(tourUrl);
					break;

				case 3:
					 
					moveToNextActivity(brandUrl);
					break;

					
					
				default:
					break;
				}
			}


			
		});
	}

	private void moveToNextActivity(String url) {

		Intent intent = new Intent(FTVWebViewActivity.this, FTVMainActivity.class);
		intent.putExtra("url",url);
		startActivity(intent);


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

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        TestFlight.passCheckpoint("FTVWebViewActivity - onBackPressed");

        finish();
    }

	@Override
	public View getActivityLayout() {
		
		return getLayoutInflater().inflate(R.layout.layout_webview, null);
	}
}
