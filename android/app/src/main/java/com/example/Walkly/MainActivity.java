package com.angelstoyanov.walkly;

import android.util.Log;

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
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;


import org.json.JSONObject;

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

                        registerUser(first_name,last_name,email,password);
                        result.success("1");
                    }
                    if (call.method.equals("getOffers")) {
                        JSONObject jsonObject = getOffers();
                        result.success(jsonObject);
                    }

                });

    }

    private void registerUser(final String first_name, final String last_name, final String email, final String password){
        final String URL_REGISTER = "http://192.168.1.9/walklyapp/register.php";

        StringRequest stringRequest = new StringRequest(Request.Method.POST, URL_REGISTER, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                String success = response;

                if(success.equals("1")){
                    //TODO: Open a session if success
                }

            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError e) {

            }
        }) {
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

    private JSONObject getOffers(){
        final String url = "http://192.168.1.9/walklyapp/get_offers.php";
        final JSONObject[] jsonObject = new JSONObject[1];
        JsonObjectRequest getRequest = new JsonObjectRequest(Request.Method.GET, url, null,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        jsonObject[0] = response;

                        Log.d("Response", response.toString());
                    }
                }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        //Log.d("Error.Response", error.getMessage());
                    }
                }
        );

        RequestQueue requestQueue = Volley.newRequestQueue(this);
        requestQueue.add(getRequest);
        return jsonObject[0];
    }

}