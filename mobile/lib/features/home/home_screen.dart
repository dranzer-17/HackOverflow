import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/noise_background.dart';
import '../../core/widgets/ember_divider.dart';
import '../../core/widgets/live_ticker.dart';
import '../../core/widgets/pulse_dot.dart';
import '../../core/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _initial = 'U';

  @override
  void initState() {
    super.initState();
    AuthService.meProfile().then((m) {
      if (!mounted) return;
      final name = m['full_name'] ?? m['email'] ?? 'U';
      setState(() => _initial = name.toString().substring(0, 1).toUpperCase());
    }).catchError((Object _) {
      // Network unreachable, backend down, or not configured (e.g. use --dart-define=API_BASE_URL=http://10.0.2.2:8000 for Android emulator)
      if (!mounted) return;
      setState(() => _initial = 'U');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoiseBackground(
        opacity: 0.04,
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(initial: _initial),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HeroSection(),
                      EmberDivider(label: 'PROFILE'),
                      _SectionTiles(
                        tiles: [
                          _Tile(label: 'User Profile', icon: Icons.person, onTap: () => context.push('/user-profile')),
                          _Tile(label: 'Resume Builder', icon: Icons.description, onTap: () => context.push('/resume-builder')),
                          _Tile(label: 'Portfolio Builder', icon: Icons.dashboard_customize, onTap: () => context.push('/portfolio-builder')),
                        ],
                      ),
                      EmberDivider(label: 'LEARNING'),
                      _SectionTiles(
                        tiles: [
                          _Tile(label: 'Roadmap Generator', icon: Icons.map, onTap: () => context.push('/roadmap-generator')),
                          _Tile(label: 'PPT Maker', icon: Icons.slideshow, onTap: () => context.push('/ppt-maker')),
                          _Tile(label: 'Flashcards', icon: Icons.style, onTap: () => context.push('/flashcards')),
                          _Tile(label: 'Explainer Agent', icon: Icons.lightbulb, onTap: () => context.push('/explainer-agent')),
                          _Tile(label: 'Career Counsellor', icon: Icons.record_voice_over, onTap: () => context.push('/career-counsellor')),
                        ],
                      ),
                      EmberDivider(label: 'JOB APPLICATION'),
                      _SectionTiles(
                        tiles: [
                          _Tile(label: 'Resume ATS Score', icon: Icons.analytics, onTap: () => context.push('/resume-ats')),
                          _Tile(label: 'Cover Letter', icon: Icons.mail, onTap: () => context.push('/cover-letter')),
                          _Tile(label: 'AI Mock Interview', icon: Icons.video_call, onTap: () => context.push('/mock-interview')),
                          _Tile(label: 'Cold Mail Sender', icon: Icons.send, onTap: () => context.push('/cold-mail')),
                          _Tile(label: 'Active Jobs', icon: Icons.work, onTap: () => context.push('/active-jobs')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LiveTicker(
                        items: const [
                          'RESUME ATS: 87% ↑',
                          'INTERVIEW PREP: ACTIVE',
                          '3 JOBS MATCHED',
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.initial = 'U'});
  final String initial;

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Text(
            'MORPHEUS',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.mercury,
              fontSize: 22,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8),
            height: 2,
            width: 40,
            color: AppColors.primary,
          ),
          const Spacer(),
          const PulseDot(size: 10, active: true),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surface,
            child: Text(
              initial,
              style: AppTypography.label.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            color: AppColors.mercury,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(40, 40),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(-0.1, -0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR CAREER.\nACCELERATED.',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 28,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '// AI-powered. Human-centered.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.foregroundFaded),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('87', style: AppTypography.displayLarge.copyWith(color: AppColors.primary, fontSize: 48)),
                Text('ATS SCORE', style: AppTypography.label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTiles extends StatelessWidget {
  const _SectionTiles({required this.tiles});

  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final t = tiles[i];
          return _FeatureTile(label: t.label, icon: t.icon, onTap: t.onTap);
        },
      ),
    );
  }
}

class _Tile {
  const _Tile({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.heavyImpact();
          onTap();
        },
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: AppColors.cardBorder, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
