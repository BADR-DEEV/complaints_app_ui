class AddComplaintResponse {
  bool? success;
  String? message;
  Data? data;
  int? statusCode;

  AddComplaintResponse({this.success, this.message, this.data, this.statusCode});

  AddComplaintResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class Data {
  int? id;
  String? complainTitle;
  String? complainDescription;
  String? complainDateTime;
  String? complainStatus;
  String? fileName;
  int? categoriesId;
  Categories? categories;
  String? userId;
  Null? user;

  Data({this.id, this.complainTitle, this.complainDescription, this.complainDateTime, this.complainStatus, this.fileName, this.categoriesId, this.categories, this.userId, this.user});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    complainTitle = json['complainTitle'];
    complainDescription = json['complainDescription'];
    complainDateTime = json['complainDateTime'];
    complainStatus = json['complainStatus'];
    fileName = json['fileName'];
    categoriesId = json['categoriesId'];
    categories = json['categories'] != null ? new Categories.fromJson(json['categories']) : null;
    userId = json['userId'];
    user = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['complainTitle'] = this.complainTitle;
    data['complainDescription'] = this.complainDescription;
    data['complainDateTime'] = this.complainDateTime;
    data['complainStatus'] = this.complainStatus;
    data['fileName'] = this.fileName;
    data['categoriesId'] = this.categoriesId;
    if (this.categories != null) {
      data['categories'] = this.categories!.toJson();
    }
    data['userId'] = this.userId;
    data['user'] = this.user;
    return data;
  }
}

class Categories {
  int? id;
  String? name;
  String? aRName;
  String? aRDes;
  String? description;

  Categories({this.id, this.name, this.aRName, this.aRDes, this.description});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    aRName = json['aR_Name'];
    aRDes = json['aR_Des'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['aR_Name'] = this.aRName;
    data['aR_Des'] = this.aRDes;
    data['description'] = this.description;
    return data;
  }
}
