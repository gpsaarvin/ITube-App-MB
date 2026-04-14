import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/roadmap/presentation/roadmap_detail_screen.dart';
import '../../features/roadmap/presentation/roadmap_generate_screen.dart';
import '../../features/resume/presentation/resume_analyzer_screen.dart';
import '../widgets/app_shell.dart';
import '../widgets/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authStateProvider.stream),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/resume',
            builder: (context, state) => const ResumeAnalyzerScreen(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/roadmap/generate',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => RoadmapGenerateScreen(
          initialTopic: state.uri.queryParameters['topic'],
        ),
      ),
      GoRoute(
        path: '/roadmap/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            RoadmapDetailScreen(roadmapId: state.pathParameters['id'] ?? ''),
      ),
    ],
    redirect: (context, state) {
      final uri = state.uri;
      if (uri.scheme == 'itubelearn' && uri.host == 'roadmap') {
        final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
        if (id.isNotEmpty) {
          return '/roadmap/$id';
        }
      }

      final location = uri.path;
      final isSplash = location == '/splash';
      if (isSplash) return null;
      final isLogin = location == '/login';
      final isLoggedIn = authState.valueOrNull != null;
      if (!isLoggedIn && !isLogin) return '/login';
      if (isLoggedIn && isLogin) return '/';
      return null;
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
