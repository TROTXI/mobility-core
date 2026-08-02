import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Presentations/Home/pages/home_page.dart';
import 'package:trotxi_commuter/Presentations/Onboarding/widgets/app_button.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';
import 'package:trotxi_commuter/core/Tokens/token_storage.dart';
class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key});

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  late final AuthApi _authApi;

  bool _isGoogleSignInInitialized = false;
  bool _isSigningIn = false;

  // Your Android OAuth serverId
  static const String _serverId =
      //'431341307838-856vjsg6a8mbukis3vvogvld2bskimsn.apps.googleusercontent.com';
      '431341307838-pc4m046v2lj18ssfnfl1g52fl5g1cg4q.apps.googleusercontent.com';

  @override
  void initState() {
    super.initState();

    _initializeApi();
    _initializeGoogleSignIn();
  }

  void _initializeApi() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://trotxi-api-staging.onrender.com',
        // Staging runs on a free instance that sleeps when idle, so the first
        // request after a quiet spell pays a cold start. Keep these generous
        // enough to survive it rather than failing on a healthy backend.
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );

    _authApi = AuthApi(dio, standardSerializers);
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(serverClientId: _serverId);

      _isGoogleSignInInitialized = true;

      // Attempt to restore a previous Google session.
      await _googleSignIn.attemptLightweightAuthentication();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Google Sign-In initialization failed: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!_isGoogleSignInInitialized || _isSigningIn) {
      return;
    }

    setState(() {
      _isSigningIn = true;
    });

    try {
      // 1. Open Google Sign-In.
      final GoogleSignInAccount user = await _googleSignIn.authenticate();

      debugPrint('Google user: ${user.email}');

      debugPrint('Google user ID: ${user.id}');

      // 2. Get Google authentication details.
      final GoogleSignInAuthentication authentication = user.authentication;

      // 3. Get the Google ID token.
      final String? idToken = authentication.idToken;
      debugPrint(idToken);

      if (idToken == null) {
        throw Exception('Google ID token was not returned.');
      }

      debugPrint('Google ID token received.');

      // 4. Create the generated API request.
      final AuthGooglePostRequest request = AuthGooglePostRequest(
        (builder) => builder..idToken = idToken,
      );

      // 5. Send the Google ID token to your backend.
      final response = await _authApi.authGooglePost(
        authGooglePostRequest: request,
      );

      // 6. Get the backend response.
      final data = response.data;

      debugPrint('Backend Google login successful.');

      debugPrint('Response: $data');

      if (!mounted) {
        return;
      }
      await TokenStorage.instance.saveTokens(
        accessToken: data!.accessToken,
        refreshToken: data.refreshToken,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );



    } on DioException catch (e) {
      debugPrint('Backend authentication failed: ${e.message}');

      debugPrint('Status code: ${e.response?.statusCode}');

      debugPrint('Response: ${e.response?.data}');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to sign in. Please try again.')),
      );
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to sign in with Google. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    debugPrint('Continue with Apple');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Image.asset(Appvectors.logo, width: 180),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Welcome to Trotxi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Google Sign-In
                    AppSignInButton(
                      onPressed: _signInWithGoogle,
                      text: _isSigningIn
                          ? 'Signing in...'
                          : 'Continue with Google',
                      icon: Image.asset(Appvectors.googleIconImage),
                    ),

                    const SizedBox(height: 16),

                    // Apple Sign-In
                    AppSignInButton(
                      onPressed: _signInWithApple,
                      text: 'Continue with Apple',
                      icon: Image.asset(Appvectors.appleIconImage),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
