/*
 * Created by GAZIRU Developer on 14/01/21
 * Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
 */

package jp.co.fashiontv.fscan.Logic;

import jp.co.nec.gazirur.rtsearch.lib.clientapi.RTSearchApi;
import android.content.Context;
import android.util.Log;

/**
 * 企業認証処理ロジック。 
 * 画像識別ライブラリの企業認証APIを実行するクラスです。
 */
public class AuthLogic {
    private static final String TAG = "AuthLogic";

    /** アプリケーションコンテキスト */
    private Context context;

    /**
     * 企業認証処理コンストラクタ。
     * 企業認証完了通知リスナーおよびアプリケーションコンテキストを保持します。
     *
     * @param context アプリケーションコンテキスト
     */
    public AuthLogic(Context context) {
        this.context = context;
    }

    /**
     * GAZIRU認証を実行する
     * @return 認証結果
     */
    public String executeAuth() {
        Log.d(TAG, "AuthLogic.doInBackground() start");
        // 企業認証処理API実行
        RTSearchApi rtSearchApi = new RTSearchApi(context);
        // 認証処理
        String result = rtSearchApi.RTSearchAuth();
        Log.d(TAG, "AuthLogic.doInBackground() end. result = " + result);
        return result;
    }

}
