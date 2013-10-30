package jp.co.fashiontv.fscan;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.Window;
import android.webkit.WebView;
import android.widget.LinearLayout;

public class MainActivity extends Activity {

	WebView webView = null;
	OurWebClient webViewClient = null;


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		requestWindowFeature(Window.FEATURE_NO_TITLE);
//		LinearLayout linearLayout = new LinearLayout(this);
		setContentView(R.layout.activity_main);
		webView = (WebView) findViewById(R.id.main);;
		webView.loadUrl("http://fashiontv.co.jp");
		webViewClient = new OurWebClient(this,webView);

		WebView navWebView = (WebView) findViewById(R.id.navigation);
		navWebView.setInitialScale(100);
		navWebView.setScrollBarStyle(WebView.SCROLLBARS_INSIDE_OVERLAY);
		navWebView.getSettings().setJavaScriptEnabled(true);
		navWebView.setWebViewClient(webViewClient);

		webViewClient.shouldOverrideUrlLoading(navWebView, "file:///android_asset/navigation.html");

//		new MethodCall("Camera", this);

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

}
