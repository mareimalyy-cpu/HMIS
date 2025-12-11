import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

// Base class for configuring Dio with interceptors, logging, and timeouts
class DioClient {
  late final Dio _dio;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  DioClient({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        sendTimeout: const Duration(milliseconds: 30000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            _logger.i("REQUEST[${options.method}] => PATH: ${options.path}");
            _logger.i("Headers: ${options.headers}");
            _logger.i("Data: ${options.data}");
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            _logger.i(
              "RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}",
            );
            _logger.i("Data: ${response.data}");
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            _logger.e(
              "ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}",
            );
            _logger.e("Message: ${e.message}");
          }
          return handler.next(e);
        },
      ),
    );

    // Add retry interceptor (simplified version for now, prefer using dio_smart_retry/retry package)
    // For a robust implementation, consider adding the `dio_smart_retry` package.
  }

  Dio get dio => _dio;
}
