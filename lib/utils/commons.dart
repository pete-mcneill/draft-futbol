import 'dart:convert';

import 'package:http/http.dart' as http;

import 'AppException.dart';

class Commons {
  // static const baseUrl = "http://192.168.1.202:4000";
  static const baseUrl = "https://draft.premierleague.com";
  static dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
