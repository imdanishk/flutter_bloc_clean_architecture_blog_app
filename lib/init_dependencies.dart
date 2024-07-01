import 'package:flutter_bloc_clean_architecture_blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/core/secrets/app_secrets.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/domain/usecases/current_user.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/domain/usecases/user_login.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();

  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  // Registering Supabase client as a lazy singleton to ensure only one instance is created and shared across the app.
  serviceLocator.registerLazySingleton(() => supabase.client);

  // core
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(),
  );
}

void _initAuth() {
  // Datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )

    // Repository
    // Registering AuthRepository as a factory to get a new instance each time it's needed.
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
      ),
    )

    // Usecases
    // Registering UserSignUp use case as a factory to ensure each use case call gets a fresh instance.
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )

    // Registering AuthBloc as a lazy singleton to maintain a single instance throughout the app's lifecycle.
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}
