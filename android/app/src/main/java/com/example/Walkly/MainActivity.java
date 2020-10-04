package com.angelstoyanov.walkly;

import io.flutter.embedding.android.FlutterActivity;

import androidx.annotation.NonNull;
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
    private String cookie_test = "";
    private String getOffers = "";
    private String couponCode = "";

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
                        {getOffers();}
                        result.success(getOffers);
                    }
                    if (call.method.equals("makeOffer")) {
                        final String date_from_to = call.argument("date_from_to");
                        final String coupon_count = call.argument("coupon_count");
                        final String business_user_id = call.argument("business_user_id");
                        final String description = call.argument("description");
                        final String points = call.argument("points");
                        makeOffer(date_from_to,coupon_count,business_user_id,description,points);
                        result.success("1");
                    }
                    if (call.method.equals("registerDealer")) {
                        final String company_name = call.argument("company_name");
                        final String category_id = call.argument("category_id");
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

                    if (call.method.equals("logIn")) {
                        final String email = call.argument("email");
                        final String password = call.argument("password");

                        {logIn(email,password);}
                        result.success(cookie_test);

                    }

                    if(call.method.equals("logout")){
                        final String cookie = call.argument("cookie");
                        logOut(cookie);
                        result.success("1");

                    }
                    if (call.method.equals("useOffer")) {
                        final String email = call.argument("email");
                        final String cookie = call.argument("cookie");

                        {useOffer(email,cookie);}
                        result.success(couponCode);

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

        private void getOffers() {
            final String url = "http://192.168.1.9/walklyapp/view_offers.php";
            StringRequest getRequest = new StringRequest(Request.Method.GET, url,
                    new Response.Listener<String>() {
                        @Override
                        public void onResponse(String response) {
                            getOffers = response;

                        }
                    }, new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError error) {
                }
            }
            );

            RequestQueue requestQueue = Volley.newRequestQueue(this);
            requestQueue.add(getRequest);
        }

        private void makeOffer(final String date_from_to, final String coupon_count,
        final String business_user_id, final String description, final String points) {
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
                    params.put("coupon_count", coupon_count);
                    params.put("business_user_id", business_user_id);
                    params.put("description", description);
                    params.put("points", points);
                    return params;
                }
            };

            RequestQueue requestQueue = Volley.newRequestQueue(this);
            requestQueue.add(stringRequest);
        }

        private void registerDealer(final String company_name,
        final String category_id,
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
                    params.put("category_id", category_id);
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

        void logOut(final String cookie){
            final String url = "http://192.168.1.9/walklyapp/logout.php";

            StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    String success = response;

                    if (success.equals("1")) {
                        //If user is logged out
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
                    params.put("cookie", cookie);
                    return params;
                }
            };

            RequestQueue requestQueue = Volley.newRequestQueue(this);
            requestQueue.add(stringRequest);


        }

        public void logIn(final String email, final String password){
            final String url = "http://192.168.1.9/walklyapp/login.php";
            StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    if ( (response.length() + "").equals("20") ) { //The cookie is always 20 symbols
                        cookie_test = response;

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
                    params.put("email", email);
                    params.put("password", password);
                    return params;
                }
            };

            RequestQueue requestQueue = Volley.newRequestQueue(this);
            requestQueue.add(stringRequest);
        }

        public void deleteUser(final String email, final String cookie){
            final String url = "http://192.168.1.9/walklyapp/delete_user.php";
            StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    String success = response;

                    if (success.equals("1")) {
                        //If user is logged out
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
                    params.put("email", email);
                    params.put("cookie", cookie);
                    return params;
                }
            };

            RequestQueue requestQueue = Volley.newRequestQueue(this);
            requestQueue.add(stringRequest);
        }
        public void useOffer(final String email, final String cookie){
            final String url = "http://192.168.1.9/walklyapp/use_offer.php";
            StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    if ( (response.length() + "").equals("6") ) { //The coupon code must always 6 symbols
                        couponCode = response;

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
                    params.put("email", email);
                    params.put("cookie", cookie);
                    return params;
                }
            };

            RequestQueue requestQueue = Volley.newRequestQueue(this);
            requestQueue.add(stringRequest);
        }

    }
