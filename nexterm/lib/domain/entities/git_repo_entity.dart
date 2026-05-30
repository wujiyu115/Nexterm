class GitRepoEntity {
  final String id;
  final String hostId;
  final String remotePath;
  final String? label;

  const GitRepoEntity({
    required this.id,
    required this.hostId,
    required this.remotePath,
    this.label,
  });

  String get displayName => label ?? remotePath.split('/').last;
}
