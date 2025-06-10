import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart'; // for local storage
import 'package:http/http.dart' as http; // for downloading the image
import 'package:path/path.dart' as p;

class ImageUploadService {
  static final ValueNotifier<File?> profileImageNotifier = ValueNotifier<File?>(null);
  final ImagePicker _picker = ImagePicker();

  static final ImageUploadService _instance = ImageUploadService._internal();

  factory ImageUploadService() {
    return _instance;
  }

  // Private constructor to prevent instantiation from outside
  ImageUploadService._internal();

  // Picking image from gallery and resizing
  Future<File?> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      // final originalImage = File(pickedFile.path);

      // Decode the image

      if (pickedFile != null) {
        print("file is : ${pickedFile}");
        return File(pickedFile.path);
        // // Create a square image
        // int size = original.width > original.height ? original.height : original.width;
        // img.Image squareImage = img.copyResizeCropSquare(original, size: size);

        // // Resize the image
        // img.Image resizedImage = img.copyResize(squareImage, width: 200, height: 200);

        // final resizedImageBytes = img.encodePng(resizedImage);
        // final resizedImageFile = File('${originalImage.parent.path}/resized_${originalImage.uri.pathSegments.last}');

        // // Write the resized image to file
        // await resizedImageFile.writeAsBytes(resizedImageBytes);

        // // profileImageNotifier.value = resizedImageFile;
        // return resizedImageFile;
      } else {
        File("");
      }
    } catch (e) {
      print('Error picking image: $e');
    }

    return null;
  }

  // Converting image to base64 and MIME type
  Future<Map<String, String?>> convertToBase64AndMime(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = lookupMimeType(imageFile.path);

      return {
        "base64Image": base64Image,
        "mimeType": mimeType,
      };
    } catch (e) {
      print('Error converting image to base64: $e');
      return {"base64Image": null, "mimeType": null};
    }
  }

  // Download image from URL and save locally
  Future<File?> downloadAndSaveProfileImage(String imageUrl) async {
    print('Downloading image from $imageUrl');
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Get the directory to store the file
        final directory = await getApplicationDocumentsDirectory();
        final filePath = p.join(directory.path, 'profile_image.png');
        final file = File(filePath);

        // Delete old file if exists
        await _deleteOldFileIfExists(file);
        PaintingBinding.instance.imageCache.evict(FileImage(file));
        //clear image cache

        // Write the new image bytes to the file
        await file.writeAsBytes(response.bodyBytes);
        print('Image saved at $filePath');

        // Notify listeners
        profileImageNotifier.value = file;

        return file;
      } else {
        print('Failed to download image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  Future<void> _deleteOldFileIfExists(File file) async {
    if (await file.exists()) {
      print('Deleting old profile image at ${file.path}');
      await file.delete();
    }
  }

  Future<File?> getSavedProfileImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = p.join(directory.path, 'profile_image.png');
      final file = File(filePath);

      // Check if the saved file exists
      if (await file.exists()) {
        profileImageNotifier.value = file;
        return file;
      } else {
        print('Profile image file not found at path: $filePath');
      }
    } catch (e) {
      print('Error retrieving profile image: $e');
    }

    // Return null if file doesn't exist or an error occurred
    return null;
  }

  Future<void> deleteSavedProfileImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = p.join(directory.path, 'profile_image.png');
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
      profileImageNotifier.value = null;
    }
  }

  Future<void> saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = p.join(directory.path, 'profile_image.png');
    final file = File(filePath);

    // Delete old file if exists
    await _deleteOldFileIfExists(file);

    // Copy the new image
    await image.copy(filePath);
    print('New image saved at $filePath');

    // Update the notifier with the saved file
    profileImageNotifier.value = file;
    print('Notifier updated with new image file: ${file.path}');
  }

  Future<String> convertToBase64WithMime(File imageFile) async {
    final bytes = imageFile.readAsBytesSync();
    final base64Image = base64Encode(bytes);
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/png';
    return 'data:$mimeType;base64,$base64Image';
  }
}
