sealed class Failure {
  const Failure({required this.message});
  final String message;
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}
