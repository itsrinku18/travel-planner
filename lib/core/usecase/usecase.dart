import 'package:travel_planner/core/error/failure.dart';

typedef Result<T> = ({T? data, Failure? failure});

abstract interface class UseCase<T, P> {
  Future<Result<T>> call(P params);
}

final class NoParams {
  const NoParams();
}
