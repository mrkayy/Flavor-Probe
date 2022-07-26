import 'dart:io';

import 'package:dio/dio.dart';

class BackendService {
  static final BackendService _instance = BackendService._singleton();

  late Dio dio;
  late String _host;

  BackendService._singleton();

  factory BackendService({required Dio dio, required String hosturl}) {
    _instance.dio = dio;
    _instance._host = hosturl;
    return _instance;
  }

  /// This allows you set [header] options outside the backend service class
  // Function get setExtraHeader => _setExtraHeaders;
  // get initializeService => _initializeDio();

  void setExtraHeaders(Map<String, dynamic> newHeaders) {
    Map<String, dynamic> existingHeaders = _instance.dio.options.headers;
    newHeaders.forEach((key, value) =>
        existingHeaders.update(key, (_) => value, ifAbsent: () => value));
    _instance.dio.options.headers = existingHeaders;
  }

  void initializeDio() {
    //
    _instance.dio.options = BaseOptions(
      baseUrl: _instance._host,
      connectTimeout: 5000,
      receiveTimeout: 5000,
      // set request headers
      headers: {
        "content-Type": "application/json",
      },
    );

    _instance.dio.interceptors.add(
      InterceptorsWrapper(
          onRequest: _onRequestInterceptors,
          onResponse: _onResponseInterceptors,
          onError: _onErrorInterceptorHandler),
    );
  }

  Future<void> _setToken(RequestOptions option) async {
    String? token = 'toke';
    token != null ? option.headers = {"Authorization": "Bearer $token"} : null;
  }

  _onRequestInterceptors(RequestOptions options,
      RequestInterceptorHandler requestInterceptorHandler) async {
    await _setToken(options);
    return requestInterceptorHandler.next(options); //continue
  }

  _onResponseInterceptors(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    return handler.next(response); // continue
  }

  _onErrorInterceptorHandler(DioError e, handler) {
    return handler.next(e); //continue
  }

  /// This allows you change [baseurl] options outside the backend service class
  // void changeBaseUrl(String newBaseUrl) => dio.options.baseUrl = newBaseUrl;

  _apiResponse({dynamic message, dynamic? errorCode}) {
    return {
      "message": message ?? "an_error_occurred_please_try_again",
      "errorCode": errorCode ?? "000",
    };
  }

  Response? handleError(DioError? e) {
    // debugPrint();
    // debugPrint(
    // "=============================[ALERT-😱😱😱]: ${e?.requestOptions.uri}");
    // debugPrint(
    //     "=====================================[ALERT-😱😱😱]: ${e?.response?.data["description"]}");

    Response? response;

    switch (e?.type) {
      case DioErrorType.cancel:
        response = Response(
          data: _apiResponse(
            message: 'Request cancelled!',
          ),
          requestOptions: RequestOptions(path: ''),
        );
        break;
      case DioErrorType.connectTimeout:
        response = Response(
          data: _apiResponse(
            message: "Network connection timed out!",
          ),
          requestOptions: RequestOptions(path: ''),
        );
        break;
      case DioErrorType.receiveTimeout:
        response = Response(
          data: _apiResponse(
            message: "Something went wrong. Please try again later!",
          ),
          requestOptions: RequestOptions(path: ''),
        );
        break;
      case DioErrorType.sendTimeout:
        response = Response(
          data: _apiResponse(
            message: "Something went wrong. Please try again later",
          ),
          requestOptions: RequestOptions(path: ''),
        );
        break;
      case DioErrorType.other:
        if (e?.error is SocketException) {
          response = Response(
            data: _apiResponse(
              message: "Please check your network connection!",
            ),
            requestOptions: RequestOptions(path: ''),
          );
        } else if (e?.error is HttpException) {
          response = Response(
            data: _apiResponse(
              message: "Network connection issue",
            ),
            requestOptions: RequestOptions(path: ''),
          );
        }
        break;
      default:
        if (e!.response!.data.runtimeType == String &&
            e.error.toString().contains("404")) {
          response = Response(
            data: _apiResponse(
              message: "An error occurred, please try again",
              errorCode: '404',
            ),
            requestOptions: RequestOptions(path: ''),
          );
        } else if (e.response?.data.runtimeType == String &&
            e.error.toString().contains("400")) {
          try {
            response = Response(
              data: _apiResponse(
                message: e.response?.data["description"] ??
                    "An error occurred, please try again",
                errorCode: '400',
              ),
              requestOptions: RequestOptions(path: ''),
            );
          } catch (e) {
            response = Response(
              data: _apiResponse(
                message: "An error occurred, please try again",
                errorCode: '400',
              ),
              requestOptions: RequestOptions(path: ''),
            );
          }
        } else {
          response = Response(
              data: _apiResponse(
                  message: e.response!.data.isNotEmpty
                      ? e.response!.data["description"]
                      : "NULL",
                  errorCode: e.response!.data.isNotEmpty
                      ? e.response!.data["errorCode"]
                      : "null"),
              statusCode: e.response?.statusCode ?? 000,
              requestOptions: RequestOptions(path: ''));
        }
    }
    return response;
  }
}
