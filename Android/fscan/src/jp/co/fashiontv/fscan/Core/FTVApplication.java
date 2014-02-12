package jp.co.fashiontv.fscan.Core;

import android.app.Application;
import android.app.Instrumentation;
import android.content.Context;
import android.view.Display;
import android.view.WindowManager;
import com.testflightapp.lib.TestFlight;

/**
 * Created by Alsor Zhou on 13-11-9.
 */
public class FTVApplication extends Application {
    static {
        System.loadLibrary("rtsearch");
    }

    private static FTVApplication instance;

    private static Display display;

    public FTVApplication() {
        super();
    }

    /**
     * Create main application
     *
     * @param context
     */
    public FTVApplication(final Context context) {
        this();

        attachBaseContext(context);

    }
    public static Display getDisplay() {
        if (display == null) {
            WindowManager wm = (WindowManager) instance.getSystemService(Context.WINDOW_SERVICE);
            display = wm.getDefaultDisplay();
        }
        return display;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        // Initialize TestFlight with your app token.
        // https://www.testflightapp.com/dashboard/applications/907671/token/
        TestFlight.takeOff(this, "a6693e1d-95e8-495b-a7c3-ff6e5bd7f2f8");
        TestFlight.passCheckpoint("Start FTVApplication");

        instance = this;
        display = null;

    }

    /**
     * Create main application
     *
     * @param instrumentation
     */
    public FTVApplication(final Instrumentation instrumentation) {
        this();
        attachBaseContext(instrumentation.getTargetContext());
    }

    public static FTVApplication getInstance() {
        return instance;
    }

}
