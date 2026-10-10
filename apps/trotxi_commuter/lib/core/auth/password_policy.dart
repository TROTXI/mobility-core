const newPasswordGuidance = 'Meet the password requirements below.';

typedef PasswordRequirement = ({String label, bool met});

bool _isCommonPassword(String value) {
  final letters = value.toLowerCase().replaceAll(
    RegExp(r'[^\p{L}]', unicode: true),
    '',
  );
  return RegExp(r'^(.{1,8})\1+$', unicode: true).hasMatch(value) ||
      const {
        'password',
        'passwordpassword',
        'qwerty',
        'qwertyuiop',
        'qwertyuiopasdfgh',
        'letmein',
        'welcome',
        'trotxi',
        'iloveyou',
      }.contains(letters) ||
      value == '123456789012345';
}

List<PasswordRequirement> passwordRequirements(String value) => [
  (label: 'At least 12 characters', met: value.runes.length >= 12),
  (label: 'Uppercase letter', met: RegExp(r'[A-Z]').hasMatch(value)),
  (label: 'Number', met: RegExp(r'[0-9]').hasMatch(value)),
  (
    label: 'Symbol',
    met: RegExp(r'[\x21-\x2f\x3a-\x40\x5b-\x60\x7b-\x7e]').hasMatch(value),
  ),
  (
    label: 'Not a common password',
    met: value.isNotEmpty && !_isCommonPassword(value),
  ),
];

String? validateNewPassword(String? value) {
  if (value == null) return newPasswordGuidance;
  if (value.length > 128) return 'Password is too long.';
  if (_isCommonPassword(value)) return 'Choose a less common password.';
  if (passwordRequirements(value).any((requirement) => !requirement.met)) {
    return newPasswordGuidance;
  }
  return null;
}
