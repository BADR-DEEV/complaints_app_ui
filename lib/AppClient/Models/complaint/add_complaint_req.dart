import 'dart:io';

class AddComplaintRequest {
  final String complainTitle;
  final String complainDescription;
  final int categoriesId;
  final File? image;

  AddComplaintRequest({
    required this.complainTitle,
    required this.complainDescription,
    required this.categoriesId,
    this.image,
  });

  Map<String, String> toJson() {
    return {
      'ComplainTitle': complainTitle,
      'ComplainDescription': complainDescription,
      'CategoriesId': categoriesId.toString(),
    };
  }
}
