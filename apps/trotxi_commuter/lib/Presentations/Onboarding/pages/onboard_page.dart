import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Presentations/Home/pages/home_page.dart';
import 'package:trotxi_commuter/core/Tokens/token_storage.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_spacing.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';
import 'package:trotxi_commuter/Presentations/Onboarding/widgets/app_button.dart';

class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key, required this.client});

  final TrotxiApiClient client;

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  static const String _googleServerId =
      '431341307838-pc4m046v2lj18ssfnfl1g52fl5g1cg4q.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  late final AuthApi _authApi;

  bool _isGoogleSignInInitialized = false;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    _authApi = widget.client.getAuthApi();
    _initializeGoogleSignIn();
  }

  // ---------------------------------------------------------------------
  // Auth logic (unchanged from the original implementation)
  // ---------------------------------------------------------------------

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(serverClientId: _googleServerId);
      _isGoogleSignInInitialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Google Sign-In initialization failed: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!_isGoogleSignInInitialized || _isSigningIn) return;

    setState(() => _isSigningIn = true);

    try {
      final idToken = await _authenticateWithGoogle();
      final tokens = await _exchangeGoogleToken(idToken);

      await TokenStorage.instance.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      if (!mounted) return;
      _navigateToHome();
    } on DioException catch (e) {
      debugPrint('Backend authentication failed: ${e.message}');
      _showError('Unable to sign in. Please try again.');
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      _showError('Unable to sign in with Google. Please try again.');
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<String> _authenticateWithGoogle() async {
    final GoogleSignInAccount user = await _googleSignIn.authenticate();

    final GoogleSignInAuthentication authentication = user.authentication;
    final String? idToken = authentication.idToken;

    if (idToken == null) {
      throw Exception('Google ID token was not returned.');
    }

    return idToken;
  }

  Future<({String accessToken, String refreshToken})> _exchangeGoogleToken(
    String idToken,
  ) async {
    final request = AuthGooglePostRequest(
      (builder) => builder..idToken = idToken,
    );

    final response = await _authApi.authGooglePost(
      authGooglePostRequest: request,
    );

    final data = response.data;

    return (accessToken: data!.accessToken, refreshToken: data.refreshToken);
  }

  Future<void> _signInWithApple() async {
    debugPrint('Pending Implementation: Apple Sign-In is not yet implemented.');
  }

  // void _continueWithPhone() {
  //   debugPrint('Pending Implementation: Phone sign-in is not yet implemented.');
  // }

  // void _continueWithEmail() {
  //   debugPrint('Pending Implementation: Email sign-in is not yet implemented.');
  // }

  // void _goToCreateAccount() {
  //   debugPrint('Pending Implementation: Create account is not yet implemented.');
  // }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(client: widget.client)),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------
  // UI — matches the Figma "Sign in to Trotxi" layout, theme-aware via
  // context.appColors so it adapts automatically to light/dark, the same
  // pattern EntryAuthView already uses.
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final pageColor = AppPrimitiveColors.authPage(brightness);
    final systemIconBrightness = brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: pageColor,
        statusBarIconBrightness: systemIconBrightness,
        statusBarBrightness: brightness,
        systemNavigationBarColor: pageColor,
        systemNavigationBarIconBrightness: systemIconBrightness,
      ),
      child: Scaffold(
        backgroundColor: pageColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 30,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: AppSpacing.space24),
                        _buildHeader(context),
                        const SizedBox(height: 22),
                        _buildAuthCard(context),
                        const SizedBox(height: 10),

                        const Spacer(),
                        const SizedBox(height: AppSpacing.space24),

                        const SizedBox(height: AppSpacing.space20),
                        _buildTagline(context),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(child: Image.asset(Appvectors.logo, width: 180));
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Sign in to Trotxi',
          textAlign: TextAlign.center,
          style: AppTypography.heading1.copyWith(
            color: colors.textPrimary,
            fontSize: 27,
            height: 34 / 27,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        Text(
          'Use Google, Apple, phone number, or email to access your Trotxi account.',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: colors.textSecondary,
            fontSize: 14.5,
            height: 22 / 14.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSignInButton(
            onPressed: _signInWithGoogle,
            text: _isSigningIn ? 'Signing in...' : 'Continue with Google',
            icon: Image.asset(Appvectors.googleIconImage),
          ),
          const SizedBox(height: 13),
          AppSignInButton(
            onPressed: _signInWithApple,
            text: 'Continue with Apple',
            icon: Image.asset(Appvectors.appleIconImage),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            'Use an existing Google or Apple account to continue. By continuing, '
            'you agree to Trotxi\u2019s Terms and acknowledge the Privacy Policy.',
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: colors.textTertiary,
              fontSize: 9.5,
              height: 14 / 10,
            ),
          ),
        ],
      ),
    );
  }
  //Future kyc will implement these
  // Widget _buildPhoneEmailActions(BuildContext context) {
  //   final narrow = MediaQuery.sizeOf(context).width < 360;
  //   final largeText = MediaQuery.textScalerOf(context).scale(14) > 19;

  //   if (narrow || largeText) {
  //     return Column(
  //       children: [
  //         _textAction(
  //           context: context,
  //           label: 'Sign in with phone number',
  //           onPressed: _continueWithPhone,
  //           alignment: Alignment.center,
  //         ),
  //         _textAction(
  //           context: context,
  //           label: 'Sign in with email',
  //           onPressed: _continueWithEmail,
  //           alignment: Alignment.center,
  //         ),
  //       ],
  //     );
  //   }

  //   return Row(
  //     children: [
  //       Expanded(
  //         flex: 3,
  //         child: _textAction(
  //           context: context,
  //           label: 'Sign in with phone number',
  //           onPressed: _continueWithPhone,
  //           alignment: Alignment.centerLeft,
  //         ),
  //       ),
  //       const SizedBox(width: AppSpacing.space8),
  //       Expanded(
  //         flex: 2,
  //         child: _textAction(
  //           context: context,
  //           label: 'Sign in with email',
  //           onPressed: _continueWithEmail,
  //           alignment: Alignment.centerRight,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _textAction({
  //   required BuildContext context,
  //   required String label,
  //   required VoidCallback onPressed,
  //   required AlignmentGeometry alignment,
  // }) {
  //   return Align(
  //     alignment: alignment,
  //     child: TextButton(
  //       onPressed: onPressed,
  //       style: TextButton.styleFrom(
  //         minimumSize: const Size(44, 44),
  //         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
  //         foregroundColor: context.appColors.actionPrimaryDefault,
  //         textStyle: AppTypography.bodySmall.copyWith(
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       child: FittedBox(
  //         fit: BoxFit.scaleDown,
  //         child: Text(label, maxLines: 1, textAlign: TextAlign.center),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildCreateAccountPrompt(BuildContext context) {
  //   final colors = context.appColors;
  //   return Center(
  //     child: TextButton(
  //       onPressed: _goToCreateAccount,
  //       style: TextButton.styleFrom(
  //         minimumSize: const Size(44, 44),
  //         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
  //       ),
  //       child: Text.rich(
  //         TextSpan(
  //           children: [
  //             TextSpan(
  //               text: 'New to Trotxi?  ',
  //               style: AppTypography.bodySmall.copyWith(
  //                 color: colors.textSecondary,
  //               ),
  //             ),
  //             TextSpan(
  //               text: 'Create account',
  //               style: AppTypography.bodySmall.copyWith(
  //                 color: colors.actionPrimaryDefault,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //         textAlign: TextAlign.center,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTagline(BuildContext context) {
    return Text(
      'Move smart. Live better.',
      textAlign: TextAlign.center,
      style: AppTypography.caption.copyWith(
        color: context.appColors.textTertiary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
