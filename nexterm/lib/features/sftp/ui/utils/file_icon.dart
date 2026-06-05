import 'package:flutter/material.dart';

/// Returns an appropriate [IconData] for the given [filename].
/// If [isDirectory] is true, returns a folder icon.
IconData getFileIcon(String filename, {bool isDirectory = false}) {
  if (isDirectory) return Icons.folder;

  final ext = _extension(filename);

  switch (ext) {
    // Code / programming
    case 'dart':
    case 'go':
    case 'java':
    case 'kt':
    case 'kts':
    case 'c':
    case 'cc':
    case 'cpp':
    case 'cxx':
    case 'h':
    case 'hpp':
    case 'cs':
    case 'swift':
    case 'rs':
    case 'rb':
    case 'php':
    case 'pl':
    case 'lua':
    case 'r':
    case 'scala':
    case 'groovy':
    case 'clj':
    case 'elm':
    case 'ex':
    case 'exs':
    case 'hs':
    case 'ml':
    case 'mli':
    case 'fs':
    case 'fsx':
    case 'v':
    case 'vhd':
    case 'vhdl':
      return Icons.code;

    case 'js':
    case 'ts':
    case 'jsx':
    case 'tsx':
    case 'mjs':
    case 'cjs':
    case 'vue':
    case 'svelte':
      return Icons.javascript;

    case 'py':
    case 'pyw':
    case 'pyc':
      return Icons.code;

    case 'html':
    case 'htm':
    case 'xhtml':
      return Icons.html;

    case 'css':
    case 'scss':
    case 'sass':
    case 'less':
      return Icons.css;

    case 'xml':
    case 'xsl':
    case 'xslt':
    case 'plist':
    case 'svg':
      return Icons.code;

    case 'json':
    case 'jsonc':
    case 'json5':
      return Icons.data_object;

    case 'yaml':
    case 'yml':
    case 'toml':
    case 'ini':
    case 'cfg':
    case 'conf':
    case 'config':
      return Icons.settings;

    case 'sh':
    case 'bash':
    case 'zsh':
    case 'fish':
    case 'ksh':
    case 'csh':
    case 'tcsh':
    case 'ps1':
    case 'bat':
    case 'cmd':
      return Icons.terminal;

    // Text / docs
    case 'md':
    case 'mdx':
    case 'markdown':
    case 'rst':
    case 'txt':
    case 'log':
    case 'csv':
    case 'tsv':
      return Icons.description;

    case 'pdf':
      return Icons.picture_as_pdf;

    case 'doc':
    case 'docx':
    case 'odt':
    case 'rtf':
      return Icons.article;

    case 'xls':
    case 'xlsx':
    case 'ods':
      return Icons.table_chart;

    case 'ppt':
    case 'pptx':
    case 'odp':
      return Icons.slideshow;

    // Images
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'gif':
    case 'bmp':
    case 'webp':
    case 'ico':
    case 'tiff':
    case 'tif':
    case 'heic':
    case 'heif':
    case 'avif':
      return Icons.image;

    // Audio
    case 'mp3':
    case 'wav':
    case 'ogg':
    case 'flac':
    case 'aac':
    case 'm4a':
    case 'wma':
      return Icons.audio_file;

    // Video
    case 'mp4':
    case 'mkv':
    case 'avi':
    case 'mov':
    case 'wmv':
    case 'flv':
    case 'webm':
    case 'm4v':
      return Icons.video_file;

    // Archives
    case 'zip':
    case 'gz':
    case 'bz2':
    case 'xz':
    case 'tar':
    case 'rar':
    case '7z':
    case 'zst':
    case 'lz':
    case 'lzma':
    case 'tgz':
    case 'tbz2':
    case 'txz':
      return Icons.archive;

    // Executables / binaries
    case 'exe':
    case 'msi':
    case 'app':
    case 'deb':
    case 'rpm':
    case 'apk':
    case 'dmg':
    case 'iso':
    case 'img':
      return Icons.install_desktop;

    // Fonts
    case 'ttf':
    case 'otf':
    case 'woff':
    case 'woff2':
    case 'eot':
      return Icons.font_download;

    // Databases
    case 'db':
    case 'sqlite':
    case 'sqlite3':
    case 'sql':
      return Icons.storage;

    default:
      return Icons.insert_drive_file;
  }
}

/// Returns a color for the file icon based on its type.
/// [brightness] controls whether to use light or dark variants.
Color getFileIconColor(
  String filename, {
  bool isDirectory = false,
  Brightness brightness = Brightness.light,
}) {
  if (isDirectory) {
    return brightness == Brightness.dark
        ? const Color(0xFFFFCA28) // amber-ish for dark
        : const Color(0xFFFFA000); // darker amber for light
  }

  final ext = _extension(filename);

  switch (ext) {
    // Dart → blue
    case 'dart':
      return const Color(0xFF0175C2);

    // Python → blue/yellow
    case 'py':
    case 'pyw':
      return const Color(0xFF3572A5);

    // JavaScript / TypeScript → yellow / blue
    case 'js':
    case 'mjs':
    case 'cjs':
      return const Color(0xFFF7DF1E);
    case 'ts':
      return const Color(0xFF007ACC);
    case 'jsx':
    case 'tsx':
      return const Color(0xFF61DAFB);

    // Web
    case 'html':
    case 'htm':
      return const Color(0xFFE44D26);
    case 'css':
    case 'scss':
    case 'sass':
      return const Color(0xFF264DE4);
    case 'less':
      return const Color(0xFF1D365D);
    case 'vue':
      return const Color(0xFF41B883);
    case 'svelte':
      return const Color(0xFFFF3E00);

    // Go → cyan
    case 'go':
      return const Color(0xFF00ADD8);

    // Rust → orange
    case 'rs':
      return const Color(0xFFDEA584);

    // Java / Kotlin → orange-red / purple
    case 'java':
      return const Color(0xFFB07219);
    case 'kt':
    case 'kts':
      return const Color(0xFF7F52FF);

    // C / C++
    case 'c':
    case 'h':
      return const Color(0xFF555555);
    case 'cpp':
    case 'cc':
    case 'cxx':
    case 'hpp':
      return const Color(0xFF00599C);

    // C#
    case 'cs':
      return const Color(0xFF178600);

    // Swift → orange
    case 'swift':
      return const Color(0xFFF05138);

    // Ruby → red
    case 'rb':
      return const Color(0xFFCC342D);

    // PHP → indigo
    case 'php':
      return const Color(0xFF8892BF);

    // Shell scripts → green
    case 'sh':
    case 'bash':
    case 'zsh':
    case 'fish':
    case 'ksh':
    case 'csh':
    case 'ps1':
    case 'bat':
    case 'cmd':
      return const Color(0xFF4CAF50);

    // Data formats
    case 'json':
    case 'jsonc':
    case 'json5':
      return const Color(0xFFFF8C00);
    case 'yaml':
    case 'yml':
    case 'toml':
      return const Color(0xFF9C27B0);
    case 'xml':
      return const Color(0xFF795548);
    case 'sql':
    case 'db':
    case 'sqlite':
    case 'sqlite3':
      return const Color(0xFF00897B);

    // Docs / text
    case 'md':
    case 'mdx':
    case 'markdown':
      return const Color(0xFF083FA1);
    case 'pdf':
      return const Color(0xFFE53935);
    case 'txt':
    case 'log':
      return brightness == Brightness.dark
          ? const Color(0xFFBDBDBD)
          : const Color(0xFF757575);

    // Images → pink
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'gif':
    case 'bmp':
    case 'webp':
    case 'svg':
    case 'ico':
      return const Color(0xFFE91E63);

    // Audio → teal
    case 'mp3':
    case 'wav':
    case 'ogg':
    case 'flac':
    case 'aac':
    case 'm4a':
      return const Color(0xFF009688);

    // Video → deep purple
    case 'mp4':
    case 'mkv':
    case 'avi':
    case 'mov':
    case 'webm':
      return const Color(0xFF673AB7);

    // Archives → brown
    case 'zip':
    case 'gz':
    case 'bz2':
    case 'xz':
    case 'tar':
    case 'rar':
    case '7z':
    case 'tgz':
      return const Color(0xFF795548);

    default:
      return brightness == Brightness.dark
          ? const Color(0xFF9E9E9E)
          : const Color(0xFF616161);
  }
}

/// Returns the highlight.js / highlight package language identifier
/// for the given [filename], or an empty string if unknown.
String detectLanguage(String filename) {
  final ext = _extension(filename);

  switch (ext) {
    case 'dart':
      return 'dart';
    case 'py':
    case 'pyw':
      return 'python';
    case 'js':
    case 'mjs':
    case 'cjs':
      return 'javascript';
    case 'ts':
      return 'typescript';
    case 'jsx':
      return 'javascript';
    case 'tsx':
      return 'typescript';
    case 'html':
    case 'htm':
    case 'xhtml':
      return 'html';
    case 'css':
      return 'css';
    case 'scss':
      return 'scss';
    case 'less':
      return 'less';
    case 'xml':
    case 'xsl':
    case 'xslt':
    case 'plist':
      return 'xml';
    case 'svg':
      return 'xml';
    case 'json':
    case 'jsonc':
    case 'json5':
      return 'json';
    case 'yaml':
    case 'yml':
      return 'yaml';
    case 'toml':
      return 'ini'; // closest available
    case 'ini':
    case 'cfg':
    case 'conf':
    case 'config':
      return 'ini';
    case 'sh':
    case 'bash':
    case 'zsh':
    case 'fish':
    case 'ksh':
    case 'csh':
    case 'tcsh':
      return 'bash';
    case 'ps1':
      return 'powershell';
    case 'bat':
    case 'cmd':
      return 'dos';
    case 'go':
      return 'go';
    case 'rs':
      return 'rust';
    case 'java':
      return 'java';
    case 'kt':
    case 'kts':
      return 'kotlin';
    case 'cs':
      return 'csharp';
    case 'c':
    case 'h':
      return 'c';
    case 'cpp':
    case 'cc':
    case 'cxx':
    case 'hpp':
      return 'cpp';
    case 'swift':
      return 'swift';
    case 'rb':
      return 'ruby';
    case 'php':
      return 'php';
    case 'pl':
      return 'perl';
    case 'lua':
      return 'lua';
    case 'r':
      return 'r';
    case 'scala':
      return 'scala';
    case 'groovy':
      return 'groovy';
    case 'clj':
      return 'clojure';
    case 'hs':
      return 'haskell';
    case 'ml':
    case 'mli':
      return 'ocaml';
    case 'fs':
    case 'fsx':
      return 'fsharp';
    case 'ex':
    case 'exs':
      return 'elixir';
    case 'elm':
      return 'elm';
    case 'vue':
      return 'xml'; // closest available
    case 'md':
    case 'mdx':
    case 'markdown':
      return 'markdown';
    case 'sql':
      return 'sql';
    case 'makefile':
      return 'makefile';
    case 'dockerfile':
      return 'dockerfile';
    case 'txt':
    case 'log':
    default:
      return '';
  }
}

const _imageExtensions = {
  'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'ico',
  'tiff', 'tif', 'heic', 'heif', 'avif', 'svg',
};

const _videoExtensions = {
  'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v',
  'mpg', 'mpeg', 'ts', '3gp', 'rmvb', 'rm',
};

const _binaryExtensions = {
  // Audio
  'mp3', 'wav', 'ogg', 'flac', 'aac', 'm4a', 'wma',
  // Video
  'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v',
  // Archives
  'zip', 'gz', 'bz2', 'xz', 'tar', 'rar', '7z', 'zst',
  'lz', 'lzma', 'tgz', 'tbz2', 'txz',
  // Executables / binaries
  'exe', 'msi', 'app', 'deb', 'rpm', 'apk', 'dmg', 'iso', 'img',
  // Fonts
  'ttf', 'otf', 'woff', 'woff2', 'eot',
  // Databases
  'db', 'sqlite', 'sqlite3',
  // Office / PDF
  'doc', 'docx', 'odt', 'xls', 'xlsx', 'ods',
  'ppt', 'pptx', 'odp', 'pdf',
  // Compiled objects
  'o', 'so', 'dylib', 'dll', 'a', 'lib', 'class', 'pyc',
};

bool isImageFile(String filename) =>
    _imageExtensions.contains(_extension(filename));

bool isVideoFile(String filename) =>
    _videoExtensions.contains(_extension(filename));

bool isBinaryFile(String filename) {
  final ext = _extension(filename);
  return _binaryExtensions.contains(ext) || _imageExtensions.contains(ext);
}

bool isViewableFile(String filename) => !isBinaryFile(filename) || isImageFile(filename);

bool isEditableFile(String filename) =>
    !isBinaryFile(filename) && !isImageFile(filename);

/// Extracts the lowercase file extension (without leading dot) from [filename].
/// Returns the full lowercase filename for files without a dot (e.g. "Makefile").
String _extension(String filename) {
  final name = filename.toLowerCase();
  final dotIndex = name.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == name.length - 1) return name;
  return name.substring(dotIndex + 1);
}
