import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final adminUsersProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance.collection('users').snapshots();
}); 