import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:poem/config/app_config.dart';
import 'package:poem/models/poem.dart';

class PoemService {
  final String baseUrl;

  PoemService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Future<ApiResult<List<Poem>>> fetchPoems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/poems'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final apiResponse = ApiResult<List<Poem>>.fromJson(
          jsonResponse,
          dataDecoder: (data) {
            if (data is List) {
              return data.map((item) => Poem.fromJson(item)).toList();
            }
            return [];
          },
        );

        if (!apiResponse.isSuccess) {
          throw Exception(apiResponse.msg);
        }

        return apiResponse;
      } else {
        throw Exception('Failed to load poems: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiResult<Poem>> fetchPoemById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/poem/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final apiResponse = ApiResult<Poem>.fromJson(
          jsonResponse,
          dataDecoder: (data) => Poem.fromJson(data),
        );

        if (!apiResponse.isSuccess) {
          throw Exception(apiResponse.msg);
        }

        return apiResponse;
      } else {
        throw Exception('Failed to load poem: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiResult<Poem>> createPoem({
    required String name,
    required String author,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/poem'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'author': author, 'content': content}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final apiResponse = ApiResult<Poem>.fromJson(
          jsonResponse,
          dataDecoder: (data) => Poem.fromJson(data),
        );

        if (!apiResponse.isSuccess) {
          throw Exception(apiResponse.msg);
        }

        return apiResponse;
      } else {
        throw Exception('Failed to create poem: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiResult<void>> renewPoem(Poem poem) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/poem/${poem.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(poem.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final apiResponse = ApiResult<void>.fromJson(jsonResponse);

        if (!apiResponse.isSuccess) {
          throw Exception(apiResponse.msg);
        }

        return apiResponse;
      } else {
        throw Exception('Failed to renew poem: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiResult<void>> removePoemById(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/poem/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final apiResponse = ApiResult<void>.fromJson(jsonResponse);

        if (!apiResponse.isSuccess) {
          throw Exception(apiResponse.msg);
        }

        return apiResponse;
      } else {
        throw Exception('Failed to remove poem: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
