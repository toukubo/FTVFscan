package jp.co.fashiontv.fscan;

import com.squareup.otto.Bus;
import dagger.Module;
import dagger.Provides;
import jp.co.fashiontv.fscan.Activities.FTVMainActivity;
import jp.co.fashiontv.fscan.Activities.FTVSplashActivity;
import jp.co.fashiontv.fscan.Activities.FTVWebViewActivity;
import jp.co.fashiontv.fscan.Common.FTVNavigatorWebClient;
import jp.co.fashiontv.fscan.Core.FTVApplication;

import javax.inject.Singleton;

/**
 * Created by veiz on 12/1/13.
 */
@Module
    (
        complete = false,

        injects = {
            FTVApplication.class,
            FTVMainActivity.class,
            FTVSplashActivity.class,
            FTVWebViewActivity.class,
            FTVNavigatorWebClient.class
        }

    )
public class FTVModule  {

    @Singleton
    @Provides
    Bus provideOttoBus() {
        return new Bus();
    }

//    @Provides
//    @Singleton
//    LogoutService provideLogoutService(final Context context, final AccountManager accountManager) {
//        return new LogoutService(context, accountManager);
//    }

}