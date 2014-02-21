/*
 * Created by GAZIRU Developer on 14/01/21
 * Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
 */

package jp.co.fashiontv.fscan.Utils;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;

import jp.co.fashiontv.fscan.R;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.Bitmap.CompressFormat;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.MediaStore.Images;
import android.util.Log;

public class ImageUtil {
    private static final String TAG = "ImageUtil";

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

    /** ��������������������� */
    private static final SimpleDateFormat FILE_NAME_DATEFORMAT = new SimpleDateFormat("yyyyMMdd-HHmmss");
    /**  */
    private static final String SAVE_IMAGE_ROOTDIR = Environment.getExternalStorageDirectory().getAbsolutePath();

    /**
     * ���������������������(������������������������������) .
     */
    private ImageUtil() {
    }

    /**
     * @see http://embedav.blogspot.jp/2013/06/convert-rgb-to-yuv420-planar-format-in.html
     * @param aRGB
     * @param width
     * @param height
     * @return
     */
    public static byte[] colorconvertRGB_IYUV_I420(int[] aRGB, int width, int height) {
        final int frameSize = width * height;
        final int chromasize = frameSize / 4;

        int yIndex = 0;
        int uIndex = frameSize;
        int vIndex = frameSize + chromasize;
        byte[] yuv = new byte[width * height * 3 / 2];

        // int a, R, G, B, Y, U, V;
        int R, G, B, Y, U, V;
        int index = 0;
        for (int j = 0; j < height; j++) {
            for (int i = 0; i < width; i++) {

                // a = (aRGB[index] & 0xff000000) >> 24; //not using it right now
                R = (aRGB[index] & 0xff0000) >> 16;
                G = (aRGB[index] & 0xff00) >> 8;
                B = (aRGB[index] & 0xff) >> 0;

                Y = ((66 * R + 129 * G + 25 * B + 128) >> 8) + 16;
                U = ((-38 * R - 74 * G + 112 * B + 128) >> 8) + 128;
                V = ((112 * R - 94 * G - 18 * B + 128) >> 8) + 128;

                yuv[yIndex++] = (byte) ((Y < 0) ? 0 : ((Y > 255) ? 255 : Y));

                if (j % 2 == 0 && index % 2 == 0) {
                    yuv[uIndex++] = (byte) ((U < 0) ? 0 : ((U > 255) ? 255 : U));
                    yuv[vIndex++] = (byte) ((V < 0) ? 0 : ((V > 255) ? 255 : V));
                }

                index++;
            }
        }
        return yuv;
    }

    /**
     * YUV420SP���ARGB8888 Bitmap������������������������������
     * ������YUV420SP���ARGB8888 Bitmap���������������������������������������
     * ������trimRect������������������������������������������������
     * ������������������������������������������������
     *
     * @param data YUV420SP������������
     * @param resolution data���������
     * @param trimRect ���������������������
     * @param scale ���������
     * @return ARGB8888 Bitmap
     */
    public static Bitmap createScaledBitmapFromYUV420SP(byte[] data, Point resolution, Rect trimRect, float scale) {
        Bitmap tmp = getBitmapFromYUV420SP(data, resolution);
        Matrix m = new Matrix();
        m.postScale(scale, scale);
        Bitmap bmp = Bitmap.createBitmap(tmp, trimRect.left, trimRect.top, trimRect.width(), trimRect.height(), m, true);
        tmp.recycle();
        return bmp;
    }

    /**
     * YUV420SP���������������ARGB8888 Bitmap������������
     * YUV420SP���������������ARGB8888 Bitmap���������������������������������������
     *
     * @param data YUV420SP������������
     * @param resolution data���������
     * @return ARGB8888 Bitmap
     */
    public static Bitmap getBitmapFromYUV420SP(byte[] data, Point resolution) {
        return getBitmapFromYUV420SP(data, resolution.x, resolution.y);
    }

    /**
     * YUV420SP���������������ARGB8888 Bitmap������������
     * YUV420SP���������������ARGB8888 Bitmap���������������������������������������
     *
     * @param data YUV420SP������������
     * @param width data������������
     * @param height data������������
     * @return ARGB8888 Bitmap
     */
    public static Bitmap getBitmapFromYUV420SP(byte[] data, int width, int height) {
        // Array pixel of ARGB8888
        int[] rgb = new int[(width * height)];

        // Create empty bitmap
        Bitmap bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);

        // Change from ARGB format to YUV420 format
        ImageUtil.decodeYUV420SP(rgb, data, width, height);

        // Set bitmap from pixel is changed
        bmp.setPixels(rgb, 0, width, 0, 0, width, height);
        return bmp;
    }

    /**
     * Bitmap������������������
     * ���������Bitmap���������90���������������������
     *
     * @param source ������������bitmap
     * @return ���������Bitmap
     */
    public static Bitmap createBitmapRotated(Bitmap source) {
        Matrix m = new Matrix();
        m.postRotate(90.0f);
        Bitmap bmp = Bitmap.createBitmap(source, 0, 0, source.getWidth(), source.getHeight(), m, true);
        return bmp;
    }

    /**
     * SD������������������������������������
     *
     * @return
     */
    public static String saveImageSD(Context context, Bitmap bmp) {

        // ������������������������
        String fileDir = SAVE_IMAGE_ROOTDIR + "/" + context.getString(R.string.imageutil_savebitmapsd_savesubdirname);

        // ���������������
        String fileName;
        synchronized (FILE_NAME_DATEFORMAT) {
            fileName = context.getString(R.string.imageutil_savebitmapsd_filenameprefix) + FILE_NAME_DATEFORMAT.format(new Date()) + ".png";
        }

        // OutputStream������
        OutputStream os = null;

        // ������������Path
        String filePath = fileDir + "/" + fileName;

        try {
            // ������������������������������������������������
            File dir = new File(fileDir);

            // ������������������������������������������������
            if (!dir.exists()) {
                dir.mkdir();
                Log.d(TAG, "create directory:" + dir.toString());
            }

            // ������������������������������
            File file = new File(fileDir, fileName);

            // ���������������������������
            if (file.createNewFile()) {

                // FileOutputStream���������������������������
                os = new FileOutputStream(file);

                // Bitmap������������������������
                if (bmp != null) {

                    // JPEG���������������������
                    bmp.compress(CompressFormat.PNG, 100, os);

                }
            }
        } catch (IOException e) {
            Log.w(TAG, e);
            return null;
        } finally {

            // OutputStream������������������close������
            if (os != null) {

                try {
                    os.close();

                } catch (Throwable t) {
                    Log.w(TAG, t);
                }
            }
        }

        // ������������������������������������������������������
        ContentResolver cr = context.getContentResolver();
        ContentValues values = new ContentValues(7);
        values.put(Images.Media.TITLE, fileName); // ������������
        values.put(Images.Media.DISPLAY_NAME, fileName); // ���������
        values.put(Images.Media.DATE_TAKEN, System.currentTimeMillis());// ���������������������
        values.put(Images.Media.MIME_TYPE, "image/png"); // MIME���������
        values.put(Images.Media.DATA, filePath); // ���������
        cr.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);

        Log.d(TAG, "filePath = " + filePath);
        return filePath;
    }
}
