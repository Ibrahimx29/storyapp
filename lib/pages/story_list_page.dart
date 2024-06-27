import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/providers/auth_provider.dart';
import 'package:storyapp/providers/story_provider.dart';
import 'package:storyapp/widgets/story_card_widget.dart';

class StoryListPage extends StatefulWidget {
  final Function(String) onTapped;
  final Function() onActionButtonTapped;
  final Function() onLogout;

  const StoryListPage({
    super.key,
    required this.storyProvider,
    required this.title,
    required this.onTapped,
    required this.onActionButtonTapped,
    required this.onLogout,
  });

  final String title;
  final StoryProvider storyProvider;

  @override
  State<StoryListPage> createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // final storyProvider = context.read<StoryProvider>();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        if (widget.storyProvider.pageItems != null) {
          widget.storyProvider.getStories();
        }
      }
    });

    Future.microtask(() async => widget.storyProvider.getStories());
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authWatch = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              final authRead = context.read<AuthProvider>();
              final result = await authRead.logout();
              if (result) widget.onLogout();
            },
            icon: authWatch.isLoadingLogout
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer<StoryProvider>(
        builder: (context, value, child) {
          final state = value.isLoadingStories;
          if (state == true) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state == false) {
            return ListView.builder(
              controller: scrollController,
              itemCount:
                  value.stories.length + (value.pageItems != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == value.stories.length && value.pageItems != null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                var story = value.stories[index];
                return StoryCard(
                    index: index, story: story, onTapped: widget.onTapped);
              },
            );
          } else {
            return const Center(
              child: Text("No data"),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onActionButtonTapped,
        child: const Icon(Icons.add),
      ),
    );
  }
}
