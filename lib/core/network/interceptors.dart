import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// This interceptor is used to show request and response logs
class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.e('${options.method} request ==> $requestPath'); //Error log
    logger.d(
      'Error type: ${err.error} \n '
      'Error message: ${err.message}',
    ); //Debug log
    handler.next(err); //Continue with the Error
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} request ==> $requestPath'); //Info log
    logger.i('request ${options.data}'); //Info log
    handler.next(options); // continue with the Request
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d(
      'Response Details:\n'
      '========================\n'
      'Status Code: ${response.statusCode}\n'
      'Status Message: ${response.statusMessage}\n'
      'Headers:\n${_formatHeaders(response.headers)}'
      // 'Data:\n${_formatData(response.data)}\n'
      '========================',
    );

    handler.next(response); // Continue with the Response
  }

  String _formatHeaders(Headers headers) {
    final headerStringBuffer = StringBuffer();
    headers.forEach((key, value) {
      headerStringBuffer.writeln('$key: ${value.join(', ')}');
    });
    return headerStringBuffer.toString();
  }

  String _formatData(dynamic data) {
    if (data is Map || data is List) {
      return const JsonEncoder.withIndent('  ').convert(data);
    } else {
      return data.toString();
    }
  }
  // String _formatData(dynamic data) {
  //   if (data is Map) {
  //     // Extract only the desired fields
  //     final filteredData = {
  //       'responseCode': data['responseCode'],
  //       'responseMessage': data['responseMessage'],
  //     };
  //     return const JsonEncoder.withIndent('  ').convert(filteredData);
  //   } else if (data is List) {
  //     return const JsonEncoder.withIndent('  ').convert(data);
  //   } else {
  //     return data.toString();
  //   }
  // }

  // @override
  // void onResponse(Response response, ResponseInterceptorHandler handler) {
  //   logger.d('STATUSCODE: ${response.statusCode} \n '
  //       'STATUSMESSAGE: ${response.statusMessage} \n'
  //       'HEADERS: ${response.headers} \n'
  //       'Data: ${response.data}'); // Debug log
  //   handler.next(response); // continue with the Response
  // }
}
