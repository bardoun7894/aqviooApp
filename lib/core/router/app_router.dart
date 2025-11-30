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
import '../../features/admin/auth/screens/admin_login_screen.dart';
import '../../features/admin/auth/providers/admin_auth_provider.dart';
import '../../features/admin/dashboard/screens/dashboard_home_screen.dart';
import '../../features/admin/users/screens/users_list_screen.dart';
import '../../features/admin/users/screens/user_detail_screen.dart';
import '../../features/admin/content/screens/content_viewer_screen.dart';
import '../../features/admin/payments/screens/payments_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final adminAuthState = ref.watch(adminAuthControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authRepositoryProvider).authStateChanges,
    ),
    redirect: (context, state) {
      final isLoggedIn = authState.value == true;
      final isAdminLoggedIn = adminAuthState.isAuthenticated;
      final currentPath = state.uri.toString();
      final isAdminRoute = currentPath.startsWith('/admin');
      final isAdminLogin = currentPath == '/admin/login';
      final isSplash = currentPath == '/splash';
      final isLogin = currentPath == '/login';
      final isSignup = currentPath == '/signup';

      // Admin routes handling
      if (isAdminRoute) {
        if (!isAdminLoggedIn && !isAdminLogin) {
          return '/admin/login';
        }
        if (isAdminLogin && isAdminLoggedIn) {
          return '/admin/dashboard';
        }
        return null; // Allow access to admin route
      }

      // Mobile app routes handling
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
      // Admin Routes
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const DashboardHomeScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UsersListScreen(),
      ),
      GoRoute(
        path: '/admin/users/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserDetailScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/admin/content',
        builder: (context, state) => const ContentViewerScreen(),
      ),
      GoRoute(
        path: '/admin/payments',
        builder: (context, state) => const PaymentsScreen(),
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
