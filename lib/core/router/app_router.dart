import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/creation/presentation/screens/magic_loading_screen.dart';
import '../../features/preview/presentation/screens/preview_screen.dart';
import '../../features/creation/presentation/screens/my_creations_screen.dart';
import '../../features/auth/presentation/screens/account_settings_screen.dart';
import '../../features/payment/presentation/screens/payment_screen.dart';

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
      final isSignup = state.uri.toString() == '/signup';

      if (authState.isLoading) {
        return '/splash';
      }

      if (isSplash && isLoggedIn) {
        return '/home';
      }

      if ((isLogin || isSignup) && isLoggedIn) {
        return '/home';
      }

      if (!isLoggedIn && !isLogin && !isSignup && !isSplash) {
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
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/magic-loading',
        builder: (context, state) => const MagicLoadingScreen(),
      ),
      GoRoute(
        path: '/preview',
        builder: (context, state) {
          String? videoUrl;
          String? thumbnailUrl;

          if (state.extra is Map<String, dynamic>) {
            final args = state.extra as Map<String, dynamic>;
            videoUrl = args['videoUrl'] as String?;
            thumbnailUrl = args['thumbnailUrl'] as String?;
          } else if (state.extra is String) {
            videoUrl = state.extra as String;
          }

          if (videoUrl == null) return const HomeScreen();
          return PreviewScreen(
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
          );
        },
      ),
      GoRoute(
        path: '/my-creations',
        builder: (context, state) => const MyCreationsScreen(),
      ),
      GoRoute(
        path: '/account-settings',
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          double amount = 199.0;
          if (state.extra is double) {
            amount = state.extra as double;
          }
          return PaymentScreen(amount: amount);
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
