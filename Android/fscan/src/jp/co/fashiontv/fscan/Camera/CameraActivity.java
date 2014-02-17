package jp.co.fashiontv.fscan.Camera;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;

import com.testflightapp.lib.TestFlight;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Activities.BaseActivity;
import jp.co.fashiontv.fscan.Activities.FTVMainActivity;
import jp.co.fashiontv.fscan.Activities.FTVWebViewActivity;
import jp.co.fashiontv.fscan.Activities.ResultActivity;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Gaziru.GaziruSearchParams;
import jp.co.fashiontv.fscan.ImgProc.FTVImageProcEngine;
import jp.co.fashiontv.fscan.Utils.StringUtil;
import jp.co.fashiontv.fscan.Listener.CameraViewListener;
import jp.co.fashiontv.fscan.Logic.*;
import jp.co.fashiontv.fscan.View.*;
import jp.co.nec.gazirur.rtsearch.lib.bean.SearchResult;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PixelFormat;
import android.graphics.Point;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.PictureCallback;
import android.hardware.Camera.ShutterCallback;
import android.hardware.Camera.Size;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;


/**
 * Created by GAZIRU Developer on 14/01/21
 * 
 * Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
 * 
 * @author Alsor Zhou
 */
public class CameraActivity extends BaseActivity implements CameraViewListener {
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

//	private GaziruSearchParams gaziruSearchParams;
    
	/** プログレスバー */
	private ProgressBar mProgressBar;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
 
        mContext = getApplicationContext();
        
        // 結果領域取得
        resultView = (RelativeLayout)findViewById(R.id.result_view);
        // 結果領域のリスナをnullで初期化
        resultView.setOnClickListener(null);
        
        // 画像識別ロジックインスタンス生成
        mSearchLogic = new SearchLogic();

        setUpHeaderView();
        setUpSlidingView();

        mProgressBar = (ProgressBar) findViewById(R.id.progressBar);
        mProgressBar.setVisibility(View.VISIBLE);
    }

    /*
     * @see android.app.Activity#onStart()
     */
    @Override
    protected void onStart() {
         super.onStart();
         // CameraView設定
         // viewの取得
         cameraView = (CameraView) findViewById(R.id.camera_view);
         // カメラインスタンスの作成
         cameraView.recreateCamera();
         // プレビューデータ通知用のリスナー登録
         // カメラプレビューコールバックをnotifyPreviewData()で受け取けとる。
         cameraView.setCameraViewListener(this);

         // クエリ画像を初期化する
         queryImageBMP = null;
         // 結果表示領域のテキストビューを初期化する
         TextView resultText1 = (TextView)findViewById(R.id.result_text1);
         TextView resultText2 = (TextView)findViewById(R.id.result_text2);
         resultText1.setText(getString(R.string.result_text_default));
         resultText2.setText("");
         resultView.setOnClickListener(null);

         // 企業認証処理実行
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
                 
                 // 認証成功の場合
                 if (result.equals("0000")) {
                     mProgressBar.setVisibility(View.INVISIBLE);
                     // 認証済みフラグをON
                     isAuthed = true;
                     // プレビューデータ通知を開始
                     if (cameraView != null) {
                         cameraView.notifyRestartPreview();
                     }
                 }
                 // 認証失敗の場合
                 else {
                     showGAZIRUAuthFailedAlertDialog();
                 }
             }
         }.execute();
    }
    
    /**
     * CameraViewからのプレビューデータ通知を受信時処理
     * @param data プレビューデータ
     */
    public void notifyPreviewData(byte[] data) {
        Log.d(TAG, "notifyPreviewData() isAuthed = " + isAuthed);
        // カメラViewが存在するかつ認証済みの場合
        if (cameraView != null && isAuthed) {
            // 画像識別ロジック開始
            Point cameraResolution = new Point();
            cameraResolution.x = cameraView.getPreviewSize().width;
            cameraResolution.y = cameraView.getPreviewSize().height;
            
            TestFlight.passCheckpoint("start Search Logic");
            startSearchLogic(data, cameraResolution);
        }
    }

    /**
     * 画像識別ロジックを開始
     * @param data プレビューデータ
     * @param cameraResolution カメラ解像度
     */
	public void startSearchLogic(byte[] data, final Point cameraResolution) {

		// 検索処理実行
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
     * 識別完了後処理
     * 識別結果の追加情報1,2を画面に表示します。
     * カメラプレビューデータのコールバックを有効化します。
     * @param searchResultList 識別結果リスト
     */
    @SuppressWarnings("unchecked")
    public void searchExecuted(List<SearchResult> searchResultList) {
        Log.d(TAG, "notifyPhotosearchExecuted() searchResultList = " + searchResultList);
        TestFlight.passCheckpoint("notifyPhotosearchExecuted() searchResultList = " + searchResultList);
        // 追加情報をテキストに設定
        TextView resultText1 = (TextView)findViewById(R.id.result_text1);
        TextView resultText2 = (TextView)findViewById(R.id.result_text2);

        // 検索失敗の場合
        if (searchResultList == null) {
            resultText1.setText(getString(R.string.result_text_connection_failed));
            resultText2.setText("");
            resultView.setOnClickListener(null);
            return;
        }

        // 検索成功しヒットした場合
        if (searchResultList.size() > 0) {
            // スコアをソート
            Collections.sort(searchResultList, new ScoreComparator());
            resultText1.setText(getString(R.string.result_text_append_info1) + searchResultList.get(0).getAppendInfo().get(0));
            resultText2.setText(getString(R.string.result_text_append_info2) + searchResultList.get(0).getAppendInfo().get(1));
            // ヒットした場合のみリスナを設定
            resultView.setOnClickListener(ResultTextClickListener);
            // 次の画面で利用するため検索に利用した画像を画面で保持
            if (mSearchLogic != null) {
            	TestFlight.passCheckpoint("mSearchLogic.getQueryImageBMP();");
                queryImageBMP = mSearchLogic.getQueryImageBMP();
            }
        } else {
            resultText1.setText(getString(R.string.result_text_default));
            resultText2.setText("");
            resultView.setOnClickListener(null);
        }

        // プレビューデータ通知を再開
        cameraView.notifyRestartPreview();

    }

    /**
     * SearchResultをスコア降順にソートするクラス
     * SearchResultをスコア降順にソートするためのComparatorクラスです。
     */
    @SuppressWarnings("rawtypes")
    private class ScoreComparator implements Comparator {

        public int compare(Object o1, Object o2) {

            double delta = ((SearchResult) o2).getScore() - ((SearchResult) o1).getScore();
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
        // クリックイベントを許可する
        isClicked = false;
    }
    
    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    /**
     * GAZIRU認証処理失敗時ダイアログ表示処理
     * OKボタン押下でActivityを終了します。
     */
    private void showGAZIRUAuthFailedAlertDialog() {
        if (!isFinishing()) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle(getString(R.string.alert_camera_title_auth_failed));
            builder.setMessage(getString(R.string.alert_camera_message_auth_failed));
            builder.setPositiveButton(getString(R.string.alert_camera_ok_auth_failed), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    // Activity終了
                    finish();
                }
            });
            builder.setCancelable(false);
            AlertDialog dialog = builder.create();
            dialog.show();
        }
    }

//    /**
//     * Finish camera activity and set the result after taken photo
//     *
//     * @param uri taken photo uri
//     */
//    private void finishWithResult(String uri) {
//        Intent previousIntent = getIntent();
//        previousIntent.putExtra("imageUri", uri);
//
//        if (getParent() == null) {
//            setResult(Activity.RESULT_OK, previousIntent);
//        } else {
//            getParent().setResult(Activity.RESULT_OK, previousIntent);
//        }
//
//        finish();
//    }

    /** 結果領域クリックリスナ */
    private OnClickListener ResultTextClickListener = (new OnClickListener() {
        @Override
        public void onClick(View v) {
            if (!isClicked) {
                // 結果画面へ遷移
            	TestFlight.passCheckpoint("結果領域クリックリスナ");
            	
                Intent intent = new Intent(getApplicationContext(), ResultActivity.class);
                if (queryImageBMP != null) {
                    intent.putExtra("imageBitmap", queryImageBMP);
                }
                startActivity(intent);
                queryImageBMP = null;
                isClicked = true;
            }
        }
    });
    
    @Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.d(TAG, "REQUEST CODE - " + requestCode);
			
//			if (requestCode == FTVConstants.activityRequestCodeGallery) {
//				// return from camera
//				if (resultCode == RESULT_OK) {
//					Uri imageUri = data.getData();
//					String systemIamgePath  = getPath(imageUri);
//					String uri = null;
//					try {
//						uri = resizeImage(systemIamgePath);
//					} catch (IOException e) {
//						// TODO Auto-generated catch block
//						e.printStackTrace();
//					}
//				
//					gaziruSearchParams = new GaziruSearchParams(this, uri, null);
//					if (uri != null) {
//						new ImageSearchTask().execute(gaziruSearchParams);
//					}
//					// TODO: finish the camera activity
//				} else if (resultCode == RESULT_CANCELED) {
//					Log.d(TAG, "camera cancelled");
//					// on camera screen, if you push the back hardware button, then the brands page should be displays.
//				//	webViewClient.shouldOverrideUrlLoading(mainWebView, FTVConstants.urlBrands);
//				} else {
//					Log.e(TAG, "CAMERA - SHOULD NEVER REACH");
//				}
//			}
//			// never reach
//			
//			
//			Log.e(TAG, "onActivityResult SHOULD NEVER REACH");
		 
		super.onActivityResult(requestCode, resultCode, data);
	}
    
 // -------------------------- Async Task --------------------------

// 	/**
// 	 * Gaziru : image search task should never be executed from ui thread. Library has enabled the STRICT_MODE.
// 	 */
// 	private class ImageSearchTask extends AsyncTask<GaziruSearchParams, Void, String> {
// 		@Override
// 		protected void onPreExecute() {
// 			super.onPreExecute();
//
// 			//maskView.setVisibility(View.VISIBLE);
// 			//progressWheel.spin();
// 		}
//
// 		/**
// 		 * The system calls this to perform work in a worker thread and delivers
// 		 * it the parameters given to AsyncTask.execute()
// 		 */
// 		protected String doInBackground(GaziruSearchParams... params) {
// 			return FTVImageProcEngine.imageSearchProcess(params[0]);
// 		}
//
// 		/**
// 		 * The system calls this to perform work in the UI thread and delivers
// 		 * the result from doInBackground()
// 		 */
// 		protected void onPostExecute(String brandSlug) {
// 			//progressWheel.stopSpinning();
// 			//maskView.setVisibility(View.INVISIBLE);
//
// 			// exeute image post
// 			if (brandSlug != null) {
// 				Log.d(TAG, "Post image with brand slug - " + brandSlug);
// 				gaziruSearchParams.brandSlug = brandSlug;
//
// 				if (brandSlug == null || brandSlug.equals("failure")) {
// 					// show search form
// 					Intent is = new Intent(CameraActivity.this, FTVWebViewActivity.class);
// 					String urlSearch = String.format("%s%s", FTVConstants.baseUrl, FTVConstants.urlSearch);
// 					is.putExtra("url", urlSearch);
// 					CameraActivity.this.startActivity(is);
// 				} else {
// 					new ImagePostTask().execute(gaziruSearchParams);
// 				}
// 			}
// 		}
// 	}
//
// 	/**
// 	 * Gaziru : image search task should never be executed from ui thread. Library has enabled the STRICT_MODE.
// 	 */
// 	private class ImagePostTask extends AsyncTask<GaziruSearchParams, Void, Void> {
// 		@Override
// 		protected void onPreExecute() {
// 			super.onPreExecute();
// 			//maskView.setVisibility(View.VISIBLE);
// 			//progressWheel.spin();
// 		}
//
// 		/**
// 		 * The system calls this to perform work in a worker thread and delivers
// 		 * it the parameters given to AsyncTask.execute()
// 		 */
// 		protected Void doInBackground(GaziruSearchParams... params) {
// 			return FTVImageProcEngine.imagePostProcess(params[0]);
// 		}
//
// 		/**
// 		 * The system calls this to perform work in the UI thread and delivers
// 		 * the result from doInBackground()
// 		 */
// 		protected void onPostExecute() {
// 			//progressWheel.stopSpinning();
// 			//maskView.setVisibility(View.GONE);
// 		}
// 	}
    
       
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
					moveToNextActivity(histroryUrl);
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

}