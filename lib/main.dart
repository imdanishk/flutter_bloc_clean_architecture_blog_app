import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/core/theme/theme.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/custom_bloc_observer.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/blog/presentation/pages/blog_page.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/init_dependencies.dart';

/// Core module/ package can not depend on other features but other features can depend on core.

/// Dependency Injection is a Design Pattern, used to achieve inversion of control, which means that
/// the dependencies of a component, and that component can be a class or a module, so the dependencies
/// of those components are provided externally rather than creating internally.
///
/// With GetIt for DI, you need to register your dependencies, and then you can just register the service locator
/// to pass the dependencies to the component, that's all.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  Bloc.observer = CustomBlocObserver();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AppUserCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<AuthBloc>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<BlogBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bloc Clean Architecture Blog App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkThemeMode,
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) {
          return state is AppUserLoggedIn;
        },
        builder: (context, isLoggedIn) {
          if (isLoggedIn) {
            return const BlogPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
