import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/noise_background.dart';
import '../../../core/widgets/glitch_text.dart';
import '../../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await AuthService.signup(
        email: _email.text.trim(),
        password: _password.text,
        fullName: _name.text.trim(),
      );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoiseBackground(
        opacity: 0.04,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: GlitchText(
                    'MORPHEUS',
                    style: AppTypography.displayMedium.copyWith(color: AppColors.mercury),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'CREATE ACCOUNT',
                    style: AppTypography.tag,
                  ),
                ),
                const SizedBox(height: 40),
                Text('> FULL NAME', style: AppTypography.terminalPrefix),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(hintText: 'John Doe'),
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text('> EMAIL', style: AppTypography.terminalPrefix),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'you@example.com'),
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text('> PASSWORD', style: AppTypography.terminalPrefix),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: '••••••••'),
                  style: AppTypography.bodyMedium,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.ember)),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ember,
                      foregroundColor: AppColors.mercury,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mercury),
                          )
                        : Text('CREATE ACCOUNT', style: AppTypography.label.copyWith(color: AppColors.mercury)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text('Already have an account? Log in', style: AppTypography.bodySmall.copyWith(color: AppColors.ember)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
