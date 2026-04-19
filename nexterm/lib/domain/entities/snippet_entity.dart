class SnippetVariable {
  final String name;
  final String? defaultValue;
  final String? description;

  const SnippetVariable({required this.name, this.defaultValue, this.description});

  Map<String, dynamic> toJson() => {'name': name, 'defaultValue': defaultValue, 'description': description};

  factory SnippetVariable.fromJson(Map<String, dynamic> json) => SnippetVariable(
    name: json['name'] as String,
    defaultValue: json['defaultValue'] as String?,
    description: json['description'] as String?,
  );
}

class SnippetEntity {
  final String id;
  final String name;
  final String command;
  final List<SnippetVariable> variables;
  final String? group;
  final List<String> tags;
  final bool isFavorite;
  final int sortOrder;

  const SnippetEntity({
    required this.id, required this.name, required this.command,
    this.variables = const [], this.group, this.tags = const [],
    this.isFavorite = false, this.sortOrder = 0,
  });

  SnippetEntity copyWith({
    String? id, String? name, String? command, List<SnippetVariable>? variables,
    String? Function()? group, List<String>? tags, bool? isFavorite, int? sortOrder,
  }) {
    return SnippetEntity(
      id: id ?? this.id, name: name ?? this.name, command: command ?? this.command,
      variables: variables ?? this.variables, group: group != null ? group() : this.group,
      tags: tags ?? this.tags, isFavorite: isFavorite ?? this.isFavorite,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
