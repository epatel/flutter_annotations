class FieldInfo {
  final String name;
  final String type;

  FieldInfo(this.name, this.type);

  @override
  String toString() => 'FieldInfo(name: $name, type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type;

  @override
  int get hashCode => name.hashCode ^ type.hashCode;
}
