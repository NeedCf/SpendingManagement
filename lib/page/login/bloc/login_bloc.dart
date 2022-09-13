import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spending_management/page/login/bloc/login_event.dart';
import 'package:spending_management/page/login/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(InitState()) {
    on<LoginWithEmailPasswordEvent>((event, emit) async {
      bool check = await signInWithEmailAndPassword(
          emailAddress: event.email, password: event.password);
      if (check) {
        emit(LoginSuccessState());
      } else {
        emit(LoginErrorState());
      }
    });

    on<LoginWithGoogleEvent>((event, emit) async {
      UserCredential? user = await signInWithGoogle();
      if (user != null) {
        emit(LoginSuccessState());
      } else {
        emit(LoginErrorState());
      }
    });

    on<LoginWithFacebookEvent>((event, emit) async {
      await signInWithFacebook();
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    }

    return null;
  }

  Future<UserCredential> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();

    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  Future<bool> signInWithEmailAndPassword(
      {required String emailAddress, required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return false;
    }
  }
}
