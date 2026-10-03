import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return ApiException('No internet connection.');
      case DioExceptionType.cancel:
        return ApiException('Request cancelled.');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        return ApiException(_messageFromStatus(code), statusCode: code);
      default:
        return ApiException('Something went wrong.');
    }
  }

  static String _messageFromStatus(int? code) {
    switch (code) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Not found.';
      case 500:
        return 'Server error. Try again later.';
      default:
        return 'Unexpected error ($code).';
    }
  }

  @override
  String toString() => message;
}