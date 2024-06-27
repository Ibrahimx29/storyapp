import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/apis/auth_service.dart';
import 'package:storyapp/apis/story_service.dart';
import 'package:storyapp/providers/auth_provider.dart';
import 'package:storyapp/providers/image_path_provider.dart';
import 'package:storyapp/providers/story_provider.dart';
import 'package:storyapp/routes/router_delegate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyRouterDelegate myRouterDelegate;
  late AuthProvider authProvider;
  late StoryProvider storyProvider;
  late ImagePathProvider imagePathProvider;

  @override
  void initState() {
    super.initState();
    final authService = AuthService();
    final storyService = StoryService();

    authProvider = AuthProvider(authService);
    storyProvider = StoryProvider(storyService);
    imagePathProvider = ImagePathProvider();
    myRouterDelegate =
        MyRouterDelegate(authProvider, storyProvider, imagePathProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: storyProvider),
        ChangeNotifierProvider.value(value: imagePathProvider),
      ],
      child: MaterialApp(
        title: 'Dicoding Story App',
        theme: FlexThemeData.light(scheme: FlexScheme.ebonyClay),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.ebonyClay),
        themeMode: ThemeMode.system,
        home: Router(
          routerDelegate: myRouterDelegate,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      ),
    );
  }
}
