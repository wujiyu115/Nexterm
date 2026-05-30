class GitTag {
  final String name;
  final String shortSha;
  final DateTime? timestamp;

  const GitTag({required this.name, required this.shortSha, this.timestamp});
}
