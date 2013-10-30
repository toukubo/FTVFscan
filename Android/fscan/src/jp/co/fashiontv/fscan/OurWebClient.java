package jp.co.fashiontv.fscan;

import java.io.IOException;
import java.io.InputStream;
import java.util.Hashtable;
import java.util.Iterator;

import org.apache.commons.io.IOUtils;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.CountDownTimer;
import android.util.Log;
import android.view.KeyEvent;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

public class OurWebClient extends WebViewClient{
	String hash = "jio00f7z";
	Activity activity = null;
	WebView webView;
	public static final int REQUEST_CODE = 0;
	public static final int QR_REQUEST_CODE = 1;

	private Hashtable<String, String> attributeSet = new Hashtable<String, String>();


	OurWebClient(Activity activity, WebView webView){
		this.activity = activity;
		this.webView = webView;
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if( requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK){
			String contents = data.getStringExtra("SCAN_RESULT");
		}
	}

	public boolean shouldOverrideUrlLoading(WebView view, String url) {
		if(url.startsWith("inapp-http")){
			String uri = url.replaceAll("inapp-http://", "");
			if(uri.startsWith("local/")){
				webView.loadUrl("file:///android_asset/"+uri.replaceAll("local/", ""));
			}else{
				webView.loadUrl("http://"+uri);
			}
		}else if(url.contains(".action")){
			//              view.clearView();
			String[] paramsets = url.split("\\?");
			String actionuri = paramsets[0];
			String file = "";
			for (int i = 1; i < paramsets.length; i++) {
				String name = paramsets[i].split("=")[0];
				String value = paramsets[i].split("=")[1];
				if(name.equals("file")){
					file = value;
				}
			}

			//              view.loadData("<html><body bgcolor='black'></body></html> ", "text/html", "utf-8");
			String action = actionuri.replace(".action", "");
			action = action.split("/")[url.split("/").length-1];
			action = action.replaceAll("file:///android_asset/", "");
			new MethodCall(action, activity);

			Log.v("fscan", "========== the url loaded: E" + url);
		}else if(url.contains(".ahtml")){
			String thefile = url.replace(".ahtml", "");
			thefile = thefile.replaceAll("file:///android_asset/", "");

			try {
				setData(thefile);
				InputStream is = this.activity.getAssets().open(thefile+".ahtml");
				String thehtml = IOUtils.toString(is);
				for (Iterator iterator = this.attributeSet.keySet().iterator(); iterator.hasNext();) {
					String key = (String) iterator.next();
					String value = this.attributeSet.get(key);
					thehtml = thehtml.replaceAll("\\$\\{"+key+"\\}", value);
				}
				view.loadDataWithBaseURL("file:///android_asset/",thehtml, "text/html", "UTF-8",null);
				//                  view.loadData(thehtml, "text/html", "utf-8");
				return true;

			} catch (IOException e) {
				e.printStackTrace();
			}
		}else{
			view.loadUrl(url);
			view.requestFocus();

		}
		return true;
	}

	public boolean shouldOverrideKeyEvent(WebView view, KeyEvent event) {
		Log.v("evaid", String.valueOf(event.getKeyCode()));
		return true;
	}

	public void setData(String action){
		if(action.equals("score")){
		}
	}
	public void onPageStarted (WebView view, String url, Bitmap favicon){
		Log.v("theurl", "========== the url loaded: E" + url);
		view.requestFocus();

	}

	public  void setAttribute(String string, String string2) {
		Hashtable<String, String> hashtable = this.attributeSet;
		hashtable.put(string, string2);
	}

}

