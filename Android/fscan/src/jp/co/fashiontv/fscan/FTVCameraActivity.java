package jp.co.fashiontv.fscan;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.Window;
import jp.co.fashiontv.fscan.Common.StringUtil;
import jp.co.fashiontv.fscan.ImgProc.FTVImageProcEngine;

public class FTVCameraActivity extends Activity {
    private static String TAG = "FTVCameraActivity";

	final int CAMERA_RESULT = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		requestWindowFeature(Window.FEATURE_NO_TITLE);

		Intent intent = new Intent();
		intent.setAction("android.media.action.IMAGE_CAPTURE"); 
		startActivityForResult(intent, CAMERA_RESULT);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
		super.onActivityResult(requestCode, resultCode, intent);

		if (requestCode == CAMERA_RESULT && resultCode == RESULT_OK) {
            Bitmap originImage = (Bitmap) intent.getExtras().get("data");

            // resize image data
            Bitmap resizedImage = FTVImageProcEngine.imageResize(originImage, StringUtil.randomFilename(), true);

            // execute API in sync mode, call NEC stuff
            String brand_slug = FTVImageProcEngine.executeApi(this, resizedImage);
            Log.d(TAG, String.format("brand slug : %s", brand_slug));

            if (brand_slug.isEmpty()) {
                brand_slug = "GUCCI";
            }

            // image post to our server
            FTVImageProcEngine.postData(resizedImage, brand_slug);

            // show webview activity
            Intent is = new Intent(this, FTVWebViewActivity.class);
            startActivity(is);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

}
