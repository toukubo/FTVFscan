package jp.co.fashiontv.fscan;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.Window;

public class SplashActivity extends Activity {
	private static final int SPLASHTIME = 3;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// タイトルを非表示にします。
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		// splash.xmlをViewに指定します。
		setContentView(R.layout.activity_splash);
		Handler hdl = new Handler();
		// 500ms遅延させてsplashHandlerを実行します。
		hdl.postDelayed(new splashHandler(), SPLASHTIME * 1000);
	}
	class splashHandler implements Runnable {
		public void run() {
			// スプラッシュ完了後に実行するActivityを指定します。
			Intent intent = new Intent(getApplication(), MainActivity.class);
			startActivity(intent);
			// SplashActivityを終了させます。
			SplashActivity.this.finish();
		}
	}
}
