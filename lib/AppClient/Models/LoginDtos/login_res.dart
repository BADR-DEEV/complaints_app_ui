class LoginResponse {
  bool? success;
  String? message;
  Data? data;
  int? statusCode;

  LoginResponse({this.success, this.message, this.data, this.statusCode});

  LoginResponse.fromJson(Map<String, dynamic> json) {
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
  //tomap method to convert the object to a Map
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'statusCode': statusCode,
    };
  }

  //copyWith method to create a copy of the object with modified values
  LoginResponse copyWith({
    bool? success,
    String? message,
    Data? data,
    int? statusCode,
  }) {
    return LoginResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}

class Data {
  String? displayName;
  String? email;
  String? role;
  String? createdAt;
  String? accessToken;

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
