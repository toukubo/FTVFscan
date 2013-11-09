package jp.co.fashiontv.fscan;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Window;
import jp.co.fashiontv.fscan.ImgProc.DamyGaziring;
import jp.co.fashiontv.fscan.Utils.BitmapUtil;

public class FTVGalleryActivity extends Activity{

	private static final int REQUEST_GALLERY = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		requestWindowFeature(Window.FEATURE_NO_TITLE);

		setContentView(R.layout.activity_main);
		Intent intent = new Intent();  
		intent.setType("image/*");
		intent.setAction(Intent.ACTION_GET_CONTENT);
		startActivityForResult(intent, REQUEST_GALLERY);
		
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode,
			Intent intent) {
		super.onActivityResult(requestCode, resultCode, intent);
		if (requestCode == REQUEST_GALLERY && resultCode == RESULT_OK) {
			byte[] imgData = BitmapUtil.getImageBytes(intent);
			DamyGaziring damyGaziring = new DamyGaziring("http://fashiontv.co.jp", this);
			//				Gaziring gaziring = new Gaziring(this, imgData);
		}
	}

}
