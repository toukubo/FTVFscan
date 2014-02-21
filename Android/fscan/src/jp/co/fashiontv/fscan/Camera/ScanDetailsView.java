package jp.co.fashiontv.fscan.Camera;

import jp.co.fashiontv.fscan.R;
import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class ScanDetailsView extends Activity {

	private WebView webView;
	private ProgressDialog progressDialog;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.scandetail_layout);
		webView = (WebView) findViewById(R.id.webview);
		String url = "http://zxc.cz/fdbdev/nec_mwc2014_0000?hogehoge";
		webView.getSettings().setLoadsImagesAutomatically(true);
		webView.getSettings().setJavaScriptEnabled(true);
		webView.setWebViewClient(new webviewClient());
		webView.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
		webView.loadUrl(url);
	}

	private class webviewClient extends WebViewClient {
		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url) {
			view.loadUrl(url);
			return true;
		}
		@Override
		public void onLoadResource (WebView view, String url) {
            if (progressDialog == null) {
                progressDialog = new ProgressDialog(ScanDetailsView.this);
                progressDialog.setMessage("Loading...");
                progressDialog.show();
            }
        }
        public void onPageFinished(WebView view, String url) {
            if (progressDialog.isShowing()) {
                progressDialog.dismiss();
                progressDialog = null;
            }
        }
	}
}
