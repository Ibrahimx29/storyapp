import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:storyapp/models/story.dart';
import 'package:http/http.dart' as http;
import 'package:storyapp/models/upload_response.dart';

class StoryService {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1/';

  Future<List<ListStory>> getAllStories([int page = 1, int size = 10]) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');
    const location = 1;

    final url =
        Uri.parse("$_baseUrl/stories?page=$page&size=$size&location=$location");
    final response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> listStoryJson = responseData['listStory'];

      return listStoryJson.map((json) => ListStory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch stories');
    }
  }

  Future<DetailStory> getStoryDetail(String storyId) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');

    final url = Uri.parse("$_baseUrl/stories/$storyId");
    final response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      DetailStory detailStory = DetailStory.fromJson(jsonData);

      return detailStory;
    } else {
      throw Exception('Failed to fetch stories');
    }
  }

  Future<UploadResponse> uploadDocument(
    List<int> bytes,
    String fileName,
    String description,
  ) async {
    const String url = "https://story-api.dicoding.dev/v1/stories";
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');

    final uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);

    final multiPartFile = http.MultipartFile.fromBytes(
      "photo",
      bytes,
      filename: fileName,
    );
    final Map<String, String> fields = {
      "description": description,
    };
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      "Content-type": "multipart/form-data",
    };

    request.files.add(multiPartFile);
    request.fields.addAll(fields);
    request.headers.addAll(headers);

    final http.StreamedResponse streamedResponse = await request.send();
    final int statusCode = streamedResponse.statusCode;

    final Uint8List responseList = await streamedResponse.stream.toBytes();
    final String responseData = String.fromCharCodes(responseList);

    if (statusCode == 201) {
      final UploadResponse uploadResponse = UploadResponse.fromJsonString(
        responseData,
      );
      return uploadResponse;
    } else {
      throw Exception("Upload file error");
    }
  }
}
