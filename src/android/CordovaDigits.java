//
//  CordovaDigits.swift
//  Quanto Plugins
//
//  Created by Bradley Suira on 2/17/17.
//

package red.quanto.plugins.digits;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;

import java.util.*;
import android.app.Activity;
import android.util.Log;
import android.os.Bundle;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.digits.sdk.android.AuthCallback;
import com.digits.sdk.android.AuthConfig;
import com.digits.sdk.android.Digits;
import com.digits.sdk.android.DigitsSession;
import com.digits.sdk.android.DigitsException;
import com.digits.sdk.android.DigitsOAuthSigning;

import com.twitter.sdk.android.core.TwitterAuthConfig;
import com.twitter.sdk.android.core.TwitterAuthToken;
import com.twitter.sdk.android.core.TwitterCore;

import io.fabric.sdk.android.Fabric;

public class CordovaDigits extends CordovaPlugin {
  private static final String META_DATA_KEY = "io.fabric.ApiKey";
  private static final String META_DATA_SECRET = "io.fabric.ConsumerSecret";
  private static final String TAG = "CORDOVA DIGITS";

  private AuthCallback authCallback;

  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
	super.initialize(cordova, webView);
	TwitterAuthConfig authConfig = getTwitterAuthConfig();
	Digits.Builder digitsBuilder = new Digits.Builder()
											 .withTheme(cordova.getActivity().getResources().getIdentifier("CordovaDigitsTheme", "style", cordova.getActivity().getPackageName()));
	Fabric.with(cordova.getActivity().getApplicationContext(), new TwitterCore(authConfig), digitsBuilder.build());
  }

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
	Log.i(TAG, "executing action " + action);

	if ("authenticate".equals(action)) {
		 authenticate(callbackContext, args);

	} else if ("logOut".equals(action)) {
	  logOut(callbackContext);

	} else if ("isAuthenticated".equals(action)) {
	  isAuthenticated(callbackContext);

	} else if ("onSessionHasChanged".equals(action)) {
	  onSessionHasChanged(callbackContext);

	} else if ("onSessionExpired".equals(action)) {
	  onSessionExpired(callbackContext);

	} else {
	  Log.w(TAG, "unknown action `" + action + "`");
	  return false;
	}

	return true;
  }

  public void authenticate(final CallbackContext callbackContext, JSONArray args) {

		boolean withEmailCollection = false;
		String phoneNumber;
		String accountFields;

		try{

			JSONObject arg = args.getJSONObject(0);

			phoneNumber = arg.getString("phoneNumber");
			accountFields = arg.getString("accountFields");
			if(accountFields.toLowerCase() == "email") {
			  withEmailCollection = true;
			}

			AuthCallback authCallback = new AuthCallback() {

			  @Override
			  public void success(DigitsSession session, String phoneNumber) {
				// Do something with the session and phone number
			   try{
				   Log.i(TAG, "authentication successful");

				   TwitterAuthConfig authConfig = TwitterCore.getInstance().getAuthConfig();
				   TwitterAuthToken authToken = session.getAuthToken();
				   DigitsOAuthSigning oauthSigning = new DigitsOAuthSigning(authConfig, authToken);
				   Map<String, String> authHeaders = oauthSigning.getOAuthEchoHeadersForVerifyCredentials();

				   String result = new JSONObject(authHeaders).toString();
				   callbackContext.success(result);
			   }catch (Exception ex){
				   Log.e(TAG, "error in success " + ex.getMessage());
				   callbackContext.error(ex.getMessage());
			   }

			  }

			  @Override
			  public void failure(DigitsException exception) {
				  // Do something on failure
				  Log.e(TAG, "error " + exception.getMessage());
				  callbackContext.error(exception.getMessage());
			  }
		  };

		  AuthConfig.Builder authConfigBuilder = new AuthConfig.Builder()
												.withAuthCallBack(authCallback)
												.withEmailCollection(withEmailCollection)
												.withPhoneNumber(phoneNumber);

		  Digits.authenticate(authConfigBuilder.build());

		}catch(JSONException jsonEx){

		  Log.e(TAG, "error " + jsonEx.getMessage());
		  callbackContext.error(jsonEx.getMessage());
		}catch(Exception ex){

		  Log.e(TAG, "error " + ex.getMessage());
		  callbackContext.error(ex.getMessage());
		}

	}

  public void isAuthenticated(final CallbackContext callbackContext) {

	DigitsSession session = Digits.getActiveSession();

	if(session != null) {
	  TwitterAuthConfig authConfig = TwitterCore.getInstance().getAuthConfig();
	  TwitterAuthToken authToken = session.getAuthToken();
	  DigitsOAuthSigning oauthSigning = new DigitsOAuthSigning(authConfig, authToken);

	  Map<String, String> authHeaders = oauthSigning.getOAuthEchoHeadersForVerifyCredentials();
	  String result = new JSONObject(authHeaders).toString();
	  Log.e(TAG, "Session is active");

	  callbackContext.success(result);
	}else {
	  Log.e(TAG, "No active session");
	  callbackContext.error("No active session");
	}


  }

  public void onSessionHasChanged(final CallbackContext callbackContext) {

  }

  public void onSessionExpired(final CallbackContext callbackContext) {

  }

  public void logOut(final CallbackContext callbackContext) {
	Digits.logout();
  }

  private TwitterAuthConfig getTwitterAuthConfig() {
	String key = getMetaData(META_DATA_KEY);
	String secret = getMetaData(META_DATA_SECRET);

	return new TwitterAuthConfig(key, secret);
  }

  private String getMetaData(String name) {
	try {
	  Context context = cordova.getActivity().getApplicationContext();
	  ApplicationInfo ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);

	  Bundle metaData = ai.metaData;
	  if(metaData == null) {
		Log.w(TAG, "metaData is null. Unable to get meta data for " + name);
	  }
	  else {
		String value = metaData.getString(name);
		return value;
	  }
	} catch (NameNotFoundException e) {
	  e.printStackTrace();
	}
	return null;
  }
}