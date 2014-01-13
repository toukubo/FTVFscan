package jp.co.fashiontv.fscan.Camera;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Activities.BaseActivity;
import jp.co.fashiontv.fscan.Activities.FTVMainActivity;
import jp.co.fashiontv.fscan.Activities.FTVWebViewActivity;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Gaziru.GaziruSearchParams;
import jp.co.fashiontv.fscan.ImgProc.FTVImageProcEngine;
import jp.co.fashiontv.fscan.Utils.StringUtil;
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
import android.widget.Toast;

/**
 * @author Alsor Zhou
 */
@SuppressLint("NewApi")
public class CameraActivity extends BaseActivity implements SurfaceHolder.Callback {
    private String TAG = "CameraActivity";
    private SurfaceView surfaceView;
    private SurfaceHolder surfaceHolder;
    private ImageButton takePicView;// , exitView;
    private Context context;

    private Camera mCamera;

    private boolean isTakingPicture = false;
    private static final String JPEG_FILE_PREFIX = "IMG_";
    private static final String JPEG_FILE_SUFFIX = ".jpg";
    private String mCurrentPhotoPath;
    private AlbumStorageDirFactory mAlbumStorageDirFactory = null;

    /* Photo album for this application */
    private String getAlbumName() {
        return getString(R.string.app_name);
    }

    private File getAlbumDir() {
        File storageDir = null;

        if (Environment.MEDIA_MOUNTED.equals(Environment
            .getExternalStorageState())) {

            storageDir = mAlbumStorageDirFactory
                .getAlbumStorageDir(getAlbumName());

            if (storageDir != null) {
                if (!storageDir.mkdirs()) {
                    if (!storageDir.exists()) {
                        Toast.makeText(context, context.getString(R.string.failed_create_album), Toast.LENGTH_SHORT);
                        return null;
                    }
                }
            }

        } else {
            Toast.makeText(context, context.getString(R.string.cannot_read_sd_card), Toast.LENGTH_SHORT);
        }

        return storageDir;
    }

    private File createImageFile() throws IOException {
        // Create an image file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss")
            .format(new Date());
        String imageFileName = JPEG_FILE_PREFIX + timeStamp;
        File albumF = getAlbumDir();
        File imageF = File.createTempFile(imageFileName, JPEG_FILE_SUFFIX,
            albumF);
        return imageF;
    }

    private File setUpPhotoFile() throws IOException {

        File f = createImageFile();
        mCurrentPhotoPath = f.getAbsolutePath();

        return f;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
      //  setContentView(R.layout.camera_layout);
 
        isTakingPicture = false;
        mAlbumStorageDirFactory = new BaseAlbumDirFactory();
        context = this.getApplicationContext();
        takePicView = (ImageButton) this.findViewById(R.id.button_capture);
        takePicView.setOnClickListener(TakePicListener);
        surfaceView = (SurfaceView) this.findViewById(R.id.camera_preview);
        surfaceHolder = surfaceView.getHolder();
        surfaceHolder.addCallback(this);
        surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
        checkSoftStage();
        setUpHeaderView();
        setUpSlidingView();
    }

    
     
    private void setUpHeaderView() {
		 
    	camera.setVisibility(View.INVISIBLE);
    	home.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
			    moveToNextActivity(FTVConstants.urlHome);	
			}
		});
    	
	}

	private void setUpSlidingView() {
    	lvMenuDrawerItems.setOnItemClickListener(new OnItemClickListener() {
    		@Override
			public void onItemClick(AdapterView<?> parent, View view, int position,
					long id) {
				 
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
					//moveToNextActivity(tourUrl);
					Intent galleryIntent = new Intent(
							Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
					startActivityForResult(galleryIntent, FTVConstants.activityRequestCodeGallery);

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
		intent.putExtra("url",url);
		startActivity(intent);


	}


    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    private void checkSoftStage() {
        if (Environment.getExternalStorageState().equals(
            Environment.MEDIA_MOUNTED)) {
            File file = getAlbumDir();
            if (!file.exists()) {
                file.mkdir();
            }
        } else {
            new AlertDialog.Builder(this)
                .setMessage("1")
                .setPositiveButton("2",
                    new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog,
                                            int which) {
                            finish();
                        }
                    }).show();
        }
    }

    private final OnClickListener TakePicListener = new OnClickListener() {
        @Override
        public void onClick(View v) {

            if (!isTakingPicture) {
                isTakingPicture = true;

                try {
                    File f = setUpPhotoFile();
                    mCurrentPhotoPath = f.getAbsolutePath();
                } catch (Exception e) {
                    e.printStackTrace();
                }

                mCamera.autoFocus(new AutoFocusCallback() {
                    boolean once = true;

                    @Override
                    public void onAutoFocus(boolean b, Camera camera) {
                        if (once && mCamera != null) {
                            mCamera.takePicture(null, null, mPictureCallback);
                            once = false;
                        }
                    }
                });
            }
        }
    };


    private final PictureCallback mPictureCallback = new PictureCallback() {
        @Override
        public void onPictureTaken(byte[] data, Camera camera) {
            // stop camera preview
            camera.stopPreview();

            try {
                // resize raw image and save
                Bitmap originImage = BitmapFactory.decodeByteArray(data, 0, data.length);

                originImage = FTVImageProcEngine.rotateImage(originImage, 90);

                Bitmap resizedImage = FTVImageProcEngine.imageResize(originImage, StringUtil.randomFilename(), true);

                byte[] resizedBytes = FTVImageProcEngine.getBytesFromBitmap(resizedImage);

                File file = createImageFile();
                FileOutputStream fileOutputStream = new FileOutputStream(file);
                fileOutputStream.write(resizedBytes);
                fileOutputStream.close();

                String path = file.getAbsolutePath();
                finishWithResult(path);

                // indicate the camera was free
                isTakingPicture = false;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * Finish camera activity and set the result after taken photo
     *
     * @param uri taken photo uri
     */
    private void finishWithResult(String uri) {
        Intent previousIntent = getIntent();
        previousIntent.putExtra("imageUri", uri);

        if (getParent() == null) {
            setResult(Activity.RESULT_OK, previousIntent);
        } else {
            getParent().setResult(Activity.RESULT_OK, previousIntent);
        }

        finish();
    }

    private final ShutterCallback mShutterCallback = new ShutterCallback() {
        @Override
        public void onShutter() {
            Log.d("ShutterCallback", "...onShutter...");
        }
    };
	private GaziruSearchParams gaziruSearchParams;

    /**
     * Get optimal size from size list, can be used to get the proper preview size and picutre size
     *
     * @param sizes target sizes
     * @param w source width
     * @param h source height
     * @return best match size from size list, based on the source size
     */
    private Size getOptimalSize(List<Size> sizes, int w, int h) {
        final double ASPECT_TOLERANCE = 0.05;
        double targetRatio = (double) w / h;
        if (sizes == null)
            return null;

        Size optimalSize = null;
        double minDiff = Double.MAX_VALUE;

        int targetHeight = h;

        // Try to find an size match aspect ratio and size
        for (Size size : sizes) {
            double ratio = (double) size.width / size.height;
            if (Math.abs(ratio - targetRatio) > ASPECT_TOLERANCE)
                continue;
            if (Math.abs(size.height - targetHeight) < minDiff) {
                optimalSize = size;
                minDiff = Math.abs(size.height - targetHeight);
            }
        }

        // Cannot find the one match the aspect ratio, ignore the requirement
        if (optimalSize == null) {
            minDiff = Double.MAX_VALUE;
            for (Size size : sizes) {
                if (Math.abs(size.height - targetHeight) < minDiff) {
                    optimalSize = size;
                    minDiff = Math.abs(size.height - targetHeight);
                }
            }
        }
        return optimalSize;
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width,
                               int height) {
        // Now that the size is known, set up the camera parameters and begin
        // the preview.
        Camera.Parameters parameters = mCamera.getParameters();
        parameters.setPictureFormat(PixelFormat.JPEG);

        // Preview Size
        List<Size> previewSizes = parameters.getSupportedPreviewSizes();
        for (Size size : previewSizes) {
            Log.d(TAG, "Camera supported preview size : width - " + size.width + " height - " + size.height);
        }
        Size optimalPreviewSize = getOptimalSize(previewSizes, width, height);
        Log.d(TAG, "Camera set preview size : width - " + optimalPreviewSize.width + " height - " + optimalPreviewSize.height);
        parameters.setPreviewSize(optimalPreviewSize.width, optimalPreviewSize.height);

        // Picture Size
        List<Size> pictureSizes = parameters.getSupportedPictureSizes();
        for (Size size : pictureSizes) {
            Log.d(TAG, "Camera supported picutre size : width - " + size.width + " height - " + size.height);
        }
        Size optimalPictureSize = getOptimalSize(pictureSizes, width, height);

        Log.d(TAG, "Camera set picture size : width - " + optimalPictureSize.width + " height - " + optimalPictureSize.height);
        parameters.setPictureSize(optimalPictureSize.width, optimalPictureSize.height);

        // Focus Mode
        parameters.setFocusMode(Camera.Parameters.FOCUS_MODE_AUTO);

        mCamera.setParameters(parameters);

        mCamera.startPreview();
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        try {
            mCamera = Camera.open();
            mCamera.setPreviewDisplay(holder);
        } catch (IOException e) {
            mCamera.release();
            mCamera = null;
        }

        mCamera.setDisplayOrientation(90);

        // ImageView mask = new ImageView(this);
        // // FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(
        // //         ViewGroup.LayoutParams.FILL_PARENT,
        // //         ViewGroup.LayoutParams.FILL_PARENT);
        // // mask.setLayoutParams(lp);
        // FrameLayout preview = (FrameLayout) findViewById(R.id.camera_preview);
        //
        // mask.setImageResource(R.drawable.camera_mask);
        // preview.addView(mask);
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        mCamera.stopPreview();
        if (mCamera != null)
            mCamera.release();
        mCamera = null;
    }

//    @Override
//    public boolean onKeyDown(int keyCode, KeyEvent event) {
//        if (keyCode == KeyEvent.KEYCODE_CAMERA) {
//            mCamera.autoFocus(new AutoFoucus());
//        } else {
//            super.onKeyDown(keyCode, event);
//        }
//
//        return true;
//    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        // Checks the orientation of the screen
        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            Toast.makeText(this, "landscape", Toast.LENGTH_SHORT).show();
        } else if (newConfig.orientation == Configuration.ORIENTATION_PORTRAIT) {
            Toast.makeText(this, "portrait", Toast.LENGTH_SHORT).show();
        }
    }
    
    
    
    
    @Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.d(TAG, "REQUEST CODE - " + requestCode);
		 
			
			if (requestCode == FTVConstants.activityRequestCodeGallery) {
				// return from camera
				if (resultCode == RESULT_OK) {
					Uri imageUri = data.getData();
					String systemIamgePath  = getPath(imageUri);
					String uri = null;
					try {
						uri = resizeImage(systemIamgePath);
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				
					gaziruSearchParams = new GaziruSearchParams(this, uri, null);
					if (uri != null) {
						new ImageSearchTask().execute(gaziruSearchParams);
					}
					// TODO: finish the camera activity
				} else if (resultCode == RESULT_CANCELED) {
					Log.d(TAG, "camera cancelled");
					// on camera screen, if you push the back hardware button, then the brands page should be displays.
				//	webViewClient.shouldOverrideUrlLoading(mainWebView, FTVConstants.urlBrands);
				} else {
					Log.e(TAG, "CAMERA - SHOULD NEVER REACH");
				}
			}
			// never reach
			
			
			Log.e(TAG, "onActivityResult SHOULD NEVER REACH");
		 

		super.onActivityResult(requestCode, resultCode, data);
	}
    
    
    
   



	/**
     
    
 // -------------------------- Async Task --------------------------

 	/**
 	 * Gaziru : image search task should never be executed from ui thread. Library has enabled the STRICT_MODE.
 	 */
 	private class ImageSearchTask extends AsyncTask<GaziruSearchParams, Void, String> {
 		@Override
 		protected void onPreExecute() {
 			super.onPreExecute();

 			//maskView.setVisibility(View.VISIBLE);
 			//progressWheel.spin();
 		}

 		/**
 		 * The system calls this to perform work in a worker thread and delivers
 		 * it the parameters given to AsyncTask.execute()
 		 */
 		protected String doInBackground(GaziruSearchParams... params) {
 			return FTVImageProcEngine.imageSearchProcess(params[0]);
 		}

 		/**
 		 * The system calls this to perform work in the UI thread and delivers
 		 * the result from doInBackground()
 		 */
 		protected void onPostExecute(String brandSlug) {
 			//progressWheel.stopSpinning();
 			//maskView.setVisibility(View.INVISIBLE);

 			// exeute image post
 			if (brandSlug != null) {
 				Log.d(TAG, "Post image with brand slug - " + brandSlug);
 				gaziruSearchParams.brandSlug = brandSlug;

 				if (brandSlug == null || brandSlug.equals("failure")) {
 					// show search form
 					Intent is = new Intent(CameraActivity.this, FTVWebViewActivity.class);
 					String urlSearch = String.format("%s%s", FTVConstants.baseUrl, FTVConstants.urlSearch);
 					is.putExtra("url", urlSearch);
 					CameraActivity.this.startActivity(is);
 				} else {
 					new ImagePostTask().execute(gaziruSearchParams);
 				}
 			}
 		}
 	}

 	/**
 	 * Gaziru : image search task should never be executed from ui thread. Library has enabled the STRICT_MODE.
 	 */
 	private class ImagePostTask extends AsyncTask<GaziruSearchParams, Void, Void> {
 		@Override
 		protected void onPreExecute() {
 			super.onPreExecute();
 			//maskView.setVisibility(View.VISIBLE);
 			//progressWheel.spin();
 		}

 		/**
 		 * The system calls this to perform work in a worker thread and delivers
 		 * it the parameters given to AsyncTask.execute()
 		 */
 		protected Void doInBackground(GaziruSearchParams... params) {
 			return FTVImageProcEngine.imagePostProcess(params[0]);
 		}

 		/**
 		 * The system calls this to perform work in the UI thread and delivers
 		 * the result from doInBackground()
 		 */
 		protected void onPostExecute() {
 			//progressWheel.stopSpinning();
 			//maskView.setVisibility(View.GONE);
 		}
 	}
    
       

@Override
public View getActivityLayout() {
	// TODO Auto-generated method stub
	return getLayoutInflater().inflate(R.layout.camera_layout, null);
}


}