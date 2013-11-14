package jp.co.fashiontv.fscan;

import android.content.Context;
import android.net.Uri;

/**
* Created by Alsor Zhou on 13-11-13.
*/
public class SearchParams {
    public Context context;
    public Uri uri;

    SearchParams(Context context, Uri uri) {
        this.context = context;
        this.uri = uri;
    }
}
