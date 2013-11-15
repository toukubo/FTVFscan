package jp.co.fashiontv.fscan.Core;

import android.app.Application;
import android.content.Context;
import android.view.Display;
import android.view.WindowManager;

/**
 * Created by Alsor Zhou on 13-11-9.
 */
public class FTVApplication extends Application {
    static {
        System.loadLibrary("rtsearch");
    }

    private static FTVApplication instance;

    private static Display display;

    public static Context getContext() {
        return instance;
    }

    public FTVApplication() {
        super();

        instance = this;
        display = null;
    }

    public static Display getDisplay() {
        if (display == null) {
            WindowManager wm = (WindowManager) instance.getSystemService(Context.WINDOW_SERVICE);
            display = wm.getDefaultDisplay();
        }
        return display;
    }
}
