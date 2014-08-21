package jp.co.fashiontv.fscan.Camera;

import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Activities.BaseActivity;
import jp.co.fashiontv.fscan.Activities.FTVMainActivity;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Database.DatabaseHandler;
import jp.co.fashiontv.fscan.Listener.CameraViewListener;
import jp.co.fashiontv.fscan.Logic.AuthLogic;
import jp.co.fashiontv.fscan.Logic.SearchLogic;
import jp.co.fashiontv.fscan.View.CameraView;
import jp.co.nec.gazirur.rtsearch.lib.bean.SearchResult;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.testflightapp.lib.TestFlight;

/**
 * Created by GAZIRU Developer on 14/01/21
 * 
 * Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
 * 
 * @author Alsor Zhou
 */
public class CameraActivity extends BaseActivity implements CameraViewListener {
	public ProgressDialog progressDialog;

	private static final String TAG = "CameraActivity";
	/** ������������������ */
	private CameraView cameraView = null;
	/** ������������ */
	private RelativeLayout resultView = null;
	/** ��������������������� */
	private boolean isAuthed = false;
	/** ������������������������������������������ */
	Context mContext = null;
	/** ������������������������������������������ */
	private SearchLogic mSearchLogic = null;
	/** ��������������� */
	Bitmap queryImageBMP = null;
	/** ��������������������������� */
	boolean isClicked = false;
	private ImageView imageView;


	TextView resultText2;
	String brand_slug = "";

	// private GaziruSearchParams gaziruSearchParams;

	/** ��������������������� */
	ProgressBar mProgressBar;
	private OnClickListener ResultTextClickListener = null;
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		mContext = getApplicationContext();

		// ������������������
		resultView = (RelativeLayout) findViewById(R.id.result_view);
		// ���������������������������null������������
		resultView.setOnClickListener(null);

		// ������������������������������������������������
		mSearchLogic = new SearchLogic();
		ResultTextClickListener = new DetailClickListener(this);
		setUpHeaderView();
		setUpSlidingView();


//		mProgressBar = (ProgressBar) findViewById(R.id.progressBar);
//		mProgressBar.setVisibility(View.VISIBLE);
	}

	/*
	 * @see android.app.Activity#onStart()
	 */
	@Override
	protected void onStart() {
		super.onStart();
		// CameraView������
		// view���������
		cameraView = (CameraView) findViewById(R.id.camera_view);
		// ������������������������������������
		cameraView.recreateCamera();
		// ������������������������������������������������������
		// ���������������������������������������������notifyPreviewData()������������������������
		cameraView.setCameraViewListener(this);
		RelativeLayout maskView = (RelativeLayout) findViewById(R.id.maskView);
		maskView.setVisibility(View.GONE);

		// ���������������������������������
		queryImageBMP = null;
		// ������������������������������������������������������������

        Animation hyperspaceJump = AnimationUtils.loadAnimation(this, R.anim.translate);
        imageView = (ImageView)findViewById(R.id.image);

		 imageView.startAnimation(hyperspaceJump);
		
		resultText2 = (TextView) findViewById(R.id.result_text2);

		resultText2.setText("");
		resultView.setOnClickListener(null);


		// ������������������������
		new AsyncTask<Void, Void, String>() {
			@Override
			protected String doInBackground(Void... params) {
				String result = new AuthLogic(mContext).executeAuth();
				return result;
			}

			@Override
			protected void onPostExecute(String result) {
				Log.d(TAG, "onPostExecute() result = " + result);
				TestFlight.passCheckpoint("onPostExecute() result = " + result);

				// ���������������������
				if (result.equals("0000")) {
//					mProgressBar.setVisibility(View.INVISIBLE);
					// ������������������������ON
					isAuthed = true;
					// ���������������������������������������
					if (cameraView != null) {
						cameraView.notifyRestartPreview();
					}
				}
				// ���������������������
				else {
					showGAZIRUAuthFailedAlertDialog();
				}
			}
		}.execute();
	}

	/**
	 * CameraView���������������������������������������������������������
	 * 
	 * @param data
	 *            ������������������������
	 */
	public void notifyPreviewData(byte[] data) {
		Log.d(TAG, "notifyPreviewData() isAuthed = " + isAuthed);
		// ���������View������������������������������������������
		if (cameraView != null && isAuthed) {
			// ������������������������������
			Point cameraResolution = new Point();
			cameraResolution.x = cameraView.getPreviewSize().width;
			cameraResolution.y = cameraView.getPreviewSize().height;

			TestFlight.passCheckpoint("start Search Logic");
			startSearchLogic(data, cameraResolution);
		}
	}

	/**
	 * ���������������������������������
	 * 
	 * @param data
	 *            ������������������������
	 * @param cameraResolution
	 *            ������������������
	 */
	public void startSearchLogic(byte[] data, final Point cameraResolution) {

		// ������������������
		new AsyncTask<byte[], Void, List<SearchResult>>() {

			@Override
			protected List<SearchResult> doInBackground(byte[]... data) {
				return mSearchLogic.executeSearch(data, mContext,
						cameraResolution);
			}

			@Override
			protected void onPostExecute(List<SearchResult> result) {
				searchExecuted(result);
			}

		}.execute(data);

	}

	/**
	 * ��������������������� ���������������������������1,2������������������������������ ������������������������������������������������������������������������������
	 * 
	 * @param searchResultList
	 *            ���������������������
	 */
	@SuppressWarnings("unchecked")
	public void searchExecuted(List<SearchResult> searchResultList) {
		Log.d(TAG, "notifyPhotosearchExecuted() searchResultList = "
				+ searchResultList);
		TestFlight
				.passCheckpoint("notifyPhotosearchExecuted() searchResultList = "
						+ searchResultList);
		// ������������������������������������
//		TextView resultText1 = (TextView) findViewById(R.id.result_text1);
		TextView resultText2 = (TextView) findViewById(R.id.result_text2);

		// ���������������������
		if (searchResultList == null) {
			resultText2.setText("");
			resultView.setOnClickListener(null);
			return;
		}

		// ������������������������������������
		if (searchResultList.size() > 0) {
			// ���������������������
			Collections.sort(searchResultList, new ScoreComparator());
			resultText2.setText(searchResultList.get(0).getAppendInfo().get(1));
			brand_slug = searchResultList.get(0).getAppendInfo().get(0);

			// ���������������������������������������������
			resultView.setOnClickListener(ResultTextClickListener);
			// ������������������������������������������������������������������������������
			if (mSearchLogic != null) {
				TestFlight.passCheckpoint("mSearchLogic.getQueryImageBMP();");
				queryImageBMP = mSearchLogic.getQueryImageBMP();
			}
		} else {
			resultText2.setText("");
			resultView.setOnClickListener(null);
		}

		// ���������������������������������������
		cameraView.notifyRestartPreview();

	}

	/**
	 * SearchResult��������������������������������������������� SearchResult���������������������������������������������Comparator������������������
	 */
	@SuppressWarnings("rawtypes")
	private class ScoreComparator implements Comparator {

		public int compare(Object o1, Object o2) {

			double delta = ((SearchResult) o2).getScore()
					- ((SearchResult) o1).getScore();
			if (delta < 0) {
				return -1;
			} else if (delta > 0) {
				return 1;
			}

			return 0;
		}
	}

	/*
	 * @see android.app.Activity#onResume()
	 */
	@Override
	protected void onResume() {
		super.onResume();
		// ���������������������������������������
		isClicked = false;
	}

	@Override
	public void onBackPressed() {
		super.onBackPressed();
	}

	/**
	 * GAZIRU������������������������������������������������ OK������������������Activity���������������������
	 */
	private void showGAZIRUAuthFailedAlertDialog() {
		if (!isFinishing()) {
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setTitle(getString(R.string.alert_camera_title_auth_failed));
			builder.setMessage(getString(R.string.alert_camera_message_auth_failed));
			builder.setPositiveButton(
					getString(R.string.alert_camera_ok_auth_failed),
					new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
							// Activity������
							finish();
						}
					});
			builder.setCancelable(false);
			AlertDialog dialog = builder.create();
			dialog.show();
		}
	}

	// /**
	// * Finish camera activity and set the result after taken photo
	// *
	// * @param uri taken photo uri
	// */
	// private void finishWithResult(String uri) {
	// Intent previousIntent = getIntent();
	// previousIntent.putExtra("imageUri", uri);
	//
	// if (getParent() == null) {
	// setResult(Activity.RESULT_OK, previousIntent);
	// } else {
	// getParent().setResult(Activity.RESULT_OK, previousIntent);
	// }
	//
	// finish();
	// }

	/** ��������������������������������� */

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.d(TAG, "REQUEST CODE - " + requestCode);

		// if (requestCode == FTVConstants.activityRequestCodeGallery) {
		// // return from camera
		// if (resultCode == RESULT_OK) {
		// Uri imageUri = data.getData();
		// String systemIamgePath = getPath(imageUri);
		// String uri = null;
		// try {
		// uri = resizeImage(systemIamgePath);
		// } catch (IOException e) {
		// // TODO Auto-generated catch block
		// e.printStackTrace();
		// }
		//
		// gaziruSearchParams = new GaziruSearchParams(this, uri, null);
		// if (uri != null) {
		// new ImageSearchTask().execute(gaziruSearchParams);
		// }
		// // TODO: finish the camera activity
		// } else if (resultCode == RESULT_CANCELED) {
		// Log.d(TAG, "camera cancelled");
		// // on camera screen, if you push the back hardware button, then the
		// brands page should be displays.
		// // webViewClient.shouldOverrideUrlLoading(mainWebView,
		// FTVConstants.urlBrands);
		// } else {
		// Log.e(TAG, "CAMERA - SHOULD NEVER REACH");
		// }
		// }
		// // never reach
		//
		//
		// Log.e(TAG, "onActivityResult SHOULD NEVER REACH");

		super.onActivityResult(requestCode, resultCode, data);
	}

	// -------------------------- Async Task --------------------------

	// /**
	// * Gaziru : image search task should never be executed from ui thread.
	// Library has enabled the STRICT_MODE.
	// */
	// private class ImageSearchTask extends AsyncTask<GaziruSearchParams, Void,
	// String> {
	// @Override
	// protected void onPreExecute() {
	// super.onPreExecute();
	//
	// //maskView.setVisibility(View.VISIBLE);
	// //progressWheel.spin();
	// }
	//
	// /**
	// * The system calls this to perform work in a worker thread and delivers
	// * it the parameters given to AsyncTask.execute()
	// */
	// protected String doInBackground(GaziruSearchParams... params) {
	// return FTVImageProcEngine.imageSearchProcess(params[0]);
	// }
	//
	// /**
	// * The system calls this to perform work in the UI thread and delivers
	// * the result from doInBackground()
	// */
	// protected void onPostExecute(String brandSlug) {
	// //progressWheel.stopSpinning();
	// //maskView.setVisibility(View.INVISIBLE);
	//
	// // exeute image post
	// if (brandSlug != null) {
	// Log.d(TAG, "Post image with brand slug - " + brandSlug);
	// gaziruSearchParams.brandSlug = brandSlug;
	//
	// if (brandSlug == null || brandSlug.equals("failure")) {
	// // show search form
	// Intent is = new Intent(CameraActivity.this, FTVWebViewActivity.class);
	// String urlSearch = String.format("%s%s", FTVConstants.baseUrl,
	// FTVConstants.urlSearch);
	// is.putExtra("url", urlSearch);
	// CameraActivity.this.startActivity(is);
	// } else {
	// new ImagePostTask().execute(gaziruSearchParams);
	// }
	// }
	// }
	// }
	//
	// /**
	// * Gaziru : image search task should never be executed from ui thread.
	// Library has enabled the STRICT_MODE.
	// */
	// private class ImagePostTask extends AsyncTask<GaziruSearchParams, Void,
	// Void> {
	// @Override
	// protected void onPreExecute() {
	// super.onPreExecute();
	// //maskView.setVisibility(View.VISIBLE);
	// //progressWheel.spin();
	// }
	//
	// /**
	// * The system calls this to perform work in a worker thread and delivers
	// * it the parameters given to AsyncTask.execute()
	// */
	// protected Void doInBackground(GaziruSearchParams... params) {
	// return FTVImageProcEngine.imagePostProcess(params[0]);
	// }
	//
	// /**
	// * The system calls this to perform work in the UI thread and delivers
	// * the result from doInBackground()
	// */
	// protected void onPostExecute() {
	// //progressWheel.stopSpinning();
	// //maskView.setVisibility(View.GONE);
	// }
	// }

	@Override
	public View getActivityLayout() {
		// TODO Auto-generated method stub
		return getLayoutInflater().inflate(R.layout.camera, null);
	}

	// View Helper
	/**
	 * Fixed navigation bar
	 */
	private void setUpHeaderView() {
		camera.setVisibility(View.INVISIBLE);
		home.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				moveToNextActivity(FTVConstants.urlHome);
			}
		});
	}

	/**
	 * Sliding Menu from the right
	 */
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
					String string = histroryUrl;
					moveToNextActivity(string);
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
		Intent intent = new Intent(CameraActivity.this, FTVMainActivity.class);
		intent.putExtra("url", url);
		startActivity(intent);
	}

	private void SaveHistory(Bitmap bitmap, String Brandname, String BrandLogo) {
		int year, month, day;
		final Calendar c = Calendar.getInstance();
		year = c.get(Calendar.YEAR);
		month = c.get(Calendar.MONTH);
		day = c.get(Calendar.DAY_OF_MONTH);
		String date = year + "/" + String.format("%02d", (month + 1)) + "/"
				+ day;
		String logo = makesubstring(BrandLogo, ':');
		String name = makesubstring(Brandname, ':');
		DatabaseHandler db = new DatabaseHandler(this);
		db.addHistory(name, logo, date, bitmap);
	}

	public String makesubstring(String string1, char c) {
		int pos = string1.indexOf(c);
		String newString = string1.substring(pos + 1, string1.length());
		return newString;
	}

}