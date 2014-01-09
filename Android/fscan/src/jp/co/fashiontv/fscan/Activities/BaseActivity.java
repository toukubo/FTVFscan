package jp.co.fashiontv.fscan.Activities;

import jp.co.fashiontv.fscan.R;
import jp.co.fashiontv.fscan.Activities.adapter.DrawerItemsAdapter;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ListView;

import com.jeremyfeinstein.slidingmenu.lib.SlidingMenu;
import com.jeremyfeinstein.slidingmenu.lib.app.SlidingActivity;

public abstract class BaseActivity extends SlidingActivity {
	private SlidingMenu slidingMenu;

	public abstract View getActivityLayout();
	@Override
	public void onCreate(Bundle savedInstanceState) {
	 	super.onCreate(savedInstanceState);
	 	requestWindowFeature(Window.FEATURE_NO_TITLE);
	 	setUpView();
	}

	private void setUpView() {
		slidingMenu = getSlidingMenu();
		slidingMenu.setShadowWidthRes(R.dimen.shadow_width);
		slidingMenu.setShadowDrawable(R.drawable.shadow);
		slidingMenu.setBehindOffsetRes(R.dimen.slidingmenu_offset);
		slidingMenu.setFadeDegree(0.35f);
		slidingMenu.setMode(SlidingMenu.RIGHT);
		slidingMenu.setTouchModeAbove(SlidingMenu.TOUCHMODE_FULLSCREEN);
		setBehindContentView(R.layout.layout_sliding_menu);
	 	setContentView(R.layout.menu_frame);
		FrameLayout layout = (FrameLayout)findViewById(R.id.menu_frame);
		layout.addView(getActivityLayout());
		
		
		ListView lvMenuDrawerItems = (ListView)findViewById(R.id.lv_menu_items);
		DrawerItemsAdapter adapter =  new DrawerItemsAdapter(BaseActivity.this);
		lvMenuDrawerItems.setAdapter(adapter);
		
		ImageView slider = (ImageView)findViewById(R.id.slider);

		slider.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
			 
				slidingMenu.toggle();
			}
		});
		
		
	}
 
}
