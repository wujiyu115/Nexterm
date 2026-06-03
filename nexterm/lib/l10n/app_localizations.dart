import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @nav_hosts.
  ///
  /// In zh, this message translates to:
  /// **'主机'**
  String get nav_hosts;

  /// No description provided for @nav_terminal.
  ///
  /// In zh, this message translates to:
  /// **'终端'**
  String get nav_terminal;

  /// No description provided for @nav_sessions.
  ///
  /// In zh, this message translates to:
  /// **'会话'**
  String get nav_sessions;

  /// No description provided for @nav_keys.
  ///
  /// In zh, this message translates to:
  /// **'密钥'**
  String get nav_keys;

  /// No description provided for @nav_snippets.
  ///
  /// In zh, this message translates to:
  /// **'片段'**
  String get nav_snippets;

  /// No description provided for @nav_forwarding.
  ///
  /// In zh, this message translates to:
  /// **'转发'**
  String get nav_forwarding;

  /// No description provided for @nav_settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get nav_settings;

  /// No description provided for @common_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get common_cancel;

  /// No description provided for @common_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get common_confirm;

  /// No description provided for @common_delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get common_delete;

  /// No description provided for @common_save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get common_save;

  /// No description provided for @common_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get common_retry;

  /// No description provided for @common_error.
  ///
  /// In zh, this message translates to:
  /// **'错误: {message}'**
  String common_error(String message);

  /// No description provided for @auth_password.
  ///
  /// In zh, this message translates to:
  /// **'密码认证'**
  String get auth_password;

  /// No description provided for @auth_key.
  ///
  /// In zh, this message translates to:
  /// **'密钥认证'**
  String get auth_key;

  /// No description provided for @auth_keyboardInteractive.
  ///
  /// In zh, this message translates to:
  /// **'键盘交互'**
  String get auth_keyboardInteractive;

  /// No description provided for @forwarding_local.
  ///
  /// In zh, this message translates to:
  /// **'本地转发'**
  String get forwarding_local;

  /// No description provided for @forwarding_remote.
  ///
  /// In zh, this message translates to:
  /// **'远程转发'**
  String get forwarding_remote;

  /// No description provided for @forwarding_dynamic.
  ///
  /// In zh, this message translates to:
  /// **'动态转发 (SOCKS5)'**
  String get forwarding_dynamic;

  /// No description provided for @hosts_title.
  ///
  /// In zh, this message translates to:
  /// **'主机'**
  String get hosts_title;

  /// No description provided for @hosts_add.
  ///
  /// In zh, this message translates to:
  /// **'添加主机'**
  String get hosts_add;

  /// No description provided for @hosts_addTooltip.
  ///
  /// In zh, this message translates to:
  /// **'添加主机'**
  String get hosts_addTooltip;

  /// No description provided for @hosts_search.
  ///
  /// In zh, this message translates to:
  /// **'搜索主机、IP、标签...'**
  String get hosts_search;

  /// No description provided for @hosts_noHosts.
  ///
  /// In zh, this message translates to:
  /// **'暂无主机'**
  String get hosts_noHosts;

  /// No description provided for @hosts_selectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 项'**
  String hosts_selectedCount(int count);

  /// No description provided for @hosts_selectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get hosts_selectAll;

  /// No description provided for @hosts_moveToGroup.
  ///
  /// In zh, this message translates to:
  /// **'移动到组'**
  String get hosts_moveToGroup;

  /// No description provided for @hosts_deleteTooltip.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get hosts_deleteTooltip;

  /// No description provided for @hosts_deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get hosts_deleteConfirm;

  /// No description provided for @hosts_deleteConfirmSingle.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除此主机吗？'**
  String get hosts_deleteConfirmSingle;

  /// No description provided for @hosts_deleteConfirmMultiple.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除选中的 {count} 台主机吗？'**
  String hosts_deleteConfirmMultiple(int count);

  /// No description provided for @hosts_favorites.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get hosts_favorites;

  /// No description provided for @hosts_ungrouped.
  ///
  /// In zh, this message translates to:
  /// **'未分组'**
  String get hosts_ungrouped;

  /// No description provided for @hosts_sftpConnectFailed.
  ///
  /// In zh, this message translates to:
  /// **'SSH 连接失败，无法打开 SFTP'**
  String get hosts_sftpConnectFailed;

  /// No description provided for @hosts_newGroup.
  ///
  /// In zh, this message translates to:
  /// **'新建分组'**
  String get hosts_newGroup;

  /// No description provided for @hosts_newGroupHint.
  ///
  /// In zh, this message translates to:
  /// **'输入分组名称'**
  String get hosts_newGroupHint;

  /// No description provided for @hosts_copy.
  ///
  /// In zh, this message translates to:
  /// **'副本'**
  String get hosts_copy;

  /// No description provided for @hosts_selectToConnect.
  ///
  /// In zh, this message translates to:
  /// **'选择要连接的主机'**
  String get hosts_selectToConnect;

  /// No description provided for @hosts_activeConnections.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个活跃连接'**
  String hosts_activeConnections(int count);

  /// No description provided for @hosts_contextConnect.
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get hosts_contextConnect;

  /// No description provided for @hosts_contextSftp.
  ///
  /// In zh, this message translates to:
  /// **'SFTP 连接'**
  String get hosts_contextSftp;

  /// No description provided for @hosts_contextCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get hosts_contextCopy;

  /// No description provided for @hosts_contextMoveToGroup.
  ///
  /// In zh, this message translates to:
  /// **'移动到组'**
  String get hosts_contextMoveToGroup;

  /// No description provided for @hosts_contextEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get hosts_contextEdit;

  /// No description provided for @hosts_contextSelect.
  ///
  /// In zh, this message translates to:
  /// **'选中'**
  String get hosts_contextSelect;

  /// No description provided for @hosts_contextDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get hosts_contextDelete;

  /// No description provided for @hostForm_editTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑主机'**
  String get hostForm_editTitle;

  /// No description provided for @hostForm_addTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加主机'**
  String get hostForm_addTitle;

  /// No description provided for @hostForm_deleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除主机'**
  String get hostForm_deleteTitle;

  /// No description provided for @hostForm_deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除「{name}」吗？'**
  String hostForm_deleteConfirm(String name);

  /// No description provided for @hostForm_deleteTooltip.
  ///
  /// In zh, this message translates to:
  /// **'删除主机'**
  String get hostForm_deleteTooltip;

  /// No description provided for @hostForm_noJumpHosts.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的跳板机'**
  String get hostForm_noJumpHosts;

  /// No description provided for @hostForm_selectJumpHost.
  ///
  /// In zh, this message translates to:
  /// **'选择跳板机'**
  String get hostForm_selectJumpHost;

  /// No description provided for @hostForm_sectionBasic.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get hostForm_sectionBasic;

  /// No description provided for @hostForm_name.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get hostForm_name;

  /// No description provided for @hostForm_nameHint.
  ///
  /// In zh, this message translates to:
  /// **'我的服务器'**
  String get hostForm_nameHint;

  /// No description provided for @hostForm_nameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入名称'**
  String get hostForm_nameRequired;

  /// No description provided for @hostForm_host.
  ///
  /// In zh, this message translates to:
  /// **'主机名 / IP'**
  String get hostForm_host;

  /// No description provided for @hostForm_hostHint.
  ///
  /// In zh, this message translates to:
  /// **'192.168.1.1 或 example.com'**
  String get hostForm_hostHint;

  /// No description provided for @hostForm_hostRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入主机地址'**
  String get hostForm_hostRequired;

  /// No description provided for @hostForm_username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get hostForm_username;

  /// No description provided for @hostForm_usernameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户名'**
  String get hostForm_usernameRequired;

  /// No description provided for @hostForm_port.
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get hostForm_port;

  /// No description provided for @hostForm_portInvalid.
  ///
  /// In zh, this message translates to:
  /// **'无效端口'**
  String get hostForm_portInvalid;

  /// No description provided for @hostForm_sectionAuth.
  ///
  /// In zh, this message translates to:
  /// **'认证方式'**
  String get hostForm_sectionAuth;

  /// No description provided for @hostForm_sectionGroup.
  ///
  /// In zh, this message translates to:
  /// **'分组与标签'**
  String get hostForm_sectionGroup;

  /// No description provided for @hostForm_group.
  ///
  /// In zh, this message translates to:
  /// **'分组'**
  String get hostForm_group;

  /// No description provided for @hostForm_groupHint.
  ///
  /// In zh, this message translates to:
  /// **'生产环境（可选）'**
  String get hostForm_groupHint;

  /// No description provided for @hostForm_tags.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get hostForm_tags;

  /// No description provided for @hostForm_tagsHint.
  ///
  /// In zh, this message translates to:
  /// **'web, prod, nginx（逗号分隔）'**
  String get hostForm_tagsHint;

  /// No description provided for @hostForm_password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get hostForm_password;

  /// No description provided for @hostForm_sectionKey.
  ///
  /// In zh, this message translates to:
  /// **'密钥'**
  String get hostForm_sectionKey;

  /// No description provided for @hostForm_keyLoadError.
  ///
  /// In zh, this message translates to:
  /// **'加载密钥失败: {error}'**
  String hostForm_keyLoadError(String error);

  /// No description provided for @hostForm_noKeys.
  ///
  /// In zh, this message translates to:
  /// **'尚未添加任何 SSH 密钥，请先在\"密钥\"页面创建或导入密钥。'**
  String get hostForm_noKeys;

  /// No description provided for @hostForm_selectKey.
  ///
  /// In zh, this message translates to:
  /// **'选择密钥'**
  String get hostForm_selectKey;

  /// No description provided for @hostForm_selectKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'请选择 SSH 密钥'**
  String get hostForm_selectKeyHint;

  /// No description provided for @hostForm_selectKeyRequired.
  ///
  /// In zh, this message translates to:
  /// **'请选择一个 SSH 密钥'**
  String get hostForm_selectKeyRequired;

  /// No description provided for @hostForm_sectionJumpHost.
  ///
  /// In zh, this message translates to:
  /// **'跳板机'**
  String get hostForm_sectionJumpHost;

  /// No description provided for @hostForm_noJumpHostConfigured.
  ///
  /// In zh, this message translates to:
  /// **'未配置跳板机'**
  String get hostForm_noJumpHostConfigured;

  /// No description provided for @hostForm_addJumpHost.
  ///
  /// In zh, this message translates to:
  /// **'添加跳板机'**
  String get hostForm_addJumpHost;

  /// No description provided for @hostForm_sectionStartup.
  ///
  /// In zh, this message translates to:
  /// **'启动命令'**
  String get hostForm_sectionStartup;

  /// No description provided for @hostForm_startupModeCommand.
  ///
  /// In zh, this message translates to:
  /// **'命令'**
  String get hostForm_startupModeCommand;

  /// No description provided for @hostForm_startupModeSnippet.
  ///
  /// In zh, this message translates to:
  /// **'片段'**
  String get hostForm_startupModeSnippet;

  /// No description provided for @hostForm_startupCommand.
  ///
  /// In zh, this message translates to:
  /// **'命令'**
  String get hostForm_startupCommand;

  /// No description provided for @hostForm_startupCommandHint.
  ///
  /// In zh, this message translates to:
  /// **'cd /var/log && tail -f syslog'**
  String get hostForm_startupCommandHint;

  /// No description provided for @hostForm_startupSnippet.
  ///
  /// In zh, this message translates to:
  /// **'选择片段'**
  String get hostForm_startupSnippet;

  /// No description provided for @hostForm_startupSnippetHint.
  ///
  /// In zh, this message translates to:
  /// **'选择已保存的片段'**
  String get hostForm_startupSnippetHint;

  /// No description provided for @hostForm_noSnippets.
  ///
  /// In zh, this message translates to:
  /// **'暂无片段'**
  String get hostForm_noSnippets;

  /// No description provided for @sessions_title.
  ///
  /// In zh, this message translates to:
  /// **'会话'**
  String get sessions_title;

  /// No description provided for @sessions_activeConnections.
  ///
  /// In zh, this message translates to:
  /// **'活跃连接'**
  String get sessions_activeConnections;

  /// No description provided for @sessions_hosts.
  ///
  /// In zh, this message translates to:
  /// **'主机'**
  String get sessions_hosts;

  /// No description provided for @sessions_recentConnections.
  ///
  /// In zh, this message translates to:
  /// **'最近连接'**
  String get sessions_recentConnections;

  /// No description provided for @sessions_noActive.
  ///
  /// In zh, this message translates to:
  /// **'没有活跃会话'**
  String get sessions_noActive;

  /// No description provided for @sessions_noActiveHint.
  ///
  /// In zh, this message translates to:
  /// **'连接一台主机以开始会话'**
  String get sessions_noActiveHint;

  /// No description provided for @terminal_connecting.
  ///
  /// In zh, this message translates to:
  /// **'正在连接…'**
  String get terminal_connecting;

  /// No description provided for @terminal_noTabs.
  ///
  /// In zh, this message translates to:
  /// **'没有打开的终端'**
  String get terminal_noTabs;

  /// No description provided for @terminal_noTabsHint.
  ///
  /// In zh, this message translates to:
  /// **'从主机列表中选择一台主机以开始连接'**
  String get terminal_noTabsHint;

  /// No description provided for @terminal_switchToAbc.
  ///
  /// In zh, this message translates to:
  /// **'切换到 ABC 键盘'**
  String get terminal_switchToAbc;

  /// No description provided for @terminal_switchToFunction.
  ///
  /// In zh, this message translates to:
  /// **'切换到功能面板'**
  String get terminal_switchToFunction;

  /// No description provided for @terminal_newTab.
  ///
  /// In zh, this message translates to:
  /// **'新建终端'**
  String get terminal_newTab;

  /// No description provided for @terminal_openSftp.
  ///
  /// In zh, this message translates to:
  /// **'打开 SFTP'**
  String get terminal_openSftp;

  /// No description provided for @terminal_openGit.
  ///
  /// In zh, this message translates to:
  /// **'打开 Git'**
  String get terminal_openGit;

  /// No description provided for @terminal_toggleKeyboard.
  ///
  /// In zh, this message translates to:
  /// **'切换键盘'**
  String get terminal_toggleKeyboard;

  /// No description provided for @terminal_backToHosts.
  ///
  /// In zh, this message translates to:
  /// **'返回主机'**
  String get terminal_backToHosts;

  /// No description provided for @terminal_uploadFile.
  ///
  /// In zh, this message translates to:
  /// **'上传文件'**
  String get terminal_uploadFile;

  /// No description provided for @terminal_uploading.
  ///
  /// In zh, this message translates to:
  /// **'正在上传 {name}...'**
  String terminal_uploading(String name);

  /// No description provided for @terminal_uploadComplete.
  ///
  /// In zh, this message translates to:
  /// **'上传完成'**
  String get terminal_uploadComplete;

  /// No description provided for @terminal_uploadFailed.
  ///
  /// In zh, this message translates to:
  /// **'上传失败：{error}'**
  String terminal_uploadFailed(String error);

  /// No description provided for @terminal_remotePath.
  ///
  /// In zh, this message translates to:
  /// **'远程路径'**
  String get terminal_remotePath;

  /// No description provided for @terminal_copyPath.
  ///
  /// In zh, this message translates to:
  /// **'复制路径'**
  String get terminal_copyPath;

  /// No description provided for @terminal_pasteToTerminal.
  ///
  /// In zh, this message translates to:
  /// **'粘贴到终端'**
  String get terminal_pasteToTerminal;

  /// No description provided for @terminal_pathCopied.
  ///
  /// In zh, this message translates to:
  /// **'路径已复制'**
  String get terminal_pathCopied;

  /// No description provided for @terminal_uploadTarget.
  ///
  /// In zh, this message translates to:
  /// **'上传到'**
  String get terminal_uploadTarget;

  /// No description provided for @terminal_connectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get terminal_connectionFailed;

  /// No description provided for @terminal_connectionFailedHint.
  ///
  /// In zh, this message translates to:
  /// **'按关闭按钮关闭此标签页，或从主机列表重新连接。'**
  String get terminal_connectionFailedHint;

  /// No description provided for @terminal_errorTimeout.
  ///
  /// In zh, this message translates to:
  /// **'连接超时，请检查主机地址和端口是否正确，以及网络是否可达。'**
  String get terminal_errorTimeout;

  /// No description provided for @terminal_errorRefused.
  ///
  /// In zh, this message translates to:
  /// **'无法连接到主机，请确认主机地址、端口是否正确，以及目标主机是否已开启 SSH 服务。'**
  String get terminal_errorRefused;

  /// No description provided for @terminal_errorAuth.
  ///
  /// In zh, this message translates to:
  /// **'认证失败，请检查用户名、密码或 SSH 密钥是否正确。'**
  String get terminal_errorAuth;

  /// No description provided for @terminal_errorHostKey.
  ///
  /// In zh, this message translates to:
  /// **'主机密钥验证失败，目标主机的密钥可能已变更。'**
  String get terminal_errorHostKey;

  /// No description provided for @terminal_errorNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络不可达，请检查设备的网络连接。'**
  String get terminal_errorNetwork;

  /// No description provided for @terminal_errorDns.
  ///
  /// In zh, this message translates to:
  /// **'域名解析失败，请检查主机地址是否正确。'**
  String get terminal_errorDns;

  /// No description provided for @toolbar_customize.
  ///
  /// In zh, this message translates to:
  /// **'自定义键盘'**
  String get toolbar_customize;

  /// No description provided for @toolbar_addGroupTooltip.
  ///
  /// In zh, this message translates to:
  /// **'添加按键组'**
  String get toolbar_addGroupTooltip;

  /// No description provided for @toolbar_addGroupTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加按键组'**
  String get toolbar_addGroupTitle;

  /// No description provided for @toolbar_restoreDefaults.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认'**
  String get toolbar_restoreDefaults;

  /// No description provided for @toolbar_restoreConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认'**
  String get toolbar_restoreConfirmTitle;

  /// No description provided for @toolbar_restoreConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要恢复默认的键盘布局吗？自定义的排序和显示组数将被重置。'**
  String get toolbar_restoreConfirmContent;

  /// No description provided for @toolbar_restoreButton.
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get toolbar_restoreButton;

  /// No description provided for @toolbar_visibleGroups.
  ///
  /// In zh, this message translates to:
  /// **'显示组数'**
  String get toolbar_visibleGroups;

  /// No description provided for @toolbar_visibleGroupsHint.
  ///
  /// In zh, this message translates to:
  /// **'工具栏最多显示 {count} 组快捷键'**
  String toolbar_visibleGroupsHint(int count);

  /// No description provided for @toolbar_hidden.
  ///
  /// In zh, this message translates to:
  /// **'(隐藏)'**
  String get toolbar_hidden;

  /// No description provided for @toolbar_groupTerminalCtrl.
  ///
  /// In zh, this message translates to:
  /// **'终端控制'**
  String get toolbar_groupTerminalCtrl;

  /// No description provided for @toolbar_groupSignals.
  ///
  /// In zh, this message translates to:
  /// **'信号'**
  String get toolbar_groupSignals;

  /// No description provided for @toolbar_groupSymbols1.
  ///
  /// In zh, this message translates to:
  /// **'符号 1'**
  String get toolbar_groupSymbols1;

  /// No description provided for @toolbar_groupNavigation.
  ///
  /// In zh, this message translates to:
  /// **'导航'**
  String get toolbar_groupNavigation;

  /// No description provided for @toolbar_groupPunctuation.
  ///
  /// In zh, this message translates to:
  /// **'标点'**
  String get toolbar_groupPunctuation;

  /// No description provided for @toolbar_groupSymbols2.
  ///
  /// In zh, this message translates to:
  /// **'符号 2'**
  String get toolbar_groupSymbols2;

  /// No description provided for @toolbar_groupBrackets1.
  ///
  /// In zh, this message translates to:
  /// **'括号 1'**
  String get toolbar_groupBrackets1;

  /// No description provided for @toolbar_groupBrackets2.
  ///
  /// In zh, this message translates to:
  /// **'括号 2'**
  String get toolbar_groupBrackets2;

  /// No description provided for @toolbar_groupEditing.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get toolbar_groupEditing;

  /// No description provided for @toolbar_groupAdvanced.
  ///
  /// In zh, this message translates to:
  /// **'高级控制'**
  String get toolbar_groupAdvanced;

  /// No description provided for @toolbar_groupSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get toolbar_groupSearch;

  /// No description provided for @toolbar_groupArrows.
  ///
  /// In zh, this message translates to:
  /// **'方向键'**
  String get toolbar_groupArrows;

  /// No description provided for @toolbar_groupClipboard.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板'**
  String get toolbar_groupClipboard;

  /// No description provided for @function_tabCode.
  ///
  /// In zh, this message translates to:
  /// **'代码'**
  String get function_tabCode;

  /// No description provided for @function_tabHistory.
  ///
  /// In zh, this message translates to:
  /// **'历史'**
  String get function_tabHistory;

  /// No description provided for @function_tabHelp.
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get function_tabHelp;

  /// No description provided for @function_tabKeyboard.
  ///
  /// In zh, this message translates to:
  /// **'键盘'**
  String get function_tabKeyboard;

  /// No description provided for @function_noActiveSession.
  ///
  /// In zh, this message translates to:
  /// **'无活动会话'**
  String get function_noActiveSession;

  /// No description provided for @function_switchToKeyboard.
  ///
  /// In zh, this message translates to:
  /// **'切换到系统键盘…'**
  String get function_switchToKeyboard;

  /// No description provided for @function_noSnippets.
  ///
  /// In zh, this message translates to:
  /// **'暂无代码片段'**
  String get function_noSnippets;

  /// No description provided for @function_noSnippetsHint.
  ///
  /// In zh, this message translates to:
  /// **'请在代码片段页面中添加'**
  String get function_noSnippetsHint;

  /// No description provided for @function_helpCtrlC.
  ///
  /// In zh, this message translates to:
  /// **'中断当前进程'**
  String get function_helpCtrlC;

  /// No description provided for @function_helpCtrlD.
  ///
  /// In zh, this message translates to:
  /// **'发送 EOF / 退出'**
  String get function_helpCtrlD;

  /// No description provided for @function_helpCtrlZ.
  ///
  /// In zh, this message translates to:
  /// **'挂起当前进程'**
  String get function_helpCtrlZ;

  /// No description provided for @function_helpCtrlL.
  ///
  /// In zh, this message translates to:
  /// **'清屏'**
  String get function_helpCtrlL;

  /// No description provided for @function_helpCtrlR.
  ///
  /// In zh, this message translates to:
  /// **'反向搜索历史'**
  String get function_helpCtrlR;

  /// No description provided for @function_helpCtrlA.
  ///
  /// In zh, this message translates to:
  /// **'光标移到行首'**
  String get function_helpCtrlA;

  /// No description provided for @function_helpCtrlE.
  ///
  /// In zh, this message translates to:
  /// **'光标移到行尾'**
  String get function_helpCtrlE;

  /// No description provided for @function_helpTab.
  ///
  /// In zh, this message translates to:
  /// **'自动补全'**
  String get function_helpTab;

  /// No description provided for @function_allShortcuts.
  ///
  /// In zh, this message translates to:
  /// **'全部快捷键'**
  String get function_allShortcuts;

  /// No description provided for @commandHistory_searchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索命令…'**
  String get commandHistory_searchHint;

  /// No description provided for @commandHistory_empty.
  ///
  /// In zh, this message translates to:
  /// **'暂无命令历史'**
  String get commandHistory_empty;

  /// No description provided for @commandHistory_noMatch.
  ///
  /// In zh, this message translates to:
  /// **'无匹配结果'**
  String get commandHistory_noMatch;

  /// No description provided for @keys_title.
  ///
  /// In zh, this message translates to:
  /// **'密钥'**
  String get keys_title;

  /// No description provided for @keys_importTooltip.
  ///
  /// In zh, this message translates to:
  /// **'导入密钥'**
  String get keys_importTooltip;

  /// No description provided for @keys_generateTooltip.
  ///
  /// In zh, this message translates to:
  /// **'生成密钥'**
  String get keys_generateTooltip;

  /// No description provided for @keys_noKeys.
  ///
  /// In zh, this message translates to:
  /// **'暂无 SSH 密钥'**
  String get keys_noKeys;

  /// No description provided for @keys_noKeysHint.
  ///
  /// In zh, this message translates to:
  /// **'生成一个密钥对用于免密码登录'**
  String get keys_noKeysHint;

  /// No description provided for @keys_generate.
  ///
  /// In zh, this message translates to:
  /// **'生成密钥'**
  String get keys_generate;

  /// No description provided for @keys_import.
  ///
  /// In zh, this message translates to:
  /// **'导入密钥'**
  String get keys_import;

  /// No description provided for @keyTile_copyPublicKey.
  ///
  /// In zh, this message translates to:
  /// **'复制公钥'**
  String get keyTile_copyPublicKey;

  /// No description provided for @keyTile_exportPrivateKey.
  ///
  /// In zh, this message translates to:
  /// **'导出私钥'**
  String get keyTile_exportPrivateKey;

  /// No description provided for @keyTile_exportPublicKey.
  ///
  /// In zh, this message translates to:
  /// **'导出公钥'**
  String get keyTile_exportPublicKey;

  /// No description provided for @keyTile_delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get keyTile_delete;

  /// No description provided for @keyTile_publicKeyCopied.
  ///
  /// In zh, this message translates to:
  /// **'公钥已复制到剪贴板'**
  String get keyTile_publicKeyCopied;

  /// No description provided for @keyTile_exportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败: {error}'**
  String keyTile_exportFailed(String error);

  /// No description provided for @keyTile_deleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除密钥'**
  String get keyTile_deleteTitle;

  /// No description provided for @keyTile_deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除「{name}」吗？'**
  String keyTile_deleteConfirm(String name);

  /// No description provided for @keyGenerate_title.
  ///
  /// In zh, this message translates to:
  /// **'生成密钥'**
  String get keyGenerate_title;

  /// No description provided for @keyGenerate_failed.
  ///
  /// In zh, this message translates to:
  /// **'密钥生成失败，请重试'**
  String get keyGenerate_failed;

  /// No description provided for @keyGenerate_doneTitle.
  ///
  /// In zh, this message translates to:
  /// **'密钥已生成'**
  String get keyGenerate_doneTitle;

  /// No description provided for @keyGenerate_doneMessage.
  ///
  /// In zh, this message translates to:
  /// **'「{name}」已成功生成。将以下公钥添加到服务器的 ~/.ssh/authorized_keys 文件中：'**
  String keyGenerate_doneMessage(String name);

  /// No description provided for @keyGenerate_fingerprint.
  ///
  /// In zh, this message translates to:
  /// **'指纹: {fingerprint}'**
  String keyGenerate_fingerprint(String fingerprint);

  /// No description provided for @keyGenerate_publicKeyCopied.
  ///
  /// In zh, this message translates to:
  /// **'公钥已复制'**
  String get keyGenerate_publicKeyCopied;

  /// No description provided for @keyGenerate_copyPublicKey.
  ///
  /// In zh, this message translates to:
  /// **'复制公钥'**
  String get keyGenerate_copyPublicKey;

  /// No description provided for @keyGenerate_done.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get keyGenerate_done;

  /// No description provided for @keyGenerate_sectionName.
  ///
  /// In zh, this message translates to:
  /// **'密钥名称'**
  String get keyGenerate_sectionName;

  /// No description provided for @keyGenerate_nameLabel.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get keyGenerate_nameLabel;

  /// No description provided for @keyGenerate_nameHint.
  ///
  /// In zh, this message translates to:
  /// **'我的 SSH 密钥'**
  String get keyGenerate_nameHint;

  /// No description provided for @keyGenerate_nameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入密钥名称'**
  String get keyGenerate_nameRequired;

  /// No description provided for @keyGenerate_sectionPassphrase.
  ///
  /// In zh, this message translates to:
  /// **'密码短语（可选）'**
  String get keyGenerate_sectionPassphrase;

  /// No description provided for @keyGenerate_passphraseLabel.
  ///
  /// In zh, this message translates to:
  /// **'密码短语'**
  String get keyGenerate_passphraseLabel;

  /// No description provided for @keyGenerate_passphraseHint.
  ///
  /// In zh, this message translates to:
  /// **'留空则不加密私钥'**
  String get keyGenerate_passphraseHint;

  /// No description provided for @keyGenerate_sectionType.
  ///
  /// In zh, this message translates to:
  /// **'密钥类型'**
  String get keyGenerate_sectionType;

  /// No description provided for @keyGenerate_recommended.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get keyGenerate_recommended;

  /// No description provided for @keyGenerate_ed25519Desc.
  ///
  /// In zh, this message translates to:
  /// **'更快、更安全的现代算法'**
  String get keyGenerate_ed25519Desc;

  /// No description provided for @keyGenerate_rsa2048Desc.
  ///
  /// In zh, this message translates to:
  /// **'兼容性好，适合旧系统'**
  String get keyGenerate_rsa2048Desc;

  /// No description provided for @keyGenerate_rsa4096Desc.
  ///
  /// In zh, this message translates to:
  /// **'更高安全级别，生成较慢'**
  String get keyGenerate_rsa4096Desc;

  /// No description provided for @keyGenerate_rsaWarning.
  ///
  /// In zh, this message translates to:
  /// **'RSA 密钥生成需要较长时间，请耐心等待。'**
  String get keyGenerate_rsaWarning;

  /// No description provided for @keyGenerate_generating.
  ///
  /// In zh, this message translates to:
  /// **'生成中…'**
  String get keyGenerate_generating;

  /// No description provided for @keyGenerate_button.
  ///
  /// In zh, this message translates to:
  /// **'生成密钥'**
  String get keyGenerate_button;

  /// No description provided for @keyImport_title.
  ///
  /// In zh, this message translates to:
  /// **'导入密钥'**
  String get keyImport_title;

  /// No description provided for @keyImport_noFileSelected.
  ///
  /// In zh, this message translates to:
  /// **'请先选择密钥文件'**
  String get keyImport_noFileSelected;

  /// No description provided for @keyImport_noContent.
  ///
  /// In zh, this message translates to:
  /// **'请粘贴密钥内容'**
  String get keyImport_noContent;

  /// No description provided for @keyImport_success.
  ///
  /// In zh, this message translates to:
  /// **'密钥「{name}」导入成功'**
  String keyImport_success(String name);

  /// No description provided for @keyImport_formatError.
  ///
  /// In zh, this message translates to:
  /// **'密钥导入失败，请检查格式是否正确'**
  String get keyImport_formatError;

  /// No description provided for @keyImport_failed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败: {error}'**
  String keyImport_failed(String error);

  /// No description provided for @keyImport_sectionName.
  ///
  /// In zh, this message translates to:
  /// **'密钥名称'**
  String get keyImport_sectionName;

  /// No description provided for @keyImport_nameLabel.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get keyImport_nameLabel;

  /// No description provided for @keyImport_nameHint.
  ///
  /// In zh, this message translates to:
  /// **'我的 SSH 密钥'**
  String get keyImport_nameHint;

  /// No description provided for @keyImport_nameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入密钥名称'**
  String get keyImport_nameRequired;

  /// No description provided for @keyImport_sectionMethod.
  ///
  /// In zh, this message translates to:
  /// **'导入方式'**
  String get keyImport_sectionMethod;

  /// No description provided for @keyImport_fromFile.
  ///
  /// In zh, this message translates to:
  /// **'从文件导入'**
  String get keyImport_fromFile;

  /// No description provided for @keyImport_pasteKey.
  ///
  /// In zh, this message translates to:
  /// **'粘贴密钥'**
  String get keyImport_pasteKey;

  /// No description provided for @keyImport_sectionPassphrase.
  ///
  /// In zh, this message translates to:
  /// **'密码短语（可选）'**
  String get keyImport_sectionPassphrase;

  /// No description provided for @keyImport_passphraseLabel.
  ///
  /// In zh, this message translates to:
  /// **'密码短语'**
  String get keyImport_passphraseLabel;

  /// No description provided for @keyImport_passphraseHint.
  ///
  /// In zh, this message translates to:
  /// **'如果私钥有密码保护，请输入'**
  String get keyImport_passphraseHint;

  /// No description provided for @keyImport_formatHint.
  ///
  /// In zh, this message translates to:
  /// **'支持 OpenSSH 格式的私钥文件（如 id_ed25519、id_rsa）。'**
  String get keyImport_formatHint;

  /// No description provided for @keyImport_importing.
  ///
  /// In zh, this message translates to:
  /// **'导入中…'**
  String get keyImport_importing;

  /// No description provided for @keyImport_button.
  ///
  /// In zh, this message translates to:
  /// **'导入密钥'**
  String get keyImport_button;

  /// No description provided for @keyImport_selectFile.
  ///
  /// In zh, this message translates to:
  /// **'选择密钥文件'**
  String get keyImport_selectFile;

  /// No description provided for @snippets_title.
  ///
  /// In zh, this message translates to:
  /// **'代码片段'**
  String get snippets_title;

  /// No description provided for @snippets_addTooltip.
  ///
  /// In zh, this message translates to:
  /// **'添加片段'**
  String get snippets_addTooltip;

  /// No description provided for @snippets_noSnippets.
  ///
  /// In zh, this message translates to:
  /// **'暂无代码片段'**
  String get snippets_noSnippets;

  /// No description provided for @snippets_add.
  ///
  /// In zh, this message translates to:
  /// **'添加片段'**
  String get snippets_add;

  /// No description provided for @snippets_favorites.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get snippets_favorites;

  /// No description provided for @snippets_ungrouped.
  ///
  /// In zh, this message translates to:
  /// **'未分组'**
  String get snippets_ungrouped;

  /// No description provided for @snippetForm_editTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑片段'**
  String get snippetForm_editTitle;

  /// No description provided for @snippetForm_addTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加片段'**
  String get snippetForm_addTitle;

  /// No description provided for @snippetForm_deleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除片段'**
  String get snippetForm_deleteTitle;

  /// No description provided for @snippetForm_deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除「{name}」吗？'**
  String snippetForm_deleteConfirm(String name);

  /// No description provided for @snippetForm_deleteTooltip.
  ///
  /// In zh, this message translates to:
  /// **'删除片段'**
  String get snippetForm_deleteTooltip;

  /// No description provided for @snippetForm_sectionBasic.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get snippetForm_sectionBasic;

  /// No description provided for @snippetForm_nameLabel.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get snippetForm_nameLabel;

  /// No description provided for @snippetForm_nameHint.
  ///
  /// In zh, this message translates to:
  /// **'我的部署脚本'**
  String get snippetForm_nameHint;

  /// No description provided for @snippetForm_nameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入名称'**
  String get snippetForm_nameRequired;

  /// No description provided for @snippetForm_commandLabel.
  ///
  /// In zh, this message translates to:
  /// **'命令'**
  String get snippetForm_commandLabel;

  /// No description provided for @snippetForm_commandRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入命令'**
  String get snippetForm_commandRequired;

  /// No description provided for @snippetForm_sectionVariables.
  ///
  /// In zh, this message translates to:
  /// **'变量'**
  String get snippetForm_sectionVariables;

  /// No description provided for @snippetForm_variablesHint.
  ///
  /// In zh, this message translates to:
  /// **'在命令中定义变量，并在此设置默认值'**
  String get snippetForm_variablesHint;

  /// No description provided for @snippetForm_defaultValueHint.
  ///
  /// In zh, this message translates to:
  /// **'默认值（可选）'**
  String get snippetForm_defaultValueHint;

  /// No description provided for @snippetForm_variableDescLabel.
  ///
  /// In zh, this message translates to:
  /// **'{name} 的描述'**
  String snippetForm_variableDescLabel(String name);

  /// No description provided for @snippetForm_variableDescHint.
  ///
  /// In zh, this message translates to:
  /// **'描述此变量的用途（可选）'**
  String get snippetForm_variableDescHint;

  /// No description provided for @snippetForm_sectionGroup.
  ///
  /// In zh, this message translates to:
  /// **'分组与标签'**
  String get snippetForm_sectionGroup;

  /// No description provided for @snippetForm_groupLabel.
  ///
  /// In zh, this message translates to:
  /// **'分组'**
  String get snippetForm_groupLabel;

  /// No description provided for @snippetForm_groupHint.
  ///
  /// In zh, this message translates to:
  /// **'DevOps（可选）'**
  String get snippetForm_groupHint;

  /// No description provided for @snippetForm_tagsLabel.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get snippetForm_tagsLabel;

  /// No description provided for @snippetForm_tagsHint.
  ///
  /// In zh, this message translates to:
  /// **'deploy, k8s（逗号分隔）'**
  String get snippetForm_tagsHint;

  /// No description provided for @snippetExecute_selectTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择片段'**
  String get snippetExecute_selectTitle;

  /// No description provided for @snippetExecute_searchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索片段...'**
  String get snippetExecute_searchHint;

  /// No description provided for @snippetExecute_noSnippets.
  ///
  /// In zh, this message translates to:
  /// **'暂无代码片段'**
  String get snippetExecute_noSnippets;

  /// No description provided for @snippetExecute_noMatch.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配片段'**
  String get snippetExecute_noMatch;

  /// No description provided for @snippetExecute_fillVariables.
  ///
  /// In zh, this message translates to:
  /// **'填写变量 — {name}'**
  String snippetExecute_fillVariables(String name);

  /// No description provided for @snippetExecute_execute.
  ///
  /// In zh, this message translates to:
  /// **'执行'**
  String get snippetExecute_execute;

  /// No description provided for @forwarding_title.
  ///
  /// In zh, this message translates to:
  /// **'端口转发'**
  String get forwarding_title;

  /// No description provided for @forwarding_addTooltip.
  ///
  /// In zh, this message translates to:
  /// **'添加转发'**
  String get forwarding_addTooltip;

  /// No description provided for @forwarding_noForwards.
  ///
  /// In zh, this message translates to:
  /// **'暂无端口转发'**
  String get forwarding_noForwards;

  /// No description provided for @forwarding_add.
  ///
  /// In zh, this message translates to:
  /// **'添加转发'**
  String get forwarding_add;

  /// No description provided for @forwarding_startFromTerminal.
  ///
  /// In zh, this message translates to:
  /// **'请从终端会话中启动转发'**
  String get forwarding_startFromTerminal;

  /// No description provided for @forwarding_stop.
  ///
  /// In zh, this message translates to:
  /// **'停止'**
  String get forwarding_stop;

  /// No description provided for @forwarding_start.
  ///
  /// In zh, this message translates to:
  /// **'启动'**
  String get forwarding_start;

  /// No description provided for @forwarding_autoStart.
  ///
  /// In zh, this message translates to:
  /// **'自动启动'**
  String get forwarding_autoStart;

  /// No description provided for @forwardForm_editTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑转发'**
  String get forwardForm_editTitle;

  /// No description provided for @forwardForm_addTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加转发'**
  String get forwardForm_addTitle;

  /// No description provided for @forwardForm_deleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除转发'**
  String get forwardForm_deleteTitle;

  /// No description provided for @forwardForm_deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除「{name}」吗？'**
  String forwardForm_deleteConfirm(String name);

  /// No description provided for @forwardForm_deleteTooltip.
  ///
  /// In zh, this message translates to:
  /// **'删除转发'**
  String get forwardForm_deleteTooltip;

  /// No description provided for @forwardForm_sectionBasic.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get forwardForm_sectionBasic;

  /// No description provided for @forwardForm_nameLabel.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get forwardForm_nameLabel;

  /// No description provided for @forwardForm_nameHint.
  ///
  /// In zh, this message translates to:
  /// **'数据库隧道'**
  String get forwardForm_nameHint;

  /// No description provided for @forwardForm_nameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入名称'**
  String get forwardForm_nameRequired;

  /// No description provided for @forwardForm_sectionType.
  ///
  /// In zh, this message translates to:
  /// **'转发类型'**
  String get forwardForm_sectionType;

  /// No description provided for @forwardForm_sectionPorts.
  ///
  /// In zh, this message translates to:
  /// **'端口配置'**
  String get forwardForm_sectionPorts;

  /// No description provided for @forwardForm_localPort.
  ///
  /// In zh, this message translates to:
  /// **'本地端口'**
  String get forwardForm_localPort;

  /// No description provided for @forwardForm_portInvalid.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效端口 (1-65535)'**
  String get forwardForm_portInvalid;

  /// No description provided for @forwardForm_remoteHost.
  ///
  /// In zh, this message translates to:
  /// **'远程主机'**
  String get forwardForm_remoteHost;

  /// No description provided for @forwardForm_remoteHostRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入远程主机'**
  String get forwardForm_remoteHostRequired;

  /// No description provided for @forwardForm_remotePort.
  ///
  /// In zh, this message translates to:
  /// **'远程端口'**
  String get forwardForm_remotePort;

  /// No description provided for @forwardForm_bindAddress.
  ///
  /// In zh, this message translates to:
  /// **'绑定地址'**
  String get forwardForm_bindAddress;

  /// No description provided for @forwardForm_bindAddressRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入绑定地址'**
  String get forwardForm_bindAddressRequired;

  /// No description provided for @forwardForm_typeHelpTitle.
  ///
  /// In zh, this message translates to:
  /// **'转发类型说明'**
  String get forwardForm_typeHelpTitle;

  /// No description provided for @forwardForm_typeHelpLocal.
  ///
  /// In zh, this message translates to:
  /// **'将本地端口映射到远程地址，通过 SSH 隧道访问远程服务（如数据库、内部 API），就像它们运行在本地一样。\n示例：本地端口 3306 → 远程 db.internal:3306'**
  String get forwardForm_typeHelpLocal;

  /// No description provided for @forwardForm_typeHelpRemote.
  ///
  /// In zh, this message translates to:
  /// **'将本地服务暴露给远程服务器，让远程主机能够访问你设备上运行的服务。\n示例：远程端口 8080 → 本地 127.0.0.1:3000'**
  String get forwardForm_typeHelpRemote;

  /// No description provided for @forwardForm_typeHelpDynamic.
  ///
  /// In zh, this message translates to:
  /// **'在本地端口创建 SOCKS5 代理，所有通过该代理的流量都会经由 SSH 服务器转发。适用于通过单个端口浏览网页或访问多个远程资源。'**
  String get forwardForm_typeHelpDynamic;

  /// No description provided for @forwardForm_sectionOptions.
  ///
  /// In zh, this message translates to:
  /// **'选项'**
  String get forwardForm_sectionOptions;

  /// No description provided for @forwardForm_autoStart.
  ///
  /// In zh, this message translates to:
  /// **'自动启动'**
  String get forwardForm_autoStart;

  /// No description provided for @forwardForm_autoStartHint.
  ///
  /// In zh, this message translates to:
  /// **'连接到主机时自动开启此转发'**
  String get forwardForm_autoStartHint;

  /// No description provided for @forwardForm_noHosts.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用主机，请先添加主机'**
  String get forwardForm_noHosts;

  /// No description provided for @forwardForm_hostLabel.
  ///
  /// In zh, this message translates to:
  /// **'主机'**
  String get forwardForm_hostLabel;

  /// No description provided for @forwardForm_hostRequired.
  ///
  /// In zh, this message translates to:
  /// **'请选择主机'**
  String get forwardForm_hostRequired;

  /// No description provided for @forwardForm_hostLoadError.
  ///
  /// In zh, this message translates to:
  /// **'加载主机失败: {error}'**
  String forwardForm_hostLoadError(String error);

  /// No description provided for @portDetect_title.
  ///
  /// In zh, this message translates to:
  /// **'端口探测'**
  String get portDetect_title;

  /// No description provided for @portDetect_tooltip.
  ///
  /// In zh, this message translates to:
  /// **'探测远程端口'**
  String get portDetect_tooltip;

  /// No description provided for @portDetect_noSessions.
  ///
  /// In zh, this message translates to:
  /// **'暂无活跃的 SSH 会话，请先连接主机'**
  String get portDetect_noSessions;

  /// No description provided for @portDetect_scanning.
  ///
  /// In zh, this message translates to:
  /// **'正在扫描远程端口…'**
  String get portDetect_scanning;

  /// No description provided for @portDetect_scanButton.
  ///
  /// In zh, this message translates to:
  /// **'扫描'**
  String get portDetect_scanButton;

  /// No description provided for @portDetect_rescanButton.
  ///
  /// In zh, this message translates to:
  /// **'重新扫描'**
  String get portDetect_rescanButton;

  /// No description provided for @portDetect_noPorts.
  ///
  /// In zh, this message translates to:
  /// **'未检测到监听端口'**
  String get portDetect_noPorts;

  /// No description provided for @portDetect_portsFound.
  ///
  /// In zh, this message translates to:
  /// **'检测到 {count} 个监听端口'**
  String portDetect_portsFound(int count);

  /// No description provided for @portDetect_alreadyForwarded.
  ///
  /// In zh, this message translates to:
  /// **'已转发'**
  String get portDetect_alreadyForwarded;

  /// No description provided for @portDetect_addForward.
  ///
  /// In zh, this message translates to:
  /// **'添加转发'**
  String get portDetect_addForward;

  /// No description provided for @portDetect_systemPorts.
  ///
  /// In zh, this message translates to:
  /// **'系统端口'**
  String get portDetect_systemPorts;

  /// No description provided for @portDetect_userPorts.
  ///
  /// In zh, this message translates to:
  /// **'用户端口'**
  String get portDetect_userPorts;

  /// No description provided for @portDetect_unknownProcess.
  ///
  /// In zh, this message translates to:
  /// **'未知进程'**
  String get portDetect_unknownProcess;

  /// No description provided for @portDetect_permissionHint.
  ///
  /// In zh, this message translates to:
  /// **'部分进程名需要 root 权限才能显示'**
  String get portDetect_permissionHint;

  /// No description provided for @portDetect_error.
  ///
  /// In zh, this message translates to:
  /// **'扫描失败: {error}'**
  String portDetect_error(String error);

  /// No description provided for @portDetect_selectSession.
  ///
  /// In zh, this message translates to:
  /// **'选择会话'**
  String get portDetect_selectSession;

  /// No description provided for @portDetect_search.
  ///
  /// In zh, this message translates to:
  /// **'搜索端口、进程...'**
  String get portDetect_search;

  /// No description provided for @sftp_copy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get sftp_copy;

  /// No description provided for @sftp_rename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get sftp_rename;

  /// No description provided for @sftp_download.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get sftp_download;

  /// No description provided for @sftp_copyPath.
  ///
  /// In zh, this message translates to:
  /// **'复制路径'**
  String get sftp_copyPath;

  /// No description provided for @sftp_pathCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制路径: {path}'**
  String sftp_pathCopied(String path);

  /// No description provided for @sftp_copied.
  ///
  /// In zh, this message translates to:
  /// **'已复制，前往目标文件夹粘贴'**
  String get sftp_copied;

  /// No description provided for @sftp_deleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get sftp_deleteConfirmTitle;

  /// No description provided for @sftp_deleteConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除 \"{name}\" 吗？'**
  String sftp_deleteConfirmContent(String name);

  /// No description provided for @sftp_renameTitle.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get sftp_renameTitle;

  /// No description provided for @sftp_renameLabel.
  ///
  /// In zh, this message translates to:
  /// **'新名称'**
  String get sftp_renameLabel;

  /// No description provided for @sftp_newFolderTitle.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹'**
  String get sftp_newFolderTitle;

  /// No description provided for @sftp_newFolderLabel.
  ///
  /// In zh, this message translates to:
  /// **'文件夹名称'**
  String get sftp_newFolderLabel;

  /// No description provided for @sftp_sortTitle.
  ///
  /// In zh, this message translates to:
  /// **'排序方式'**
  String get sftp_sortTitle;

  /// No description provided for @sftp_sortByName.
  ///
  /// In zh, this message translates to:
  /// **'按名称'**
  String get sftp_sortByName;

  /// No description provided for @sftp_sortBySize.
  ///
  /// In zh, this message translates to:
  /// **'按大小'**
  String get sftp_sortBySize;

  /// No description provided for @sftp_sortByDate.
  ///
  /// In zh, this message translates to:
  /// **'按日期'**
  String get sftp_sortByDate;

  /// No description provided for @sftp_sortByType.
  ///
  /// In zh, this message translates to:
  /// **'按类型'**
  String get sftp_sortByType;

  /// No description provided for @sftp_connectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败: {error}'**
  String sftp_connectionFailed(String error);

  /// No description provided for @sftp_paste.
  ///
  /// In zh, this message translates to:
  /// **'粘贴'**
  String get sftp_paste;

  /// No description provided for @sftp_showHidden.
  ///
  /// In zh, this message translates to:
  /// **'显示隐藏文件'**
  String get sftp_showHidden;

  /// No description provided for @sftp_hideHidden.
  ///
  /// In zh, this message translates to:
  /// **'隐藏隐藏文件'**
  String get sftp_hideHidden;

  /// No description provided for @sftp_upload.
  ///
  /// In zh, this message translates to:
  /// **'上传'**
  String get sftp_upload;

  /// No description provided for @sftp_newFolder.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹'**
  String get sftp_newFolder;

  /// No description provided for @sftp_sort.
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get sftp_sort;

  /// No description provided for @sftp_refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get sftp_refresh;

  /// No description provided for @sftp_view.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get sftp_view;

  /// No description provided for @sftp_viewImage.
  ///
  /// In zh, this message translates to:
  /// **'查看图片'**
  String get sftp_viewImage;

  /// No description provided for @sftp_edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get sftp_edit;

  /// No description provided for @sftp_permissions.
  ///
  /// In zh, this message translates to:
  /// **'权限'**
  String get sftp_permissions;

  /// No description provided for @sftp_goToPath.
  ///
  /// In zh, this message translates to:
  /// **'跳转路径'**
  String get sftp_goToPath;

  /// No description provided for @sftp_goToPathHint.
  ///
  /// In zh, this message translates to:
  /// **'输入远程路径'**
  String get sftp_goToPathHint;

  /// No description provided for @sftp_noFiles.
  ///
  /// In zh, this message translates to:
  /// **'无文件'**
  String get sftp_noFiles;

  /// No description provided for @fileEditor_fileSaved.
  ///
  /// In zh, this message translates to:
  /// **'文件已保存'**
  String get fileEditor_fileSaved;

  /// No description provided for @fileEditor_saveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败: {error}'**
  String fileEditor_saveFailed(String error);

  /// No description provided for @fileEditor_editMode.
  ///
  /// In zh, this message translates to:
  /// **'编辑模式'**
  String get fileEditor_editMode;

  /// No description provided for @fileEditor_previewMode.
  ///
  /// In zh, this message translates to:
  /// **'预览模式'**
  String get fileEditor_previewMode;

  /// No description provided for @fileEditor_save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get fileEditor_save;

  /// No description provided for @fileEditor_loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载文件失败: {error}'**
  String fileEditor_loadFailed(String error);

  /// No description provided for @fileEditor_modified.
  ///
  /// In zh, this message translates to:
  /// **'已修改'**
  String get fileEditor_modified;

  /// No description provided for @fileEditor_renderMarkdown.
  ///
  /// In zh, this message translates to:
  /// **'渲染 Markdown'**
  String get fileEditor_renderMarkdown;

  /// No description provided for @fileEditor_markdownSource.
  ///
  /// In zh, this message translates to:
  /// **'查看源码'**
  String get fileEditor_markdownSource;

  /// No description provided for @fileEditor_toc.
  ///
  /// In zh, this message translates to:
  /// **'目录'**
  String get fileEditor_toc;

  /// No description provided for @transfer_title.
  ///
  /// In zh, this message translates to:
  /// **'传输 ({count})'**
  String transfer_title(int count);

  /// No description provided for @transfer_clearDone.
  ///
  /// In zh, this message translates to:
  /// **'清除完成'**
  String get transfer_clearDone;

  /// No description provided for @transfer_more.
  ///
  /// In zh, this message translates to:
  /// **'+{count} 更多'**
  String transfer_more(int count);

  /// No description provided for @transfer_queued.
  ///
  /// In zh, this message translates to:
  /// **'排队中'**
  String get transfer_queued;

  /// No description provided for @permission_title.
  ///
  /// In zh, this message translates to:
  /// **'修改权限'**
  String get permission_title;

  /// No description provided for @permission_octalLabel.
  ///
  /// In zh, this message translates to:
  /// **'八进制 (例如 644)'**
  String get permission_octalLabel;

  /// No description provided for @permission_apply.
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get permission_apply;

  /// No description provided for @settings_title.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings_title;

  /// No description provided for @settings_sectionGeneral.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settings_sectionGeneral;

  /// No description provided for @settings_theme.
  ///
  /// In zh, this message translates to:
  /// **'外观主题'**
  String get settings_theme;

  /// No description provided for @settings_language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settings_language;

  /// No description provided for @settings_languageChinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get settings_languageChinese;

  /// No description provided for @settings_languageEnglish.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get settings_languageEnglish;

  /// No description provided for @settings_languageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settings_languageSystem;

  /// No description provided for @settings_sectionTerminal.
  ///
  /// In zh, this message translates to:
  /// **'终端'**
  String get settings_sectionTerminal;

  /// No description provided for @settings_cursorStyle.
  ///
  /// In zh, this message translates to:
  /// **'光标样式'**
  String get settings_cursorStyle;

  /// No description provided for @settings_hapticFeedback.
  ///
  /// In zh, this message translates to:
  /// **'触觉反馈'**
  String get settings_hapticFeedback;

  /// No description provided for @settings_voiceLocale.
  ///
  /// In zh, this message translates to:
  /// **'语音输入语言'**
  String get settings_voiceLocale;

  /// No description provided for @settings_voiceLocaleSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settings_voiceLocaleSystem;

  /// No description provided for @settings_selectVoiceLocale.
  ///
  /// In zh, this message translates to:
  /// **'选择语音输入语言'**
  String get settings_selectVoiceLocale;

  /// No description provided for @settings_sectionSecurity.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get settings_sectionSecurity;

  /// No description provided for @settings_biometric.
  ///
  /// In zh, this message translates to:
  /// **'生物识别解锁'**
  String get settings_biometric;

  /// No description provided for @settings_autoLock.
  ///
  /// In zh, this message translates to:
  /// **'自动锁定时间'**
  String get settings_autoLock;

  /// No description provided for @settings_clipboardAutoClear.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板自动清除'**
  String get settings_clipboardAutoClear;

  /// No description provided for @settings_clipboardAutoClearHint.
  ///
  /// In zh, this message translates to:
  /// **'退出应用后自动清除剪贴板'**
  String get settings_clipboardAutoClearHint;

  /// No description provided for @settings_sectionSync.
  ///
  /// In zh, this message translates to:
  /// **'同步'**
  String get settings_sectionSync;

  /// No description provided for @settings_account.
  ///
  /// In zh, this message translates to:
  /// **'账户'**
  String get settings_account;

  /// No description provided for @settings_loggedIn.
  ///
  /// In zh, this message translates to:
  /// **'已登录'**
  String get settings_loggedIn;

  /// No description provided for @settings_deviceManagement.
  ///
  /// In zh, this message translates to:
  /// **'设备管理'**
  String get settings_deviceManagement;

  /// No description provided for @settings_syncNow.
  ///
  /// In zh, this message translates to:
  /// **'立即同步'**
  String get settings_syncNow;

  /// No description provided for @settings_logout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get settings_logout;

  /// No description provided for @settings_loginRegister.
  ///
  /// In zh, this message translates to:
  /// **'登录 / 注册'**
  String get settings_loginRegister;

  /// No description provided for @settings_loginHint.
  ///
  /// In zh, this message translates to:
  /// **'登录以同步您的数据'**
  String get settings_loginHint;

  /// No description provided for @settings_sectionData.
  ///
  /// In zh, this message translates to:
  /// **'数据'**
  String get settings_sectionData;

  /// No description provided for @settings_importSshConfig.
  ///
  /// In zh, this message translates to:
  /// **'导入 SSH 配置'**
  String get settings_importSshConfig;

  /// No description provided for @settings_importSshConfigHint.
  ///
  /// In zh, this message translates to:
  /// **'从 ~/.ssh/config 文件导入'**
  String get settings_importSshConfigHint;

  /// No description provided for @settings_exportData.
  ///
  /// In zh, this message translates to:
  /// **'导出数据'**
  String get settings_exportData;

  /// No description provided for @settings_exportDataHint.
  ///
  /// In zh, this message translates to:
  /// **'将所有数据导出为 JSON 文件'**
  String get settings_exportDataHint;

  /// No description provided for @settings_sectionAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settings_sectionAbout;

  /// No description provided for @settings_version.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get settings_version;

  /// No description provided for @settings_themeGroupDark.
  ///
  /// In zh, this message translates to:
  /// **'暗色'**
  String get settings_themeGroupDark;

  /// No description provided for @settings_themeGroupLight.
  ///
  /// In zh, this message translates to:
  /// **'亮色'**
  String get settings_themeGroupLight;

  /// No description provided for @settings_cursorBlock.
  ///
  /// In zh, this message translates to:
  /// **'块状'**
  String get settings_cursorBlock;

  /// No description provided for @settings_cursorUnderline.
  ///
  /// In zh, this message translates to:
  /// **'下划线'**
  String get settings_cursorUnderline;

  /// No description provided for @settings_cursorBar.
  ///
  /// In zh, this message translates to:
  /// **'竖线'**
  String get settings_cursorBar;

  /// No description provided for @settings_autoLockNever.
  ///
  /// In zh, this message translates to:
  /// **'从不'**
  String get settings_autoLockNever;

  /// No description provided for @settings_autoLockOneMinute.
  ///
  /// In zh, this message translates to:
  /// **'1 分钟'**
  String get settings_autoLockOneMinute;

  /// No description provided for @settings_autoLockMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{minutes} 分钟'**
  String settings_autoLockMinutes(int minutes);

  /// No description provided for @settings_fontSize.
  ///
  /// In zh, this message translates to:
  /// **'字体大小'**
  String get settings_fontSize;

  /// No description provided for @settings_fontFamily.
  ///
  /// In zh, this message translates to:
  /// **'字体'**
  String get settings_fontFamily;

  /// No description provided for @settings_selectFontFamily.
  ///
  /// In zh, this message translates to:
  /// **'选择字体'**
  String get settings_selectFontFamily;

  /// No description provided for @settings_scrollbackLines.
  ///
  /// In zh, this message translates to:
  /// **'回滚行数'**
  String get settings_scrollbackLines;

  /// No description provided for @settings_selectScrollbackLines.
  ///
  /// In zh, this message translates to:
  /// **'选择回滚行数'**
  String get settings_selectScrollbackLines;

  /// No description provided for @settings_scrollbackLinesSuffix.
  ///
  /// In zh, this message translates to:
  /// **'行'**
  String get settings_scrollbackLinesSuffix;

  /// No description provided for @settings_selectTheme.
  ///
  /// In zh, this message translates to:
  /// **'选择主题'**
  String get settings_selectTheme;

  /// No description provided for @settings_selectCursorStyle.
  ///
  /// In zh, this message translates to:
  /// **'选择光标样式'**
  String get settings_selectCursorStyle;

  /// No description provided for @settings_selectAutoLock.
  ///
  /// In zh, this message translates to:
  /// **'自动锁定时间'**
  String get settings_selectAutoLock;

  /// No description provided for @settings_deviceManagementTitle.
  ///
  /// In zh, this message translates to:
  /// **'设备管理'**
  String get settings_deviceManagementTitle;

  /// No description provided for @settings_deviceManagementContent.
  ///
  /// In zh, this message translates to:
  /// **'设备管理功能即将推出。'**
  String get settings_deviceManagementContent;

  /// No description provided for @settings_syncing.
  ///
  /// In zh, this message translates to:
  /// **'正在同步...'**
  String get settings_syncing;

  /// No description provided for @settings_logoutTitle.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get settings_logoutTitle;

  /// No description provided for @settings_logoutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出登录吗？'**
  String get settings_logoutConfirm;

  /// No description provided for @settings_logoutButton.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get settings_logoutButton;

  /// No description provided for @settings_importedCount.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 个主机'**
  String settings_importedCount(int count);

  /// No description provided for @settings_importFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败: {error}'**
  String settings_importFailed(String error);

  /// No description provided for @settings_exportTitle.
  ///
  /// In zh, this message translates to:
  /// **'导出数据'**
  String get settings_exportTitle;

  /// No description provided for @settings_exportContent.
  ///
  /// In zh, this message translates to:
  /// **'将所有主机、密钥和片段数据导出为 JSON 文件。'**
  String get settings_exportContent;

  /// No description provided for @settings_exported.
  ///
  /// In zh, this message translates to:
  /// **'数据已导出'**
  String get settings_exported;

  /// No description provided for @settings_exportButton.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get settings_exportButton;

  /// No description provided for @settings_loginTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get settings_loginTitle;

  /// No description provided for @settings_registerTitle.
  ///
  /// In zh, this message translates to:
  /// **'注册账户'**
  String get settings_registerTitle;

  /// No description provided for @settings_emailLabel.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get settings_emailLabel;

  /// No description provided for @settings_passwordLabel.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get settings_passwordLabel;

  /// No description provided for @settings_switchToLogin.
  ///
  /// In zh, this message translates to:
  /// **'已有账户？登录'**
  String get settings_switchToLogin;

  /// No description provided for @settings_switchToRegister.
  ///
  /// In zh, this message translates to:
  /// **'没有账户？注册'**
  String get settings_switchToRegister;

  /// No description provided for @settings_registerButton.
  ///
  /// In zh, this message translates to:
  /// **'注册'**
  String get settings_registerButton;

  /// No description provided for @settings_loginButton.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get settings_loginButton;

  /// No description provided for @lock_locked.
  ///
  /// In zh, this message translates to:
  /// **'已锁定'**
  String get lock_locked;

  /// No description provided for @lock_unlock.
  ///
  /// In zh, this message translates to:
  /// **'解锁'**
  String get lock_unlock;

  /// No description provided for @lock_biometricReason.
  ///
  /// In zh, this message translates to:
  /// **'请验证身份以解锁 Nexterm'**
  String get lock_biometricReason;

  /// No description provided for @dataExport_shareText.
  ///
  /// In zh, this message translates to:
  /// **'Nexterm 加密备份'**
  String get dataExport_shareText;

  /// No description provided for @keysProvider_unsupportedKeyType.
  ///
  /// In zh, this message translates to:
  /// **'不支持的密钥类型: {type}'**
  String keysProvider_unsupportedKeyType(String type);

  /// No description provided for @keysProvider_invalidPkcs1.
  ///
  /// In zh, this message translates to:
  /// **'无效的 PKCS#1 RSA 私钥格式'**
  String get keysProvider_invalidPkcs1;

  /// No description provided for @keysProvider_invalidMagic.
  ///
  /// In zh, this message translates to:
  /// **'无效的 OpenSSH 私钥魔数'**
  String get keysProvider_invalidMagic;

  /// No description provided for @keysProvider_encryptedNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'暂不支持加密的私钥，请先解密后再导入'**
  String get keysProvider_encryptedNotSupported;

  /// No description provided for @keysProvider_singleKeyOnly.
  ///
  /// In zh, this message translates to:
  /// **'仅支持包含单个密钥的文件'**
  String get keysProvider_singleKeyOnly;

  /// No description provided for @keysProvider_unsupportedFormat.
  ///
  /// In zh, this message translates to:
  /// **'不支持的私钥格式: {format}'**
  String keysProvider_unsupportedFormat(String format);

  /// No description provided for @nav_vaults.
  ///
  /// In zh, this message translates to:
  /// **'保险库'**
  String get nav_vaults;

  /// No description provided for @nav_connections.
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get nav_connections;

  /// No description provided for @nav_profile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get nav_profile;

  /// No description provided for @vaults_title.
  ///
  /// In zh, this message translates to:
  /// **'个人保险库'**
  String get vaults_title;

  /// No description provided for @vaults_connections.
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get vaults_connections;

  /// No description provided for @vaults_hosts.
  ///
  /// In zh, this message translates to:
  /// **'主机'**
  String get vaults_hosts;

  /// No description provided for @vaults_tools.
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get vaults_tools;

  /// No description provided for @vaults_portForwarding.
  ///
  /// In zh, this message translates to:
  /// **'端口转发'**
  String get vaults_portForwarding;

  /// No description provided for @vaults_snippets.
  ///
  /// In zh, this message translates to:
  /// **'代码片段'**
  String get vaults_snippets;

  /// No description provided for @vaults_keychain.
  ///
  /// In zh, this message translates to:
  /// **'密钥'**
  String get vaults_keychain;

  /// No description provided for @git_title.
  ///
  /// In zh, this message translates to:
  /// **'Git'**
  String get git_title;

  /// No description provided for @git_repos.
  ///
  /// In zh, this message translates to:
  /// **'Git 仓库'**
  String get git_repos;

  /// No description provided for @git_reposEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无已保存的仓库'**
  String get git_reposEmpty;

  /// No description provided for @git_addRepo.
  ///
  /// In zh, this message translates to:
  /// **'添加仓库'**
  String get git_addRepo;

  /// No description provided for @git_editRepo.
  ///
  /// In zh, this message translates to:
  /// **'编辑仓库'**
  String get git_editRepo;

  /// No description provided for @git_repoLabel.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get git_repoLabel;

  /// No description provided for @git_repoLabelHint.
  ///
  /// In zh, this message translates to:
  /// **'例如: 我的项目'**
  String get git_repoLabelHint;

  /// No description provided for @git_repoPath.
  ///
  /// In zh, this message translates to:
  /// **'远程路径'**
  String get git_repoPath;

  /// No description provided for @git_repoPathHint.
  ///
  /// In zh, this message translates to:
  /// **'例如: /home/user/project'**
  String get git_repoPathHint;

  /// No description provided for @git_selectHost.
  ///
  /// In zh, this message translates to:
  /// **'选择主机'**
  String get git_selectHost;

  /// No description provided for @git_tabWorkTree.
  ///
  /// In zh, this message translates to:
  /// **'工作树'**
  String get git_tabWorkTree;

  /// No description provided for @git_tabBranches.
  ///
  /// In zh, this message translates to:
  /// **'分支'**
  String get git_tabBranches;

  /// No description provided for @git_tabTags.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get git_tabTags;

  /// No description provided for @git_commits.
  ///
  /// In zh, this message translates to:
  /// **'提交'**
  String get git_commits;

  /// No description provided for @git_commitDetail.
  ///
  /// In zh, this message translates to:
  /// **'提交详情'**
  String get git_commitDetail;

  /// No description provided for @git_author.
  ///
  /// In zh, this message translates to:
  /// **'作者'**
  String get git_author;

  /// No description provided for @git_date.
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get git_date;

  /// No description provided for @git_message.
  ///
  /// In zh, this message translates to:
  /// **'提交信息'**
  String get git_message;

  /// No description provided for @git_changedFiles.
  ///
  /// In zh, this message translates to:
  /// **'变更文件'**
  String get git_changedFiles;

  /// No description provided for @git_staged.
  ///
  /// In zh, this message translates to:
  /// **'已暂存'**
  String get git_staged;

  /// No description provided for @git_unstaged.
  ///
  /// In zh, this message translates to:
  /// **'未暂存'**
  String get git_unstaged;

  /// No description provided for @git_untracked.
  ///
  /// In zh, this message translates to:
  /// **'未跟踪'**
  String get git_untracked;

  /// No description provided for @git_noChanges.
  ///
  /// In zh, this message translates to:
  /// **'工作树干净'**
  String get git_noChanges;

  /// No description provided for @git_branchGraph.
  ///
  /// In zh, this message translates to:
  /// **'分支图'**
  String get git_branchGraph;

  /// No description provided for @git_currentBranch.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get git_currentBranch;

  /// No description provided for @git_deleteBranch.
  ///
  /// In zh, this message translates to:
  /// **'删除分支'**
  String get git_deleteBranch;

  /// No description provided for @git_deleteBranchProtected.
  ///
  /// In zh, this message translates to:
  /// **'无法删除当前分支或默认分支'**
  String get git_deleteBranchProtected;

  /// No description provided for @git_deleteTag.
  ///
  /// In zh, this message translates to:
  /// **'删除标签'**
  String get git_deleteTag;

  /// No description provided for @git_deleteTagConfirm.
  ///
  /// In zh, this message translates to:
  /// **'删除标签 \"{name}\"？'**
  String git_deleteTagConfirm(String name);

  /// No description provided for @git_checkoutTag.
  ///
  /// In zh, this message translates to:
  /// **'检出'**
  String get git_checkoutTag;

  /// No description provided for @git_checkoutDirtyTitle.
  ///
  /// In zh, this message translates to:
  /// **'未提交的更改'**
  String get git_checkoutDirtyTitle;

  /// No description provided for @git_checkoutDirtyMessage.
  ///
  /// In zh, this message translates to:
  /// **'工作树有未提交的更改。是否先暂存再检出？'**
  String get git_checkoutDirtyMessage;

  /// No description provided for @git_stashAndCheckout.
  ///
  /// In zh, this message translates to:
  /// **'暂存并检出'**
  String get git_stashAndCheckout;

  /// No description provided for @git_initTitle.
  ///
  /// In zh, this message translates to:
  /// **'非 Git 仓库'**
  String get git_initTitle;

  /// No description provided for @git_initMessage.
  ///
  /// In zh, this message translates to:
  /// **'此目录不是 git 仓库。是否初始化？'**
  String get git_initMessage;

  /// No description provided for @git_initButton.
  ///
  /// In zh, this message translates to:
  /// **'初始化'**
  String get git_initButton;

  /// No description provided for @git_initConfirm.
  ///
  /// In zh, this message translates to:
  /// **'在此路径初始化 git 仓库？'**
  String get git_initConfirm;

  /// No description provided for @git_fileHistory.
  ///
  /// In zh, this message translates to:
  /// **'文件历史'**
  String get git_fileHistory;

  /// No description provided for @git_diff.
  ///
  /// In zh, this message translates to:
  /// **'差异'**
  String get git_diff;

  /// No description provided for @git_additions.
  ///
  /// In zh, this message translates to:
  /// **'+{count}'**
  String git_additions(int count);

  /// No description provided for @git_deletions.
  ///
  /// In zh, this message translates to:
  /// **'-{count}'**
  String git_deletions(int count);

  /// No description provided for @git_statusModified.
  ///
  /// In zh, this message translates to:
  /// **'已修改'**
  String get git_statusModified;

  /// No description provided for @git_statusAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加'**
  String get git_statusAdded;

  /// No description provided for @git_statusDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get git_statusDeleted;

  /// No description provided for @git_statusRenamed.
  ///
  /// In zh, this message translates to:
  /// **'已重命名'**
  String get git_statusRenamed;

  /// No description provided for @git_statusUntracked.
  ///
  /// In zh, this message translates to:
  /// **'未跟踪'**
  String get git_statusUntracked;

  /// No description provided for @git_noBranches.
  ///
  /// In zh, this message translates to:
  /// **'暂无分支'**
  String get git_noBranches;

  /// No description provided for @git_noTags.
  ///
  /// In zh, this message translates to:
  /// **'暂无标签'**
  String get git_noTags;

  /// No description provided for @git_noCommits.
  ///
  /// In zh, this message translates to:
  /// **'暂无提交'**
  String get git_noCommits;

  /// No description provided for @git_openGit.
  ///
  /// In zh, this message translates to:
  /// **'打开 Git'**
  String get git_openGit;

  /// No description provided for @git_connecting.
  ///
  /// In zh, this message translates to:
  /// **'连接中...'**
  String get git_connecting;

  /// No description provided for @git_search.
  ///
  /// In zh, this message translates to:
  /// **'搜索仓库、路径...'**
  String get git_search;

  /// No description provided for @webdav_title.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV'**
  String get webdav_title;

  /// No description provided for @webdav_add.
  ///
  /// In zh, this message translates to:
  /// **'添加连接'**
  String get webdav_add;

  /// No description provided for @webdav_noConnections.
  ///
  /// In zh, this message translates to:
  /// **'暂无 WebDAV 连接'**
  String get webdav_noConnections;

  /// No description provided for @webdav_noConnectionsHint.
  ///
  /// In zh, this message translates to:
  /// **'添加 WebDAV 服务器以浏览远程文件'**
  String get webdav_noConnectionsHint;

  /// No description provided for @webdav_name.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get webdav_name;

  /// No description provided for @webdav_nameHint.
  ///
  /// In zh, this message translates to:
  /// **'我的 WebDAV 服务器'**
  String get webdav_nameHint;

  /// No description provided for @webdav_nameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入名称'**
  String get webdav_nameRequired;

  /// No description provided for @webdav_url.
  ///
  /// In zh, this message translates to:
  /// **'URL'**
  String get webdav_url;

  /// No description provided for @webdav_urlHint.
  ///
  /// In zh, this message translates to:
  /// **'https://dav.example.com/remote.php/dav/files/user'**
  String get webdav_urlHint;

  /// No description provided for @webdav_urlRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入 URL'**
  String get webdav_urlRequired;

  /// No description provided for @webdav_username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get webdav_username;

  /// No description provided for @webdav_password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get webdav_password;

  /// No description provided for @webdav_connect.
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get webdav_connect;

  /// No description provided for @webdav_connectFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败: {error}'**
  String webdav_connectFailed(String error);

  /// No description provided for @webdav_deleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除连接'**
  String get webdav_deleteTitle;

  /// No description provided for @webdav_deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除「{name}」吗？'**
  String webdav_deleteConfirm(String name);

  /// No description provided for @webdav_editTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑连接'**
  String get webdav_editTitle;

  /// No description provided for @webdav_addTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加连接'**
  String get webdav_addTitle;

  /// No description provided for @webdav_search.
  ///
  /// In zh, this message translates to:
  /// **'搜索连接、URL...'**
  String get webdav_search;

  /// No description provided for @smb_title.
  ///
  /// In zh, this message translates to:
  /// **'SMB'**
  String get smb_title;

  /// No description provided for @smb_add.
  ///
  /// In zh, this message translates to:
  /// **'添加连接'**
  String get smb_add;

  /// No description provided for @smb_noConnections.
  ///
  /// In zh, this message translates to:
  /// **'暂无 SMB 连接'**
  String get smb_noConnections;

  /// No description provided for @smb_noConnectionsHint.
  ///
  /// In zh, this message translates to:
  /// **'添加 SMB/CIFS 服务器以浏览共享文件'**
  String get smb_noConnectionsHint;

  /// No description provided for @smb_name.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get smb_name;

  /// No description provided for @smb_nameHint.
  ///
  /// In zh, this message translates to:
  /// **'我的 NAS'**
  String get smb_nameHint;

  /// No description provided for @smb_nameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入名称'**
  String get smb_nameRequired;

  /// No description provided for @smb_host.
  ///
  /// In zh, this message translates to:
  /// **'服务器地址'**
  String get smb_host;

  /// No description provided for @smb_hostHint.
  ///
  /// In zh, this message translates to:
  /// **'192.168.1.100 或 nas.local'**
  String get smb_hostHint;

  /// No description provided for @smb_hostRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入服务器地址'**
  String get smb_hostRequired;

  /// No description provided for @smb_port.
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get smb_port;

  /// No description provided for @smb_shareName.
  ///
  /// In zh, this message translates to:
  /// **'共享名'**
  String get smb_shareName;

  /// No description provided for @smb_shareNameHint.
  ///
  /// In zh, this message translates to:
  /// **'public'**
  String get smb_shareNameHint;

  /// No description provided for @smb_shareNameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入共享名'**
  String get smb_shareNameRequired;

  /// No description provided for @smb_username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get smb_username;

  /// No description provided for @smb_password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get smb_password;

  /// No description provided for @smb_domain.
  ///
  /// In zh, this message translates to:
  /// **'域'**
  String get smb_domain;

  /// No description provided for @smb_domainHint.
  ///
  /// In zh, this message translates to:
  /// **'WORKGROUP'**
  String get smb_domainHint;

  /// No description provided for @smb_connect.
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get smb_connect;

  /// No description provided for @smb_connectFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败: {error}'**
  String smb_connectFailed(String error);

  /// No description provided for @smb_deleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除连接'**
  String get smb_deleteTitle;

  /// No description provided for @smb_deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除「{name}」吗？'**
  String smb_deleteConfirm(String name);

  /// No description provided for @smb_editTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑连接'**
  String get smb_editTitle;

  /// No description provided for @smb_addTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加连接'**
  String get smb_addTitle;

  /// No description provided for @smb_search.
  ///
  /// In zh, this message translates to:
  /// **'搜索连接、主机...'**
  String get smb_search;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
