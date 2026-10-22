import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';

/// Whether this user has accepted the terms in force for their app.
class TermsCheck {
  const TermsCheck({
    required this.currentVersion,
    required this.acceptedVersion,
    required this.acceptanceRequired,
  });

  final Date currentVersion;
  final Date? acceptedVersion;
  final bool acceptanceRequired;

  /// Never accepted any version, as opposed to an update since the last one.
  bool get firstAcceptance => acceptedVersion == null;
}

/// Reads and records acceptance of the rider or driver terms. The server
/// decides which terms apply from the signed-in account's role.
class TermsClient {
  TermsClient({required this.client, required this.metadata});

  final TrotxiApiClient client;
  final ClientMetadata metadata;

  Future<TermsCheck> status() => _call(
        () => client.getSelfApi().getTermsStatus(
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              xTrotxiPlatform: metadata.platform,
            ),
      );

  Future<TermsCheck> accept(Date version) => _call(
        () => client.getSelfApi().acceptTerms(
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              xTrotxiPlatform: metadata.platform,
              termsAcceptance: TermsAcceptance(
                (b) => b
                  ..acceptedTerms = true
                  ..termsVersion = version,
              ),
            ),
      );

  Future<TermsCheck> _call(
    Future<Response<TermsStatusResponse>> Function() request,
  ) async {
    try {
      final data = (await request()).data?.data;
      if (data == null) {
        throw const ApiException(502, 'The terms status was empty.');
      }
      return TermsCheck(
        currentVersion: data.currentVersion,
        acceptedVersion: data.acceptedVersion,
        acceptanceRequired: data.acceptanceRequired,
      );
    } on DioException catch (error) {
      final mapped = error.error;
      if (mapped is TrotxiException) throw mapped;
      rethrow;
    }
  }
}

/// Shows [child] unless the server says this user has not accepted the terms
/// in force: before a driver's first trip, and after every new version.
///
/// The app opens straight away and checks in the background, so a rider on a
/// weak signal still reaches their pass. If the check cannot be made, the app
/// carries on and asks again next time; it only blocks on a definite answer.
class TermsGate extends StatefulWidget {
  const TermsGate({
    super.key,
    required this.load,
    required this.accept,
    required this.termsName,
    required this.onReadTerms,
    required this.child,
    this.onSignOut,
  });

  final Future<TermsCheck> Function() load;
  final Future<TermsCheck> Function(Date version) accept;

  /// "Rider Terms" or "Driver Terms", as the user knows them.
  final String termsName;

  /// Opens the full text of the version being accepted.
  final Future<void> Function(BuildContext context) onReadTerms;
  final Future<void> Function()? onSignOut;
  final Widget child;

  @override
  State<TermsGate> createState() => _TermsGateState();
}

class _TermsGateState extends State<TermsGate> {
  TermsCheck? _pending;
  bool _agreed = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final status = await widget.load();
      if (!mounted) return;
      setState(() {
        _pending = status.acceptanceRequired ? status : null;
        _agreed = false;
      });
    } catch (_) {
      // Unreachable or refused: keep the app usable and ask on the next start.
    }
  }

  Future<void> _accept() async {
    final pending = _pending;
    if (pending == null || !_agreed || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final status = await widget.accept(pending.currentVersion);
      if (!mounted) return;
      setState(() => _pending = status.acceptanceRequired ? status : null);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 'terms_version_outdated') {
        // A newer version was published while this screen was open.
        await _check();
        if (!mounted) return;
        setState(() => _error =
            'The ${widget.termsName} were just updated. Read the new version and accept it to continue.');
      } else {
        setState(() => _error = error.message);
      }
    } on TrotxiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Could not save your acceptance. Check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _pending;
    if (pending == null) return widget.child;
    final theme = Theme.of(context);
    final first = pending.firstAcceptance;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            children: [
              Text(
                first
                    ? 'Accept the ${widget.termsName}'
                    : 'We have updated the ${widget.termsName}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                first
                    ? 'Before you continue, please read the ${widget.termsName} and accept them.'
                    : 'Please read the new version and accept it to keep using Trotxi.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Version ${pending.currentVersion}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => widget.onReadTerms(context),
                icon: const Icon(Icons.description_outlined),
                label: Text('Read the ${widget.termsName}'),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _agreed,
                onChanged:
                    _busy ? null : (v) => setState(() => _agreed = v ?? false),
                title: Text('I have read and agree to the ${widget.termsName}'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _agreed && !_busy ? _accept : null,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Accept and continue'),
              ),
              if (widget.onSignOut != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy ? null : widget.onSignOut,
                  child: const Text('Sign out'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
