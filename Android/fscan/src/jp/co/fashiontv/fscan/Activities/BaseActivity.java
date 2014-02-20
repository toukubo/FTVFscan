package jp.co.fashiontv.fscan.Activities;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream.PutField;
import java.text.SimpleDateFormat;
import java.util.Date;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Activities.adapter.DrawerItemsAdapter;
import jp.co.fashiontv.fscan.Camera.BaseAlbumDirFactory;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVUser;
import jp.co.fashiontv.fscan.ImgProc.FTVImageProcEngine;
import jp.co.fashiontv.fscan.Utils.StringUtil;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.Toast;

import com.jeremyfeinstein.slidingmenu.lib.SlidingMenu;
import com.jeremyfeinstein.slidingmenu.lib.app.SlidingActivity;

public abstract class BaseActivity extends SlidingActivity {
	public SlidingMenu slidingMenu;
	public ListView lvMenuDrawerItems;
	public String histroryUrl =    FTVConstants.baseUrl+"/scan/list.php?deviceid="+FTVUser.getID();
	public String brandUrl =FTVConstants.urlBrands;
	public String tourUrl =  FTVConstants.urlHome+"/fscan-tour/";
	public ImageView home;
	public ImageView camera;
	private BaseAlbumDirFactory mAlbumStorageDirFactory;
	public  ImageView slider;
	private static final String JPEG_FILE_PREFIX = "IMG_";
	private static final String JPEG_FILE_SUFFIX = ".jpg";


	public abstract View getActivityLayout();
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		mAlbumStorageDirFactory = new BaseAlbumDirFactory();
		setUpView();
	}

	private void setUpView() {
		slidingMenu = getSlidingMenu();
		slidingMenu.setShadowWidthRes(R.dimen.shadow_width);
		slidingMenu.setShadowDrawable(R.drawable.shadow);
		slidingMenu.setBehindOffsetRes(R.dimen.slidingmenu_offset);
		slidingMenu.setFadeDegree(0.35f);
		slidingMenu.setMode(SlidingMenu.RIGHT);
		slidingMenu.setTouchModeAbove(SlidingMenu.TOUCHMODE_FULLSCREEN);
		setBehindContentView(R.layout.layout_sliding_menu);
		setContentView(R.layout.menu_frame);
		FrameLayout layout = (FrameLayout)findViewById(R.id.menu_frame);
		layout.addView(getActivityLayout());


		lvMenuDrawerItems = (ListView)findViewById(R.id.lv_menu_items);

		DrawerItemsAdapter adapter =  new DrawerItemsAdapter(BaseActivity.this);
		lvMenuDrawerItems.setAdapter(adapter);



		slider = (ImageView)findViewById(R.id.slider);
		home = (ImageView)findViewById(R.id.home);
		camera = (ImageView)findViewById(R.id.camera);

		slider.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {

				slidingMenu.toggle();
			}
		});



	}


	public void showToast(String  message) {
		Toast.makeText(BaseActivity.this, ""+message, Toast.LENGTH_SHORT).show();
	}

	/**
	 * helper to retrieve the path of an image URI
	 */
	public String getPath(Uri uri) {
		// just some safety built in 
		if( uri == null ) {
			// TODO perform some logging or show user feedback
			return null;
		}
		// try to retrieve the image from the media store first
		// this will only work for images selected from gallery
		String[] projection = { MediaStore.Images.Media.DATA };
		Cursor cursor = managedQuery(uri, projection, null, null, null);
		if( cursor != null ){
			int column_index = cursor
					.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
			cursor.moveToFirst();
			return cursor.getString(column_index);
		}
		// this is our fallback here
		return uri.getPath();
	}



	public String resizeImage(String uri) throws IOException {
 		Bitmap bitmap = decodeBitmapFromPath(uri, 80, 80);
		 
		Bitmap originImage = FTVImageProcEngine.rotateImage(bitmap, 90);
		Bitmap resizedImage = FTVImageProcEngine.imageResize(originImage, StringUtil.randomFilename(), true);
		byte[] resizedBytes = FTVImageProcEngine.getBytesFromBitmap(resizedImage);
	 	File file = createImageFile();
		FileOutputStream fileOutputStream = new FileOutputStream(file);
		fileOutputStream.write(resizedBytes);
		fileOutputStream.close();
		String path = file.getAbsolutePath();
		return path;
	}



	private Bitmap decodeBitmapFromPath(String filePath,
			int reqWidth, int reqHeight) {

		// First decode with inJustDecodeBounds=true to check dimensions
		final BitmapFactory.Options options = new BitmapFactory.Options();
		options.inJustDecodeBounds = true;
		BitmapFactory.decodeFile(filePath, options);

		// Calculate inSampleSize
		options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);

		// Decode bitmap with inSampleSize set
		options.inJustDecodeBounds = false;
		return BitmapFactory.decodeFile(filePath, options);
	}

	private  int calculateInSampleSize(
			BitmapFactory.Options options, int reqWidth, int reqHeight) {
		// Raw height and width of image
		final int height = options.outHeight;
		final int width = options.outWidth;
		int inSampleSize = 1;

		if (height > reqHeight || width > reqWidth) {

			final int halfHeight = height / 2;
			final int halfWidth = width / 2;

			// Calculate the largest inSampleSize value that is a power of 2 and keeps both
			// height and width larger than the requested height and width.
			while ((halfHeight / inSampleSize) > reqHeight
					&& (halfWidth / inSampleSize) > reqWidth) {
				inSampleSize *= 2;
			}
		}

		return inSampleSize;
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


	private File getAlbumDir() {
		File storageDir = null;

		if (Environment.MEDIA_MOUNTED.equals(Environment
				.getExternalStorageState())) {

			storageDir = mAlbumStorageDirFactory
					.getAlbumStorageDir(getAlbumName());

			if (storageDir != null) {
				if (!storageDir.mkdirs()) {
					if (!storageDir.exists()) {
						Toast.makeText(BaseActivity.this, BaseActivity.this.getString(R.string.failed_create_album), Toast.LENGTH_SHORT);
						return null;
					}
				}
			}

		} else {
			Toast.makeText(BaseActivity.this, BaseActivity.this.getString(R.string.cannot_read_sd_card), Toast.LENGTH_SHORT);
		}

		return storageDir;
	}
	/* Photo album for this application */
	private String getAlbumName() {
		return getString(R.string.app_name);
	}



}
