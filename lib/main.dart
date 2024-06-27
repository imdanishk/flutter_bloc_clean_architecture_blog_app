import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/core/theme/theme.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/custom_bloc_observer.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_bloc_clean_architecture_blog_app/init_dependencies.dart';

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
          create: (_) => serviceLocator<AuthBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkThemeMode,
      home: const LoginPage(),
    );
  }
}
