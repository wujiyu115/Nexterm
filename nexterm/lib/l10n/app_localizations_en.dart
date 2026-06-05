// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nav_hosts => 'Hosts';

  @override
  String get nav_terminal => 'Terminal';

  @override
  String get nav_sessions => 'Sessions';

  @override
  String get nav_keys => 'Keys';

  @override
  String get nav_snippets => 'Snippets';

  @override
  String get nav_forwarding => 'Forward';

  @override
  String get nav_settings => 'Settings';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_confirm => 'OK';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_save => 'Save';

  @override
  String get common_retry => 'Retry';

  @override
  String common_error(String message) {
    return 'Error: $message';
  }

  @override
  String get auth_password => 'Password';

  @override
  String get auth_key => 'Key';

  @override
  String get auth_keyboardInteractive => 'Keyboard Interactive';

  @override
  String get forwarding_local => 'Local Forwarding';

  @override
  String get forwarding_remote => 'Remote Forwarding';

  @override
  String get forwarding_dynamic => 'Dynamic Forwarding (SOCKS5)';

  @override
  String get hosts_title => 'Hosts';

  @override
  String get hosts_add => 'Add Host';

  @override
  String get hosts_addTooltip => 'Add Host';

  @override
  String get hosts_search => 'Search hosts, IP, tags...';

  @override
  String get hosts_noHosts => 'No hosts yet';

  @override
  String hosts_selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get hosts_selectAll => 'Select All';

  @override
  String get hosts_moveToGroup => 'Move to Group';

  @override
  String get hosts_deleteTooltip => 'Delete';

  @override
  String get hosts_deleteConfirm => 'Confirm Delete';

  @override
  String get hosts_deleteConfirmSingle =>
      'Are you sure you want to delete this host?';

  @override
  String hosts_deleteConfirmMultiple(int count) {
    return 'Are you sure you want to delete $count selected hosts?';
  }

  @override
  String get hosts_favorites => 'Favorites';

  @override
  String get hosts_ungrouped => 'Ungrouped';

  @override
  String get hosts_sftpConnectFailed =>
      'SSH connection failed, cannot open SFTP';

  @override
  String get hosts_newGroup => 'New Group';

  @override
  String get hosts_newGroupHint => 'Enter group name';

  @override
  String get hosts_copy => 'Copy';

  @override
  String get hosts_selectToConnect => 'Select a host to connect';

  @override
  String hosts_activeConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active connections',
      one: '1 active connection',
    );
    return '$_temp0';
  }

  @override
  String get hosts_contextConnect => 'Connect';

  @override
  String get hosts_contextSftp => 'SFTP Connect';

  @override
  String get hosts_contextCopy => 'Duplicate';

  @override
  String get hosts_contextMoveToGroup => 'Move to Group';

  @override
  String get hosts_contextEdit => 'Edit';

  @override
  String get hosts_contextSelect => 'Select';

  @override
  String get hosts_contextDelete => 'Delete';

  @override
  String get hostForm_editTitle => 'Edit Host';

  @override
  String get hostForm_addTitle => 'Add Host';

  @override
  String get hostForm_deleteTitle => 'Delete Host';

  @override
  String hostForm_deleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get hostForm_deleteTooltip => 'Delete Host';

  @override
  String get hostForm_noJumpHosts => 'No jump hosts available';

  @override
  String get hostForm_selectJumpHost => 'Select Jump Host';

  @override
  String get hostForm_sectionBasic => 'Basic Info';

  @override
  String get hostForm_name => 'Name';

  @override
  String get hostForm_nameHint => 'My Server';

  @override
  String get hostForm_nameRequired => 'Please enter a name';

  @override
  String get hostForm_host => 'Hostname / IP';

  @override
  String get hostForm_hostHint => '192.168.1.1 or example.com';

  @override
  String get hostForm_hostRequired => 'Please enter a host address';

  @override
  String get hostForm_username => 'Username';

  @override
  String get hostForm_usernameRequired => 'Please enter a username';

  @override
  String get hostForm_port => 'Port';

  @override
  String get hostForm_portInvalid => 'Invalid port';

  @override
  String get hostForm_sectionAuth => 'Authentication';

  @override
  String get hostForm_sectionGroup => 'Group & Tags';

  @override
  String get hostForm_group => 'Group';

  @override
  String get hostForm_groupHint => 'Production (optional)';

  @override
  String get hostForm_tags => 'Tags';

  @override
  String get hostForm_tagsHint => 'web, prod, nginx (comma separated)';

  @override
  String get hostForm_password => 'Password';

  @override
  String get hostForm_sectionKey => 'Key';

  @override
  String hostForm_keyLoadError(String error) {
    return 'Failed to load keys: $error';
  }

  @override
  String get hostForm_noKeys =>
      'No SSH keys added yet. Please create or import keys in the \"Keys\" page first.';

  @override
  String get hostForm_selectKey => 'Select Key';

  @override
  String get hostForm_selectKeyHint => 'Select an SSH key';

  @override
  String get hostForm_selectKeyRequired => 'Please select an SSH key';

  @override
  String get hostForm_manageKeys => 'Manage Keys';

  @override
  String get hostForm_sectionJumpHost => 'Jump Host';

  @override
  String get hostForm_noJumpHostConfigured => 'No jump host configured';

  @override
  String get hostForm_addJumpHost => 'Add Jump Host';

  @override
  String get hostForm_sectionStartup => 'Startup Command';

  @override
  String get hostForm_sectionSftp => 'SFTP';

  @override
  String get hostForm_sftpPath => 'Initial Directory';

  @override
  String get hostForm_sftpPathHint => '/home/user or /var/www';

  @override
  String get hostForm_startupModeCommand => 'Command';

  @override
  String get hostForm_startupModeSnippet => 'Snippet';

  @override
  String get hostForm_startupCommand => 'Command';

  @override
  String get hostForm_startupCommandHint => 'cd /var/log && tail -f syslog';

  @override
  String get hostForm_startupSnippet => 'Select Snippet';

  @override
  String get hostForm_startupSnippetHint => 'Choose a saved snippet';

  @override
  String get hostForm_noSnippets => 'No snippets available';

  @override
  String get sessions_title => 'Sessions';

  @override
  String get sessions_activeConnections => 'Active Connections';

  @override
  String get sessions_activeForwards => 'Active Forwards';

  @override
  String get sessions_hosts => 'Hosts';

  @override
  String get sessions_recentConnections => 'Recent Connections';

  @override
  String get sessions_noActive => 'No active sessions';

  @override
  String get sessions_noActiveHint => 'Connect to a host to start a session';

  @override
  String get terminal_connecting => 'Connecting...';

  @override
  String get terminal_noTabs => 'No open terminals';

  @override
  String get terminal_noTabsHint =>
      'Select a host from the host list to start a connection';

  @override
  String get terminal_switchToAbc => 'Switch to ABC Keyboard';

  @override
  String get terminal_switchToFunction => 'Switch to Function Panel';

  @override
  String get terminal_newTab => 'New Terminal';

  @override
  String get terminal_openSftp => 'Open SFTP';

  @override
  String get terminal_openGit => 'Open Git';

  @override
  String get terminal_openWeb => 'Web Preview';

  @override
  String get terminal_openMux => 'Multiplexer';

  @override
  String get mux_noSessions => 'No sessions';

  @override
  String get mux_notInstalled => 'No multiplexer installed on this host';

  @override
  String get mux_newSession => 'New Session';

  @override
  String get mux_sessionName => 'Session name';

  @override
  String mux_windows(int count) {
    return '$count windows';
  }

  @override
  String get mux_attached => 'attached';

  @override
  String get terminal_openWebHint => 'Enter remote port to preview';

  @override
  String get terminal_toggleKeyboard => 'Toggle Keyboard';

  @override
  String get terminal_backToHosts => 'Back to Hosts';

  @override
  String get terminal_uploadFile => 'Upload File';

  @override
  String terminal_uploading(String name) {
    return 'Uploading $name...';
  }

  @override
  String get terminal_uploadComplete => 'Upload complete';

  @override
  String terminal_uploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String get terminal_remotePath => 'Remote path';

  @override
  String get terminal_copyPath => 'Copy Path';

  @override
  String get terminal_pasteToTerminal => 'Paste to Terminal';

  @override
  String get terminal_pathCopied => 'Path copied';

  @override
  String get terminal_uploadTarget => 'Upload to';

  @override
  String get terminal_connectionFailed => 'Connection Failed';

  @override
  String get terminal_connectionFailedHint =>
      'Press the close button to close this tab, or reconnect from the host list.';

  @override
  String get terminal_errorTimeout =>
      'Connection timed out. Please check the host address and port, and ensure the network is reachable.';

  @override
  String get terminal_errorRefused =>
      'Unable to connect to host. Please verify the host address, port, and that the SSH service is running.';

  @override
  String get terminal_errorAuth =>
      'Authentication failed. Please check the username, password, or SSH key.';

  @override
  String get terminal_errorHostKey =>
      'Host key verification failed. The host key may have changed.';

  @override
  String get terminal_errorNetwork =>
      'Network unreachable. Please check your network connection.';

  @override
  String get terminal_errorDns =>
      'DNS resolution failed. Please check the host address.';

  @override
  String get toolbar_customize => 'Customize Keyboard';

  @override
  String get toolbar_addGroupTooltip => 'Add Key Group';

  @override
  String get toolbar_addGroupTitle => 'Add Key Group';

  @override
  String get toolbar_restoreDefaults => 'Restore Defaults';

  @override
  String get toolbar_restoreConfirmTitle => 'Restore Defaults';

  @override
  String get toolbar_restoreConfirmContent =>
      'Are you sure you want to restore the default keyboard layout? Custom ordering and visible group count will be reset.';

  @override
  String get toolbar_restoreButton => 'Restore';

  @override
  String get toolbar_visibleGroups => 'Visible Groups';

  @override
  String toolbar_visibleGroupsHint(int count) {
    return 'Toolbar shows at most $count key groups';
  }

  @override
  String get toolbar_hidden => '(Hidden)';

  @override
  String get toolbar_groupTerminalCtrl => 'Terminal Control';

  @override
  String get toolbar_groupSignals => 'Signals';

  @override
  String get toolbar_groupSymbols1 => 'Symbols 1';

  @override
  String get toolbar_groupNavigation => 'Navigation';

  @override
  String get toolbar_groupPunctuation => 'Punctuation';

  @override
  String get toolbar_groupSymbols2 => 'Symbols 2';

  @override
  String get toolbar_groupBrackets1 => 'Brackets 1';

  @override
  String get toolbar_groupBrackets2 => 'Brackets 2';

  @override
  String get toolbar_groupEditing => 'Editing';

  @override
  String get toolbar_groupAdvanced => 'Advanced';

  @override
  String get toolbar_groupSearch => 'Search';

  @override
  String get toolbar_groupArrows => 'Arrow Keys';

  @override
  String get toolbar_groupClipboard => 'Clipboard';

  @override
  String get function_tabCode => 'Code';

  @override
  String get function_tabHistory => 'History';

  @override
  String get function_tabHelp => 'Help';

  @override
  String get function_tabKeyboard => 'Keyboard';

  @override
  String get function_noActiveSession => 'No active session';

  @override
  String get function_switchToKeyboard => 'Switching to keyboard...';

  @override
  String get function_noSnippets => 'No snippets yet';

  @override
  String get function_noSnippetsHint => 'Add snippets in the Snippets page';

  @override
  String get function_helpCtrlC => 'Interrupt current process';

  @override
  String get function_helpCtrlD => 'Send EOF / Exit';

  @override
  String get function_helpCtrlZ => 'Suspend current process';

  @override
  String get function_helpCtrlL => 'Clear screen';

  @override
  String get function_helpCtrlR => 'Reverse search history';

  @override
  String get function_helpCtrlA => 'Move cursor to beginning';

  @override
  String get function_helpCtrlE => 'Move cursor to end';

  @override
  String get function_helpTab => 'Auto-complete';

  @override
  String get function_allShortcuts => 'All Shortcuts';

  @override
  String get commandHistory_searchHint => 'Search commands...';

  @override
  String get commandHistory_empty => 'No command history';

  @override
  String get commandHistory_noMatch => 'No matches found';

  @override
  String get keys_title => 'Keys';

  @override
  String get keys_importTooltip => 'Import Key';

  @override
  String get keys_generateTooltip => 'Generate Key';

  @override
  String get keys_noKeys => 'No SSH keys yet';

  @override
  String get keys_noKeysHint => 'Generate a key pair for passwordless login';

  @override
  String get keys_generate => 'Generate Key';

  @override
  String get keys_import => 'Import Key';

  @override
  String get keyTile_copyPublicKey => 'Copy Public Key';

  @override
  String get keyTile_exportPrivateKey => 'Export Private Key';

  @override
  String get keyTile_exportPublicKey => 'Export Public Key';

  @override
  String get keyTile_delete => 'Delete';

  @override
  String get keyTile_publicKeyCopied => 'Public key copied to clipboard';

  @override
  String keyTile_exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get keyTile_deleteTitle => 'Delete Key';

  @override
  String keyTile_deleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get keyGenerate_title => 'Generate Key';

  @override
  String get keyGenerate_failed => 'Key generation failed, please try again';

  @override
  String get keyGenerate_doneTitle => 'Key Generated';

  @override
  String keyGenerate_doneMessage(String name) {
    return '\"$name\" has been generated. Add the following public key to the server\'s ~/.ssh/authorized_keys file:';
  }

  @override
  String keyGenerate_fingerprint(String fingerprint) {
    return 'Fingerprint: $fingerprint';
  }

  @override
  String get keyGenerate_publicKeyCopied => 'Public key copied';

  @override
  String get keyGenerate_copyPublicKey => 'Copy Public Key';

  @override
  String get keyGenerate_done => 'Done';

  @override
  String get keyGenerate_sectionName => 'Key Name';

  @override
  String get keyGenerate_nameLabel => 'Name';

  @override
  String get keyGenerate_nameHint => 'My SSH Key';

  @override
  String get keyGenerate_nameRequired => 'Please enter a key name';

  @override
  String get keyGenerate_sectionPassphrase => 'Passphrase (optional)';

  @override
  String get keyGenerate_passphraseLabel => 'Passphrase';

  @override
  String get keyGenerate_passphraseHint => 'Leave empty for no encryption';

  @override
  String get keyGenerate_sectionType => 'Key Type';

  @override
  String get keyGenerate_recommended => 'Recommended';

  @override
  String get keyGenerate_ed25519Desc => 'Faster, more secure modern algorithm';

  @override
  String get keyGenerate_rsa2048Desc => 'Good compatibility for legacy systems';

  @override
  String get keyGenerate_rsa4096Desc => 'Higher security, slower generation';

  @override
  String get keyGenerate_rsaWarning =>
      'RSA key generation takes longer. Please be patient.';

  @override
  String get keyGenerate_generating => 'Generating...';

  @override
  String get keyGenerate_button => 'Generate Key';

  @override
  String get keyImport_title => 'Import Key';

  @override
  String get keyImport_noFileSelected => 'Please select a key file first';

  @override
  String get keyImport_noContent => 'Please paste the key content';

  @override
  String keyImport_success(String name) {
    return 'Key \"$name\" imported successfully';
  }

  @override
  String get keyImport_formatError =>
      'Key import failed. Please check the format.';

  @override
  String keyImport_failed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get keyImport_sectionName => 'Key Name';

  @override
  String get keyImport_nameLabel => 'Name';

  @override
  String get keyImport_nameHint => 'My SSH Key';

  @override
  String get keyImport_nameRequired => 'Please enter a key name';

  @override
  String get keyImport_sectionMethod => 'Import Method';

  @override
  String get keyImport_fromFile => 'Import from File';

  @override
  String get keyImport_pasteKey => 'Paste Key';

  @override
  String get keyImport_sectionPassphrase => 'Passphrase (optional)';

  @override
  String get keyImport_passphraseLabel => 'Passphrase';

  @override
  String get keyImport_passphraseHint =>
      'Enter if the private key is password protected';

  @override
  String get keyImport_formatHint =>
      'Supports OpenSSH format private key files (e.g., id_ed25519, id_rsa).';

  @override
  String get keyImport_importing => 'Importing...';

  @override
  String get keyImport_button => 'Import Key';

  @override
  String get keyImport_selectFile => 'Select Key File';

  @override
  String get snippets_title => 'Snippets';

  @override
  String get snippets_addTooltip => 'Add Snippet';

  @override
  String get snippets_noSnippets => 'No snippets yet';

  @override
  String get snippets_add => 'Add Snippet';

  @override
  String snippets_deleteConfirm(String name) {
    return 'Delete snippet \"$name\"?';
  }

  @override
  String get snippets_favorites => 'Favorites';

  @override
  String get snippets_ungrouped => 'Ungrouped';

  @override
  String get snippetForm_editTitle => 'Edit Snippet';

  @override
  String get snippetForm_addTitle => 'Add Snippet';

  @override
  String get snippetForm_deleteTitle => 'Delete Snippet';

  @override
  String snippetForm_deleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get snippetForm_deleteTooltip => 'Delete Snippet';

  @override
  String get snippetForm_sectionBasic => 'Basic Info';

  @override
  String get snippetForm_nameLabel => 'Name';

  @override
  String get snippetForm_nameHint => 'My Deploy Script';

  @override
  String get snippetForm_nameRequired => 'Please enter a name';

  @override
  String get snippetForm_commandLabel => 'Command';

  @override
  String get snippetForm_commandRequired => 'Please enter a command';

  @override
  String get snippetForm_sectionVariables => 'Variables';

  @override
  String get snippetForm_variablesHint =>
      'Define variables in the command and set default values here';

  @override
  String get snippetForm_defaultValueHint => 'Default value (optional)';

  @override
  String snippetForm_variableDescLabel(String name) {
    return 'Description for $name';
  }

  @override
  String get snippetForm_variableDescHint =>
      'Describe the purpose of this variable (optional)';

  @override
  String get snippetForm_sectionGroup => 'Group & Tags';

  @override
  String get snippetForm_groupLabel => 'Group';

  @override
  String get snippetForm_groupHint => 'DevOps (optional)';

  @override
  String get snippetForm_tagsLabel => 'Tags';

  @override
  String get snippetForm_tagsHint => 'deploy, k8s (comma separated)';

  @override
  String get snippetExecute_selectTitle => 'Select Snippet';

  @override
  String get snippetExecute_searchHint => 'Search snippets...';

  @override
  String get snippetExecute_noSnippets => 'No snippets yet';

  @override
  String get snippetExecute_noMatch => 'No matching snippets found';

  @override
  String snippetExecute_fillVariables(String name) {
    return 'Fill Variables — $name';
  }

  @override
  String get snippetExecute_execute => 'Execute';

  @override
  String get forwarding_title => 'Port Forwarding';

  @override
  String get forwarding_addTooltip => 'Add Forward';

  @override
  String get forwarding_ephemeral => 'Temporary Forwards';

  @override
  String get forwarding_noForwards => 'No port forwarding rules';

  @override
  String get forwarding_add => 'Add Forward';

  @override
  String get forwarding_startFromTerminal =>
      'Please start forwarding from a terminal session';

  @override
  String forwarding_deleteConfirm(String name) {
    return 'Delete forward rule \"$name\"?';
  }

  @override
  String get forwarding_stop => 'Stop';

  @override
  String get forwarding_start => 'Start';

  @override
  String get forwarding_autoStart => 'Auto Start';

  @override
  String get forwardForm_editTitle => 'Edit Forward';

  @override
  String get forwardForm_addTitle => 'Add Forward';

  @override
  String get forwardForm_deleteTitle => 'Delete Forward';

  @override
  String forwardForm_deleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get forwardForm_deleteTooltip => 'Delete Forward';

  @override
  String get forwardForm_sectionBasic => 'Basic Info';

  @override
  String get forwardForm_nameLabel => 'Name';

  @override
  String get forwardForm_nameHint => 'Database Tunnel';

  @override
  String get forwardForm_nameRequired => 'Please enter a name';

  @override
  String get forwardForm_sectionType => 'Forward Type';

  @override
  String get forwardForm_sectionPorts => 'Port Configuration';

  @override
  String get forwardForm_localPort => 'Local Port';

  @override
  String get forwardForm_portInvalid => 'Please enter a valid port (1-65535)';

  @override
  String get forwardForm_remoteHost => 'Remote Host';

  @override
  String get forwardForm_remoteHostRequired => 'Please enter a remote host';

  @override
  String get forwardForm_remotePort => 'Remote Port';

  @override
  String get forwardForm_bindAddress => 'Bind Address';

  @override
  String get forwardForm_bindAddressRequired => 'Please enter a bind address';

  @override
  String get forwardForm_typeHelpTitle => 'Forward Types';

  @override
  String get forwardForm_typeHelpLocal =>
      'Maps a local port to a remote address via SSH. Use it to access remote services (databases, internal APIs) as if they were running locally.\nExample: Local port 3306 → remote db.internal:3306';

  @override
  String get forwardForm_typeHelpRemote =>
      'Exposes a local service to the remote server. Use it to let the remote host access a service running on your device.\nExample: Remote port 8080 → local 127.0.0.1:3000';

  @override
  String get forwardForm_typeHelpDynamic =>
      'Creates a SOCKS5 proxy on a local port. All traffic routed through the proxy is tunneled via the SSH server. Use it to browse the internet or access multiple remote resources through a single port.';

  @override
  String get forwardForm_sectionOptions => 'Options';

  @override
  String get forwardForm_autoStart => 'Auto Start';

  @override
  String get forwardForm_autoStartHint =>
      'Automatically start this forward when connected to host';

  @override
  String get forwardForm_noHosts =>
      'No hosts available. Please add a host first.';

  @override
  String get forwardForm_hostLabel => 'Host';

  @override
  String get forwardForm_hostRequired => 'Please select a host';

  @override
  String forwardForm_hostLoadError(String error) {
    return 'Failed to load hosts: $error';
  }

  @override
  String get portDetect_title => 'Port Detection';

  @override
  String get portDetect_tooltip => 'Detect remote ports';

  @override
  String get portDetect_noSessions =>
      'No active SSH sessions. Please connect to a host first.';

  @override
  String get portDetect_scanning => 'Scanning remote ports…';

  @override
  String get portDetect_scanButton => 'Scan';

  @override
  String get portDetect_rescanButton => 'Rescan';

  @override
  String get portDetect_noPorts => 'No listening ports detected';

  @override
  String portDetect_portsFound(int count) {
    return '$count listening ports detected';
  }

  @override
  String get portDetect_alreadyForwarded => 'Forwarded';

  @override
  String get portDetect_addForward => 'Add Forward';

  @override
  String get portDetect_systemPorts => 'System Ports';

  @override
  String get portDetect_userPorts => 'User Ports';

  @override
  String get portDetect_unknownProcess => 'Unknown process';

  @override
  String get portDetect_permissionHint =>
      'Some process names require root privileges';

  @override
  String portDetect_error(String error) {
    return 'Scan failed: $error';
  }

  @override
  String get portDetect_selectSession => 'Select Session';

  @override
  String get portDetect_search => 'Search port, process...';

  @override
  String get sftp_copy => 'Copy';

  @override
  String get sftp_rename => 'Rename';

  @override
  String get sftp_download => 'Download';

  @override
  String get sftp_copyPath => 'Copy Path';

  @override
  String sftp_pathCopied(String path) {
    return 'Path copied: $path';
  }

  @override
  String get sftp_copied => 'Copied. Navigate to target folder to paste.';

  @override
  String get sftp_deleteConfirmTitle => 'Confirm Delete';

  @override
  String sftp_deleteConfirmContent(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get sftp_renameTitle => 'Rename';

  @override
  String get sftp_renameLabel => 'New Name';

  @override
  String get sftp_newFolderTitle => 'New Folder';

  @override
  String get sftp_newFolderLabel => 'Folder Name';

  @override
  String get sftp_sortTitle => 'Sort By';

  @override
  String get sftp_sortByName => 'By Name';

  @override
  String get sftp_sortBySize => 'By Size';

  @override
  String get sftp_sortByDate => 'By Date';

  @override
  String get sftp_sortByType => 'By Type';

  @override
  String sftp_connectionFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get sftp_paste => 'Paste';

  @override
  String get sftp_showHidden => 'Show Hidden Files';

  @override
  String get sftp_hideHidden => 'Hide Hidden Files';

  @override
  String get sftp_upload => 'Upload';

  @override
  String get sftp_newFolder => 'New Folder';

  @override
  String get sftp_sort => 'Sort';

  @override
  String get sftp_refresh => 'Refresh';

  @override
  String get sftp_view => 'View';

  @override
  String get sftp_viewImage => 'View Image';

  @override
  String get sftp_edit => 'Edit';

  @override
  String get sftp_permissions => 'Permissions';

  @override
  String get sftp_goToPath => 'Go to Path';

  @override
  String get sftp_goToPathHint => 'Enter remote path';

  @override
  String get sftp_noFiles => 'No files';

  @override
  String get video_loading => 'Loading video...';

  @override
  String get video_play => 'Play Video';

  @override
  String get fileEditor_fileSaved => 'File saved';

  @override
  String fileEditor_saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get fileEditor_editMode => 'Edit mode';

  @override
  String get fileEditor_previewMode => 'Preview mode';

  @override
  String get fileEditor_save => 'Save';

  @override
  String fileEditor_loadFailed(String error) {
    return 'Failed to load file: $error';
  }

  @override
  String get fileEditor_modified => 'Modified';

  @override
  String get fileEditor_renderMarkdown => 'Render Markdown';

  @override
  String get fileEditor_markdownSource => 'View Source';

  @override
  String get fileEditor_toc => 'Table of Contents';

  @override
  String transfer_title(int count) {
    return 'Transfers ($count)';
  }

  @override
  String get transfer_clearDone => 'Clear done';

  @override
  String transfer_more(int count) {
    return '+$count more';
  }

  @override
  String get transfer_queued => 'Queued';

  @override
  String get permission_title => 'Change Permissions';

  @override
  String get permission_octalLabel => 'Octal (e.g. 644)';

  @override
  String get permission_apply => 'Apply';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_sectionGeneral => 'General';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_languageChinese => '中文';

  @override
  String get settings_languageEnglish => 'English';

  @override
  String get settings_languageSystem => 'Follow System';

  @override
  String get settings_sectionTerminal => 'Terminal';

  @override
  String get settings_cursorStyle => 'Cursor Style';

  @override
  String get settings_hapticFeedback => 'Haptic Feedback';

  @override
  String get settings_voiceLocale => 'Voice Input Language';

  @override
  String get settings_voiceLocaleSystem => 'Follow System';

  @override
  String get settings_selectVoiceLocale => 'Select Voice Input Language';

  @override
  String get settings_sectionSecurity => 'Security';

  @override
  String get settings_biometric => 'Biometric Unlock';

  @override
  String get settings_autoLock => 'Auto Lock';

  @override
  String get settings_clipboardAutoClear => 'Auto Clear Clipboard';

  @override
  String get settings_clipboardAutoClearHint =>
      'Auto clear clipboard when leaving the app';

  @override
  String get settings_sectionSync => 'Sync';

  @override
  String get settings_account => 'Account';

  @override
  String get settings_loggedIn => 'Logged in';

  @override
  String get settings_deviceManagement => 'Device Management';

  @override
  String get settings_syncNow => 'Sync Now';

  @override
  String get settings_logout => 'Log Out';

  @override
  String get settings_loginRegister => 'Login / Register';

  @override
  String get settings_loginHint => 'Login to sync your data';

  @override
  String get settings_sectionData => 'Data';

  @override
  String get settings_importSshConfig => 'Import SSH Config';

  @override
  String get settings_importSshConfigHint => 'Import from ~/.ssh/config file';

  @override
  String get settings_exportData => 'Export Data';

  @override
  String get settings_exportDataHint => 'Export all data as a JSON file';

  @override
  String get settings_sectionAbout => 'About';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_themeGroupDark => 'DARK';

  @override
  String get settings_themeGroupLight => 'LIGHT';

  @override
  String get settings_cursorBlock => 'Block';

  @override
  String get settings_cursorUnderline => 'Underline';

  @override
  String get settings_cursorBar => 'Bar';

  @override
  String get settings_autoLockNever => 'Never';

  @override
  String get settings_autoLockOneMinute => '1 minute';

  @override
  String settings_autoLockMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get settings_fontSize => 'Font Size';

  @override
  String get settings_fontFamily => 'Font Family';

  @override
  String get settings_selectFontFamily => 'Select Font Family';

  @override
  String get settings_scrollbackLines => 'Scrollback Lines';

  @override
  String get settings_selectScrollbackLines => 'Select Scrollback Lines';

  @override
  String get settings_scrollbackLinesSuffix => 'lines';

  @override
  String get settings_selectTheme => 'Select Theme';

  @override
  String get settings_selectCursorStyle => 'Select Cursor Style';

  @override
  String get settings_selectAutoLock => 'Auto Lock';

  @override
  String get settings_deviceManagementTitle => 'Device Management';

  @override
  String get settings_deviceManagementContent =>
      'Device management is coming soon.';

  @override
  String get settings_syncing => 'Syncing...';

  @override
  String get settings_logoutTitle => 'Log Out';

  @override
  String get settings_logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get settings_logoutButton => 'Log Out';

  @override
  String settings_importedCount(int count) {
    return 'Imported $count hosts';
  }

  @override
  String settings_importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get settings_exportTitle => 'Export Data';

  @override
  String get settings_exportContent =>
      'Export all hosts, keys, and snippet data as a JSON file.';

  @override
  String get settings_exported => 'Data exported';

  @override
  String get settings_exportButton => 'Export';

  @override
  String get settings_loginTitle => 'Login';

  @override
  String get settings_registerTitle => 'Register';

  @override
  String get settings_emailLabel => 'Email';

  @override
  String get settings_passwordLabel => 'Password';

  @override
  String get settings_switchToLogin => 'Already have an account? Login';

  @override
  String get settings_switchToRegister => 'Don\'t have an account? Register';

  @override
  String get settings_registerButton => 'Register';

  @override
  String get settings_loginButton => 'Login';

  @override
  String get lock_locked => 'Locked';

  @override
  String get lock_unlock => 'Unlock';

  @override
  String get lock_biometricReason =>
      'Please verify your identity to unlock Nexterm';

  @override
  String get dataExport_shareText => 'Nexterm Encrypted Backup';

  @override
  String keysProvider_unsupportedKeyType(String type) {
    return 'Unsupported key type: $type';
  }

  @override
  String get keysProvider_invalidPkcs1 =>
      'Invalid PKCS#1 RSA private key format';

  @override
  String get keysProvider_invalidMagic => 'Invalid OpenSSH private key magic';

  @override
  String get keysProvider_encryptedNotSupported =>
      'Encrypted private keys are not yet supported. Please decrypt before importing.';

  @override
  String get keysProvider_singleKeyOnly =>
      'Only files containing a single key are supported';

  @override
  String keysProvider_unsupportedFormat(String format) {
    return 'Unsupported private key format: $format';
  }

  @override
  String get nav_vaults => 'Vaults';

  @override
  String get nav_connections => 'Connections';

  @override
  String get nav_profile => 'Profile';

  @override
  String get vaults_title => 'Personal Vault';

  @override
  String get vaults_connections => 'Connections';

  @override
  String get vaults_hosts => 'Hosts';

  @override
  String get vaults_tools => 'Tools';

  @override
  String get vaults_portForwarding => 'Port Forwarding';

  @override
  String get vaults_snippets => 'Snippets';

  @override
  String get vaults_keychain => 'Keychain';

  @override
  String get git_title => 'Git';

  @override
  String get git_repos => 'Git Repos';

  @override
  String get git_reposEmpty => 'No saved repositories';

  @override
  String get git_addRepo => 'Add Repository';

  @override
  String get git_editRepo => 'Edit Repository';

  @override
  String get git_deleteRepo => 'Delete Repository';

  @override
  String git_deleteRepoConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get git_repoLabel => 'Label';

  @override
  String get git_repoLabelHint => 'e.g. My Project';

  @override
  String get git_repoPath => 'Remote Path';

  @override
  String get git_repoPathHint => 'e.g. /home/user/project';

  @override
  String get git_selectHost => 'Select Host';

  @override
  String get git_tabWorkTree => 'Working Tree';

  @override
  String get git_tabBranches => 'Branches';

  @override
  String get git_tabTags => 'Tags';

  @override
  String get git_commits => 'Commits';

  @override
  String get git_commitDetail => 'Commit Detail';

  @override
  String get git_author => 'Author';

  @override
  String get git_date => 'Date';

  @override
  String get git_message => 'Message';

  @override
  String get git_changedFiles => 'Changed Files';

  @override
  String get git_staged => 'Staged';

  @override
  String get git_unstaged => 'Unstaged';

  @override
  String get git_untracked => 'Untracked';

  @override
  String get git_noChanges => 'Working tree clean';

  @override
  String get git_branchGraph => 'Branch Graph';

  @override
  String get git_currentBranch => 'Current';

  @override
  String get git_deleteBranch => 'Delete Branch';

  @override
  String get git_deleteBranchProtected =>
      'Cannot delete current or default branch';

  @override
  String get git_deleteTag => 'Delete Tag';

  @override
  String git_deleteTagConfirm(String name) {
    return 'Delete tag \"$name\"?';
  }

  @override
  String get git_checkoutTag => 'Checkout';

  @override
  String get git_checkoutDirtyTitle => 'Uncommitted Changes';

  @override
  String get git_checkoutDirtyMessage =>
      'Your working tree has uncommitted changes. Stash them before checking out?';

  @override
  String get git_stashAndCheckout => 'Stash & Checkout';

  @override
  String get git_initTitle => 'Not a Git Repository';

  @override
  String get git_initMessage =>
      'This directory is not a git repository. Initialize one?';

  @override
  String get git_initButton => 'Initialize';

  @override
  String get git_initConfirm => 'Initialize a git repository at this path?';

  @override
  String get git_changePath => 'Change Path';

  @override
  String get git_fileHistory => 'File History';

  @override
  String get git_diff => 'Diff';

  @override
  String git_additions(int count) {
    return '+$count';
  }

  @override
  String git_deletions(int count) {
    return '-$count';
  }

  @override
  String get git_statusModified => 'Modified';

  @override
  String get git_statusAdded => 'Added';

  @override
  String get git_statusDeleted => 'Deleted';

  @override
  String get git_statusRenamed => 'Renamed';

  @override
  String get git_statusUntracked => 'Untracked';

  @override
  String get git_noBranches => 'No branches';

  @override
  String get git_noTags => 'No tags';

  @override
  String get git_noCommits => 'No commits yet';

  @override
  String get git_openGit => 'Open Git';

  @override
  String get git_connecting => 'Connecting...';

  @override
  String get git_search => 'Search repos, paths...';

  @override
  String get webdav_title => 'WebDAV';

  @override
  String get webdav_add => 'Add Connection';

  @override
  String get webdav_noConnections => 'No WebDAV connections';

  @override
  String get webdav_noConnectionsHint =>
      'Add a WebDAV server to browse remote files';

  @override
  String get webdav_name => 'Name';

  @override
  String get webdav_nameHint => 'My WebDAV Server';

  @override
  String get webdav_nameRequired => 'Please enter a name';

  @override
  String get webdav_url => 'URL';

  @override
  String get webdav_urlHint =>
      'https://dav.example.com/remote.php/dav/files/user';

  @override
  String get webdav_urlRequired => 'Please enter a URL';

  @override
  String get webdav_username => 'Username';

  @override
  String get webdav_password => 'Password';

  @override
  String get webdav_connect => 'Connect';

  @override
  String webdav_connectFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get webdav_deleteTitle => 'Delete Connection';

  @override
  String webdav_deleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get webdav_editTitle => 'Edit Connection';

  @override
  String get webdav_addTitle => 'Add Connection';

  @override
  String get webdav_search => 'Search connections, URLs...';

  @override
  String get smb_title => 'SMB';

  @override
  String get smb_add => 'Add Connection';

  @override
  String get smb_noConnections => 'No SMB connections';

  @override
  String get smb_noConnectionsHint =>
      'Add an SMB/CIFS server to browse shared files';

  @override
  String get smb_name => 'Name';

  @override
  String get smb_nameHint => 'My NAS';

  @override
  String get smb_nameRequired => 'Please enter a name';

  @override
  String get smb_host => 'Server Address';

  @override
  String get smb_hostHint => '192.168.1.100 or nas.local';

  @override
  String get smb_hostRequired => 'Please enter a server address';

  @override
  String get smb_port => 'Port';

  @override
  String get smb_shareName => 'Share Name';

  @override
  String get smb_shareNameHint => 'public';

  @override
  String get smb_shareNameRequired => 'Please enter a share name';

  @override
  String get smb_username => 'Username';

  @override
  String get smb_password => 'Password';

  @override
  String get smb_domain => 'Domain';

  @override
  String get smb_domainHint => 'WORKGROUP';

  @override
  String get smb_connect => 'Connect';

  @override
  String smb_connectFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get smb_deleteTitle => 'Delete Connection';

  @override
  String smb_deleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get smb_editTitle => 'Edit Connection';

  @override
  String get smb_addTitle => 'Add Connection';

  @override
  String get smb_search => 'Search connections, hosts...';

  @override
  String get settings_sectionVoiceInput => 'Voice Input';

  @override
  String get settings_sttProvider => 'Speech Recognition Provider';

  @override
  String get settings_sttProviderSystem => 'System (On-device)';

  @override
  String get settings_sttProviderVolcengine => 'Volcengine (Doubao)';

  @override
  String get settings_sttProviderAlibaba => 'Alibaba Cloud NLS';

  @override
  String get settings_sttSelectProvider => 'Select Provider';

  @override
  String get settings_sttAppId => 'App ID';

  @override
  String get settings_sttAccessToken => 'Access Token';

  @override
  String get settings_sttResourceId => 'Resource ID';

  @override
  String get settings_sttAccessKeyId => 'AccessKey ID';

  @override
  String get settings_sttAccessKeySecret => 'AccessKey Secret';

  @override
  String get settings_sttAppKey => 'AppKey';

  @override
  String get settings_sttSpeedTest => 'Test Connection Speed';

  @override
  String settings_sttSpeedTestResult(int ms) {
    return 'Latency: ${ms}ms';
  }

  @override
  String settings_sttSpeedTestFailed(String error) {
    return 'Test failed: $error';
  }

  @override
  String get settings_sttCredentialsSaved => 'Credentials saved';

  @override
  String get settings_sttEditCredential => 'Edit';

  @override
  String get settings_sttConfigured => 'Configured';

  @override
  String get settings_sttNotConfigured => 'Not configured';
}
