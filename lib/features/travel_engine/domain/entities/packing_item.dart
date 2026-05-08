import 'package:equatable/equatable.dart';

class PackingItem extends Equatable {
  const PackingItem({
    required this.id,
    required this.label,
    required this.checked,
  });

  final String id;
  final String label;
  final bool checked;

  PackingItem copyWith({String? id, String? label, bool? checked}) =>
      PackingItem(
        id: id ?? this.id,
        label: label ?? this.label,
        checked: checked ?? this.checked,
      );

  @override
  List<Object?> get props => [id, label, checked];
}
