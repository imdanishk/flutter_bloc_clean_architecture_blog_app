import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  // Future<UserModel> loginWithEmailPassword({
  //   required String email,
  //   required String password,
  // });

  // Future<UserModel?> getCurrentUserData();
}

/// Here, Supabase client from the constructor, and not initialized here like this:
/// final supabaseClient = SupabaseClient(AppSecrets.supabaseUrl, AppSecrets.supabaseAnonKey);
/// because it'll create dependency between the auth remote data source implementation and the supabase client.
/// So, if anytime we have to change our database, lets say, from Supabase to Firebase, there'll be lots of things to do.
/// So, we're going to use a dependency injection, whenever this class is called, we're going to inject SupabaseClient over here.
/// Also, whenever we've external depedency, we always have to create a mock when we're testing, so it'll help to mock the SupabaseClient
/// and injecting when we are testing.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  // @override
  // Future<UserModel> loginWithEmailPassword({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     final response = await supabaseClient.auth.signInWithPassword(
  //       password: password,
  //       email: email,
  //     );
  //     if (response.user == null) {
  //       throw const ServerException('User is null!');
  //     }
  //     return UserModel.fromJson(response.user!.toJson());
  //   } on AuthException catch (e) {
  //     throw ServerException(e.message);
  //   } catch (e) {
  //     throw ServerException(e.toString());
  //   }
  // }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {
          'name': name,
        },
      );
      if (response.user == null) {
        throw const ServerException('User is null!');
      }
      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // @override
  // Future<UserModel?> getCurrentUserData() async {
  //   try {
  //     if (currentUserSession != null) {
  //       final userData = await supabaseClient.from('profiles').select().eq(
  //             'id',
  //             currentUserSession!.user.id,
  //           );
  //       return UserModel.fromJson(userData.first).copyWith(
  //         email: currentUserSession!.user.email,
  //       );
  //     }

  //     return null;
  //   } catch (e) {
  //     throw ServerException(e.toString());
  //   }
  // }
}
