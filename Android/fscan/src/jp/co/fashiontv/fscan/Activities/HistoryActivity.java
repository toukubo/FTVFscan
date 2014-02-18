package jp.co.fashiontv.fscan.Activities;

import java.util.ArrayList;
import java.util.List;

import com.testflightapp.lib.TestFlight;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Activities.adapter.HistoryAdapter;
import jp.co.fashiontv.fscan.Camera.CameraActivity;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Database.DatabaseHandler;
import jp.co.fashiontv.fscan.Logic.SearchLogic;
import jp.co.fashiontv.fscan.Utils.History;
import jp.co.fashiontv.fscan.View.CameraView;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.AdapterView.OnItemClickListener;

public class HistoryActivity extends BaseActivity {

	private static final String TAG = "CameraActivity";
	/** カメラビュー */
	private CameraView cameraView = null;
	/** 結果領域 */
	private RelativeLayout resultView = null;
	/** 認証済みフラグ */
	private boolean isAuthed = false;
	/** アプリケーションコンテキスト */
	private Context mContext = null;
	/** 画像識別ロジックインスタンス */
	private SearchLogic mSearchLogic = null;
	/** クエリ画像 */
	private Bitmap queryImageBMP = null;
	/** クリック済みフラグ */
	private boolean isClicked = false;

	HistoryAdapter adapter;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		mContext = getApplicationContext();

		setUpHeaderView();
		setUpSlidingView();

		ListView lv = (ListView) findViewById(R.id.history);
		ArrayList<History> imageArry = new ArrayList<History>();
		DatabaseHandler db = new DatabaseHandler(this);
		List<History> histories = db.getAllContacts();
		for (History cn : histories) {
			String log = "ID:" + cn.getID() + " Name: " + cn.getName()
					+ " ,Image: " + cn.getImage();

			// Writing Contacts to log
			Log.d("Result: ", log);
			// add contacts data in arrayList
			imageArry.add(cn);

		}
		adapter = new HistoryAdapter(this, R.layout.history_row, imageArry);
		lv.setAdapter(adapter);

	}

	@Override
	public View getActivityLayout() {
		// TODO Auto-generated method stub

		return getLayoutInflater().inflate(R.layout.history, null);
	}

	// View Helper
	/**
	 * Fixed navigation bar
	 */
	private void setUpHeaderView() {
		camera.setVisibility(View.VISIBLE);
		home.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				moveToNextActivity(FTVConstants.urlHome);
			}
		});
		camera.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				startActivityCamera();
			}
		});

	}

	private void setUpSlidingView() {
		lvMenuDrawerItems.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {

				switch (position) {
				case 0:
					slidingMenu.showContent();
					moveToNextActivity(tourUrl);
					break;
				case 1:
					slidingMenu.showContent();
					Intent historyIntent = new Intent(HistoryActivity.this,
							HistoryActivity.class);
					startActivity(historyIntent);
					finish();
					break;
				case 2:
					// code to open gallery
					// moveToNextActivity(tourUrl);
					Intent galleryIntent = new Intent(
							Intent.ACTION_PICK,
							android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
					startActivityForResult(galleryIntent,
							FTVConstants.activityRequestCodeGallery);
					slidingMenu.showContent();
					break;
				case 3:
					slidingMenu.showContent();
					moveToNextActivity(brandUrl);
					break;
				default:
					break;
				}
			}
		});
	}

	private void moveToNextActivity(String url) {
		Intent intent = new Intent(HistoryActivity.this, FTVMainActivity.class);
		intent.putExtra("url", url);
		startActivity(intent);
	}

	/**
	 * Start custom camera here
	 */
	public void startActivityCamera() {
		TestFlight.passCheckpoint("FTVMainActivity - startActivityCamera");
		Intent intent = new Intent(this, CameraActivity.class);
		startActivityForResult(intent, FTVConstants.activityRequestCodeCamera);
	}

}
