import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/filme.dart';

class FilmeService {
  FilmeService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  String get _uid {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) throw StateError('Usuário não autenticado.');
    return uid;
  }

  Future<List<Filme>> listar() async {
    final snapshot = await _db
        .collection('filmes')
        .where('uid', isEqualTo: _uid)
        .get();
    final filmes = snapshot.docs
        .map((doc) => Filme.fromMap(doc.data(), id: doc.id))
        .toList();
    filmes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filmes;
  }

  Future<void> criar(Filme filme) async {
    await _db.collection('filmes').add({...filme.toMap(), 'uid': _uid});
  }

  Future<void> remover(String id) async {
    final reference = _db.collection('filmes').doc(id);
    final snapshot = await reference.get();
    if (!snapshot.exists || snapshot.data()?['uid'] != _uid) {
      throw StateError('Filme não encontrado.');
    }
    await reference.delete();
  }
}
