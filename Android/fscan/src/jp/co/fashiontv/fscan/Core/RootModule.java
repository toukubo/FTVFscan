package jp.co.fashiontv.fscan.Core;

/**
 * Created by veiz on 12/1/13.
 */
import dagger.Module;

/**
 * Add all the other modules to this one.
 */
@Module
    (
        includes = {
            AndroidModule.class,
            FTVModule.class
        }
    )
public class RootModule {
}
