import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/repositories/user_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final userRepositoryProvider = Provider((ref) => UserRepositoryImpl(firestore: FirebaseFirestore.instance));

final userProvider = FutureProvider.family<UserEntity?, String>((ref, id) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUserById(id);
});

final allUsersProvider = FutureProvider<List<UserEntity>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getAllUsers();
}); 