package jp.co.fashiontv.fscan.ImgProc;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.net.Uri;
import android.util.Log;
import android.webkit.URLUtil;
import android.widget.Toast;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import jp.co.fashiontv.fscan.Common.*;
import jp.co.fashiontv.fscan.Activities.FTVWebViewActivity;
import jp.co.fashiontv.fscan.Common.GaziruSearchParams;
import jp.co.fashiontv.fscan.Utils.DeviceUtil;
import jp.co.fashiontv.fscan.Utils.FTVUtil;
import jp.co.fashiontv.fscan.Utils.StringUtil;
import jp.co.nec.gazirur.rtsearch.lib.bean.SearchResult;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTFeatureSearcher;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTSearchApi;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.time.DurationFormatUtils;
import org.apache.http.Header;

import java.io.*;
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
     * @param srcImage
     * @return
     */
    private static Bitmap imageResize(Bitmap srcImage) {
        return resizeImage(srcImage, 496);
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
        Bitmap bm = imageResize(srcImage);

        // TODO: write to gallery
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
            FTVUtil.encodeYUV420SP(bytes, ints, width, height);

            List<SearchResult> result = rtsearchlib.ExecuteFeatureSearch(bytes, RTFeatureSearcher.SERVER_SERVICE_SEARCH);

            String brand_slug = null;

            if (result == null) {
                brand_slug = "failure";
            } else if (result.size() == 0) {
                brand_slug = "failure";
            } else {
                SearchResult bland_dict = result.get(0);
                ArrayList<String> appendedInfos = bland_dict.getAppendInfo();
                brand_slug = appendedInfos.get(0);
            }

            // count the operation duration
            DurationFormatUtils.formatDuration(startTime.getTime(), "H:mm:ss", true);

            rtsearchlib.CloseFeatureSearcher();

            return brand_slug;

        } else if (resultCode.equals("0101")) {

        } else if (resultCode.equals("0201")) {

        } else if (resultCode.equals("0501")) {

        } else if (resultCode.equals("0901")) {

        }

        return null;

    }

    /**
     * Post resized image to our server in async mode
     *
     * @param context    application context
     * @param brand_slug recognized brand from gaziru engine
     */
    public static void postData(final Context context, String brand_slug) {
        // Step 1 - image recognized with NEC stuff, get the matched "brand slug"
        RequestParams params = new RequestParams();
        params.put("user_id", FTVUser.getID());
        params.put("brand_slug", brand_slug);

        File image = new File(DeviceUtil.photoDirectory() + "/resize.png");
        try {
            params.put("image", image);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

        String url = String.format("%s%s", FTVConstants.baseUrl, "scan/post.php");

        AsyncHttpClient client = new AsyncHttpClient();
        client.setTimeout(FTVConstants.httpTimeout);
        client.post(url, params, new AsyncHttpResponseHandler() {
            @Override
            public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                String url = encapsulateById(new String(responseBody));

                Log.d(TAG, "URL - " + url);

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

            }
        });
    }

    /**
     * Processor to execute image search and upload to our server  - Step 1
     *
     * @param param Gaziru needed search parameter
     * @return String
     */
    public static String imageSearchProcess(GaziruSearchParams param) {
        Context context = param.context;
        Uri uri = param.uri;

        FileInputStream fis = null;
        String path = uri.toString();

        try {
            if (path.startsWith("content://")) {
                // gallery picker
                path = StringUtil.getRealPathFromURI(context, uri);
            } else {
                // camera
                path = StringUtil.getRealPathFromString(path);
            }
            Log.d(TAG, "Image Process Path - " + path);

            fis = new FileInputStream(path);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return null;
        }

        Bitmap originImage = BitmapFactory.decodeStream(fis);

        // resize image data
        Bitmap resizedImage = FTVImageProcEngine.imageResize(originImage, StringUtil.randomFilename(), true);

        Log.d(TAG, String.format("resizedImage : w - %d, h - %d", resizedImage.getWidth(), resizedImage.getHeight()));

        String bname = FilenameUtils.getBaseName(path);
        try {
            FileOutputStream orig = new FileOutputStream(DeviceUtil.photoDirectory() + "/" + bname + "-orig.png");
            FileOutputStream resize = new FileOutputStream(DeviceUtil.photoDirectory() + "/" + bname + "-resize.png");

            originImage.compress(Bitmap.CompressFormat.PNG, 90, orig);
            orig.close();
            resizedImage.compress(Bitmap.CompressFormat.PNG, 90, resize);
            resize.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // execute API in sync mode, call NEC stuff
        String brand_slug = FTVImageProcEngine.executeApi(context, resizedImage);
        Log.d(TAG, String.format("BRAND SLUG - %s\n", brand_slug));

        if (brand_slug == null) {
            brand_slug = "UNKNOWN";
        }

        return brand_slug;
    }

    /**
     * post image to our server with brand slug   -   Step 2
     *   this steps was little bit slow, so we need to execute it in async mode
     * @param param GaziruSearchParams
     * @return null
     */
    public static Void imagePostProcess(GaziruSearchParams param) {
        Context context = param.context;
        String brand_slug = param.brandSlug;

        postData(context, brand_slug);

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
    private static byte[] getBytesFromBitmap(Bitmap bm) {
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bm.compress(Bitmap.CompressFormat.PNG, 100, stream);

        return stream.toByteArray();
    }

    /**
     * Get bitmap in int[]
     *
     * @param bm target bitmap
     * @return bytes in int[]
     */
    private static int[] getIntsFromBitmap(Bitmap bm) {
        int[] intArray = new int[bm.getWidth() * bm.getHeight()];

        //copy pixel data from the Bitmap into the 'intArray' array
        bm.getPixels(intArray, 0, bm.getWidth(), 0, 0, bm.getWidth(), bm.getHeight());
        return intArray;
    }
}
