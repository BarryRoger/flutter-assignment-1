/// نموذج يمثل بيانات الطالب في النظام الأكاديمي
class UserModel {
  final String id;
  final String fullName;
  final String academicId;
  final String email;
  final String college;
  final String major;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.academicId,
    required this.email,
    this.college = 'كلية علوم الحاسب والمعلومات',
    this.major = 'هندسة البرمجيات',
    required this.createdAt,
  });

  /// إنشاء نسخة مع تعديلات محددة
  UserModel copyWith({
    String? id,
    String? fullName,
    String? academicId,
    String? email,
    String? college,
    String? major,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      academicId: academicId ?? this.academicId,
      email: email ?? this.email,
      college: college ?? this.college,
      major: major ?? this.major,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// تحويل الكائن إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'academicId': academicId,
      'email': email,
      'college': college,
      'major': major,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// بناء كائن من Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      academicId: map['academicId'] as String,
      email: map['email'] as String,
      college: map['college'] as String? ?? 'كلية علوم الحاسب والمعلومات',
      major: map['major'] as String? ?? 'هندسة البرمجيات',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, academicId: $academicId, email: $email)';
  }
}
