package jp.co.fashiontv.fscan.Utils;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Created by Alsor Zhou on 13-11-15.
 * Stolen from co.nec.gazirur.apitester
 */
public class FTVUtil {
    private static String TAG = "FTVUtil";

    /**
     * The dictionary folder name in assets *
     */
    private static String ASSETS_DIC_FOLDER = "dic";

    /**
     * ini filename *
     */
    private static String INI_FILENAME = "search.ini";

    /**
     * Method to copy dic folder of assets folder to local
     */
    public static void assets2Local(Context context) {
        Log.d(TAG, "start copy assets to local");

        // Read and output from assets
        String[] fileList;
        try {
            fileList = context.getResources().getAssets().list(ASSETS_DIC_FOLDER);

            if (fileList == null || fileList.length == 0) {
                Log.d(TAG,
                    "fileList is null or 0");
                return;
            }
            AssetManager as = context.getResources().getAssets();
            InputStream input = null;
            FileOutputStream output = null;

            for (String file : fileList) {
                Log.d(TAG,
                    "copy file = " + file);
                input = as.open(ASSETS_DIC_FOLDER + "/" + file);
                output = context.openFileOutput(file, Context.MODE_WORLD_READABLE);

                int DEFAULT_BUFFER_SIZE = 1024 * 4;

                byte[] buffer = new byte[DEFAULT_BUFFER_SIZE];
                int n = 0;
                while (-1 != (n = input.read(buffer))) {
                    output.write(buffer, 0, n);
                }
                output.close();
                input.close();
            }

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Get dictionary file path of assets folder
     *
     * @return
     */
    public static String getAssetsDicPath(Context context) {
        // Get assets folder path
        String asssetsFolder = "/data/data/" + context.getPackageName() + "/files/";

        // Get file name setting and create path
        String filePath = asssetsFolder + INI_FILENAME;
        Log.i(TAG, "dic file = " + filePath);

        return filePath;
    }
}
