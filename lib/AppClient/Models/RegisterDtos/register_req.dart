class RegisterRequest {
  String? displayName;
  String? email;
  String? password;

  RegisterRequest({this.displayName, this.email, this.password});

  RegisterRequest.fromJson(Map<String, dynamic> json) {
    displayName = json['displayName'];
    email = json['email'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['displayName'] = this.displayName;
    data['email'] = this.email;
    data['password'] = this.password;
    return data;
  }

  // copyWith method to create a copy of the object with modified values
  RegisterRequest copyWith({String? displayName, String? email, String? password}) {
    return RegisterRequest(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  // toMap method to convert the object to a Map

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'password': password,
    };
  }
}
