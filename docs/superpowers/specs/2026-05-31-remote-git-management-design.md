# Remote Git Management Design

## Overview

Add a Git management feature to Nexterm that allows users to manage Git repositories on remote servers via SSH. All git commands are executed remotely through `SSHClient.execute()`, with results parsed and displayed in Flutter UI.

## Feature List

- Project-level / file-level commit history browsing
- Git branch graph: vertical branch topology with CustomPainter (left) + synced ListView (right)
- Git Diff view: unified diff with character-level highlighting
- Commit detail view (author, time, message, changed files)
- Working tree changes view (staged / unstaged files)
- Three-tab management: Working Tree / Branches / Tags, default tab persisted via SharedPreferences
- Swipe-to-delete: branches, worktrees, tags with safety protection (current branch / default branch not deletable)
- Tag management: browse tags, click to checkout, dirty worktree auto-popup handling
- Git init from UI

## Architecture

### Module Structure

```
features/git/
├── services/
│   └── git_command_service.dart     # SSH exec git commands, parse output
├── models/
│   ├── git_commit.dart              # commit data model
│   ├── git_branch.dart              # branch data model
│   ├── git_tag.dart                 # tag data model
│   ├── git_diff.dart                # diff model (hunks, lines, char-level changes)
│   ├── git_status.dart              # working tree status (staged/unstaged)
│   └── git_graph.dart               # branch graph topology (lane assignment output)
├── providers/
│   ├── git_provider.dart            # main provider, manages current repo state
│   └── git_graph_provider.dart      # branch graph topology computation
├── ui/
│   ├── git_screen.dart              # main screen, three-tab container
│   ├── git_repos_screen.dart        # Vault entry: saved remote repo list
│   ├── widgets/
│   │   ├── commit_list.dart         # commit history list
│   │   ├── commit_detail_sheet.dart # commit detail bottom sheet
│   │   ├── branch_graph.dart        # branch graph CustomPainter (left side lines)
│   │   ├── graph_commit_list.dart   # branch graph synced commit list (right side)
│   │   ├── diff_view.dart           # unified diff view with char-level highlight
│   │   ├── status_file_list.dart    # working tree changed files list
│   │   ├── branch_list.dart         # branch list (swipe to delete)
│   │   ├── tag_list.dart            # tag list (swipe to delete)
│   │   └── git_init_prompt.dart     # non-git repo: show init prompt
```

### 1. Git Command Service

Core layer — executes git commands via `SSHClient.execute()`:

- Each operation uses an independent exec channel (not shell), avoiding prompt interference
- Uses `--format` parameters for machine-parseable output (e.g., `git log --format=%H%x00%an%x00%at%x00%s` with `\0` field separators)
- Unified error handling: check exit code, throw exception with stderr on non-zero
- Auto-detect: run `git rev-parse --git-dir` to check if directory is a git repo

Command mapping:

| Feature | Git Command |
|---------|-------------|
| Detect repo | `git -C {path} rev-parse --git-dir` |
| Init | `git -C {path} init` |
| Commit history | `git -C {path} log --format=%H%x00%an%x00%ae%x00%at%x00%s%x00%b%x1e` |
| Branch graph | `git -C {path} log --all --format=%H%x00%P%x00%an%x00%at%x00%D%x00%s%x1e --parents` |
| File history | `git -C {path} log --follow --format=... -- {file}` |
| Branch list | `git -C {path} branch -a --format=%(refname:short)%x00%(objectname:short)%x00%(HEAD)` |
| Tag list | `git -C {path} tag -l --format=%(refname:short)%x00%(objectname:short)%x00%(creatordate:unix)` |
| Working tree status | `git -C {path} status --porcelain=v2` |
| Diff (unstaged) | `git -C {path} diff` |
| Diff (staged) | `git -C {path} diff --cached` |
| Diff (commit) | `git -C {path} diff {parent}..{commit}` |
| Delete branch | `git -C {path} branch -d {name}` |
| Delete tag | `git -C {path} tag -d {name}` |
| Checkout tag | `git -C {path} checkout {tag}` |
| Current branch | `git -C {path} rev-parse --abbrev-ref HEAD` |
| Commit file list | `git -C {path} diff-tree --no-commit-id -r --name-status {sha}` |

### 2. Branch Graph Topology Algorithm

Input: `git log --all --parents` provides each commit's parent SHAs, building a DAG.

**Lane assignment algorithm:**
- Each active branch gets a vertical lane (column index)
- On merge: lane from merged branch collapses
- On fork: new lane expands
- Colors are assigned per-lane (cycling through a palette)

Output: `List<GraphRow>`, each row contains:
- `GitCommit` data
- `laneIndex`: which column this commit sits in
- `lines`: list of line segments to draw (type: straight / merge-left / merge-right / fork)
- `activeLanes`: total active lanes at this row (determines painter width)

`BranchGraphPainter` (CustomPainter) reads `GraphRow` data to draw:
- Vertical lines for each active lane
- Circles at commit positions
- Curved merge/fork lines between lanes
- Colors per lane from a fixed palette

### 3. Diff Parsing & Character-Level Highlighting

Parse `git diff` unified diff output:
- Split by `diff --git` for per-file diffs
- Split by `@@ ... @@` for hunks within each file
- Each line tagged as `added` / `deleted` / `context`
- For adjacent added/deleted line pairs: run Myers diff algorithm at character level to find inline changes
- Render with `RichText` + `TextSpan`: line background (light red/green), changed characters get deeper background

`GitDiff` model structure:
```
GitDiff
├── filePath: String
├── oldPath: String? (for renames)
├── hunks: List<DiffHunk>
    ├── oldStart, oldCount, newStart, newCount
    └── lines: List<DiffLine>
        ├── type: added | deleted | context
        ├── content: String
        └── inlineChanges: List<InlineChange>?  // char-level spans
            ├── start: int
            └── length: int
```

### 4. Three-Tab UI

`GitScreen` uses `TabBar` + `TabBarView`:

**Working Tree tab:**
- Shows `git status --porcelain=v2` results
- Split into Staged / Unstaged sections with `ExpansionTile` or section headers
- Each file shows status icon (modified/added/deleted/renamed)
- Tap file to view diff

**Branches tab:**
- Lists local and remote branches via `git branch -a`
- Current branch marked with indicator
- "Branch Graph" button at top to open full graph view
- Swipe left to delete — protected: current branch and default branch (main/master) show error toast instead
- `Dismissible` widget with `confirmDismiss` callback for protection logic

**Tags tab:**
- Lists tags with name, short SHA, date
- Tap tag to checkout (detached HEAD)
- Before checkout: run `git status --porcelain`, if dirty → show dialog asking user to stash or abort
- Swipe left to delete with confirmation dialog

Default tab index persisted via `SharedPreferences` with key `git_default_tab`.

### 5. Three Entry Points

**SFTP entry:**
- In `SftpScreen`, after loading directory listing, check if `.git` directory exists in the file list
- If found: show a floating action button or inline banner "Open Git"
- On tap: navigate to `GitScreen` passing sessionId and current remote path
- Reuses the existing SSH connection (get `SSHClient` from `SSHService.getClient(sessionId)`)

**Terminal entry:**
- Add a Git icon button to `FunctionPanel`
- On tap: execute `pwd` via SSH exec to get current working directory
- Then check `git rev-parse --git-dir` at that path
- If git repo: navigate to `GitScreen`; if not: offer git init

**Vault entry:**
- Add "Git Repos" item to Vault home screen (alongside Hosts, Keys, Snippets, Forwarding)
- New screen `GitReposScreen`: list of saved remote repo configurations (host + path pairs)
- Stored in database (new `git_repos` table with fields: id, hostId, remotePath, label)
- Tap a saved repo: establish SSH connection to the host, then open `GitScreen`
- Add/edit form to configure host selection + remote path

### 6. Routing

```dart
// Under Vault branch
GoRoute(
  path: 'git',
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) => const GitReposScreen(),
),

// Standalone Git screen (from terminal/SFTP)
GoRoute(
  path: '/git/:sessionId',
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) => GitScreen(
    sessionId: state.pathParameters['sessionId']!,
    remotePath: state.uri.queryParameters['path'] ?? '.',
  ),
),
```

### 7. Database

New table for Vault entry saved repos:

```dart
class GitRepos extends Table {
  TextColumn get id => text()();
  TextColumn get hostId => text().references(Hosts, #id)();
  TextColumn get remotePath => text()();
  TextColumn get label => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 8. Safety Protections

- **Delete branch:** Reject if branch is current (`HEAD`) or default (`main`/`master`). Show toast with reason.
- **Delete tag:** Show confirmation dialog before executing `git tag -d`.
- **Checkout tag:** Before checkout, run `git status --porcelain`. If output is non-empty (dirty tree), show dialog with options: "Stash & Checkout" (`git stash && git checkout {tag}`) or "Cancel".
- **Git init:** Confirm dialog before running `git init` on a remote directory.

### 9. Localization

Add i18n keys for all Git UI strings in `app_en.arb` and `app_zh.arb`:
- Tab labels, button labels, error messages, confirmation dialogs
- Status labels (modified, added, deleted, renamed, untracked)

### 10. Dependencies

No new packages required:
- `dartssh2` already supports `SSHClient.execute()` for running commands
- `flutter_highlight` already available for syntax highlighting in diff view
- `CustomPainter` is built-in Flutter for branch graph rendering
- `SharedPreferences` can be added or use existing `settings_dao` for tab persistence
