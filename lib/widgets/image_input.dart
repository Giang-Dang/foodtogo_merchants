import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,
    required this.onPickImage,
  });
  final void Function(File image) onPickImage;

  @override
  State<StatefulWidget> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _takePicture() async {
    String imageSoure = '';
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
              color: KColors.kOnBackgroundColor,
              borderRadius: BorderRadius.circular(16.0)),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  imageSoure = 'Camera';
                  Navigator.of(context).pop();
                },
                label: const Text('Camera'),
                icon: const Icon(Icons.photo_camera),
              ),
              const SizedBox(width: 25),
              ElevatedButton.icon(
                onPressed: () {
                  imageSoure = 'Gallery';
                  Navigator.of(context).pop();
                },
                label: const Text('Gallery'),
                icon: const Icon(Icons.photo_library),
              ),
            ],
          ),
        );
      },
    );

    final imagePicker = ImagePicker();
    dynamic pickedImage;
    switch (imageSoure) {
      case 'Camera':
        pickedImage = await imagePicker.pickImage(
            source: ImageSource.camera, maxWidth: 600);
        break;
      case 'Gallery':
        pickedImage = await imagePicker.pickImage(
            source: ImageSource.gallery, maxWidth: 600);
        break;
      default:
    }

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      onPressed: _takePicture,
      icon: const Icon(Icons.camera),
      label: const Text('Take Picture'),
    );

    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takePicture,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        width: 1,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      )),
      height: 170,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}
