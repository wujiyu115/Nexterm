// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get nav_hosts => '主机';

  @override
  String get nav_terminal => '终端';

  @override
  String get nav_keys => '密钥';

  @override
  String get nav_snippets => '片段';

  @override
  String get nav_forwarding => '转发';

  @override
  String get nav_settings => '设置';

  @override
  String get common_cancel => '取消';

  @override
  String get common_confirm => '确定';

  @override
  String get common_delete => '删除';

  @override
  String get common_save => '保存';

  @override
  String get common_retry => '重试';

  @override
  String common_error(String message) {
    return '错误: $message';
  }

  @override
  String get auth_password => '密码认证';

  @override
  String get auth_key => '密钥认证';

  @override
  String get auth_keyboardInteractive => '键盘交互';

  @override
  String get forwarding_local => '本地转发';

  @override
  String get forwarding_remote => '远程转发';

  @override
  String get forwarding_dynamic => '动态转发 (SOCKS5)';

  @override
  String get hosts_title => '主机';

  @override
  String get hosts_add => '添加主机';

  @override
  String get hosts_addTooltip => '添加主机';

  @override
  String get hosts_search => '搜索主机、IP、标签...';

  @override
  String get hosts_noHosts => '暂无主机';

  @override
  String hosts_selectedCount(int count) {
    return '已选择 $count 项';
  }

  @override
  String get hosts_selectAll => '全选';

  @override
  String get hosts_moveToGroup => '移动到组';

  @override
  String get hosts_deleteTooltip => '删除';

  @override
  String get hosts_deleteConfirm => '确认删除';

  @override
  String get hosts_deleteConfirmSingle => '确定要删除此主机吗？';

  @override
  String hosts_deleteConfirmMultiple(int count) {
    return '确定要删除选中的 $count 台主机吗？';
  }

  @override
  String get hosts_favorites => '收藏';

  @override
  String get hosts_ungrouped => '未分组';

  @override
  String get hosts_sftpConnectFailed => 'SSH 连接失败，无法打开 SFTP';

  @override
  String get hosts_newGroup => '新建分组';

  @override
  String get hosts_newGroupHint => '输入分组名称';

  @override
  String get hosts_copy => '副本';

  @override
  String get hosts_contextConnect => '连接';

  @override
  String get hosts_contextSftp => 'SFTP 连接';

  @override
  String get hosts_contextCopy => '复制';

  @override
  String get hosts_contextMoveToGroup => '移动到组';

  @override
  String get hosts_contextEdit => '编辑';

  @override
  String get hosts_contextSelect => '选中';

  @override
  String get hosts_contextDelete => '删除';

  @override
  String get hostForm_editTitle => '编辑主机';

  @override
  String get hostForm_addTitle => '添加主机';

  @override
  String get hostForm_deleteTitle => '删除主机';

  @override
  String hostForm_deleteConfirm(String name) {
    return '确定要删除「$name」吗？';
  }

  @override
  String get hostForm_deleteTooltip => '删除主机';

  @override
  String get hostForm_noJumpHosts => '没有可用的跳板机';

  @override
  String get hostForm_selectJumpHost => '选择跳板机';

  @override
  String get hostForm_sectionBasic => '基本信息';

  @override
  String get hostForm_name => '名称';

  @override
  String get hostForm_nameHint => '我的服务器';

  @override
  String get hostForm_nameRequired => '请输入名称';

  @override
  String get hostForm_host => '主机名 / IP';

  @override
  String get hostForm_hostHint => '192.168.1.1 或 example.com';

  @override
  String get hostForm_hostRequired => '请输入主机地址';

  @override
  String get hostForm_username => '用户名';

  @override
  String get hostForm_usernameRequired => '请输入用户名';

  @override
  String get hostForm_port => '端口';

  @override
  String get hostForm_portInvalid => '无效端口';

  @override
  String get hostForm_sectionAuth => '认证方式';

  @override
  String get hostForm_sectionGroup => '分组与标签';

  @override
  String get hostForm_group => '分组';

  @override
  String get hostForm_groupHint => '生产环境（可选）';

  @override
  String get hostForm_tags => '标签';

  @override
  String get hostForm_tagsHint => 'web, prod, nginx（逗号分隔）';

  @override
  String get hostForm_password => '密码';

  @override
  String get hostForm_sectionKey => '密钥';

  @override
  String hostForm_keyLoadError(String error) {
    return '加载密钥失败: $error';
  }

  @override
  String get hostForm_noKeys => '尚未添加任何 SSH 密钥，请先在\"密钥\"页面创建或导入密钥。';

  @override
  String get hostForm_selectKey => '选择密钥';

  @override
  String get hostForm_selectKeyHint => '请选择 SSH 密钥';

  @override
  String get hostForm_selectKeyRequired => '请选择一个 SSH 密钥';

  @override
  String get hostForm_sectionJumpHost => '跳板机';

  @override
  String get hostForm_noJumpHostConfigured => '未配置跳板机';

  @override
  String get hostForm_addJumpHost => '添加跳板机';

  @override
  String get terminal_connecting => '正在连接…';

  @override
  String get terminal_noTabs => '没有打开的终端';

  @override
  String get terminal_noTabsHint => '从主机列表中选择一台主机以开始连接';

  @override
  String get terminal_switchToAbc => '切换到 ABC 键盘';

  @override
  String get terminal_switchToFunction => '切换到功能面板';

  @override
  String get terminal_newTab => '新建终端';

  @override
  String get terminal_connectionFailed => '连接失败';

  @override
  String get terminal_connectionFailedHint => '按关闭按钮关闭此标签页，或从主机列表重新连接。';

  @override
  String get terminal_errorTimeout => '连接超时，请检查主机地址和端口是否正确，以及网络是否可达。';

  @override
  String get terminal_errorRefused =>
      '无法连接到主机，请确认主机地址、端口是否正确，以及目标主机是否已开启 SSH 服务。';

  @override
  String get terminal_errorAuth => '认证失败，请检查用户名、密码或 SSH 密钥是否正确。';

  @override
  String get terminal_errorHostKey => '主机密钥验证失败，目标主机的密钥可能已变更。';

  @override
  String get terminal_errorNetwork => '网络不可达，请检查设备的网络连接。';

  @override
  String get terminal_errorDns => '域名解析失败，请检查主机地址是否正确。';

  @override
  String get toolbar_customize => '自定义键盘';

  @override
  String get toolbar_addGroupTooltip => '添加按键组';

  @override
  String get toolbar_addGroupTitle => '添加按键组';

  @override
  String get toolbar_restoreDefaults => '恢复默认';

  @override
  String get toolbar_restoreConfirmTitle => '恢复默认';

  @override
  String get toolbar_restoreConfirmContent => '确定要恢复默认的键盘布局吗？自定义的排序和显示组数将被重置。';

  @override
  String get toolbar_restoreButton => '恢复';

  @override
  String get toolbar_visibleGroups => '显示组数';

  @override
  String toolbar_visibleGroupsHint(int count) {
    return '工具栏最多显示 $count 组快捷键';
  }

  @override
  String get toolbar_hidden => '(隐藏)';

  @override
  String get toolbar_groupTerminalCtrl => '终端控制';

  @override
  String get toolbar_groupSignals => '信号';

  @override
  String get toolbar_groupSymbols1 => '符号 1';

  @override
  String get toolbar_groupNavigation => '导航';

  @override
  String get toolbar_groupPunctuation => '标点';

  @override
  String get toolbar_groupSymbols2 => '符号 2';

  @override
  String get toolbar_groupBrackets1 => '括号 1';

  @override
  String get toolbar_groupBrackets2 => '括号 2';

  @override
  String get toolbar_groupEditing => '编辑';

  @override
  String get toolbar_groupAdvanced => '高级控制';

  @override
  String get toolbar_groupSearch => '搜索';

  @override
  String get toolbar_groupArrows => '方向键';

  @override
  String get toolbar_groupClipboard => '剪贴板';

  @override
  String get function_tabCode => '代码';

  @override
  String get function_tabHistory => '历史';

  @override
  String get function_tabHelp => '帮助';

  @override
  String get function_tabKeyboard => '键盘';

  @override
  String get function_noActiveSession => '无活动会话';

  @override
  String get function_switchToKeyboard => '切换到系统键盘…';

  @override
  String get function_comingSoon => '代码片段（即将推出）';

  @override
  String get function_helpCtrlC => '中断当前进程';

  @override
  String get function_helpCtrlD => '发送 EOF / 退出';

  @override
  String get function_helpCtrlZ => '挂起当前进程';

  @override
  String get function_helpCtrlL => '清屏';

  @override
  String get function_helpCtrlR => '反向搜索历史';

  @override
  String get function_helpCtrlA => '光标移到行首';

  @override
  String get function_helpCtrlE => '光标移到行尾';

  @override
  String get function_helpTab => '自动补全';

  @override
  String get commandHistory_searchHint => '搜索命令…';

  @override
  String get commandHistory_empty => '暂无命令历史';

  @override
  String get commandHistory_noMatch => '无匹配结果';

  @override
  String get keys_title => '密钥';

  @override
  String get keys_importTooltip => '导入密钥';

  @override
  String get keys_generateTooltip => '生成密钥';

  @override
  String get keys_noKeys => '暂无 SSH 密钥';

  @override
  String get keys_noKeysHint => '生成一个密钥对用于免密码登录';

  @override
  String get keys_generate => '生成密钥';

  @override
  String get keys_import => '导入密钥';

  @override
  String get keyTile_copyPublicKey => '复制公钥';

  @override
  String get keyTile_exportPrivateKey => '导出私钥';

  @override
  String get keyTile_exportPublicKey => '导出公钥';

  @override
  String get keyTile_delete => '删除';

  @override
  String get keyTile_publicKeyCopied => '公钥已复制到剪贴板';

  @override
  String keyTile_exportFailed(String error) {
    return '导出失败: $error';
  }

  @override
  String get keyTile_deleteTitle => '删除密钥';

  @override
  String keyTile_deleteConfirm(String name) {
    return '确定要删除「$name」吗？';
  }

  @override
  String get keyGenerate_title => '生成密钥';

  @override
  String get keyGenerate_failed => '密钥生成失败，请重试';

  @override
  String get keyGenerate_doneTitle => '密钥已生成';

  @override
  String keyGenerate_doneMessage(String name) {
    return '「$name」已成功生成。将以下公钥添加到服务器的 ~/.ssh/authorized_keys 文件中：';
  }

  @override
  String keyGenerate_fingerprint(String fingerprint) {
    return '指纹: $fingerprint';
  }

  @override
  String get keyGenerate_publicKeyCopied => '公钥已复制';

  @override
  String get keyGenerate_copyPublicKey => '复制公钥';

  @override
  String get keyGenerate_done => '完成';

  @override
  String get keyGenerate_sectionName => '密钥名称';

  @override
  String get keyGenerate_nameLabel => '名称';

  @override
  String get keyGenerate_nameHint => '我的 SSH 密钥';

  @override
  String get keyGenerate_nameRequired => '请输入密钥名称';

  @override
  String get keyGenerate_sectionPassphrase => '密码短语（可选）';

  @override
  String get keyGenerate_passphraseLabel => '密码短语';

  @override
  String get keyGenerate_passphraseHint => '留空则不加密私钥';

  @override
  String get keyGenerate_sectionType => '密钥类型';

  @override
  String get keyGenerate_recommended => '推荐';

  @override
  String get keyGenerate_ed25519Desc => '更快、更安全的现代算法';

  @override
  String get keyGenerate_rsa2048Desc => '兼容性好，适合旧系统';

  @override
  String get keyGenerate_rsa4096Desc => '更高安全级别，生成较慢';

  @override
  String get keyGenerate_rsaWarning => 'RSA 密钥生成需要较长时间，请耐心等待。';

  @override
  String get keyGenerate_generating => '生成中…';

  @override
  String get keyGenerate_button => '生成密钥';

  @override
  String get keyImport_title => '导入密钥';

  @override
  String get keyImport_noFileSelected => '请先选择密钥文件';

  @override
  String get keyImport_noContent => '请粘贴密钥内容';

  @override
  String keyImport_success(String name) {
    return '密钥「$name」导入成功';
  }

  @override
  String get keyImport_formatError => '密钥导入失败，请检查格式是否正确';

  @override
  String keyImport_failed(String error) {
    return '导入失败: $error';
  }

  @override
  String get keyImport_sectionName => '密钥名称';

  @override
  String get keyImport_nameLabel => '名称';

  @override
  String get keyImport_nameHint => '我的 SSH 密钥';

  @override
  String get keyImport_nameRequired => '请输入密钥名称';

  @override
  String get keyImport_sectionMethod => '导入方式';

  @override
  String get keyImport_fromFile => '从文件导入';

  @override
  String get keyImport_pasteKey => '粘贴密钥';

  @override
  String get keyImport_sectionPassphrase => '密码短语（可选）';

  @override
  String get keyImport_passphraseLabel => '密码短语';

  @override
  String get keyImport_passphraseHint => '如果私钥有密码保护，请输入';

  @override
  String get keyImport_formatHint => '支持 OpenSSH 格式的私钥文件（如 id_ed25519、id_rsa）。';

  @override
  String get keyImport_importing => '导入中…';

  @override
  String get keyImport_button => '导入密钥';

  @override
  String get keyImport_selectFile => '选择密钥文件';

  @override
  String get snippets_title => '代码片段';

  @override
  String get snippets_addTooltip => '添加片段';

  @override
  String get snippets_noSnippets => '暂无代码片段';

  @override
  String get snippets_add => '添加片段';

  @override
  String get snippets_favorites => '收藏';

  @override
  String get snippets_ungrouped => '未分组';

  @override
  String get snippetForm_editTitle => '编辑片段';

  @override
  String get snippetForm_addTitle => '添加片段';

  @override
  String get snippetForm_deleteTitle => '删除片段';

  @override
  String snippetForm_deleteConfirm(String name) {
    return '确定要删除「$name」吗？';
  }

  @override
  String get snippetForm_deleteTooltip => '删除片段';

  @override
  String get snippetForm_sectionBasic => '基本信息';

  @override
  String get snippetForm_nameLabel => '名称';

  @override
  String get snippetForm_nameHint => '我的部署脚本';

  @override
  String get snippetForm_nameRequired => '请输入名称';

  @override
  String get snippetForm_commandLabel => '命令';

  @override
  String get snippetForm_commandRequired => '请输入命令';

  @override
  String get snippetForm_sectionVariables => '变量';

  @override
  String get snippetForm_variablesHint => '在命令中定义变量，并在此设置默认值';

  @override
  String get snippetForm_defaultValueHint => '默认值（可选）';

  @override
  String snippetForm_variableDescLabel(String name) {
    return '$name 的描述';
  }

  @override
  String get snippetForm_variableDescHint => '描述此变量的用途（可选）';

  @override
  String get snippetForm_sectionGroup => '分组与标签';

  @override
  String get snippetForm_groupLabel => '分组';

  @override
  String get snippetForm_groupHint => 'DevOps（可选）';

  @override
  String get snippetForm_tagsLabel => '标签';

  @override
  String get snippetForm_tagsHint => 'deploy, k8s（逗号分隔）';

  @override
  String get snippetExecute_selectTitle => '选择片段';

  @override
  String get snippetExecute_searchHint => '搜索片段...';

  @override
  String get snippetExecute_noSnippets => '暂无代码片段';

  @override
  String get snippetExecute_noMatch => '未找到匹配片段';

  @override
  String snippetExecute_fillVariables(String name) {
    return '填写变量 — $name';
  }

  @override
  String get snippetExecute_execute => '执行';

  @override
  String get forwarding_title => '端口转发';

  @override
  String get forwarding_addTooltip => '添加转发';

  @override
  String get forwarding_noForwards => '暂无端口转发';

  @override
  String get forwarding_add => '添加转发';

  @override
  String get forwarding_startFromTerminal => '请从终端会话中启动转发';

  @override
  String get forwarding_stop => '停止';

  @override
  String get forwarding_start => '启动';

  @override
  String get forwarding_autoStart => '自动启动';

  @override
  String get forwardForm_editTitle => '编辑转发';

  @override
  String get forwardForm_addTitle => '添加转发';

  @override
  String get forwardForm_deleteTitle => '删除转发';

  @override
  String forwardForm_deleteConfirm(String name) {
    return '确定要删除「$name」吗？';
  }

  @override
  String get forwardForm_deleteTooltip => '删除转发';

  @override
  String get forwardForm_sectionBasic => '基本信息';

  @override
  String get forwardForm_nameLabel => '名称';

  @override
  String get forwardForm_nameHint => '数据库隧道';

  @override
  String get forwardForm_nameRequired => '请输入名称';

  @override
  String get forwardForm_sectionType => '转发类型';

  @override
  String get forwardForm_sectionPorts => '端口配置';

  @override
  String get forwardForm_localPort => '本地端口';

  @override
  String get forwardForm_portInvalid => '请输入有效端口 (1-65535)';

  @override
  String get forwardForm_remoteHost => '远程主机';

  @override
  String get forwardForm_remoteHostRequired => '请输入远程主机';

  @override
  String get forwardForm_remotePort => '远程端口';

  @override
  String get forwardForm_bindAddress => '绑定地址';

  @override
  String get forwardForm_bindAddressRequired => '请输入绑定地址';

  @override
  String get forwardForm_sectionOptions => '选项';

  @override
  String get forwardForm_autoStart => '自动启动';

  @override
  String get forwardForm_autoStartHint => '连接到主机时自动开启此转发';

  @override
  String get forwardForm_noHosts => '暂无可用主机，请先添加主机';

  @override
  String get forwardForm_hostLabel => '主机';

  @override
  String get forwardForm_hostRequired => '请选择主机';

  @override
  String forwardForm_hostLoadError(String error) {
    return '加载主机失败: $error';
  }

  @override
  String get sftp_copy => '复制';

  @override
  String get sftp_rename => '重命名';

  @override
  String get sftp_download => '下载';

  @override
  String get sftp_copyPath => '复制路径';

  @override
  String sftp_pathCopied(String path) {
    return '已复制路径: $path';
  }

  @override
  String get sftp_copied => '已复制，前往目标文件夹粘贴';

  @override
  String get sftp_deleteConfirmTitle => '确认删除';

  @override
  String sftp_deleteConfirmContent(String name) {
    return '确定要删除 \"$name\" 吗？';
  }

  @override
  String get sftp_renameTitle => '重命名';

  @override
  String get sftp_renameLabel => '新名称';

  @override
  String get sftp_newFolderTitle => '新建文件夹';

  @override
  String get sftp_newFolderLabel => '文件夹名称';

  @override
  String get sftp_sortTitle => '排序方式';

  @override
  String get sftp_sortByName => '按名称';

  @override
  String get sftp_sortBySize => '按大小';

  @override
  String get sftp_sortByDate => '按日期';

  @override
  String get sftp_sortByType => '按类型';

  @override
  String sftp_connectionFailed(String error) {
    return '连接失败: $error';
  }

  @override
  String get sftp_paste => '粘贴';

  @override
  String get sftp_showHidden => '显示隐藏文件';

  @override
  String get sftp_hideHidden => '隐藏隐藏文件';

  @override
  String get sftp_upload => '上传';

  @override
  String get sftp_newFolder => '新建文件夹';

  @override
  String get sftp_sort => '排序';

  @override
  String get sftp_refresh => '刷新';

  @override
  String get sftp_noFiles => '无文件';

  @override
  String get fileEditor_fileSaved => '文件已保存';

  @override
  String fileEditor_saveFailed(String error) {
    return '保存失败: $error';
  }

  @override
  String get fileEditor_editMode => '编辑模式';

  @override
  String get fileEditor_previewMode => '预览模式';

  @override
  String get fileEditor_save => '保存';

  @override
  String fileEditor_loadFailed(String error) {
    return '加载文件失败: $error';
  }

  @override
  String get fileEditor_modified => '已修改';

  @override
  String transfer_title(int count) {
    return '传输 ($count)';
  }

  @override
  String get transfer_clearDone => '清除完成';

  @override
  String transfer_more(int count) {
    return '+$count 更多';
  }

  @override
  String get transfer_queued => '排队中';

  @override
  String get permission_title => '修改权限';

  @override
  String get permission_octalLabel => '八进制 (例如 644)';

  @override
  String get permission_apply => '应用';

  @override
  String get settings_title => '设置';

  @override
  String get settings_sectionGeneral => '通用';

  @override
  String get settings_theme => '外观主题';

  @override
  String get settings_language => '语言';

  @override
  String get settings_languageChinese => '中文';

  @override
  String get settings_languageEnglish => 'English';

  @override
  String get settings_languageSystem => '跟随系统';

  @override
  String get settings_sectionTerminal => '终端';

  @override
  String get settings_terminalTheme => '终端配色方案';

  @override
  String get settings_cursorStyle => '光标样式';

  @override
  String get settings_hapticFeedback => '触觉反馈';

  @override
  String get settings_sectionSecurity => '安全';

  @override
  String get settings_biometric => '生物识别解锁';

  @override
  String get settings_autoLock => '自动锁定时间';

  @override
  String get settings_clipboardAutoClear => '剪贴板自动清除';

  @override
  String get settings_clipboardAutoClearHint => '退出应用后自动清除剪贴板';

  @override
  String get settings_sectionSync => '同步';

  @override
  String get settings_account => '账户';

  @override
  String get settings_loggedIn => '已登录';

  @override
  String get settings_deviceManagement => '设备管理';

  @override
  String get settings_syncNow => '立即同步';

  @override
  String get settings_logout => '退出登录';

  @override
  String get settings_loginRegister => '登录 / 注册';

  @override
  String get settings_loginHint => '登录以同步您的数据';

  @override
  String get settings_sectionData => '数据';

  @override
  String get settings_importSshConfig => '导入 SSH 配置';

  @override
  String get settings_importSshConfigHint => '从 ~/.ssh/config 文件导入';

  @override
  String get settings_exportData => '导出数据';

  @override
  String get settings_exportDataHint => '将所有数据导出为 JSON 文件';

  @override
  String get settings_sectionAbout => '关于';

  @override
  String get settings_version => '版本';

  @override
  String get settings_themeLight => '浅色';

  @override
  String get settings_themeDark => '深色';

  @override
  String get settings_themeSystem => '跟随系统';

  @override
  String get settings_cursorBlock => '块状';

  @override
  String get settings_cursorUnderline => '下划线';

  @override
  String get settings_cursorBar => '竖线';

  @override
  String get settings_autoLockNever => '从不';

  @override
  String get settings_autoLockOneMinute => '1 分钟';

  @override
  String settings_autoLockMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get settings_fontSize => '字体大小';

  @override
  String get settings_selectTheme => '选择主题';

  @override
  String get settings_selectTerminalTheme => '选择终端配色';

  @override
  String get settings_selectCursorStyle => '选择光标样式';

  @override
  String get settings_selectAutoLock => '自动锁定时间';

  @override
  String get settings_deviceManagementTitle => '设备管理';

  @override
  String get settings_deviceManagementContent => '设备管理功能即将推出。';

  @override
  String get settings_syncing => '正在同步...';

  @override
  String get settings_logoutTitle => '退出登录';

  @override
  String get settings_logoutConfirm => '确定要退出登录吗？';

  @override
  String get settings_logoutButton => '退出';

  @override
  String settings_importedCount(int count) {
    return '已导入 $count 个主机';
  }

  @override
  String settings_importFailed(String error) {
    return '导入失败: $error';
  }

  @override
  String get settings_exportTitle => '导出数据';

  @override
  String get settings_exportContent => '将所有主机、密钥和片段数据导出为 JSON 文件。';

  @override
  String get settings_exported => '数据已导出';

  @override
  String get settings_exportButton => '导出';

  @override
  String get settings_loginTitle => '登录';

  @override
  String get settings_registerTitle => '注册账户';

  @override
  String get settings_emailLabel => '邮箱';

  @override
  String get settings_passwordLabel => '密码';

  @override
  String get settings_switchToLogin => '已有账户？登录';

  @override
  String get settings_switchToRegister => '没有账户？注册';

  @override
  String get settings_registerButton => '注册';

  @override
  String get settings_loginButton => '登录';

  @override
  String get lock_locked => '已锁定';

  @override
  String get lock_unlock => '解锁';

  @override
  String get lock_biometricReason => '请验证身份以解锁 Nexterm';

  @override
  String get dataExport_shareText => 'Nexterm 加密备份';

  @override
  String keysProvider_unsupportedKeyType(String type) {
    return '不支持的密钥类型: $type';
  }

  @override
  String get keysProvider_invalidPkcs1 => '无效的 PKCS#1 RSA 私钥格式';

  @override
  String get keysProvider_invalidMagic => '无效的 OpenSSH 私钥魔数';

  @override
  String get keysProvider_encryptedNotSupported => '暂不支持加密的私钥，请先解密后再导入';

  @override
  String get keysProvider_singleKeyOnly => '仅支持包含单个密钥的文件';

  @override
  String keysProvider_unsupportedFormat(String format) {
    return '不支持的私钥格式: $format';
  }
}
