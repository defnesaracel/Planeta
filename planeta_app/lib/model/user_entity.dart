class UserEntity {
  final String uid;
  final String email;
  final String? displayName;

  UserEntity({required this.uid, required this.email, this.displayName});

  // İleride Firebase'den veri çekerken (Firestore) kullanmak için factory metodu
  factory UserEntity.fromMap(Map<String, dynamic> data, String id) {
    return UserEntity(
      uid: id,
      email: data['email'] ?? '',
      displayName: data['username'] ?? data['displayName'],
    );
  }
}
