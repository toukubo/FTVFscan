/*
 * Created by GAZIRU Developer on 14/01/21
 * Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
 */

package jp.co.fashiontv.fscan.Listener;

/**
 * カメラプレビューデータ通知リスナー。
 */
public interface CameraViewListener {
    /**
     * カメラプレビューデータ通知インタフェース。
     * カメラプレビューデータをリスナーに通知します。
     *
     * @param data カメラプレビューデータ(YUV420形式)
     */
    public void notifyPreviewData(byte[] data);
}
