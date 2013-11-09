package jp.co.fashiontv.fscan;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.Window;
import jp.co.fashiontv.fscan.Utils.BitmapUtil;

public class FTVCameraActivity extends Activity {
	final int CAMERA_RESULT = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		requestWindowFeature(Window.FEATURE_NO_TITLE);

//		setContentView(R.layout.activity_main);
		Intent intent = new Intent();  
		intent.setAction("android.media.action.IMAGE_CAPTURE"); 
		startActivityForResult(intent, CAMERA_RESULT);

	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
		super.onActivityResult(requestCode, resultCode, intent);

		if (requestCode == CAMERA_RESULT && resultCode == RESULT_OK) {
			byte[] imgData = BitmapUtil.getImageBytes(intent);

            // TODO: resize image data

            // TODO: execute API in sync mode, call NEC stuff

            // TODO: image post to our server

            // TODO: show webview activity

            Intent is = new Intent(this, FTVWebViewActivity.class);
            startActivity(is);
//			DamyGaziring damyGaziring = new DamyGaziring("http://fashiontv.co.jp", this);
            // damyGaziring.
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

}
