package jp.co.fashiontv.fscan.Database;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.List;

import jp.co.fashiontv.fscan.Utils.History;

import android.content.ContentValues;
import android.content.Context;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.graphics.Bitmap;
import android.util.Log;

public class DatabaseHandler extends SQLiteOpenHelper {

	// All Static variables
	// Database Version
	private static final int DATABASE_VERSION = 1;

	// Database Name
	private static final String DATABASE_NAME = "fscan.db";

	// Contacts table name
	private static final String TABLE_HISTORY = "history";

	// Contacts Table Columns names
	private static final String KEY_ID = "id";
	private static final String KEY_NAME = "name";
	private static final String KEY_LOGO = "logoname";
	private static final String KEY_Date = "date";
	private static final String KEY_Image = "images";
	private static final String TAG = "Database";

	public DatabaseHandler(Context context) {
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
	}

	// Creating Tables
	@Override
	public void onCreate(SQLiteDatabase db) {
		String CREATE_HISTORY_TABLE = "CREATE TABLE " + TABLE_HISTORY + "("
				+ KEY_ID + " INTEGER PRIMARY KEY," + KEY_NAME + " TEXT,"
				+ KEY_LOGO + " TEXT," + KEY_Date + " TEXT," + KEY_Image
				+ " blob" + ")";
		db.execSQL(CREATE_HISTORY_TABLE);

		Log.v(TAG, "Database Createad");
	}

	// Upgrading database
	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		// Drop older table if existed
		db.execSQL("DROP TABLE IF EXISTS " + TABLE_HISTORY);

		// Create tables again
		onCreate(db);
	}

	// Adding new History
	public void addHistory(String name, String logoname, String date,
			Bitmap bitmap) {

		byte[] img = null;
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		bitmap.compress(Bitmap.CompressFormat.JPEG, 100, bos);
		img = bos.toByteArray();

		SQLiteDatabase db = this.getWritableDatabase();
		ContentValues values = new ContentValues();
		values.put(KEY_NAME, name); // History Name
		values.put(KEY_LOGO, logoname); // History Logoname
		values.put(KEY_Date, date); // History Date
		values.put(KEY_Image, img); // History Image
		// Inserting Row
		db.insert(TABLE_HISTORY, null, values);
		db.close(); // Closing database connection
	}

	// Getting All History
	public List<History> getAllContacts() {
		List<History> contactList = new ArrayList<History>();
		// Select All Query
		String selectQuery = "SELECT  * FROM " + TABLE_HISTORY;

		SQLiteDatabase db = this.getWritableDatabase();
		Cursor cursor = db.rawQuery(selectQuery, null);

		// looping through all rows and adding to list
		if (cursor.moveToFirst()) {
			do {
				History history = new History();
				history.setID(Integer.parseInt(cursor.getString(0)));
				history.setName(cursor.getString(1));
				history.set_logoname(cursor.getString(2));
				history.set_date(cursor.getString(3));
				history.setImage(cursor.getBlob(4));
				// Adding History object to list
				contactList.add(history);
			} while (cursor.moveToNext());
		}

		// return contact list
		return contactList;
	}
}
