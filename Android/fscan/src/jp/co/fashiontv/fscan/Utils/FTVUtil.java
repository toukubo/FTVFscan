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
 * <p/>
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

    /**
     * Decode YUV(NV21) format to RGB - NOT USED IN PROJECT
     *
     * @param rgb    RGB format bytes (output)
     * @param data   source YUV format bytes (input)
     * @param width  source image width
     * @param height source image height
     */
    public static final void decodeYUV420SP(int[] rgb, byte[] data, int width, int height) {
        final int frameSize = width * height;

        for (int j = 0, yp = 0; j < height; j++) {
            int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
            for (int i = 0; i < width; i++, yp++) {
                int y = (0xff & ((int) data[yp])) - 16;
                if (y < 0)
                    y = 0;
                if ((i & 1) == 0) {
                    v = (0xff & data[uvp++]) - 128;
                    u = (0xff & data[uvp++]) - 128;
                }

                int y1192 = 1192 * y;
                int r = (y1192 + 1634 * v);
                int g = (y1192 - 833 * v - 400 * u);
                int b = (y1192 + 2066 * u);

                if (r < 0)
                    r = 0;
                else if (r > 262143)
                    r = 262143;
                if (g < 0)
                    g = 0;
                else if (g > 262143)
                    g = 262143;
                if (b < 0)
                    b = 0;
                else if (b > 262143)
                    b = 262143;

                rgb[yp] = 0xff000000 | ((r << 6) & 0xff0000) | ((g >> 2) & 0xff00) | ((b >> 10) & 0xff);
            }
        }
    }

    /**
     * Encode ARGB format image to YUV(NV21)
     * <p/>
     * http://stackoverflow.com/a/17539753
     *
     * @param yuv420sp YUV format bytes
     * @param argb     source image bytes
     * @param width    source image width
     * @param height   source image height
     */
    public static void encodeYUV420SP(byte[] yuv420sp, int[] argb, int width, int height) {
        final int frameSize = width * height;

        int yIndex = 0;
        int uIndex = frameSize;
        int vIndex = frameSize + ((yuv420sp.length - frameSize) / 2);

        int a, R, G, B, Y, U, V;
        int index = 0;
        for (int j = 0; j < height; j++) {
            for (int i = 0; i < width; i++) {

                // argb
                a = (argb[index] & 0xff000000) >> 24; // a is not used obviously
                R = (argb[index] & 0xff0000) >> 16;
                G = (argb[index] & 0xff00) >> 8;
                B = (argb[index] & 0xff) >> 0;

                // rgba
//                r = (rgba[index] & 0xff000000) >> 24;
//                g = (rgba[index] & 0xff0000) >> 16;
//                b = (rgba[index] & 0xff00) >> 8;

                // well known RGB to YUV algorithm
                Y = ((66 * R + 129 * G + 25 * B + 128) >> 8) + 16;
                U = ((-38 * R - 74 * G + 112 * B + 128) >> 8) + 128;
                V = ((112 * R - 94 * G - 18 * B + 128) >> 8) + 128;

                // NV21 has a plane of Y and interleaved planes of VU each sampled by a factor of 2
                //    meaning for every 4 Y pixels there are 1 V and 1 U.  Note the sampling is every other
                //    pixel AND every other scanline.
                yuv420sp[yIndex++] = (byte) ((Y < 0) ? 0 : ((Y > 255) ? 255 : Y));
                if (j % 2 == 0 && index % 2 == 0) {
                    yuv420sp[uIndex++] = (byte) ((U < 0) ? 0 : ((U > 255) ? 255 : U));
                    yuv420sp[vIndex++] = (byte) ((V < 0) ? 0 : ((V > 255) ? 255 : V));
                }

                index++;
            }
        }
    }
}
