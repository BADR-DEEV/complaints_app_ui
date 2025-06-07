class RegisterResponse {
  bool? success;
  String? message;
  Data? data;
  int? statusCode;

  RegisterResponse({this.success, this.message, this.data, this.statusCode});

  RegisterResponse.fromJson(Map<String, dynamic> json) {
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
  String? displayName;
  String? email;
  String? role;
  String? createdAt;
  Null? accessToken;

  Data({this.displayName, this.email, this.role, this.createdAt, this.accessToken});

  Data.fromJson(Map<String, dynamic> json) {
    displayName = json['displayName'];
    email = json['email'];
    role = json['role'];
    createdAt = json['createdAt'];
    accessToken = json['accessToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['displayName'] = this.displayName;
    data['email'] = this.email;
    data['role'] = this.role;
    data['createdAt'] = this.createdAt;
    data['accessToken'] = this.accessToken;
    return data;
  }
}
