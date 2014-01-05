package jp.co.fashiontv.fscan.ImgProc;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.util.Log;
import android.webkit.URLUtil;
import android.widget.Toast;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.testflightapp.lib.TestFlight;
import jp.co.fashiontv.fscan.Activities.FTVWebViewActivity;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVUser;
import jp.co.fashiontv.fscan.Gaziru.GaziruSearchParams;
import jp.co.fashiontv.fscan.Utils.FTVUtil;
import jp.co.fashiontv.fscan.Utils.ImageUtil;
import jp.co.nec.gazirur.rtsearch.lib.bean.SearchResult;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTFeatureSearcher;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTSearchApi;
import org.apache.commons.lang3.time.DurationFormatUtils;
import org.apache.http.Header;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by Alsor Zhou on 13-11-9.
 */
public class FTVImageProcEngine {
    private boolean processed = false;

    public boolean isProcessed() {
        return processed;
    }

    public void setProcessed(boolean processed) {
        this.processed = processed;
    }

    private static String TAG = "FTVImageProcEngine";

    /**
     * Rotate Bitmap
     *
     * @param srcImage source image
     * @param angle    wanted rotate angle, must be 0, 90, 180, 270.
     *                 http://developer.android.com/reference/android/hardware/Camera.Parameters.html#setRotation(int)
     * @return
     */
    public static Bitmap rotateImage(Bitmap srcImage, final int angle) {
        // http://stackoverflow.com/a/16218346
        Matrix matrix = new Matrix();
        matrix.postRotate(angle);
        srcImage = Bitmap.createBitmap(srcImage, 0, 0, srcImage.getWidth(), srcImage.getHeight(), matrix, true);
        return srcImage;
    }

    /**
     * @param srcImage
     * @param desiredWidth
     * @return
     */
    private static Bitmap resizeImage(Bitmap srcImage, final int desiredWidth) {
        // Create the Resize Matrix
        int width = srcImage.getWidth();
        int height = srcImage.getHeight();

        // calculate the scale
        float factor = ((float) desiredWidth) / width;

        // create matrix for the manipulation
        Matrix matrix = new Matrix();
        // resize the bit map
        matrix.postScale(factor, factor);

        // recreate the new Bitmap
        Bitmap resizedBitmap = Bitmap.createBitmap(srcImage, 0, 0, width, height, matrix, false);

        return resizedBitmap;
    }

    /**
     * Resize Image and save to album
     *
     * @param srcImage     source image
     * @param saveWithName image name
     * @param useJpeg      need jpeg format or else
     * @return resized image
     */
    public static Bitmap imageResize(Bitmap srcImage, String saveWithName, boolean useJpeg) {
        Bitmap bm = resizeImage(srcImage, 496);

        return bm;
    }

    /**
     * Execute Image Feature Search with NEC Gaziru library.
     * <p/>
     * Important: must NOT be invoked from ui(main) thread, otherwise crash will be encountered. The library enabled STRICT_MODE.
     *
     * @param context application context
     * @param bm      target bitmap
     * @return brand slug
     */
    public static String executeApi(Context context, Bitmap bm) {
        int width = bm.getWidth();
        int height = bm.getHeight();

        RTSearchApi api = new RTSearchApi(context);
        String resultCode = api.RTSearchAuth();

        if (resultCode != null && resultCode.equals("0000")) {
            String inifilePath = FTVUtil.getAssetsDicPath(context);
            RTFeatureSearcher rtsearchlib = api.GetInstance(width, height, inifilePath);

            // if create instance failed, set error and write log.
            if (rtsearchlib == null) {
                return null;
            }

            //for calculation operation time
            Date startTime = new Date();
            int[] ints = getIntsFromBitmap(bm);

            byte[] bytes = new byte[width * height * 4];

            // Important : gaziru need YUV420 for image search
            ImageUtil.encodeYUV420SP(bytes, ints, width, height);

            List<SearchResult> result = rtsearchlib.ExecuteFeatureSearch(bytes, RTFeatureSearcher.SERVER_SERVICE_SEARCH);

            String brandSlug = null;

            if (result == null) {
                brandSlug = "failure";
            } else if (result.size() == 0) {
                brandSlug = "failure";
            } else {
                SearchResult bland_dict = result.get(0);
                ArrayList<String> appendedInfos = bland_dict.getAppendInfo();
                brandSlug = appendedInfos.get(0);
            }

            // count the operation duration
            DurationFormatUtils.formatDuration(startTime.getTime(), "H:mm:ss", true);

            rtsearchlib.CloseFeatureSearcher();

            return brandSlug;

        } else if (resultCode.equals("0101")) {
            //TODO:
        } else if (resultCode.equals("0201")) {
            //TODO:
        } else if (resultCode.equals("0501")) {
            //TODO:
        } else if (resultCode.equals("0901")) {
            //TODO:
        }

        TestFlight.passCheckpoint(String.format("FTVImageProcEngine - executeApi result code : %s", resultCode));

        return null;
    }

    /**
     * Post resized image to our server in async mode
     *
     * @param context   application context
     * @param brandSlug recognized brand from gaziru engine
     */
    public static void postData(final Context context, String brandSlug, final String imagePath) {
        final RequestParams params = new RequestParams();
        params.put("user_id", FTVUser.getID());
        params.put("brand_slug", brandSlug);

        String url = String.format("%s%s", FTVConstants.baseUrl, "scan/post.php");

        // step 1 - post without image to get the post id
        AsyncHttpClient client = new AsyncHttpClient();
        client.setTimeout(FTVConstants.httpTimeout);
        client.post(url, params, new AsyncHttpResponseHandler() {
            @Override
            public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                // get post id here
                final String postId = new String(responseBody);
                Log.d(TAG, "Post ID : " + postId);
                params.put("id", postId);

                try {
                    File image = new File(imagePath);
                    params.put("image", image);
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                    Toast.makeText(context, "Can not find the taken image, please plugin your SD card.", Toast.LENGTH_SHORT);

                    return;
                }

                String url = String.format("%s%s", FTVConstants.baseUrl, "scan/postPhoto.php");

                // step 2 - post image to server
                AsyncHttpClient client = new AsyncHttpClient();
                client.setTimeout(FTVConstants.httpTimeout);
                client.post(url, params, new AsyncHttpResponseHandler() {
                    @Override
                    public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                        String url = encapsulateById(postId);

                        Log.d(TAG, "Redirect URL to : " + url);

                        if (URLUtil.isValidUrl(url)) {
                            Intent is = new Intent(context, FTVWebViewActivity.class);
                            is.putExtra("url", url);
                            context.startActivity(is);

                        } else {
                            Toast.makeText(context, "Malform url", Toast.LENGTH_SHORT);
                        }
                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {
                        Log.e(TAG, "Failed to post image data to server, response - " + new String(responseBody));
                    }
                });
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {
                Log.e(TAG, "Failed to get post ID");
            }
        });
    }

    /**
     * Processor to execute image search and upload to our server  - Step 1
     *
     * @param param Gaziru needed search parameter
     * @return String matched brand slug, or empty if not matched
     */
    public static String imageSearchProcess(GaziruSearchParams param) {
        TestFlight.passCheckpoint("FTVImageProcEngine - imageSearchProcess");

        // FIXME: test only, bypass the image recognization
        Context context = param.context;

        String path = param.imagePath;
        Log.d(TAG, "Image Process Path - " + path);

        FileInputStream fis = null;
        try {
            fis = new FileInputStream(path);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return null;
        }

        Bitmap resizedImage = BitmapFactory.decodeStream(fis);

        Log.d(TAG, String.format("resizedImage : w - %d, h - %d", resizedImage.getWidth(), resizedImage.getHeight()));

        // execute API in sync mode, call NEC stuff
        String brandSlug = FTVImageProcEngine.executeApi(context, resizedImage);
        Log.d(TAG, String.format("BRAND SLUG - %s\n", brandSlug));

        if (brandSlug == null) {
            brandSlug = "UNKNOWN";
        }

        return brandSlug;

    }

    /**
     * post image to our server with brand slug   -   Step 2
     * this steps was little bit slow, so we need to execute it in async mode
     *
     * @param param GaziruSearchParams
     * @return null
     */
    public static Void imagePostProcess(GaziruSearchParams param) {
        TestFlight.passCheckpoint("FTVImageProcEngine - imagePostProcess");

        postData(param.context, param.brandSlug, param.imagePath);

        return null;
    }

    /**
     * Formated URL
     *
     * @param id post id from server response
     * @return url to redirect
     */
    public static String encapsulateById(String id) {
        return String.format("%s%s%s%s%s", FTVConstants.baseUrl, "scan/scan.php?deviceid=", FTVUser.getID(), "&id=", id);
    }

    /**
     * Get bitmap in bytes
     *
     * @param bm target bitmap
     * @return bytes representation of bitmap
     */
    public static byte[] getBytesFromBitmap(Bitmap bm) {
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bm.compress(Bitmap.CompressFormat.PNG, 100, stream);

        return stream.toByteArray();
    }

    /**
     * Get bitmap in int[] format
     *
     * @param bm target bitmap
     * @return bytes in int[]
     */
    public static int[] getIntsFromBitmap(Bitmap bm) {
        int[] intArray = new int[bm.getWidth() * bm.getHeight()];

        //copy pixel data from the Bitmap into the 'intArray' array
        bm.getPixels(intArray, 0, bm.getWidth(), 0, 0, bm.getWidth(), bm.getHeight());
        return intArray;
    }
}
