package jp.co.fashiontv.fscan.Utils;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

/**
 * Created by veiz on 13-11-9.
 */
public class FTVUtils {

    public static void OpenUrl(String url, Activity activity) {

        Uri uri = Uri.parse(url);
        Intent i = new Intent(Intent.ACTION_VIEW,uri);
        activity.startActivity(i);
        //
        //	Intent intent = new Intent();
        //	// インテントにアクション及びURLをセット
        //	intent.setAction(Intent.ACTION_VIEW);
        //	intent.setData(Uri.parse(url));
        // ブラウザ起動
        //	System.err.println((intent!=null) + " if the null that is true");
        //	this.activity.startActivity(intent);	}
    }
}
