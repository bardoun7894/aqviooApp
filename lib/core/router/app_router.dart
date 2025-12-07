import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import '../../features/auth/presentation/screens/support_screen.dart';
import '../../features/auth/presentation/screens/privacy_policy_screen.dart';
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
      final isAdminLoading = adminAuthState.isLoading;
      final currentPath = state.uri.toString();
      final isAdminRoute = currentPath.startsWith('/admin');
      final isAdminLogin = currentPath == '/admin/login';
      final isSplash = currentPath == '/splash';
      final isLogin = currentPath == '/login';
      final isSignup = currentPath == '/signup';

      debugPrint(
          '🛣️ Router: path=$currentPath, isAdminRoute=$isAdminRoute, isAdminLoading=$isAdminLoading, isAdminLoggedIn=$isAdminLoggedIn, mobileAuthLoading=${authState.isLoading}');

      // Platform-specific routing
      // Admin dashboard is WEB ONLY - redirect mobile users away from admin routes
      if (isAdminRoute && !kIsWeb) {
        debugPrint(
            '🛣️ Router: Admin routes not available on mobile, redirecting to /home');
        return isLoggedIn ? '/home' : '/login';
      }

      // Payment route is MOBILE ONLY - redirect web users away from payment
      if (currentPath == '/payment' && kIsWeb) {
        debugPrint(
            '🛣️ Router: Payment not available on web, redirecting to /home');
        return '/home';
      }

      // Admin routes handling - completely separate from mobile app (WEB ONLY)
      // IMPORTANT: Check admin routes FIRST before any mobile auth logic
      if (isAdminRoute) {
        // Don't redirect while admin auth is still loading/checking
        if (isAdminLoading) {
          debugPrint('🛣️ Router: Admin loading, staying on $currentPath');
          return null; // Stay on current page while checking auth
        }
        if (!isAdminLoggedIn && !isAdminLogin) {
          debugPrint(
              '🛣️ Router: Not admin logged in, redirecting to /admin/login');
          return '/admin/login';
        }
        if (isAdminLogin && isAdminLoggedIn) {
          debugPrint(
              '🛣️ Router: Admin logged in on login page, redirecting to /admin/dashboard');
          return '/admin/dashboard';
        }
        debugPrint('🛣️ Router: Admin route OK, no redirect');
        return null; // Allow access to admin route - don't run mobile app logic
      }

      // If admin is logged in and we're NOT on an admin route,
      // but trying to access splash/home due to refresh, stay on admin dashboard
      // This prevents the refreshListenable from redirecting away from admin
      if (isAdminLoggedIn &&
          !isAdminRoute &&
          (isSplash || authState.isLoading)) {
        debugPrint(
            '🛣️ Router: Admin logged in, preventing redirect to mobile routes');
        return '/admin/dashboard';
      }

      // Mobile app routes handling (only for non-admin routes)
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
      GoRoute(
          path: '/signup', builder: (context, state) => const SignUpScreen()),
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
          String? prompt;
          bool isImage = false;

          if (state.extra is Map<String, dynamic>) {
            final args = state.extra as Map<String, dynamic>;
            videoUrl = args['videoUrl'] as String?;
            thumbnailUrl = args['thumbnailUrl'] as String?;
            prompt = args['prompt'] as String?;
            isImage = args['isImage'] as bool? ?? false;
          } else if (state.extra is String) {
            videoUrl = state.extra as String;
          }

          if (videoUrl == null) return const HomeScreen();
          return PreviewScreen(
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
            prompt: prompt,
            isImage: isImage,
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
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
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
        path: '/admin',
        redirect: (context, state) => '/admin/dashboard',
      ),
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
