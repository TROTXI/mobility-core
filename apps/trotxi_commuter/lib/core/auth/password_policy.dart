const newPasswordGuidance =
    'Use 12 to 128 characters with a capital letter, number and symbol.';

String? validateNewPassword(String? value) {
  if (value == null || value.runes.length < 12 || value.length > 128) {
    return newPasswordGuidance;
  }
  if (!RegExp(r'[A-Z]').hasMatch(value) ||
      !RegExp(r'[0-9]').hasMatch(value) ||
      !RegExp(r'[\x21-\x2f\x3a-\x40\x5b-\x60\x7b-\x7e]').hasMatch(value)) {
    return newPasswordGuidance;
  }
  return null;
}
