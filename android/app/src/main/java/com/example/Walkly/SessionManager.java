package com.angelstoyanov.walkly;

import android.content.Context;
import android.content.SharedPreferences;

import java.util.HashMap;

public class SessionManager {
    SharedPreferences sharedPreferences;
    public SharedPreferences.Editor editor;
    public Context context;

    private static final String PREF_NAME = "LOGIN";
    private static final String LOGIN = "IS_LOGIN";

    public static final String NAME = "NAME";
    public static final String EMAIL = "EMAIL";

    public SessionManager(Context context){
        this.context = context;
        sharedPreferences = context.getSharedPreferences("Login",Context.MODE_PRIVATE);
        editor.apply(); //TIP: Comment this if doesn't work
        editor = sharedPreferences.edit();
    }

    public void createSession(){
        editor.putBoolean(LOGIN, true);
        //editor.putString(NAME,name);
        //editor.putString(EMAIL,email);
        editor.apply();
    }

    public boolean isLoggin(){
        return sharedPreferences.getBoolean(LOGIN,false);
    }

    public int checkLogin(){
        if(!this.isLoggin()){
            return 0;
            /*Intent intent = new Intent(context, LoginActivity.class);
            context.startActivity(intent);
            ((HubActivity)context).finish();*/

        }
        return 1;
    }

    public HashMap<String, String> getUserDetails(){
        HashMap<String, String> user = new HashMap<>();
            user.put(NAME,sharedPreferences.getString(NAME,null));
            user.put(EMAIL,sharedPreferences.getString(EMAIL,null));
        return user;
    }
    public int logout(){
        editor.clear();
        editor.commit();
        /*Intent intent = new Intent(context, LoginActivity.class);
        context.startActivity(intent);
        ((HubActivity)context).finish();*/
        return 0;
    }

}
