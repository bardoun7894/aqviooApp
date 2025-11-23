import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/creation/presentation/screens/magic_loading_screen.dart';
import '../../features/preview/presentation/screens/preview_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authRepositoryProvider).authStateChanges,
    ),
    redirect: (context, state) {
      final isLoggedIn = authState.value == true;
      final isSplash = state.uri.toString() == '/splash';
      final isLogin = state.uri.toString() == '/login';

      if (authState.isLoading) {
        return '/splash';
      }

      if (isSplash && isLoggedIn) {
        return '/home';
      }

      if (isSplash && !isLoggedIn) {
        return '/login';
      }

      if (isLogin && isLoggedIn) {
        return '/home';
      }

      if (!isLoggedIn && !isLogin && !isSplash) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/magic-loading',
        builder: (context, state) => const MagicLoadingScreen(),
      ),
      GoRoute(
        path: '/preview',
        builder: (context, state) {
          final videoUrl = state.extra as String;
          return PreviewScreen(videoUrl: videoUrl);
        },
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
