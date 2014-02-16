/*
 * Created by GAZIRU Developer on 14/01/21
 * Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
 */

package jp.co.fashiontv.fscan.Logic;

import java.util.List;

import jp.co.fashiontv.fscan.Utils.ImageUtil;
import jp.co.nec.gazirur.rtsearch.lib.bean.SearchResult;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTFeatureSearcher;
import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTSearchApi;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.graphics.Rect;
import android.util.Log;

/**
 * 画像識別処理ロジック。
 * 画像識別ライブラリの画像識別APIを実行するクラスです。
 * 実行時の引数はカメラプレビューデータとなります。
 */
public class SearchLogic {
    private static final String TAG = "SearchLogic";
    /** クエリ画像サイズ(QVGA以下を必須とする) */
    private static final int QUERY_IMAGE_WIDTH = 320;
    private static final int QUERY_IMAGE_HEIGHT = 240;
    /** 画像識別インスタンス */
    private RTFeatureSearcher feSearcher;
    /** クエリ画像 */
    private Bitmap queryImageBMP = null;

    /**
     * コンストラクタ
     */
    public SearchLogic() {
    }

    /**
     * クエリ画像取得処理
     * 検索実行する際に利用したクエリ画像を取得する処理です。
     * ARGB 8888 Bitmap形式で返却します。
     *
     * @return queryImageBMP
     */
    public Bitmap getQueryImageBMP() {
        return queryImageBMP;
    }

    /**
     * 画像識別APIを実行
     * @param data プレビューデータ
     * @param context アプリケーションコンテキスト
     * @param cameraResolution カメラ解像度
     * @return 識別結果
     */
    public List<SearchResult> executeSearch(byte[][] data, Context context, Point cameraResolution) {
        Log.d(TAG, "executeSearch() start");

        if (data[0] == null) {
            Log.i(TAG, "executeSearch() data[0] = null");
        } else {
            Log.i(TAG, "executeSearch() data[0].length = " + data[0].length);
        }

        // YUV420バイナリ→ARGB_8888 Bitmap変換（リスケール）
        // クエリ画像はQVGAサイズ以下を必須とする
        float scaleW = (float) (QUERY_IMAGE_WIDTH) / cameraResolution.x;
        float scaleH = (float) (QUERY_IMAGE_HEIGHT) / cameraResolution.y;
        float scale = Math.min(scaleW, scaleH);
        Rect trimRect = new Rect(0, 0, cameraResolution.x, cameraResolution.y);
        Bitmap scaledBMP = ImageUtil.createScaledBitmapFromYUV420SP(data[0], cameraResolution, trimRect, scale);
        // GAZIRU検索用画像を生成
        int width = (scaledBMP.getWidth() / 4) * 4;
        int height = (scaledBMP.getHeight() / 4) * 4;
        int[] rgb = new int[width * height];
        // リサイズ後のBitmapをYUV420に再変換
        scaledBMP.getPixels(rgb, 0, scaledBMP.getWidth(), 0, 0, width, height);
        byte[] queryImageYUV = ImageUtil.colorconvertRGB_IYUV_I420(rgb, width, height);

        // クエリ画像表示用に回転
        queryImageBMP = ImageUtil.createBitmapRotated(scaledBMP);
        Log.d(TAG, "executeSearch() cameraResolution = " + cameraResolution + " : width = " + width + " : height = " + height);

        // 識別インスタンス取得
        feSearcher = new RTSearchApi(context).GetInstance(width, height, "");
        if (feSearcher != null) {
        	// 識別処理を実行
            List<SearchResult> searchResults = feSearcher.ExecuteFeatureSearch(queryImageYUV, RTFeatureSearcher.SERVER_SERVICE_SEARCH);
            if (searchResults == null) {
                Log.i(TAG, "executeSearch() searchResults == null");
            } else {
                Log.i(TAG, "executeSearch() searchResults.size() = " + searchResults.size());
            }
            Log.d(TAG, "executeSearch() end");

            // 終了APIコール
            feSearcher.CloseFeatureSearcher();

            return searchResults;
        }
        Log.d(TAG, "executeSearch() end feSearcher is null");
        return null;
    }

}
