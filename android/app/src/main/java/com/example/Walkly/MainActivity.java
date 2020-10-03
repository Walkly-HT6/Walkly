package com.angelstoyanov.walkly;

import io.flutter.embedding.android.FlutterActivity;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;


import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "walkly/native";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("registerUser")) {
                        final String first_name = call.argument("first_name");
                        final String last_name = call.argument("last_name");
                        final String email = call.argument("email");
                        final String password = call.argument("password");
                        //Context context = call.argument("context");

                        registerUser(first_name,last_name,email,password);
                        result.success("1");
                    }

                });

    }

    private void registerUser(final String first_name, final String last_name, final String email, final String password){
        final String URL_REGISTER = "http://192.168.1.9/walklyapp/register.php";
        //SessionManager sessionManager = new SessionManager(context);

        StringRequest stringRequest = new StringRequest(Request.Method.POST, URL_REGISTER, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                //Response goes here

                //JSONObject jsonObject = new JSONObject(response);
                //String success = jsonObject.getString("success");
                String success = response;

                if(success.equals("1")){
                    //sessionManager.createSession();
                }

            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError e) {
                //Toast.makeText(RegisterActivity.this, "Registration failed (" + e.toString() + ")", Toast.LENGTH_SHORT).show();
            }
        })
        {
            @Override
            protected Map<String, String> getParams() {
                Map<String,String> params = new HashMap<>();
                params.put("first_name",first_name);
                params.put("last_name",last_name);
                params.put("email",email);
                params.put("password",password);
                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(this);
        requestQueue.add(stringRequest);

    }
}