class UserResponseDto {
  final String displayName;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? accessToken;

  UserResponseDto({
    required this.displayName,
    required this.email,
    required this.role,
    required this.createdAt,
    this.accessToken,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      displayName: json['displayName'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      accessToken: json['accessToken'],
    );
  }
}
