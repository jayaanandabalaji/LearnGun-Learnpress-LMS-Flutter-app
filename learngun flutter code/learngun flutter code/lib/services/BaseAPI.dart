import 'dart:developer';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../services/SharedPrefs.dart';
import '../../utils/constants.dart';
import '../../services/GetTokenAPI.dart';
import '../../widgets/Notify/notify.dart';

class baseAPI {
  static const base_url = Constants.base_url;
  static const String apiEndpoint = base_url + "/wp-json/learnpress/v1/";
  final _dio = Dio();

  Future getAsync(String endPoint,
      {Map? data,
      bool customUrl = false,
      bool requires_license = false}) async {
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 10,
    ));

    String url = apiEndpoint + endPoint;

    if (customUrl) {
      url = base_url + "/wp-json/" + endPoint;
    }
    if (requires_license) {
      _dio.options.headers["Authorization"] =
          "Bearer ${Constants.purchase_code}";
    }
    if (data != null) {
      if (data.containsKey("requirestoken")) {
        data.remove("requirestoken");
        var token = await GetToken();
        _dio.options.headers["Authorization"] = "Bearer $token";
      }
    }
    _dio.options.headers["Cache-Control"] = "no-cache";
    Response response;
    try {
      response = await _dio.get(url);
    } on DioError catch (e) {
      if (e.type == DioErrorType.other) {
        return await prefs.getJson(url);
      } else {
        HandleError(e);
        return null;
      }
    }
    log("returing response " + response.data.runtimeType.toString());
    prefs.setJson(url, response.data);
    return (response.data);
  }

  postAsync(String endPoint, Map data,
      {bool customUrl = false, bool requires_license = false}) async {
    _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));

    Object MapData;

    String url = apiEndpoint + endPoint;
    if (customUrl) {
      url = base_url + "/wp-json/" + endPoint;
    }
    if (requires_license) {
      _dio.options.headers["Authorization"] =
          "Bearer ${Constants.purchase_code}";
    }
    _dio.options.headers["Cache-Control"] = "no-cache";
    if (data.containsKey("requirestoken")) {
      data.remove("requirestoken");
      var token = await GetToken();
      _dio.options.headers["Authorization"] = "Bearer $token";
    }
    if (data.containsKey("file")) {
      for (var file in data["file"].keys.toList()) {
        _dio.options.headers["Content-Type"] = "multipart/form-data";
        data[file] = await MultipartFile.fromFile(data["file"][file].path,
            filename: data["file"][file].path.split('/').last);
      }
      data.remove("file");

      MapData = FormData.fromMap(Map<String, dynamic>.from(data));
    } else {
      MapData = jsonEncode(data);
    }
    Response response;
    try {
      response = await _dio.post(url, data: MapData);
    } on DioError catch (e) {
      HandleError(e);
      return null;
    }
    return (response.data);
  }

  static HandleError(DioError error) {
    if (jsonDecode(error.response.toString())["message"] != null) {
      RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      notify.showDialog("Error " + error.response!.statusCode.toString(),
          jsonDecode(error.response.toString())["message"].replaceAll(exp, ''),
          on_confirm: () {
        Get.back();
      });
    } else {
      notify.showDialog(error.type.toString(), error.response.toString(),
          on_confirm: () {
        Get.back();
      });
    }
  }
}
