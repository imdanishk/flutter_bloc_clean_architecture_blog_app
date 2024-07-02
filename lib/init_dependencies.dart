import 'package:flutter_bloc_clean_architecture_blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/core/network/connection_checker.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/core/secrets/app_secrets.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/domain/usecases/current_user.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/domain/usecases/user_login.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/blog/domain/usecases/upload_blog.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();

  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

  // Registering Supabase client as a lazy singleton to ensure only one instance is created and shared across the app.
  serviceLocator.registerLazySingleton(() => supabase.client);

  serviceLocator.registerLazySingleton(
    () => Hive.box(name: 'blogs'),
  );

  serviceLocator.registerFactory(() => InternetConnection());

  // core
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(),
  );
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      serviceLocator(),
    ),
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

void _initBlog() {
  // Datasource
  serviceLocator
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<BlogLocalDataSource>(
      () => BlogLocalDataSourceImpl(
        serviceLocator(),
      ),
    )

    // Repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => UploadBlog(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetAllBlogs(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => BlogBloc(
        uploadBlog: serviceLocator(),
        getAllBlogs: serviceLocator(),
      ),
    );
}
