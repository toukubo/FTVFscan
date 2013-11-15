package jp.co.fashiontv.fscan.Common;

import android.content.Context;
import android.net.Uri;

/**
* Created by Alsor Zhou on 13-11-13.
*/
public class GaziruSearchParams {
    public Context context;
    public Uri uri;

    public GaziruSearchParams(Context context, Uri uri) {
        this.context = context;
        this.uri = uri;
    }
}
