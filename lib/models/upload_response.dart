import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'upload_response.g.dart';

@JsonSerializable()
class UploadResponse {
  final bool error;
  final String message;

  UploadResponse({
    required this.error,
    required this.message,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadResponseToJson(this);

  factory UploadResponse.fromJsonString(String source) =>
      UploadResponse.fromJson(json.decode(source));

  String toJsonString() => json.encode(toJson());
}
