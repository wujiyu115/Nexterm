class GitCommit {
  final String sha;
  final String authorName;
  final String authorEmail;
  final DateTime timestamp;
  final String subject;
  final String body;
  final List<String> parentShas;
  final List<String> refs;

  const GitCommit({
    required this.sha,
    required this.authorName,
    required this.authorEmail,
    required this.timestamp,
    required this.subject,
    this.body = '',
    this.parentShas = const [],
    this.refs = const [],
  });

  String get shortSha => sha.length >= 7 ? sha.substring(0, 7) : sha;
  bool get isMerge => parentShas.length > 1;
}
