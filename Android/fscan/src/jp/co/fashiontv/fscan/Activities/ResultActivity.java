/*
 * Created by GAZIRU Developer on 14/01/21
 * Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
 */

package jp.co.fashiontv.fscan.Activities;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Utils.ImageUtil;
import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.os.Bundle;
import android.widget.ImageView;
import android.widget.TextView;

public class ResultActivity extends Activity {
    /** クエリ画像 */
    private Bitmap queryImageBMP;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // プレビュー画面レイアウトの登録
        setContentView(R.layout.result);
//        ActionBar actionbar = getActionBar();
//        if (actionbar != null) {
//            actionbar.setTitle(R.string.title_actionbar_result);
//        }

        // Viewを初期化
        ImageView iv = (ImageView)findViewById(R.id.result_image);
        iv.setImageBitmap(null);
        TextView tv = (TextView)findViewById(R.id.image_path);
        tv.setText("");

    }

    @Override
    public void onResume() {
        super.onResume();

        // クエリ画像を取得
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {
            queryImageBMP = (Bitmap) bundle.get("imageBitmap");
        }

        ImageView iv = (ImageView)findViewById(R.id.result_image);
        iv.setImageBitmap(queryImageBMP);

        new AsyncTask<Void, Void, String>() {
            @Override
            protected String doInBackground(Void... params) {
                // 画像を保存
                String filePath = ImageUtil.saveImageSD(getApplicationContext(), queryImageBMP);
                return filePath;
            }
            @Override
            protected void onPostExecute(String filePath) {
                // ファイル保存先を画面に表示
                if (queryImageBMP != null && filePath != null) {
                    TextView tv = (TextView)findViewById(R.id.image_path);
                    tv.setText(getString(R.string.result_text_image_path) + filePath);
                }
            }
        }.execute();
    }

}
