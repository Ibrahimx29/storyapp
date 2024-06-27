import 'package:json_annotation/json_annotation.dart';

part 'story.g.dart';

@JsonSerializable()
class Story {
  bool error;
  String message;
  List<ListStory> listStory;

  Story({
    required this.error,
    required this.message,
    required this.listStory,
  });

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);
}

@JsonSerializable()
class DetailStory {
  bool error;
  String message;
  StoryDetails story;

  DetailStory({
    required this.error,
    required this.message,
    required this.story,
  });

  factory DetailStory.fromJson(Map<String, dynamic> json) =>
      _$DetailStoryFromJson(json);

  Map<String, dynamic> toJson() => _$DetailStoryToJson(this);
}

@JsonSerializable()
class ListStory {
  String id;
  String name;
  String description;
  String photoUrl;
  DateTime createdAt;
  double? lat;
  double? lon;

  ListStory({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    required this.lat,
    required this.lon,
  });

  factory ListStory.fromJson(Map<String, dynamic> json) =>
      _$ListStoryFromJson(json);

  Map<String, dynamic> toJson() => _$ListStoryToJson(this);
}

@JsonSerializable()
class StoryDetails {
  String id;
  String name;
  String description;
  String photoUrl;
  DateTime createdAt;
  dynamic lat;
  dynamic lon;

  StoryDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    required this.lat,
    required this.lon,
  });

  factory StoryDetails.fromJson(Map<String, dynamic> json) =>
      _$StoryDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$StoryDetailsToJson(this);
}
