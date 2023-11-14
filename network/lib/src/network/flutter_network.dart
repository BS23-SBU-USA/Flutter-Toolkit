import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_network/src/network/dio_cache_service.dart';
import 'package:flutter_network/src/utils/failures.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

part 'api_options.dart';

class FlutterNetwork {
  static final FlutterNetwork _instance = FlutterNetwork._internal();

  FlutterNetwork._internal();

  factory FlutterNetwork({
    required String baseUrl,
    required Future<String?> Function() tokenCallBack,
    VoidCallback? onUnAuthorizedError,
    Future<String?> Function()? initializeCacheDirectory,
    int connectionTimeout = 30000,
    int receiveTimeout = 30000,
  }) {
    _instance.baseUrl = baseUrl;
    _instance.tokenCallBack = tokenCallBack;
    _instance.onUnAuthorizedError = onUnAuthorizedError ?? () {};
    _instance.connectionTimeout = connectionTimeout;
    _instance.receiveTimeout = receiveTimeout;
    _instance.initializeCacheDirectory = initializeCacheDirectory;

    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: connectionTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
    );

    _instance._dio = Dio(options);
    return _instance;
  }

  late Dio _dio;
  late int connectionTimeout;
  late int receiveTimeout;
  late String baseUrl;
  late Future<String?> Function() tokenCallBack;
  late VoidCallback onUnAuthorizedError;
  late Future<String?> Function()? initializeCacheDirectory;
  String? cacheDirectoryPath;

  Future<Response<dynamic>> get(
    String path, {
    APIType apiType = APIType.public,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    bool isCacheEnabled = true,
  }) async {
    _setDioInterceptorList(isCacheEnabled: isCacheEnabled);

    final standardHeaders = await _getOptions(apiType);

    return _dio
        .get(path, queryParameters: query, options: standardHeaders)
        .then((value) => value)
        .catchError(_handleException);
  }

  Future<Response<dynamic>> post(
    String path, {
    required Map<String, dynamic> data,
    APIType apiType = APIType.public,
    bool isFormData = false,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? query,
  }) async {
    _setDioInterceptorList();

    final standardHeaders = await _getOptions(apiType);
    if (headers != null) {
      standardHeaders.headers?.addAll(headers);
    }

    if (isFormData) {
      standardHeaders.headers?.addAll({
        'Content-Type': 'multipart/form-data',
      });
    } else {
      if (headers != null) {
        standardHeaders.headers?.addAll(headers);
      }
    }

    return _dio
        .post(
          path,
          data: isFormData ? FormData.fromMap(data) : data,
          options: standardHeaders,
          queryParameters: query,
        )
        .then((value) => value)
        .catchError(_handleException);
  }

  Future<Response<dynamic>> patch(
    String path, {
    required Map<String, dynamic> data,
    APIType apiType = APIType.public,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? query,
  }) async {
    _setDioInterceptorList();

    final standardHeaders = await _getOptions(apiType);
    if (headers != null) {
      standardHeaders.headers?.addAll(headers);
    }

    return _dio
        .patch(
          path,
          data: data,
          options: standardHeaders,
          queryParameters: query,
        )
        .then((value) => value)
        .catchError(_handleException);
  }

  Future<Response<dynamic>> put(
    String path, {
    required Map<String, dynamic> data,
    APIType apiType = APIType.public,
    bool isFormData = false,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? query,
  }) async {
    _setDioInterceptorList();

    final standardHeaders = await _getOptions(apiType);

    if (isFormData) {
      if (headers != null) {
        standardHeaders.headers?.addAll({
          'Content-Type': 'multipart/form-data',
        });
      }
      data.addAll({
        '_method': 'PUT',
      });
    } else {
      if (headers != null) {
        standardHeaders.headers?.addAll(headers);
      }
    }

    return _dio
        .put(
          path,
          data: isFormData ? FormData.fromMap(data) : data,
          options: standardHeaders,
        )
        .then((value) => value)
        .catchError(_handleException);
  }

  Future<Response<dynamic>> delete(
    String path, {
    Map<String, dynamic>? data,
    APIType apiType = APIType.public,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? query,
  }) async {
    _setDioInterceptorList();

    final standardHeaders = await _getOptions(apiType);
    if (headers != null) {
      standardHeaders.headers?.addAll(headers);
    }

    return _dio
        .delete(
          path,
          data: data,
          queryParameters: query,
          options: standardHeaders,
        )
        .then((value) => value)
        .catchError(_handleException);
  }

  dynamic _handleException(error) {
    dynamic errorData = error.response!.data;

    switch (error.response?.statusCode) {
      case 400:
        throw BadRequest(errorData);
      case 401:
        onUnAuthorizedError();
        throw Unauthorized(errorData);
      case 403:
        throw Forbidden(errorData);
      case 404:
        throw NotFound(errorData);
      case 405:
        throw MethodNotAllowed(errorData);
      case 406:
        throw NotAcceptable(errorData);
      case 408:
        throw RequestTimeout(errorData);
      case 409:
        throw Conflict(errorData);
      case 410:
        throw Gone(errorData);
      case 411:
        throw LengthRequired(errorData);
      case 412:
        throw PreconditionFailed(errorData);
      case 413:
        throw PayloadTooLarge(errorData);
      case 414:
        throw URITooLong(errorData);
      case 415:
        throw UnsupportedMediaType(errorData);
      case 416:
        throw RangeNotSatisfiable(errorData);
      case 417:
        throw ExpectationFailed(errorData);
      case 422:
        throw UnprocessableEntity(errorData);
      case 429:
        throw TooManyRequests(errorData);
      case 500:
        throw InternalServerError(errorData);
      case 501:
        throw NotImplemented(errorData);
      case 502:
        throw BadGateway(errorData);
      case 503:
        throw ServiceUnavailable(errorData);
      case 504:
        throw GatewayTimeout(errorData);
      default:
        throw Unexpected(errorData);
    }
  }

  void _setDioInterceptorList({bool isCacheEnabled = false}) async {
    List<Interceptor> interceptorList = [];
    _dio.interceptors.clear();

    if (kDebugMode) {
      interceptorList.add(PrettyDioLogger());
    }

    try {
      if (initializeCacheDirectory != null) {
        cacheDirectoryPath ??= await initializeCacheDirectory!();
      }

      if (isCacheEnabled) {
        interceptorList.add(
          DioCacheInterceptor(
            options: DioCacheService.getCacheOptions(path: cacheDirectoryPath),
          ),
        );
      }
    } catch (e, stackTrace) {
      print(e.toString());
      print(stackTrace.toString());
    }

    _dio.interceptors.addAll(interceptorList);
  }

  Future<Options> _getOptions(APIType api) async {
    switch (api) {
      case APIType.public:
        return PublicApiOptions().options;

      case APIType.protected:
        String? token = await tokenCallBack();

        return ProtectedApiOptions(token!).options;

      default:
        return PublicApiOptions().options;
    }
  }
}
