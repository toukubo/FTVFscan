package jp.co.fashiontv.fscan.ImgProc;

import android.app.Activity;
import jp.co.fashiontv.fscan.Utils.FTVUtils;


public class DamyGaziring {
	public DamyGaziring(String url,Activity activity){
//		new OpenUrl(iurl,activity);
        FTVUtils.OpenUrl(url,activity);
	}
}
