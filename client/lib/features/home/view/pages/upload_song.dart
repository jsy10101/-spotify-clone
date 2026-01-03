import 'dart:io';

import 'package:client/core/theme/app_theme.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  final songNameController = TextEditingController();
  final artistController = TextEditingController();
  Color selectedColor = Pallete.cardColor;
  File? selectedImage;
  File? selectedAudio;

  void selectAudio() async {
    final pickedAudio = await pickAudio();
    if (pickedAudio != null) {
      setState(() {
        selectedAudio = pickedAudio;
      });
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  @override
  void dispose() {
    songNameController.dispose();
    artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload song"),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.check))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: selectImage,
                child: selectedImage != null
                    ? SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(selectedImage!, fit: BoxFit.cover),
                        ),
                      )
                    : DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: const Radius.circular(10),
                          color: Pallete.borderColor,
                          strokeWidth: 2,
                          dashPattern: const [10, 4],
                        ),
                        child: const SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open, size: 40),
                              SizedBox(height: 15),
                              Text(
                                'Select the thumbnail for your song',
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              CustomField(
                hintText: 'Pick a song',
                controller: null,
                readOnly: true,
                onTap: selectAudio,
              ),
              const SizedBox(height: 20),
              CustomField(hintText: 'Artist', controller: artistController),
              const SizedBox(height: 20),
              CustomField(hintText: 'Song', controller: songNameController),
              const SizedBox(height: 20),
              ColorPicker(
                pickersEnabled: const {ColorPickerType.wheel: true},
                color: selectedColor,
                onColorChanged: (color) => {
                  setState(() {
                    selectedColor = color;
                  }),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
