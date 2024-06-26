import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:recipes_app/core/constants/app_constants.dart';
import 'package:recipes_app/features/recipes/data/managers/remote/api_manager.dart';

class DioApiManager implements ApiManager {
  final Dio _dio;

  DioApiManager(this._dio) {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.headers = AppConstants.headers();
  }

  @override
  Future<dynamic> get(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParams);
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> post(String url,
      {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(url, data: jsonEncode(data));
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> put(String url,
      {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(url, data: jsonEncode(data));
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> delete(String url,
      {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.delete(url, data: jsonEncode(data));
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _processResponse(Response response) {
    if (response.statusCode == HttpStatus.ok) {
      if (response.data is String) {
        return jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.data is List<dynamic>) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Unsupported response format');
      }
    } else {
      final error = jsonDecode(response.data)['message'];
      if (error != null) {
        throw Exception(error);
      }
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }

  Exception _handleError(DioException error) {
    if (error.response != null) {
      return Exception(
          'Server error: ${error.response?.statusCode} ${error.response?.statusMessage}');
    } else {
      return Exception('Network error: ${error.message}');
    }
  }
}
