import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Here, also we cannot create AuthRemoteDataSource like this:
/// final AuthRemoteDataSource authRemoteDataSource = AuthRemoteDataSourceImpl(supabaseClient);
/// because AuthRepositoryImpl should not depends on AuthRemoteDataSource, so again we're going to use dependency injection.

/// Also, don't put AuthRemoteDataSourceImpl here like this:
/// final AuthRemoteDataSourceImpl authRemoteDataSourceImpl;
/// because we don't want to depend on implementation, we just want to use/depend on the interface that we created.
/// Depending on the interface means, we don't care about how the implementation was done, we just care if the mothod
/// exist or not in our contract.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  const AuthRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<Either<Failure, String>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, String>> _getUser(
    Future<String> Function() fn,
  ) async {
    try {
      // if (!await (connectionChecker.isConnected)) {
      //   return left(Failure(Constants.noConnectionErrorMessage));
      // }
      final userId = await fn();

      return right(userId);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> loginWithEmailPassword(
      {required String email, required String password}) {
    // TODO: implement loginWithEmailPassword
    throw UnimplementedError();
  }
}
