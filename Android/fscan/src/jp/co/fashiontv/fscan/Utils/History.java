package jp.co.fashiontv.fscan.Utils;

public class History {

	// private variables
	int _id;
	public String _name;
	public String _date;
	public String _logoname;
	public byte[] _image;

	// Empty constructor
	public History() {

	}

	// constructor
	public History(int keyId, String name, byte[] image) {
		this._id = keyId;
		this._name = name;
		this._image = image;

	}

	public History(String contactID, String name, byte[] image) {
		this._name = name;
		this._image = image;

	}

	public History(String name, byte[] image) {
		this._name = name;
		this._image = image;
	}

	public int getID() {
		return this._id;
	}

	public void setID(int keyId) {
		this._id = keyId;
	}


	public String getName() {
		return this._name;
	}

	public void setName(String name) {
		this._name = name;
	}

	public byte[] getImage() {
		return this._image;
	}

	public void setImage(byte[] image) {
		this._image = image;
	}

	public String get_date() {
		return _date;
	}

	public void set_date(String _date) {
		this._date = _date;
	}

	public String get_logoname() {
		return _logoname;
	}

	public void set_logoname(String _logoname) {
		this._logoname = _logoname;
	}

}
