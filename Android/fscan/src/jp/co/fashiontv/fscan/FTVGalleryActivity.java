package jp.co.fashiontv.fscan;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Window;

public class FTVGalleryActivity extends Activity {
    private static final int REQUEST_GALLERY = 0;
    private static final String TAG = "FTVGalleryActivity";
    private Uri fileUri;
//    FTVImageProcEngine engine = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);

        setContentView(R.layout.layout_camera);
//        this.engine = new FTVImageProcEngine();

        Intent intent = new Intent();
        intent.setType("image/*");
        intent.setAction(Intent.ACTION_GET_CONTENT);
        startActivityForResult(intent, REQUEST_GALLERY);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG, "Enter onResume");
//        if(this.engine.isProcessed()){
//        	finish();
//        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if (requestCode == REQUEST_GALLERY && resultCode == RESULT_OK) {
            fileUri = intent.getData();
//            this.engine.commonProcess(this, fileUri);
        }
        finish();

    }

}
