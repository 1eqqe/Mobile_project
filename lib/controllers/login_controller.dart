import 'dart:convert';

import 'package:mobile_project/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController{
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<void> loginWithEmail() async{
    try {
      var headers = {'Content-type' : 'application/json'};
      var url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.loginEmail);
      Map body = {
        'email' : emailController.text.trim(),
        'password' : passwordController.text
      };
      http.Response response = await http.post(url, body: jsonEncode(body), headers:headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['code'] == 0) {
          var token = json['data']['Token'];
          final SharedPreferences? prefs = await _prefs;
          await prefs?.setString('token', token);
          emailController.clear();
          passwordController.clear();
          //go to home
        } else if (json['code'] == 1){
          throw jsonDecode(response.body)["Message"];
        }
      } else {
        throw jsonDecode(response.body)["Message"] ?? "Unknown Error Occured";
      }
    } catch (error) {
      Get.back();
      showDialog(context: Get.context!, builder: (context){
        return SimpleDialog(
          title: Text('Error'),
          contentPadding: EdgeInsets.all(20),
          children: [Text(error.toString())],
        );
      });
      }
    }
  }