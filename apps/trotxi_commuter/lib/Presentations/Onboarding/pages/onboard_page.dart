import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Presentations/Home/pages/home_page.dart';
import 'package:trotxi_commuter/Presentations/Onboarding/widgets/app_button.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';
import 'package:trotxi_commuter/core/Tokens/token_storage.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

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
  // Auth logic
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

      if (!mounted) return;
      await TokenStorage.instance.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      if (!mounted) return;
      _navigateToHome();
    } on DioException catch (e) {
      debugPrint('Backend authentication failed: ${e.message}');
      debugPrint('Type: ${e.type}');
      debugPrint('Error: ${e.error}');
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
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
    debugPrint('Google user: ${user.email}');
    debugPrint('Google user ID: ${user.id}');

    final GoogleSignInAuthentication authentication = user.authentication;
    final String? idToken = authentication.idToken;

    if (idToken == null) {
      throw Exception('Google ID token was not returned.');
    }

    debugPrint('Google ID token received. $idToken');
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
    debugPrint('Backend Google login successful.');
    debugPrint('Response: $data');

    return (accessToken: data!.accessToken, refreshToken: data.refreshToken);
  }

  Future<void> _signInWithApple() async {
    debugPrint('Continue with Apple');
  }

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
  // UI
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildLogo(),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: _buildOnboardingContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Image.asset(Appvectors.logo, width: 180),
    );
  }

  Widget _buildOnboardingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildAuthCard(),
        const SizedBox(height: 24),
        _buildSignInPrompt(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Text(
          'Join the Network',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.dark,
            fontSize: 24,
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.w700,
            height: 1.33,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Create your Accra Commuter account to start moving smarter.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.body,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSignInButton(
            onPressed: _signInWithGoogle,
            text: _isSigningIn ? 'Signing in...' : 'Continue with Google',
            icon: Image.asset(Appvectors.googleIconImage),
          ),
          const SizedBox(height: 16),
          AppSignInButton(
            onPressed: _signInWithApple,
            text: 'Continue with Apple',
            icon: Image.asset(Appvectors.appleIconImage),
          ),
          const SizedBox(height: 16),
          const Text(
            'By continuing, you agree to Trotxi\'s Terms and Conditions '
            'and Usage Policy, and acknowledge their Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.body,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return const Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Move Smarter Live Better ',
              style: TextStyle(
                color: AppColors.body,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
