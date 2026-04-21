/// A tiny expression language for per-op / per-record authorization.
///
/// Grammar (loosely PocketBase-flavored):
///
///   expr       := or
///   or         := and ( "||" and )*
///   and        := comparison ( "&&" comparison )*
///   comparison := unary ( ( "=" | "!=" | "<" | ">" | "<=" | ">=" ) unary )?
///   unary      := "!" unary | primary
///   primary    := literal | ident | "(" expr ")"
///   literal    := number | string | "true" | "false" | "null"
///   ident      := "@" name ( "." name )*
///
/// Kept deliberately boolean-only: no arithmetic, no function calls, no
/// array membership (`.has(x)`). Those are next-phase additions when the
/// use cases demand them — today's surface is enough for ownership,
/// publicity, and scope checks.
library;

enum TokenType {
  ident,
  number,
  string,
  trueKw,
  falseKw,
  nullKw,
  openParen,
  closeParen,
  bang,
  and,
  or,
  eq,
  neq,
  lt,
  gt,
  lte,
  gte,
  eof,
}

class Token {
  final TokenType type;
  final String lexeme;
  final int position;
  final dynamic literal;
  const Token(this.type, this.lexeme, this.position, [this.literal]);

  @override
  String toString() => '$type($lexeme)';
}

/// Thrown when a rule expression is syntactically invalid. Caught at
/// rule-store time and surfaced as [SpodLiteException] to the client.
class RuleSyntaxException implements Exception {
  final String message;
  final int? position;
  RuleSyntaxException(this.message, {this.position});

  @override
  String toString() =>
      position == null ? message : '$message (at pos $position)';
}

// ─── AST ──────────────────────────────────────────────────────────────

sealed class Expr {
  const Expr();
}

class LiteralExpr extends Expr {
  final dynamic value;
  const LiteralExpr(this.value);
}

class IdentExpr extends Expr {
  /// Full path, e.g. `@record.owner_id` or `@request.auth.id`.
  final String path;
  const IdentExpr(this.path);
}

class UnaryExpr extends Expr {
  final TokenType op;
  final Expr operand;
  const UnaryExpr(this.op, this.operand);
}

class BinaryExpr extends Expr {
  final TokenType op;
  final Expr left;
  final Expr right;
  const BinaryExpr(this.op, this.left, this.right);
}

// ─── Lexer ────────────────────────────────────────────────────────────

class _Lexer {
  final String src;
  int _pos = 0;
  _Lexer(this.src);

  List<Token> tokenize() {
    final out = <Token>[];
    while (_pos < src.length) {
      final c = src[_pos];
      if (_isWhitespace(c)) {
        _pos++;
        continue;
      }
      final start = _pos;
      if (c == '(' || c == ')') {
        _pos++;
        out.add(Token(c == '(' ? TokenType.openParen : TokenType.closeParen,
            c, start));
        continue;
      }
      if (c == '!') {
        _pos++;
        if (_match('=')) {
          out.add(Token(TokenType.neq, '!=', start));
        } else {
          out.add(Token(TokenType.bang, '!', start));
        }
        continue;
      }
      if (c == '=') {
        _pos++;
        // Accept either "=" or "==" for equality.
        if (_match('=')) {
          out.add(Token(TokenType.eq, '==', start));
        } else {
          out.add(Token(TokenType.eq, '=', start));
        }
        continue;
      }
      if (c == '<') {
        _pos++;
        if (_match('=')) {
          out.add(Token(TokenType.lte, '<=', start));
        } else {
          out.add(Token(TokenType.lt, '<', start));
        }
        continue;
      }
      if (c == '>') {
        _pos++;
        if (_match('=')) {
          out.add(Token(TokenType.gte, '>=', start));
        } else {
          out.add(Token(TokenType.gt, '>', start));
        }
        continue;
      }
      if (c == '&') {
        if (_peekAt(_pos + 1) == '&') {
          _pos += 2;
          out.add(Token(TokenType.and, '&&', start));
          continue;
        }
        throw RuleSyntaxException('Unexpected "&" — did you mean "&&"?',
            position: _pos);
      }
      if (c == '|') {
        if (_peekAt(_pos + 1) == '|') {
          _pos += 2;
          out.add(Token(TokenType.or, '||', start));
          continue;
        }
        throw RuleSyntaxException('Unexpected "|" — did you mean "||"?',
            position: _pos);
      }
      if (c == "'" || c == '"') {
        out.add(_stringLiteral(c));
        continue;
      }
      if (_isDigit(c)) {
        out.add(_numberLiteral());
        continue;
      }
      if (c == '@') {
        out.add(_ident());
        continue;
      }
      if (_isLetter(c)) {
        out.add(_keyword());
        continue;
      }
      throw RuleSyntaxException('Unexpected character "$c"', position: _pos);
    }
    out.add(Token(TokenType.eof, '', _pos));
    return out;
  }

  bool _match(String s) {
    if (_pos >= src.length) return false;
    if (src[_pos] != s) return false;
    _pos++;
    return true;
  }

  String? _peekAt(int i) => i < src.length ? src[i] : null;

  Token _stringLiteral(String quote) {
    final start = _pos;
    _pos++;
    final buf = StringBuffer();
    while (_pos < src.length && src[_pos] != quote) {
      if (src[_pos] == r'\' && _pos + 1 < src.length) {
        final next = src[_pos + 1];
        switch (next) {
          case 'n':
            buf.write('\n');
            break;
          case 't':
            buf.write('\t');
            break;
          case r'\':
            buf.write(r'\');
            break;
          case "'":
            buf.write("'");
            break;
          case '"':
            buf.write('"');
            break;
          default:
            buf.write(next);
        }
        _pos += 2;
        continue;
      }
      buf.write(src[_pos]);
      _pos++;
    }
    if (_pos >= src.length) {
      throw RuleSyntaxException('Unterminated string', position: start);
    }
    _pos++; // closing quote
    return Token(TokenType.string, buf.toString(), start, buf.toString());
  }

  Token _numberLiteral() {
    final start = _pos;
    while (_pos < src.length && _isDigit(src[_pos])) {
      _pos++;
    }
    if (_pos < src.length &&
        src[_pos] == '.' &&
        _pos + 1 < src.length &&
        _isDigit(src[_pos + 1])) {
      _pos++; // .
      while (_pos < src.length && _isDigit(src[_pos])) {
        _pos++;
      }
    }
    final lex = src.substring(start, _pos);
    final numv = num.parse(lex);
    return Token(TokenType.number, lex, start,
        numv is int ? numv : numv.toDouble());
  }

  Token _ident() {
    final start = _pos;
    _pos++; // @
    if (_pos >= src.length || !_isLetter(src[_pos])) {
      throw RuleSyntaxException('Expected name after "@"', position: start);
    }
    while (_pos < src.length &&
        (_isLetter(src[_pos]) || _isDigit(src[_pos]) || src[_pos] == '.' ||
            src[_pos] == '_')) {
      _pos++;
    }
    return Token(TokenType.ident, src.substring(start, _pos), start);
  }

  Token _keyword() {
    final start = _pos;
    while (_pos < src.length &&
        (_isLetter(src[_pos]) || _isDigit(src[_pos]) || src[_pos] == '_')) {
      _pos++;
    }
    final lex = src.substring(start, _pos);
    switch (lex) {
      case 'true':
        return Token(TokenType.trueKw, lex, start, true);
      case 'false':
        return Token(TokenType.falseKw, lex, start, false);
      case 'null':
        return Token(TokenType.nullKw, lex, start, null);
    }
    throw RuleSyntaxException('Unknown identifier "$lex" — did you forget the "@"?',
        position: start);
  }

  static bool _isWhitespace(String c) => ' \t\n\r'.contains(c);
  static bool _isDigit(String c) =>
      c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;
  static bool _isLetter(String c) {
    final cc = c.codeUnitAt(0);
    return (cc >= 0x41 && cc <= 0x5A) || (cc >= 0x61 && cc <= 0x7A) || c == '_';
  }
}

// ─── Parser ───────────────────────────────────────────────────────────

class _Parser {
  final List<Token> tokens;
  int _pos = 0;
  _Parser(this.tokens);

  Expr parse() {
    final expr = _or();
    if (_peek().type != TokenType.eof) {
      throw RuleSyntaxException(
          'Unexpected "${_peek().lexeme}" after expression',
          position: _peek().position);
    }
    return expr;
  }

  Expr _or() {
    var left = _and();
    while (_peek().type == TokenType.or) {
      _advance();
      left = BinaryExpr(TokenType.or, left, _and());
    }
    return left;
  }

  Expr _and() {
    var left = _comparison();
    while (_peek().type == TokenType.and) {
      _advance();
      left = BinaryExpr(TokenType.and, left, _comparison());
    }
    return left;
  }

  Expr _comparison() {
    final left = _unary();
    const cmpOps = [
      TokenType.eq,
      TokenType.neq,
      TokenType.lt,
      TokenType.gt,
      TokenType.lte,
      TokenType.gte,
    ];
    if (cmpOps.contains(_peek().type)) {
      final op = _advance().type;
      final right = _unary();
      return BinaryExpr(op, left, right);
    }
    return left;
  }

  Expr _unary() {
    if (_peek().type == TokenType.bang) {
      _advance();
      return UnaryExpr(TokenType.bang, _unary());
    }
    return _primary();
  }

  Expr _primary() {
    final tok = _advance();
    switch (tok.type) {
      case TokenType.number:
      case TokenType.string:
        return LiteralExpr(tok.literal);
      case TokenType.trueKw:
        return const LiteralExpr(true);
      case TokenType.falseKw:
        return const LiteralExpr(false);
      case TokenType.nullKw:
        return const LiteralExpr(null);
      case TokenType.ident:
        return IdentExpr(tok.lexeme);
      case TokenType.openParen:
        final inner = _or();
        if (_peek().type != TokenType.closeParen) {
          throw RuleSyntaxException('Expected ")"', position: _peek().position);
        }
        _advance();
        return inner;
      default:
        throw RuleSyntaxException('Unexpected "${tok.lexeme}"',
            position: tok.position);
    }
  }

  Token _peek() => tokens[_pos];
  Token _advance() => tokens[_pos++];
}

/// Parses [source] into an [Expr] tree. Throws [RuleSyntaxException] on
/// invalid input.
Expr parseExpression(String source) {
  final tokens = _Lexer(source).tokenize();
  return _Parser(tokens).parse();
}
