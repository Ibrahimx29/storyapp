import 'package:flutter/material.dart';
import 'package:storyapp/models/story.dart';
import 'package:storyapp/pages/new_story_page.dart';
import 'package:storyapp/pages/story_detail_page.dart';
import 'package:storyapp/pages/story_list_page.dart';
import 'package:storyapp/pages/login_page.dart';
import 'package:storyapp/pages/register_page.dart';
import 'package:storyapp/pages/splash_screen_page.dart';
import 'package:storyapp/providers/auth_provider.dart';
import 'package:storyapp/providers/image_path_provider.dart';
import 'package:storyapp/providers/story_provider.dart';
import 'package:storyapp/screens/pick_maps_screen.dart';
import 'package:storyapp/screens/view_maps_screen.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;
  final AuthProvider authProvider;
  final StoryProvider storyProvider;
  final ImagePathProvider imagePathProvider;

  MyRouterDelegate(
      this.authProvider, this.storyProvider, this.imagePathProvider)
      : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  _init() async {
    isLoggedIn = await authProvider.authService.isLoggedIn();
    notifyListeners();
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  String? selectedStory;
  double? latitude;
  double? longitude;

  List<Page> historyStack = [];
  bool? isLoggedIn;
  bool? isAddNewStory;
  bool? isPickLocation;
  bool? isViewLocation;
  bool isRegister = false;

  void onNewStoryUploaded() {
    isAddNewStory = false;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      historyStack = _splashStack;
    } else if (isLoggedIn == true) {
      historyStack = _loggedInStack;
    } else {
      historyStack = _loggedOutStack;
    }

    return Navigator(
      key: navigatorKey,
      pages: List.of(historyStack),
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }

        if (isViewLocation == true) {
          isViewLocation = false;
          latitude = null;
          longitude = null;
        } else if (isPickLocation == true) {
          isPickLocation = false;
        } else if (isAddNewStory == true) {
          isAddNewStory = false;
        } else if (selectedStory != null) {
          selectedStory = null;
        } else if (isRegister == true) {
          isRegister = false;
        }

        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async {}

  List<Page> get _splashStack => const [
        MaterialPage(
          key: ValueKey("SplashScreen"),
          child: SplashScreen(title: "Story List"),
        ),
      ];

  List<Page> get _loggedOutStack => [
        MaterialPage(
          key: const ValueKey("LoginPage"),
          child: LoginPage(
            onLogin: () {
              isLoggedIn = true;
              notifyListeners();
            },
            onRegister: () {
              isRegister = true;
              notifyListeners();
            },
          ),
        ),
        if (isRegister == true)
          MaterialPage(
            key: const ValueKey("RegisterPage"),
            child: RegisterPage(
              onRegister: () {
                isRegister = false;
                notifyListeners();
              },
              onLogin: () {
                isRegister = false;
                notifyListeners();
              },
            ),
          ),
      ];

  List<Page> get _loggedInStack => [
        MaterialPage(
          key: const ValueKey("HomePage"),
          child: StoryListPage(
            storyProvider: storyProvider,
            onTapped: (String storyId) {
              selectedStory = storyId;
              notifyListeners();
            },
            onLogout: () {
              isLoggedIn = false;
              notifyListeners();
            },
            onActionButtonTapped: () {
              isAddNewStory = true;
              notifyListeners();
            },
            title: 'Story List',
          ),
        ),
        if (selectedStory != null)
          MaterialPage(
            key: ValueKey(selectedStory),
            child: FutureBuilder<DetailStory>(
              future: storyProvider.fetchStoryDetail(selectedStory!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return StoryDetailPage(
                    story: snapshot.data!,
                    onTapped: (double lat, double lon) {
                      latitude = lat;
                      longitude = lon;
                      isViewLocation = true;
                      notifyListeners();
                    },
                  );
                } else {
                  return const Text('Cannot retrieve data');
                }
              },
            ),
          ),
        if (isViewLocation == true && latitude != null && longitude != null)
          MaterialPage(
            key: const ValueKey("ViewLocation"),
            child: ViewMapScreen(
              title: 'View Location',
              lat: latitude,
              lon: longitude,
            ),
          ),
        if (isAddNewStory == true)
          MaterialPage(
            key: const ValueKey("NewStory"),
            child: NewStoryPage(
              title: 'Add New Story',
              onPickLocation: () {
                isPickLocation = true;
                notifyListeners();
              },
            ),
          ),
        if (isPickLocation == true)
          const MaterialPage(
            key: ValueKey("PickLocation"),
            child: PickMapScreen(
              title: 'Pick Location',
            ),
          ),
      ];
}
