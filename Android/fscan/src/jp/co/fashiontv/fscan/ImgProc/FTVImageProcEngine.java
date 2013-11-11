package jp.co.fashiontv.fscan.ImgProc;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.net.Uri;
import android.util.Log;
import android.widget.Toast;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import jp.co.fashiontv.fscan.Common.DeviceUtil;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVUser;
import jp.co.fashiontv.fscan.Common.StringUtil;
import jp.co.fashiontv.fscan.FTVWebViewActivity;
import jp.co.nec.gazirur.rtsearch.lib.bean.SearchResult;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTFeatureSearcher;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTSearchApi;
import org.apache.commons.lang3.time.DurationFormatUtils;
import org.apache.http.Header;
import android.webkit.URLUtil;

import java.io.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by Alsor Zhou on 13-11-9.
 */
public class FTVImageProcEngine {

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

//        int desiredHeight = (int) (height * factor);
//        // make a Drawable from Bitmap to allow to set the BitMap
//        // to the ImageView, ImageButton or what ever
//        return resizedBitmap;
//        Bitmap scaledBitmap = Bitmap.createBitmap(desiredWidth, desiredHeight, Bitmap.Config.ARGB_8888);
//
//        float ratioX = desiredWidth / (float) srcImage.getWidth();
//        float ratioY = desiredHeight / (float) srcImage.getHeight();
//        float middleX = desiredWidth / 2.0f;
//        float middleY = desiredHeight / 2.0f;
//
//        Matrix scaleMatrix = new Matrix();
//        scaleMatrix.setScale(ratioX, ratioY, middleX, middleY);
//
//        Canvas canvas = new Canvas(scaledBitmap);
//        canvas.setMatrix(scaleMatrix);
//        canvas.drawBitmap(srcImage, middleX - srcImage.getWidth() / 2, middleY - srcImage.getHeight() / 2, new Paint(Paint.FILTER_BITMAP_FLAG));
//
//        return srcImage;
    }

    /**
     * @param srcImage
     * @return
     */
    private static Bitmap imageResize(Bitmap srcImage) {
        return resizeImage(srcImage, 496);
    }

    /**
     * @param srcImage
     * @param saveWithName
     * @param useJpeg
     * @return
     */
    public static Bitmap imageResize(Bitmap srcImage, String saveWithName, boolean useJpeg) {
        Bitmap bm = imageResize(srcImage);

        // TODO: write to gallery
        return bm;
    }

    /**
     * @param context
     * @param bm
     * @return
     */
    public static String executeApi(Context context, Bitmap bm) {
        int width = 0;
        int height = 0;

        RTSearchApi api = new RTSearchApi(context);
        String resultCode = api.RTSearchAuth();

        if (!resultCode.isEmpty() && resultCode.equals("0000")) {
            /************* Create Instance API ****************/
            String inifilePath = "/mnt/sdcard/rtsearch/db/search.ini"; //画像識別用􏰀インスタンスを取得
            RTFeatureSearcher rtsearchlib = api.GetInstance(width, height, inifilePath);

            // if create instance failed, set error and write log.
            if (rtsearchlib == null) {
                return null;
            }

            /************* Image Search API ****************/
            //for calculation operation time
            Date startTime = new Date();


            List<SearchResult> result = rtsearchlib.ExecuteFeatureSearch(getBytesFromBitmap(bm), RTFeatureSearcher.SERVER_SERVICE_SEARCH);

            String brand_slug = null;

            //if search failed, set error.
            if (result == null) {
                //result count was 0
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

            /************* Terminate API ****************/
            rtsearchlib.CloseFeatureSearcher();

            return brand_slug;

        } else if (resultCode.equals("0101")) {//0101 : サービス未契約 (認証処理􏰁終了したが、サーバから􏰀応答によりサービス未契約
            Toast.makeText(context, "0101 : サービス未契約 (認証処理􏰁終了したが、サーバから􏰀応答によりサービス未契約", Toast.LENGTH_SHORT);
        } else if (resultCode.equals("0201")) {//0201 : 認証処理失敗 (認証に必要な情報が取得できない、サーバ側で認証に必要な情
            Toast.makeText(context, "0201 : 認証処理失敗 (認証に必要な情報が取得できない、サーバ側で認証に必要な情", Toast.LENGTH_SHORT);
        } else if (resultCode.equals("0501")) {//0501 : サーバ通信失敗 (サーバから􏰀HTTPステータスが不正􏰀場合に返却される)
            Toast.makeText(context, "0501 : サーバ通信失敗 (サーバから􏰀HTTPステータスが不正􏰀場合に返却される)", Toast.LENGTH_SHORT);
        } else if (resultCode.equals("0901")) {//0901 : 接続失敗 (圏外などでサーバへ􏰀接続ができない場合に返却される)
            Toast.makeText(context, "0901 : 接続失敗 (圏外などでサーバへ􏰀接続ができない場合に返却される)", Toast.LENGTH_SHORT);
        }

        return null;

    }

    /**
     * Async HTTP Post
     *
     * @param context
     * @param
     * @param brand_slug recognized brand from nec engine
     */
    public static void postData(final Context context, String brand_slug) {
        RequestParams params = new RequestParams();
        params.put("user_id", FTVUser.getID());
        params.put("brand_slug", brand_slug);

        File image = new File(DeviceUtil.photoDirectory() + "/resize.jpg");
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

    public static void commonProcess(Context context, Uri uri) {
        FileInputStream fis = null;
        try {
            String path = uri.toString();
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
            return;
        }

        Bitmap originImage = BitmapFactory.decodeStream(fis);

        // resize image data
        Bitmap resizedImage = FTVImageProcEngine.imageResize(originImage, StringUtil.randomFilename(), true);

        Log.d(TAG, String.format("resizedImage : w - %d, h - %d", resizedImage.getWidth(), resizedImage.getHeight()));

        try {
            FileOutputStream orig = new FileOutputStream(DeviceUtil.photoDirectory() + "/orig.jpg");
            FileOutputStream resize = new FileOutputStream(DeviceUtil.photoDirectory() + "/resize.jpg");

            originImage.compress(Bitmap.CompressFormat.JPEG, 90, orig);
            orig.close();
            resizedImage.compress(Bitmap.CompressFormat.JPEG, 90, resize);
            resize.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // execute API in sync mode, call NEC stuff
        String brand_slug = FTVImageProcEngine.executeApi(context, resizedImage);
        Log.d(TAG, String.format("brand slug : %s", brand_slug));

        if (brand_slug == null) {
            brand_slug = "GUCCI";
        }

        // image post to our server
        FTVImageProcEngine.postData(context, brand_slug);
    }

    /**
     * @param id
     * @return
     */
    public static String encapsulateById(String id) {
        return String.format("%s%s%s%s%s", FTVConstants.baseUrl, "scan/scan.php?deviceid=", FTVUser.getID(), "&id=", id);
    }

    /**
     * @param context
     * @param url
     */
    public static void openExternalBrowser(Context context, String url) {
        Uri uri = Uri.parse(url);
        Intent i = new Intent(Intent.ACTION_VIEW, uri);
        context.startActivity(i);
    }

    /**
     * @param bm
     * @return
     */
    private static byte[] getBytesFromBitmap(Bitmap bm) {
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bm.compress(Bitmap.CompressFormat.JPEG, 100, stream);

        return stream.toByteArray();
    }
}
