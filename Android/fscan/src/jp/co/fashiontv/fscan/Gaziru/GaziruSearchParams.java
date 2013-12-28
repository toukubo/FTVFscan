package jp.co.fashiontv.fscan.Gaziru;

import android.content.Context;

/**
* Created by Alsor Zhou on 13-11-13.
*/
public class GaziruSearchParams {
    public Context context;
    public String imagePath;
    public String brandSlug;

    public GaziruSearchParams(Context context, String path, String brandSlug) {
        this.context = context;
        this.imagePath = path;
        this.brandSlug = brandSlug;
    }
}
