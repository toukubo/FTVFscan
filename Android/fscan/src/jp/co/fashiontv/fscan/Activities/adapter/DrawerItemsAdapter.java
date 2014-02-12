package jp.co.fashiontv.fscan.Activities.adapter;

import jp.co.fashiontv.fscan.R;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

public class DrawerItemsAdapter extends BaseAdapter {
	 

	private LayoutInflater inflator;

	int items[]= new int[]{
		R.drawable.label_tour,
		R.drawable.label_history,
		R.drawable.label_album,
		R.drawable.label_brands,
	};
	
	public DrawerItemsAdapter(Context context) {
		inflator  =LayoutInflater.from(context);
		 
	}


	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return items.length;
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		 

		final ViewHolder holder;
		if (convertView == null) {
			convertView = inflator.inflate(R.layout.row_sliding_menu, parent, false);
	 		holder = new ViewHolder();
			holder.ivItem= (ImageView) convertView.findViewById(R.id.iv_menu_item);
			convertView.setTag(holder);
		} else {
			holder = (ViewHolder) convertView.getTag();
		}


		Drawable icon = convertView.getContext().getResources().getDrawable(items[position]);
 		holder.ivItem.setImageDrawable(icon);
 		return convertView;
	}
	
	
	class ViewHolder{
		ImageView ivItem ;
	}

}
