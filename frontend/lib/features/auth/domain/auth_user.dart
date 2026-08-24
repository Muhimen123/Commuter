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

  Map<String, dynamic> toDbMap({String? passwordHash}) => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'password_hash': passwordHash ?? 'supabase_auth',
        'profile_photo_url': profilePhotoUrl,
        'location_permission_granted': locationPermissionGranted,
        'contacts_permission_granted': contactsPermissionGranted,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        fullName: (json['fullName'] ?? json['full_name'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        phoneNumber:
            (json['phoneNumber'] ?? json['phone_number'] ?? '') as String,
        profilePhotoUrl:
            (json['profilePhotoUrl'] ?? json['profile_photo_url']) as String?,
        locationPermissionGranted: (json['locationPermissionGranted'] ??
            json['location_permission_granted'] ??
            false) as bool,
        contactsPermissionGranted: (json['contactsPermissionGranted'] ??
            json['contacts_permission_granted'] ??
            false) as bool,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : json['created_at'] != null
                ? DateTime.parse(json['created_at'] as String)
                : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : json['updated_at'] != null
                ? DateTime.parse(json['updated_at'] as String)
                : DateTime.now(),
      );

  @override
  String toString() =>
      'AuthUser(id: $id, fullName: $fullName, email: $email, phoneNumber: $phoneNumber)';
}