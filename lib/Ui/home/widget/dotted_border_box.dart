import 'dart:io';

import 'package:complaintsapp/AppClient/Services/image_picker.dart';
import 'package:complaintsapp/Ui/shared/constants/colors&fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

class DottedBorderBox extends StatefulWidget {
  final void Function(File? image) onImageSelected;

  const DottedBorderBox({super.key, required this.onImageSelected});
  @override
  State<DottedBorderBox> createState() => _DottedBorderBoxState();
}

class _DottedBorderBoxState extends State<DottedBorderBox> {
  File? image;
  Future<void> _pickImage() async {
    final pickedImage = await ImageUploadService().pickImage(); // Assuming you have this service

    // 3. Call the callback with the new image
    widget.onImageSelected(pickedImage);

    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  void _removeImage() {
    // 4. Call the callback with null when the image is removed
    widget.onImageSelected(null);
    setState(() {
      image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          // The border is defined on the outer container
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primaryColor,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              // Change 1: Remove the button's internal padding
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                // The shape clips the child, making ClipRRect redundant
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _pickImage,
            child: Center(
              child: image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primaryColor),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.tapToUpload,
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                      ],
                    )
                  // Change 2: Removed the redundant ClipRRect widget
                  : Image.file(
                      image!,
                      fit: BoxFit.cover,
                      // These ensure the image tries to fill the available space
                      width: double.infinity,
                      height: double.infinity,
                    ),
            ),
          ),
        ),
        // This part for the "close" button remains the same and is correct
        if (image != null)
          Positioned(
            top: 8, // Added a small padding for better visuals
            right: 8, // Added a small padding for better visuals
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(4), // Give the icon some breathing room
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
