package jp.co.fashiontv.fscan.Camera;

import com.todddavies.components.progressbar.ProgressWheel;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Activities.FTVMainActivity;
import jp.co.fashiontv.fscan.ImgProc.FTVImageProcEngine;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.RelativeLayout;

public class DetailClickListener implements OnClickListener {
	CameraActivity cameraActivity = null;
	ProgressWheel progressWheel;

	RelativeLayout maskView;
	
	public DetailClickListener(CameraActivity cameraActivity){
		this.cameraActivity = cameraActivity;
		maskView = (RelativeLayout) cameraActivity.findViewById(R.id.maskView);
//		progressWheel = (ProgressWheel) cameraActivity.findViewById(R.id.progressWheel);


		
	}
	public void onClick(View v) {
		if (!this.cameraActivity.isClicked) {
			// ���������������������
//			TestFlight.passCheckpoint("���������������������������������");
//			SaveHistory(queryImageBMP, resultText2.getText().toString(),
//					brand_slug);
			onPageStarted();
			FTVImageProcEngine.postImageDataWithBrandSlug(this.cameraActivity.mContext,this.cameraActivity.brand_slug,this.cameraActivity.queryImageBMP);
			
//			Intent is = new Intent(mContext, FTVWebViewActivity.class);
//			String urlSearch = String.format("%s%s",
//					FTVConstants.baseUrl, FTVConstants.urlSearch);
//            String url = String.format("%s%s%s%s%s", FTVConstants.baseUrl, "scan/scan.php?deviceid=", FTVUser.getID(), "&id=", resultText1.getText().toString());
//			String url = FTVConstants.urlHome + brand_slug;
//			is.putExtra("url", url);
//			mContext.startActivity(is);
			
//			if (queryImageBMP != null) {
//				intent.putExtra("imageBitmap", queryImageBMP);
//			}
//			startActivity(is);
			this.cameraActivity.queryImageBMP = null;
			this.cameraActivity.isClicked = true;
			onPageFinished();

		}
	}
	
	public void onPageStarted() {
//		Log.d(TAG, "onPageStartedEvent");
		maskView.setVisibility(View.VISIBLE);
//		progressWheel.spin();
	}


	public void onPageFinished() {
//		this.cameraActivity.mProgressBar.stopSpinning();
		maskView.setVisibility(View.GONE);
	}

	public void onPageReceivedError() {
//		progressWheel.stopSpinning();
		maskView.setVisibility(View.GONE);
	}
	
}
