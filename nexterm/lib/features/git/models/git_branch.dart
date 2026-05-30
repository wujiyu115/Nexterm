class GitBranch {
  final String name;
  final String shortSha;
  final bool isCurrent;
  final bool isRemote;

  const GitBranch({
    required this.name,
    required this.shortSha,
    this.isCurrent = false,
    this.isRemote = false,
  });

  bool get isDefault =>
      name == 'main' ||
      name == 'master' ||
      name == 'origin/main' ||
      name == 'origin/master';
}
