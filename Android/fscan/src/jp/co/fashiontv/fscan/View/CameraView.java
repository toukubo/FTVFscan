/*
 * Created by GAZIRU Developer on 14/01/21
 * Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
 */

package jp.co.fashiontv.fscan.View;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import jp.co.fashiontv.fscan.Listener.CameraViewListener;
import android.content.Context;
import android.content.res.Configuration;
import android.hardware.Camera;
import android.hardware.Camera.Size;
import android.util.AttributeSet;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

/**
 * カメラビュークラス。
 * カメラプレビュー画像をSurfaceViewに描画、およびカメラのデバイス制御を行うクラスです。
 */
public class CameraView extends SurfaceView implements Camera.PreviewCallback, SurfaceHolder.Callback {
    private static final String TAG = "CameraView";

    /** カメラインスタンス */
    private Camera camera = null;
    /** 画面回転角度*/
    private int dOrientation = 90;
    /** Activity通知用リスナー */
    private CameraViewListener cameraViewListener = null;
    /** カメラプレビューサイズ */
    private Size mOptimalPreviewSize = null;

    /**
     * CameraViewコンストラクタ
     *
     * @param context
     * @param attrs
     */
    @SuppressWarnings("deprecation")
    public CameraView(Context context, AttributeSet attrs) {
        super(context, attrs);
        // surfaceholderの取得、登録
        getHolder().addCallback(this);
        getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
        // カメラオープン
        camera = Camera.open();
    }

    /*
     * (非 Javadoc) カメラープレビューデータ通知コールバック
     * @see android.hardware.Camera.PreviewCallback#onPreviewFrame(byte[], android.hardware.Camera)
     */
    @Override
    public void onPreviewFrame(byte[] data, Camera camera) {
        if (data == null) {
            // データが無い場合は何もしない
            return;
        }
        if (camera != this.camera) {
            // カメラが破棄済みまたはカメラが一致しない場合は何も行わない
            return;
        }
        if (cameraViewListener == null) {
            // リスナー登録がされていない場合は何もしない
            return;
        }
        // 再開要求がされるまでプレビューデータ通知を停止する
        // カメラからのプレビュー通知毎に識別APIをコールすることは禁止(通信過多のため)
        // 識別処理が完了したタイミングCameraActivity.searchExecuted()でコールバックを有効化する
        camera.setPreviewCallback(null);
        // リスナーにプレビューデータの通知をする
        cameraViewListener.notifyPreviewData(data);
    }

    /**
     * カメラプレビューデータ通知受信のリスナを設定する
     * @param cameraViewListener セットするcameraViewListener
     */
    public void setCameraViewListener(CameraViewListener cameraViewListener) {
        this.cameraViewListener = cameraViewListener;
    }

    /**
     * カメラインスタンス再生成処理
     */
    public synchronized void recreateCamera() {
        if (camera == null) {
            camera = Camera.open();
        }
    }

    /**
     * カメラプレビューサイズ取得
     * @return プレビューサイズ
     */
    public Size getPreviewSize() {
        return mOptimalPreviewSize;
    }

    /**
     * Get optimal size from size list, can be used to get the proper preview size and picutre size
     *
     * @param sizes target sizes
     * @param w source width
     * @param h source height
     * @return best match size from size list, based on the source size
     */
    private Size getOptimalSize(List<Size> sizes, int w, int h) {
        final double ASPECT_TOLERANCE = 0.05;
        double targetRatio = (double) w / h;
        if (sizes == null)
            return null;

        Size optimalSize = null;
        double minDiff = Double.MAX_VALUE;

        int targetHeight = h;

        // Try to find an size match aspect ratio and size
        for (Size size : sizes) {
            double ratio = (double) size.width / size.height;
            if (Math.abs(ratio - targetRatio) > ASPECT_TOLERANCE)
                continue;
            if (Math.abs(size.height - targetHeight) < minDiff) {
                optimalSize = size;
                minDiff = Math.abs(size.height - targetHeight);
            }
        }

        // Cannot find the one match the aspect ratio, ignore the requirement
        if (optimalSize == null) {
            minDiff = Double.MAX_VALUE;
            for (Size size : sizes) {
                if (Math.abs(size.height - targetHeight) < minDiff) {
                    optimalSize = size;
                    minDiff = Math.abs(size.height - targetHeight);
                }
            }
        }
        return optimalSize;
    }


    /*
     * (非 Javadoc)
     * @see android.view.SurfaceHolder.Callback#surfaceCreated(android.view.SurfaceHolder)
     */
    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        Log.d(TAG, "surfaceCreated start");

        // カメラインスタンスがない場合は処理を行わずに抜ける
        if (camera == null) {
            Log.d(TAG, "surfaceCreated end : camera instance is null");
            return;
        }

        // 縦画面固定に設定
        Configuration config = getResources().getConfiguration();
        if (config.orientation == Configuration.ORIENTATION_PORTRAIT) {
            camera.setDisplayOrientation(dOrientation);
        }

        // カメラの画像をプレビューに表示
        try {
            camera.setPreviewDisplay(holder);
        } catch (IOException e) {
            Log.e(TAG, "setPreviewDisplay failed!!", e);
        }

        // カメラのプレビュー画像を取得するリスナを登録する
        camera.setPreviewCallback(this);

        Log.d(TAG, "surfaceCreated end");
    }

    /*
     * (非 Javadoc)
     * @see android.view.SurfaceHolder.Callback#surfaceChanged(android.view.SurfaceHolder, int, int, int)
     */
    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        Log.d(TAG, "surfaceChanged start : scree size width = " + width + " height = " + height);
        // カメラインスタンスがない場合は処理を行わずに抜ける
        if (camera == null) {
            Log.d(TAG, "surfaceChanged end : camera instance is null");
            return;
        }
        // カメラパラメータ取得
        Camera.Parameters parameters = camera.getParameters();
        List<Size> rawSupportedSizes = parameters.getSupportedPreviewSizes();

        // サポートサイズをソート
        List<Camera.Size> supportedPreviewSizes = new ArrayList<Camera.Size>(rawSupportedSizes);
        Collections.sort(supportedPreviewSizes, new Comparator<Camera.Size>() {
            @Override
            public int compare(Camera.Size a, Camera.Size b) {
                int aPixels = a.height * a.width;
                int bPixels = b.height * b.width;
                if (bPixels < aPixels) {
                    return -1;
                }
                if (bPixels > aPixels) {
                    return 1;
                }
                return 0;
            }
        });
        for (Size size : supportedPreviewSizes) {
            Log.d(TAG, "Camera supported preview size : width - " + size.width + " height - " + size.height);
        }

        // サポートされているプレビュー解像度から画面解像度にマッチしたプレビューサイズを取得する
        mOptimalPreviewSize = getOptimalSize(supportedPreviewSizes, width, height);
        Log.d(TAG, "Camera set preview size : width - " + mOptimalPreviewSize.width + " height - " + mOptimalPreviewSize.height);
        // プレビューサイズを設定
        parameters.setPreviewSize(mOptimalPreviewSize.width, mOptimalPreviewSize.height);

        // カメラパラメータを設定
        loadCameraParams(parameters);
        camera.setParameters(parameters);

        try {
            // プレビュー開始
            camera.startPreview();
        } catch (Exception e) {
            Log.e(TAG, "start preview failed!!", e);
        }

        Log.d(TAG, "surfaceChanged end");
    }

    /*
     * (非 Javadoc)
     * @see android.view.SurfaceHolder.Callback#surfaceDestroyed(android.view.SurfaceHolder)
     */
    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        Log.d(TAG, "surfaceDestroyed start");

          // カメラインスタンスがない場合は処理を行わずに抜ける
          if (camera == null) {
              Log.d(TAG, "surfaceDestroyed end : camera instance is null");
              return;
          }

          // プレビューを一度停止
          camera.stopPreview();
          // プレビューコールバックの設定解除
          camera.setPreviewCallback(null);
          // カメラ解放
          camera.release();
          // カメラインスタンス初期化
          camera = null;

          Log.d(TAG, "surfaceDestroyed end");
    }

    /**
     * プレビューデータ通知再開要求。
     * Cameraからのプレビューデータ通知を再開する。
     */
    public void notifyRestartPreview() {
        Log.d(TAG, "notifyRestartPreviewCallback() start");

        // カメラインスタンスが解放されていない場合
        if (camera != null) {
            camera.setPreviewCallback(this);
        }

        Log.d(TAG, "notifyRestartPreviewCallback() end");
    }

    /**
     * カメラパラメータ設定処理
     * @param params カメラパラメータ
     */
    private void loadCameraParams(Camera.Parameters params) {

        if (params == null) {
            Log.w(TAG, "Parameter is invalid. params[" + params + "].");
            return;
        }

        // フラッシュ設定
        if (params.getSupportedFlashModes().contains(Camera.Parameters.FLASH_MODE_OFF)) {
            params.setFlashMode(Camera.Parameters.FLASH_MODE_OFF);
            Log.d(TAG, "Camera flash mode [FLASH_MODE_OFF] is set.");
        } else {
            Log.i(TAG, "Camera flash mode [FLASH_MODE_OFF] is not supported.");
        }

        // フォーカス設定
        if (params.getSupportedFocusModes().contains(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO)) {
            params.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO);
            Log.d(TAG, "Camera focus mode [FOCUS_MODE_CONTINUOUS_VIDEO] is set.");
        } else {
            Log.i(TAG, "Camera focus mode [FOCUS_MODE_CONTINUOUS_VIDEO] is not supported.");
        }

        // エフェクト設定
        if (params.getSupportedColorEffects().contains(Camera.Parameters.EFFECT_NONE)) {
            params.setColorEffect(Camera.Parameters.EFFECT_NONE);
            Log.d(TAG, "Camera effect mode [EFFECT_NONE] is set.");
        } else {
            Log.i(TAG, "Camera effect mode [EFFECT_NONE] is not supported.");
        }

        // シーン設定値
        if (params.getSupportedSceneModes().contains(Camera.Parameters.SCENE_MODE_AUTO)) {
            params.setSceneMode(Camera.Parameters.SCENE_MODE_AUTO);
            Log.d(TAG, "Camera scene mode [SCENE_MODE_AUTO] is set.");
        } else {
            Log.i(TAG, "Camera scene mode [SCENE_MODE_AUTO] is not supported.");
        }

        // ホワイトバランス設定
        if (params.getSupportedWhiteBalance().contains(Camera.Parameters.WHITE_BALANCE_AUTO)) {
            params.setWhiteBalance(Camera.Parameters.WHITE_BALANCE_AUTO);
            Log.d(TAG, "Camera white balance mode [WHITE_BALANCE_AUTO] is set.");
        } else {
            Log.i(TAG, "Camera white balance mode [WHITE_BALANCE_AUTO] is not supported.");
        }
    }

}