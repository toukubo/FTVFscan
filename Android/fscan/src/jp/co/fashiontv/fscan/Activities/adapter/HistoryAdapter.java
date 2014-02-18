package jp.co.fashiontv.fscan.Activities.adapter;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Utils.History;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.nfc.Tag;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class HistoryAdapter extends ArrayAdapter<History> {
	Context context;
	int layoutResourceId;
	// BcardImage data[] = null;
	ArrayList<History> data = new ArrayList<History>();

	public HistoryAdapter(Context context, int layoutResourceId,
			ArrayList<History> data) {
		super(context, layoutResourceId, data);
		this.layoutResourceId = layoutResourceId;
		this.context = context;
		this.data = data;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View row = convertView;
		ImageHolder holder = null;

		if (row == null) {
			LayoutInflater inflater = ((Activity) context).getLayoutInflater();
			row = inflater.inflate(layoutResourceId, parent, false);

			holder = new ImageHolder();
			holder.txtTitle = (TextView) row.findViewById(R.id.txtBrandName);
			holder.imgIcon = (ImageView) row.findViewById(R.id.imgIcon);
			holder.txtDate = (TextView) row.findViewById(R.id.txtDate);
			row.setTag(holder);
		} else {
			holder = (ImageHolder) row.getTag();
		}

		History history = data.get(position);
		holder.txtTitle.setText(history.getName());
		holder.txtDate.setText(history.get_date());
		// convert byte to bitmap take from contact class
		byte[] outImage = history._image;
		Bitmap b1 = BitmapFactory.decodeByteArray(outImage, 0, outImage.length);
		holder.imgIcon.setImageBitmap(b1);
		return row;

	}

	static class ImageHolder {
		ImageView imgIcon;
		TextView txtTitle;
		TextView txtDate;
	}
}
