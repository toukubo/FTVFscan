package jp.co.fashiontv.fscan;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Menu;
import android.view.Window;
import android.widget.ImageView;
import jp.co.fashiontv.fscan.Common.DeviceUtil;
import jp.co.fashiontv.fscan.ImgProc.FTVImageProcEngine;

public class FTVCameraActivity extends Activity {
    private static String TAG = "FTVCameraActivity";
    private static final int CAMERA_REQUEST = 1888;

    private Uri fileUri;

    ImageView imageView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.layout_camera);

//        imageView = (ImageView)findViewById(R.id.imageView);

        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        fileUri = DeviceUtil.getOutputMediaFileUri(DeviceUtil.MEDIA_TYPE_IMAGE);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri);

        startActivityForResult(intent, CAMERA_REQUEST);

    }

    @Override
    protected void onResume() {
        super.onResume();

        Log.d(TAG, "Enter FTVCameraActivity");

        if (fileUri != null) {
            FTVImageProcEngine.commonProcess(this, fileUri);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == CAMERA_REQUEST) {
            if (resultCode == RESULT_OK) {
                // Camera finished successful
            } else if (resultCode == RESULT_CANCELED) {
                // User cancelled the image capture
            } else {
                // Image capture failed, advise user
            }
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
}
