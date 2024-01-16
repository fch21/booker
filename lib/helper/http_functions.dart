
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class HttpFunctions {

   static Future<Map<String, dynamic>?> getResponseMap({required String url, required Object? requestMap}) async {

     final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

     if(idToken != null){
       final uri = Uri.tryParse(url);

       if(uri != null){
         final reqBody = json.encode(requestMap);
         //print('reqBody = ${reqBody}');
         //print('reqBidTokenody = ${idToken}');
         final response = await http.post(uri,
             headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $idToken'},
             body: reqBody);

         //print('response.body = ${response.body}');

         Map<String, dynamic>? responseBody;

         try{
           responseBody = json.decode(response.body);
         }
         catch(e){
           print('getResponseMap error in json decode: $e');
         }

         print('responseBody = $responseBody');

         return responseBody;
       }
     }
     return null;

  }

}