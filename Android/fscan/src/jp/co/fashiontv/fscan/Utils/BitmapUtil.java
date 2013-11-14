package jp.co.fashiontv.fscan.Utils;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.net.Uri;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;

/**
 * THIS CLASS WAS NOT USED IN OTHER PLACE
 */
public class BitmapUtil {

	public static Bitmap getData(Intent data) {
		Bitmap  bitmap = null;
		if (data!=null && data.getData()!=null) {  
			//		  bitmap = uri2bmp(this, data.getData(), (int)(280*scaledDensity), (int)(280*scaledDensity));  
		} else {  
			bitmap = (Bitmap) data.getExtras().get("data");

			//Xperia以外の場合  
			//    	  bitmap = uri2bmp(this, currentData.photo, (int)(280*scaledDensity), (int)(280*scaledDensity));  
		}
		return bitmap;
	}

	public static byte[] getImageBytes(Intent intent) {
		Bitmap selectedImage = BitmapUtil.getData(intent);
		byte[] imgData = null;
		try {
			ByteArrayOutputStream bos = new ByteArrayOutputStream();
			selectedImage.compress(CompressFormat.JPEG, 100, bos);
			imgData = bos.toByteArray();

		} catch (Exception e) {
			e.printStackTrace();
		}
		return imgData;
	}


public static byte[] getBytes(InputStream is){

	try {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		byte[] buf = new byte[128];
		int ch = -1;
		while ((ch = is.read(buf)) != -1) {
			out.write(buf, 0, ch);
		}
		out.close();
		out = null;
		return out.toByteArray();
	} catch (Exception e) {
		System.err.println("Exception : "+e);
	}
	return null;
}



public static Bitmap uri2bmp(Context context,Uri uri,int maxW,int maxH) {  
    BitmapFactory.Options options;  
    InputStream in=null;  
    try {  
        //画像サイズの取得  
        options=new BitmapFactory.Options();  
        options.inJustDecodeBounds=true;  
        in=context.getContentResolver().openInputStream(uri);    
        BitmapFactory.decodeStream(in,null,options);  
        in.close();  
        int scaleW=options.outWidth /maxW+1;  
        int scaleH=options.outHeight/maxH+1;  
        int scale =Math.max(scaleW,scaleH);  
       
        //画像の読み込み  
        options=new BitmapFactory.Options();  
        options.inJustDecodeBounds=false;  
        options.inSampleSize=scale;  
        options.inPurgeable=true;  
        in=context.getContentResolver().openInputStream(uri);    
        Bitmap bmp = BitmapFactory.decodeStream(in, null, options);  
        in.close();  
        return bmp;  
    } catch (Exception e) {  
        try {  
            if (in!=null) in.close();  
        } catch (Exception e2) {  
        }  
        return null;  
    }  
}  

}
