class AuthUser {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profilePhotoUrl;
  final bool locationPermissionGranted;
  final bool contactsPermissionGranted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePhotoUrl,
    this.locationPermissionGranted = false,
    this.contactsPermissionGranted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  AuthUser copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? Function()? profilePhotoUrl,
    bool? locationPermissionGranted,
    bool? contactsPermissionGranted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl:
          profilePhotoUrl == null ? this.profilePhotoUrl : profilePhotoUrl(),
      locationPermissionGranted:
          locationPermissionGranted ?? this.locationPermissionGranted,
      contactsPermissionGranted:
          contactsPermissionGranted ?? this.contactsPermissionGranted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'profilePhotoUrl': profilePhotoUrl,
        'locationPermissionGranted': locationPermissionGranted,
        'contactsPermissionGranted': contactsPermissionGranted,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        profilePhotoUrl: json['profilePhotoUrl'] as String?,
        locationPermissionGranted: json['locationPermissionGranted'] as bool,
        contactsPermissionGranted: json['contactsPermissionGranted'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  String toString() =>
      'AuthUser(id: $id, fullName: $fullName, email: $email, phoneNumber: $phoneNumber)';
}