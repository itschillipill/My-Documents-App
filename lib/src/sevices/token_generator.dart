import 'dart:math';
import 'dart:typed_data';

class TokenGenerator {
  static final List<int> _tokenCharacters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
          .codeUnits;

  static final Random _rand = Random.secure();

  /// Generates a random token of the specified length using alphanumeric characters.
  /// The default length is 32 characters.
  static String generateToken({int length = 32, String? characters}) {
    if (length < 1) {
      throw ArgumentError.value(
        length,
        'length',
        'Token length must be at least 1',
      );
    }

    final Uint16List buffer = Uint16List(length);
    final pool = characters?.codeUnits ?? _tokenCharacters;
    final poolLength = pool.length;

    for (var i = 0; i < length; i++) {
      buffer[i] = pool[_rand.nextInt(poolLength)];
    }

    return String.fromCharCodes(buffer, 0, length);
  }
}