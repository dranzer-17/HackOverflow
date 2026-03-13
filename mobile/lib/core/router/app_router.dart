import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/user_profile_screen.dart';
import '../../features/profile/resume_builder_screen.dart';
import '../../features/profile/portfolio_builder_screen.dart';
import '../../features/learning/roadmap_generator_screen.dart';
import '../../features/learning/ppt_maker_screen.dart';
import '../../features/learning/flashcards_screen.dart';
import '../../features/learning/explainer_agent_screen.dart';
import '../../features/learning/career_counsellor/presentation/career_counsellor_screen.dart';
import '../../features/job_application/resume_ats_screen.dart';
import '../../features/job_application/cover_letter_screen.dart';
import '../../features/job_application/mock_interview/presentation/mock_interview_screen.dart';
import '../../features/job_application/cold_mail_screen.dart';
import '../../features/job_application/active_jobs_screen.dart';
import '../services/auth_service.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;
  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = AuthService.isLoggedIn;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (!isAuth && !isAuthRoute && state.matchedLocation != '/') {
        return '/login';
      }
      if (isAuth && (state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
        return '/home';
      }
      if (isAuth && state.matchedLocation == '/') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const _SplashRedirect(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/career-counsellor',
        builder: (_, __) => const CareerCounsellorScreen(),
      ),
      GoRoute(
        path: '/mock-interview',
        builder: (_, __) => const MockInterviewScreen(),
      ),
      GoRoute(path: '/user-profile', builder: (_, __) => const UserProfileScreen()),
      GoRoute(path: '/resume-builder', builder: (_, __) => const ResumeBuilderScreen()),
      GoRoute(path: '/portfolio-builder', builder: (_, __) => const PortfolioBuilderScreen()),
      GoRoute(path: '/roadmap-generator', builder: (_, __) => const RoadmapGeneratorScreen()),
      GoRoute(path: '/ppt-maker', builder: (_, __) => const PptMakerScreen()),
      GoRoute(path: '/flashcards', builder: (_, __) => const FlashcardsScreen()),
      GoRoute(path: '/explainer-agent', builder: (_, __) => const ExplainerAgentScreen()),
      GoRoute(path: '/resume-ats', builder: (_, __) => const ResumeAtsScreen()),
      GoRoute(path: '/cover-letter', builder: (_, __) => const CoverLetterScreen()),
      GoRoute(path: '/cold-mail', builder: (_, __) => const ColdMailScreen()),
      GoRoute(path: '/active-jobs', builder: (_, __) => const ActiveJobsScreen()),
    ],
  );
}

class _SplashRedirect extends StatelessWidget {
  const _SplashRedirect();

  @override
  Widget build(BuildContext context) {
    if (AuthService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/home'));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text('MORPHEUS', style: TextStyle(color: AppColors.foreground, fontSize: 24)),
      ),
    );
  }
}
