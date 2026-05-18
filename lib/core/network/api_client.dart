import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../services/preferences_service.dart';

class ApiClient {
  ApiClient(this._prefs, {http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final PreferencesService _prefs;
  final http.Client _http;
  static const Duration _timeout = Duration(seconds: 30);

  Map<String, String> _headers({bool auth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = _prefs.token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  Future<Map<String, dynamic>> get(String path, {bool auth = true}) async {
    return _send(() => _http
        .get(_uri(path), headers: _headers(auth: auth))
        .timeout(_timeout));
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    return _send(() => _http
        .post(_uri(path),
            headers: _headers(auth: auth), body: jsonEncode(body))
        .timeout(_timeout));
  }

  Future<Map<String, dynamic>> delete(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    return _send(() => _http
        .delete(_uri(path),
            headers: _headers(auth: auth), body: jsonEncode(body))
        .timeout(_timeout));
  }

  Future<Map<String, dynamic>> _send(
      Future<http.Response> Function() request) async {
    try {
      final response = await request();
      return _decode(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    final code = response.statusCode;
    Map<String, dynamic> body = const {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      } catch (_) {
        throw ServerException('Malformed response', statusCode: code);
      }
    }

    if (code >= 200 && code < 300) return body;

    final message = (body['message'] ?? body['detail'] ?? 'Request failed')
        .toString();
    if (code == 401 || code == 403) {
      throw AuthException(message);
    }
    throw ServerException(message, statusCode: code);
  }

  void dispose() => _http.close();
}
