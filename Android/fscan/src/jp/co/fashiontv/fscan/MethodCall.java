package jp.co.fashiontv.fscan;

import android.app.Activity;
import android.content.Intent;

public class MethodCall {
	public MethodCall(String action,Activity parentActivity){

		Intent intent=new Intent();
		String packageName = "jp.co.fashiontv.fscan";
		String activityName = packageName + "." + action;

		Class intentClass;
		try {
			intentClass = Class.forName(activityName);
			intent = new Intent(parentActivity.getApplication(), intentClass);
			parentActivity.startActivity(intent);
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

//		intent.setClassName(packageName,activityName);
//		parentActivity.startActivity(intent);

	}
}
