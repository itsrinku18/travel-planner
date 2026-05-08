import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/features/discovery/data/datasources/discovery_local_datasource.dart';
import 'package:travel_planner/features/discovery/data/repositories/discovery_repository_impl.dart';

void main() {
  final repo = DiscoveryRepositoryImpl(local: DiscoveryLocalDataSourceImpl());

  test('trending returns up to 4 destinations', () async {
    final result = await repo.trending();

    expect(result.failure, isNull);
    expect(result.data!.length, lessThanOrEqualTo(4));
    expect(result.data, isNotEmpty);
  });

  test('recommended returns full seed list', () async {
    final result = await repo.recommended();

    expect(result.failure, isNull);
    expect(result.data!.length, greaterThanOrEqualTo(5));
  });

  test('search matches by name', () async {
    final result = await repo.search('goa');

    expect(result.failure, isNull);
    expect(result.data, isNotEmpty);
    expect(result.data!.any((d) => d.name.toLowerCase() == 'goa'), isTrue);
  });

  test('search matches by tag', () async {
    final result = await repo.search('beaches');

    expect(result.failure, isNull);
    expect(
      result.data!.any(
        (d) => d.tags.map((t) => t.toLowerCase()).contains('beaches'),
      ),
      isTrue,
    );
  });

  test('empty query returns no results', () async {
    final result = await repo.search('   ');

    expect(result.failure, isNull);
    expect(result.data, isEmpty);
  });
}
