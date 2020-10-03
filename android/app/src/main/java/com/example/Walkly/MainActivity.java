package com.angelstoyanov.walkly;

import android.content.Intent;
import android.util.Log;
import android.view.View;

import io.flutter.embedding.android.FlutterActivity;

import androidx.annotation.NonNull;
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


import org.json.JSONArray;
import org.json.JSONException;
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

                        registerUser(first_name, last_name, email, password);
                        result.success("1");
                    }
                    if (call.method.equals("getOffers")) {
                        JSONObject jsonObject = getOffers();
                        result.success(jsonObject);
                    }
                    if (call.method.equals("makeOffer")) {
                        final String date_from_to = call.argument("date_from_to");
                        final int coupon_count = call.argument("coupon_count");
                        final int business_user_id = call.argument("business_user_id");
                        final String description = call.argument("description");
                        final float price = call.argument("price");
                        makeOffer(date_from_to,coupon_count,business_user_id,description,price);
                        result.success("1");
                    }
                    if (call.method.equals("registerDealer")) {
                        final String company_name = call.argument("company_name");
                        final int category_id = call.argument("category_id");
                        final String business_hours = call.argument("business_hours");
                        final String first_name = call.argument("first_name");
                        final String last_name = call.argument("last_name");
                        final String phone_number = call.argument("phone_number");
                        final String description = call.argument("description");
                        final String email = call.argument("email");
                        final String password = call.argument("password");
                        final String city = call.argument("city");
                        final String street_name = call.argument("street_name");
                        final String post_code = call.argument("post_code");
                        final String built_number = call.argument("built_number");
                        registerDealer(company_name,
                                category_id,
                                business_hours,
                                first_name,
                                last_name,
                                phone_number,
                                description, email, password, city, street_name, post_code, built_number);
                        result.success("1");
                    }

                });

    }

    private void registerUser(final String first_name, final String last_name, final String email, final String password) {
        final String URL_REGISTER = "http://192.168.1.9/walklyapp/register.php";

        StringRequest stringRequest = new StringRequest(Request.Method.POST, URL_REGISTER, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                String success = response;

                if (success.equals("1")) {
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
                Map<String, String> params = new HashMap<>();
                params.put("first_name", first_name);
                params.put("last_name", last_name);
                params.put("email", email);
                params.put("password", password);
                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(this);
        requestQueue.add(stringRequest);

    }

    private JSONObject getOffers() {
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

    private void makeOffer(final String date_from_to, final int coupon_count,
                           final int business_user_id, final String description, final float price) {
        final String url = "http://192.168.1.9/walklyapp/make_offer.php";
        StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                String success = response;

                if (success.equals("1")) {
                    //TODO: Success
                }

            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError e) {

            }
        }) {
            @Override
            protected Map<String, String> getParams() {
                Map<String, String> params = new HashMap<>();
                params.put("date_from_to", date_from_to);
                params.put("coupon_count", coupon_count + "");
                params.put("business_user_id", business_user_id + "");
                params.put("description", description);
                params.put("price", price + "");
                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(this);
        requestQueue.add(stringRequest);
    }

    private void registerDealer(final String company_name,
                                final int category_id,
                                final String business_hours,
                                final String first_name,
                                final String last_name,
                                final String phone_number,
                                final String description,
                                final String email,
                                final String password,
                                final String city,
                                final String street_name,
                                final String post_code,
                                final String built_number) {

        final String url = "http://192.168.1.9/walklyapp/register_dealer.php";

        StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                String success = response;

                if (success.equals("1")) {
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
                Map<String, String> params = new HashMap<>();
                params.put("company_name", company_name);
                params.put("business_hours", business_hours);
                params.put("category_id", category_id + "");
                params.put("first_name", first_name);
                params.put("last_name", last_name);
                params.put("phone_number", phone_number);
                params.put("description", description);
                params.put("password", password);
                params.put("email", email);
                params.put("city", city);
                params.put("street_name", street_name);
                params.put("post_code", post_code);
                params.put("built_number", built_number);
                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(this);
        requestQueue.add(stringRequest);
    }

    public void logIn(final String email, final String password){
        final String url = "http://192.168.1.9/walklyapp/login.php";
        StringRequest stringRequest = new StringRequest(Request.Method.POST, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        try {
                            JSONObject jsonObject = new JSONObject(response);
                            String success = jsonObject.getString("success");
                            JSONArray jsonArray = jsonObject.getJSONArray("login");

                            if(success.equals("1")){
                                for(int i =0; i <jsonArray.length(); i++){
                                    JSONObject object = jsonArray.getJSONObject(i);
                                    //sessionManager.createSession(name,email);
                                    //sessionManager.createSession();
                                }
                            }
                        }catch (JSONException e){
                            e.printStackTrace();
                            //TODO: Add Toast for error login
                        }
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                //TODO: Add Toast for error login ( response )
            }
        })
        {
            @Override
            protected Map<String, String> getParams(){
                Map<String, String> params = new HashMap<>();
                params.put("email",email);
                params.put("password",password);
                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(this);
        requestQueue.add(stringRequest);

    }

    void logOut(){
        //TODO: Make this one
    }

}