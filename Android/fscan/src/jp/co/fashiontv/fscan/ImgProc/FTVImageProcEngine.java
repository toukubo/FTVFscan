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
import jp.co.fashiontv.fscan.Common.DeviceUtil;
import jp.co.fashiontv.fscan.Common.FTVConstants;
import jp.co.fashiontv.fscan.Common.FTVUser;
import jp.co.fashiontv.fscan.Common.StringUtil;
import jp.co.fashiontv.fscan.FTVWebViewActivity;
import jp.co.fashiontv.fscan.SearchParams;
import jp.co.nec.gazirur.rtsearch.lib.bean.SearchResult;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTFeatureSearcher;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTSearchApi;
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
        int width = bm.getWidth();
        int height = bm.getHeight();

        RTSearchApi api = new RTSearchApi(context);
        String resultCode = api.RTSearchAuth();

        if (resultCode != null && resultCode.equals("0000")) {
            String inifilePath = "/mnt/sdcard/rtsearch/db/search.ini";
            RTFeatureSearcher rtsearchlib = api.GetInstance(width, height, inifilePath);

            // if create instance failed, set error and write log.
            if (rtsearchlib == null) {
                return null;
            }

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

            rtsearchlib.CloseFeatureSearcher();

            return brand_slug;

        } else if (resultCode.equals("0101")) {
//            Toast.makeText(context, "0101 : ��������������������� (�����������������������������������������������������������������������������������������", Toast.LENGTH_SHORT);
        } else if (resultCode.equals("0201")) {//0201 : ������������������ (������������������������������������������������������������������������������������
//            Toast.makeText(context, "0201 : ������������������ (������������������������������������������������������������������������������������", Toast.LENGTH_SHORT);
        } else if (resultCode.equals("0501")) {//0501 : ��������������������� (�������������������HTTP����������������������������������������������������)
//            Toast.makeText(context, "0501 : ��������������������� (�������������������HTTP����������������������������������������������������)", Toast.LENGTH_SHORT);
        } else if (resultCode.equals("0901")) {//0901 : ������������ (����������������������������������������������������������������������������)
//            Toast.makeText(context, "0901 : ������������ (����������������������������������������������������������������������������)", Toast.LENGTH_SHORT);
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
    public  void postData(final Context context, String brand_slug) {
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

                if (URLUtil.isValidUrl(url)) {
                    processed = true;
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

    public static Void commonProcess(SearchParams param) {
        Context context = param.context;
        Uri uri = param.uri;

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
            return null;
        }

        Bitmap originImage = BitmapFactory.decodeStream(fis);

        // resize image data
        Bitmap resizedImage = FTVImageProcEngine.imageResize(originImage, StringUtil.randomFilename(), true);

        Log.d(TAG, String.format("resizedImage : w - %d, h - %d", resizedImage.getWidth(), resizedImage.getHeight()));

        try {
            FileOutputStream orig = new FileOutputStream(DeviceUtil.photoDirectory() + "/orig.png");
            FileOutputStream resize = new FileOutputStream(DeviceUtil.photoDirectory() + "/resize.png");

            originImage.compress(Bitmap.CompressFormat.PNG, 90, orig);
            orig.close();
            resizedImage.compress(Bitmap.CompressFormat.PNG, 90, resize);
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
//        postData(context, brand_slug);

        return null;
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


    /**
     * @param bm
     * @return
     */
    private static byte[] getBytesFromBitmap(Bitmap bm) {
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bm.compress(Bitmap.CompressFormat.PNG, 100, stream);

        return stream.toByteArray();
    }

//    private class ExecuteImageSearchTask extends
//        AsyncTask<Void, Void, ArrayList<Offer>> {
//
//        /**
//         * The system calls this to perform work in a worker thread and delivers
//         * it the parameters given to AsyncTask.execute()
//         */
//        protected ArrayList<Offer> doInBackground(Void... voids) {
//            return CapaProcess.obtainOffers();
//        }
//
//        private boolean isToday(Date date) {
//            return DateUtils.isToday(date.getTime());
//        }
//
//        /**
//         * The system calls this to perform work in the UI thread and delivers
//         * the result from doInBackground()
//         */
//        protected void onPostExecute(ArrayList<Offer> result) {
//            for (Offer of : result) {
//                if (isToday(of.departureDate)) {
//                    // TODO : there is only ONE deal each day, so just find out "TODAY".
//                    mOffer = of;
//
//                    // Rellenamos los controles en pantalla
//                    FillData();
//
//                    // Escondemos el progress dialog
//                    pdLoading.dismiss();
//
//                    tracker.trackEvent("TodayFragment", "ObtenerOferta", "Mostramos la oferta del d�a: " + mOffer.title, null);
//
//                    // Actualizamos el toast
//                    // Si lo hacemos sin retraso no se muestra. Se supone pq se
//                    // solapa con el di�logo
//                    final Handler handler = new Handler();
//                    handler.postDelayed(new Runnable() {
//                        @Override
//                        public void run() {
//                            Toast.makeText(mContext, R.string.disfruta_oferta,
//                                Toast.LENGTH_SHORT).show();
//                        }
//                    }, 100);
//
//                    return;
//                }
//            }
//        }
//    }

}
