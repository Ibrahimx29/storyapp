import 'package:flutter/foundation.dart';
import 'package:storyapp/apis/story_service.dart';
import 'package:storyapp/models/api_state.dart';
import 'package:storyapp/models/story.dart';
import 'package:storyapp/models/upload_response.dart';
import 'package:image/image.dart' as img;

class StoryProvider extends ChangeNotifier {
  final StoryService storyService;

  StoryProvider(this.storyService);

  bool isLoadingStories = false;
  bool isUploading = false;
  ApiState loadingState = ApiState.initial;
  String message = "";
  UploadResponse? uploadResponse;
  List<ListStory> stories = [];

  int? pageItems = 1;
  int sizeItems = 10;

  Future<void> getStories() async {
    try {
      if (pageItems == 1) {
        isLoadingStories = true;
        notifyListeners();
      }

      var newStories = await storyService.getAllStories(pageItems!, sizeItems);

      stories.addAll(newStories);

      isLoadingStories = false;

      if (stories.length < sizeItems) {
        pageItems = null;
      } else {
        pageItems = pageItems! + 1;
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching stories: $e');
      }
      stories = [];
    }

    isLoadingStories = false;
    notifyListeners();
  }

  Future<DetailStory> fetchStoryDetail(String storyId) async {
    isLoadingStories = true;
    try {
      DetailStory story = await storyService.getStoryDetail(storyId);
      isLoadingStories = false;
      notifyListeners();
      return story;
    } catch (e) {
      isLoadingStories = false;
      if (kDebugMode) {
        print('Error fetching story: $e');
      }
      if (e is Exception && e.toString().contains('Story data not found')) {
        throw Exception("Story data not found!");
      } else {
        rethrow;
      }
    } finally {
      isLoadingStories = false;
      notifyListeners();
    }
  }

  Future<void> upload(
    List<int> bytes,
    String fileName,
    String description,
  ) async {
    try {
      message = "";
      uploadResponse = null;
      isUploading = true;
      notifyListeners();
      uploadResponse =
          await storyService.uploadDocument(bytes, fileName, description);

      if (uploadResponse != null) {
        stories.clear();
        pageItems = 1;
        await getStories();
      }

      message = uploadResponse?.message ?? "success";
      isUploading = false;
      notifyListeners();
    } catch (e) {
      isUploading = false;
      message = e.toString();
      notifyListeners();
    }
  }

  Future<List<int>> compressImage(List<int> bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;
    final image = img.decodeImage(Uint8List.fromList(bytes))!;
    int compressQuality = 100;
    int length = imageLength;
    List<int> newByte = [];
    do {
      ///
      compressQuality -= 10;
      newByte = img.encodeJpg(
        image,
        quality: compressQuality,
      );
      length = newByte.length;
    } while (length > 1000000);
    return newByte;
  }
}
