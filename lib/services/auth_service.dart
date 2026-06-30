import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth;

  final FirebaseAuth? _auth;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  Future<void> login(String email, String senha) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mensagem(error.code));
    } catch (_) {
      throw const AuthException(
        'Não foi possível entrar. Verifique a configuração do Firebase.',
      );
    }
  }

  Future<void> cadastro(String email, String senha) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mensagem(error.code));
    } catch (_) {
      throw const AuthException(
        'Não foi possível criar a conta. Verifique a configuração do Firebase.',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      throw const AuthException('Não foi possível sair. Tente novamente.');
    }
  }

  String _mensagem(String code) => switch (code) {
        'invalid-email' => 'Informe um e-mail válido.',
        'invalid-credential' || 'wrong-password' =>
          'E-mail ou senha incorretos.',
        'user-not-found' => 'Nenhuma conta encontrada com este e-mail.',
        'weak-password' => 'A senha deve ter pelo menos 6 caracteres.',
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'too-many-requests' => 'Muitas tentativas. Aguarde e tente novamente.',
        'network-request-failed' => 'Sem conexão. Verifique sua internet.',
        _ => 'Não foi possível concluir a autenticação. Tente novamente.',
      };
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
