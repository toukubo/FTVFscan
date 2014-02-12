package jp.co.fashiontv.fscan.Activities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.Window;

import com.bugsense.trace.BugSenseHandler;
import com.testflightapp.lib.TestFlight;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.R;

/**
 * Splash screen like iOS launcher page
 */
public class FTVSplashActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// code for adding bugsence
		BugSenseHandler.initAndStartSession(FTVSplashActivity.this, "9ba8ee51");
		
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_splash);

        TestFlight.passCheckpoint("FTVSplashActivity - onCreate");

        Handler hdl = new Handler();
		hdl.postDelayed(new splashHandler(), FTVConstants.splashScreenTimeout * 1000);
	}

	class splashHandler implements Runnable {
		public void run() {
			Intent intent = new Intent(getApplication(), FTVMainActivity.class);
			startActivity(intent);
			FTVSplashActivity.this.finish();
		}
	}
}
