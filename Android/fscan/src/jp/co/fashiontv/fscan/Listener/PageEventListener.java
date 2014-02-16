package jp.co.fashiontv.fscan.Listener;

public interface PageEventListener {
	public void onPageStarted();
	public void onPageFinished();
	public void onPageReceivedError();
}
