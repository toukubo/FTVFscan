package jp.co.fashiontv.fscan.Activities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.Window;
import jp.co.fashiontv.fscan.R;

public class SplashActivity extends Activity {
	private static final int SPLASHTIME = 5;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_splash);
		Handler hdl = new Handler();
		hdl.postDelayed(new splashHandler(), SPLASHTIME * 1000);
	}
	class splashHandler implements Runnable {
		public void run() {
			Intent intent = new Intent(getApplication(), MainActivity.class);
			startActivity(intent);
			SplashActivity.this.finish();
		}
	}
}
