package jp.co.fashiontv.fscan.ImgProc;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.net.Uri;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVUser;
import jp.co.nec.gazirur.rtsearch.lib.bean.SearchResult;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTFeatureSearcher;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTSearchApi;
import org.apache.commons.lang3.time.DurationFormatUtils;
import org.apache.http.Header;

import java.io.ByteArrayOutputStream;
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

        } else if (resultCode.equals("0201")) {//0201 : 認証処理失敗 (認証に必要な情報が取得できない、サーバ側で認証に必要な情

        } else if (resultCode.equals("0501")) {//0501 : サーバ通信失敗 (サーバから􏰀HTTPステータスが不正􏰀場合に返却される)

        } else if (resultCode.equals("0901")) {//0901 : 接続失敗 (圏外などでサーバへ􏰀接続ができない場合に返却される)

        }

        return null;

    }

    /**
     * Async HTTP Post
     *
     * @param bm
     * @param brand_slug
     */
    public static void postData(Bitmap bm, String brand_slug) {
        // config params
        RequestParams params = new RequestParams();
        params.put("user_id", FTVUser.getID());
        params.put("brand_slug", brand_slug);
        params.put("image", getBytesFromBitmap(bm));

        String url = String.format("%s%s", FTVConstants.baseUrl, "scan/post.php");

        AsyncHttpClient client = new AsyncHttpClient();
        client.setTimeout(FTVConstants.httpTimeout);
        client.post(url, params, new AsyncHttpResponseHandler() {
            @Override
            public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                super.onSuccess(statusCode, headers, responseBody);
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {
                super.onFailure(statusCode, headers, responseBody, error);
            }
        });
    }

    /**
     * @param id
     * @return
     */
    public static String encapsulateById(String id) {
        return String.format("%s%s%s%s%s", FTVConstants.baseUrl, "/scan/scan.php?deviceid=", FTVUser.getID(), "&id=", id);
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
