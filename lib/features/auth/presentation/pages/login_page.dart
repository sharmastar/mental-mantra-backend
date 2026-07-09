import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/debouncer.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_gradient_button.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/auth_text_field.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../core/theme/app_theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? returnRoute;
  const LoginPage({super.key, this.returnRoute});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Throttler _signInThrottle = Throttler(interval: const Duration(milliseconds: 1000));
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _signInThrottle.reset();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSignInSuccess() {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    final isOnboarded = ref.read(authStateProvider).isOnboarded;
    final route = widget.returnRoute;
    if (route != null && route.isNotEmpty) {
      context.go(route);
    } else if (isOnboarded) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  void _onEmailPasswordSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_signInThrottle.tryRun()) return;
    try {
      final success = await ref.read(authStateProvider.notifier).signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            rememberMe: _rememberMe,
          );
      if (success && mounted) _onSignInSuccess();
    } catch (e) {
      if (mounted) _showError('Sign-in failed: ${e.toString()}');
    }
  }

  void _onGoogleSignIn() async {
    if (!_signInThrottle.tryRun()) return;
    try {
      final success = await ref.read(authStateProvider.notifier).signInWithGoogle();
      if (success && mounted) _onSignInSuccess();
    } catch (e) {
      if (mounted) _showError('Google sign-in failed: ${e.toString()}');
    }
  }

  void _showError(String message) {
    final size = MediaQuery.of(context).size;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: const Color(0xFFE06B7A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: EdgeInsets.only(bottom: size.height * 0.05, left: 20, right: 20),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Please enter a valid email';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider.select((s) => s.isLoading));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    ref.listen(authStateProvider, (prev, next) {
      if (next.errorMessage != null && prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(next.errorMessage!, style: const TextStyle(color: Colors.white))),
              ],
            ),
            backgroundColor: const Color(0xFFE06B7A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: EdgeInsets.only(
              bottom: size.height * 0.05,
              left: 20,
              right: 20,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        ref.read(authStateProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF12101E), Color(0xFF1A1530), Color(0xFF221D3D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFF8F7FC), Color(0xFFF0EBFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: size.height * 0.06,
                  bottom: 32,
                ),
                child: Column(
                  children: [
                    // Logo
                    _buildLogo(isDark),
                    SizedBox(height: size.height * 0.04),

                    // Heading
                    Text(
                      'Welcome Back 👋',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFF0EEFF) : const Color(0xFF1A1530),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login to continue your wellness journey',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? const Color(0xFF9E97B0) : const Color(0xFF6B6580),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),

                    // Form Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : AppTheme.primaryColor).withValues(alpha: isDark ? 0.3 : 0.06),
                            blurRadius: isDark ? 40 : 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AuthTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'Enter your email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: _emailValidator,
                            ),
                            const SizedBox(height: 20),
                            AuthTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onEditingComplete: _onEmailPasswordSignIn,
                              validator: _passwordValidator,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: isDark ? const Color(0xFF6B6580) : const Color(0xFF9E97B0),
                                  size: 22,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Remember Me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                        activeColor: AppTheme.primaryColor,
                                        checkColor: Colors.white,
                                        side: BorderSide(
                                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                        ),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? const Color(0xFF9E97B0) : const Color(0xFF6B6580),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => context.push(AppRoutes.forgotPassword),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            AuthGradientButton(
                              label: 'Login',
                              isLoading: isLoading,
                              onPressed: _onEmailPasswordSignIn,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? const Color(0xFF2D2852) : const Color(0xFFE0DBF0))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF6B6580) : const Color(0xFF9E97B0),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? const Color(0xFF2D2852) : const Color(0xFFE0DBF0))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Google Sign In
                    GoogleSignInButton(
                      isLoading: isLoading,
                      onPressed: _onGoogleSignIn,
                    ),
                    const SizedBox(height: 32),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: isDark ? const Color(0xFF9E97B0) : const Color(0xFF6B6580),
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.signup),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildLogo(bool isDark) {
    return const AppLogo(
      width: 150,
      height: 150,
    );
  }
}
