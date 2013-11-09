package jp.co.fashiontv.fscan.Common;

import android.content.Context;
import android.telephony.TelephonyManager;
import jp.co.fashiontv.fscan.FTVApplication;

import java.util.UUID;

/**
 * Created by veiz on 13-11-9.
 */
public class FTVUser {

    public static String getID() {
        Context context = FTVApplication.getContext();
        final TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);

        final String tmDevice, tmSerial, androidId;
        tmDevice = "" + tm.getDeviceId();
        tmSerial = "" + tm.getSimSerialNumber();
        androidId = "" + android.provider.Settings.Secure.getString(context.getContentResolver(), android.provider.Settings.Secure.ANDROID_ID);

        UUID deviceUuid = new UUID(androidId.hashCode(), ((long)tmDevice.hashCode() << 32) | tmSerial.hashCode());
        String deviceId = deviceUuid.toString();

        return deviceId;
    }
}
