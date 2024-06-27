import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/providers/image_path_provider.dart';
import 'package:storyapp/providers/story_provider.dart';
import 'package:storyapp/routes/router_delegate.dart';

class NewStoryPage extends StatefulWidget {
  final String title;
  final Function() onPickLocation;

  const NewStoryPage({
    super.key,
    required this.title,
    required this.onPickLocation,
  });

  @override
  State<NewStoryPage> createState() => _NewStoryPageState();
}

class _NewStoryPageState extends State<NewStoryPage> {
  final storyTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    storyTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(top: 10, left: 50, right: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Consumer<ImagePathProvider>(
                          builder: (context, provider, _) {
                            return provider.imagePath == null
                                ? const Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.image,
                                      size: 100,
                                    ),
                                  )
                                : _showImage(provider.imagePath!);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _onGalleryView(context),
                        child: const Text("Gallery"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _onCameraView(context),
                        child: const Text("Camera"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: TextFormField(
                          controller: storyTextController,
                          minLines: 6,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            hintText: "Write your story...",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: widget.onPickLocation,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Pick a location'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _onUpload(storyTextController.text),
                        child: const Text("Upload New Story"),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showImage(String imagePath) {
    return kIsWeb
        ? Image.network(
            imagePath,
            fit: BoxFit.contain,
          )
        : Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            width: 250,
            height: 300,
          );
  }

  _onGalleryView(BuildContext context) async {
    final provider = Provider.of<ImagePathProvider>(context, listen: false);

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onCameraView(BuildContext context) async {
    final provider = Provider.of<ImagePathProvider>(context, listen: false);

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onUpload(String description) async {
    final uploadProvider = context.read<StoryProvider>();
    final homeProvider = context.read<ImagePathProvider>();
    final imagePath = homeProvider.imagePath;
    final imageFile = homeProvider.imageFile;

    if (imagePath == null || imageFile == null) {
      const snackBar = SnackBar(
        content: Text('Please provide an image.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (description.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Please enter your story description.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);

      final fileName = imageFile.name;
      final bytes = await imageFile.readAsBytes();

      final newBytes = await uploadProvider.compressImage(bytes);

      await uploadProvider.upload(
        newBytes,
        fileName,
        description,
      );

      if (uploadProvider.uploadResponse != null) {
        homeProvider.setImageFile(null);
        homeProvider.setImagePath(null);
        storyTextController.clear();

        scaffoldMessengerState.showSnackBar(
          SnackBar(content: Text(uploadProvider.message)),
        );

        final routerDelegate =
            Router.of(context).routerDelegate as MyRouterDelegate;
        routerDelegate.onNewStoryUploaded();
      } else {
        scaffoldMessengerState.showSnackBar(
          const SnackBar(content: Text('Failed to upload story.')),
        );
      }
    }
  }
}
