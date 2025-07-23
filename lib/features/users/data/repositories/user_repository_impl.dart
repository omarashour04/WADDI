import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore firestore;
  UserRepositoryImpl({required this.firestore});

  @override
  Future<UserEntity?> getUserById(String id) async {
    final doc = await firestore.collection('users').doc(id).get();
    if (!doc.exists) return null;
    return UserEntity.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> createUser(UserEntity user) async {
    await firestore.collection('users').doc(user.id).set(user.toMap());
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await firestore.collection('users').doc(user.id).update(user.toMap());
  }

  @override
  Future<void> deleteUser(String id) async {
    await firestore.collection('users').doc(id).delete();
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final snapshot = await firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserEntity.fromMap(doc.data(), doc.id)).toList();
  }
} 