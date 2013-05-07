package com.quicsystems.ruboto.taskit;

import android.os.Bundle;

public class NewTaskActivity extends org.ruboto.EntryPointActivity {
	public void onCreate(Bundle bundle) {
		getScriptInfo().setRubyClassName(getClass().getSimpleName());
	    super.onCreate(bundle);
	}
}
