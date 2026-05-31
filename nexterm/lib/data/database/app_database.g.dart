// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HostsTable extends Hosts with TableInfo<$HostsTable, Host> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostnameMeta = const VerificationMeta(
    'hostname',
  );
  @override
  late final GeneratedColumn<String> hostname = GeneratedColumn<String>(
    'hostname',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(22),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authMethodMeta = const VerificationMeta(
    'authMethod',
  );
  @override
  late final GeneratedColumn<String> authMethod = GeneratedColumn<String>(
    'auth_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyIdMeta = const VerificationMeta('keyId');
  @override
  late final GeneratedColumn<String> keyId = GeneratedColumn<String>(
    'key_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupMeta = const VerificationMeta('group');
  @override
  late final GeneratedColumn<String> group = GeneratedColumn<String>(
    'group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _jumpHostsMeta = const VerificationMeta(
    'jumpHosts',
  );
  @override
  late final GeneratedColumn<String> jumpHosts = GeneratedColumn<String>(
    'jump_hosts',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _startupSnippetIdMeta = const VerificationMeta(
    'startupSnippetId',
  );
  @override
  late final GeneratedColumn<String> startupSnippetId = GeneratedColumn<String>(
    'startup_snippet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startupCommandMeta = const VerificationMeta(
    'startupCommand',
  );
  @override
  late final GeneratedColumn<String> startupCommand = GeneratedColumn<String>(
    'startup_command',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastConnectedMeta = const VerificationMeta(
    'lastConnected',
  );
  @override
  late final GeneratedColumn<DateTime> lastConnected =
      GeneratedColumn<DateTime>(
        'last_connected',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastConnectionTypeMeta =
      const VerificationMeta('lastConnectionType');
  @override
  late final GeneratedColumn<String> lastConnectionType =
      GeneratedColumn<String>(
        'last_connection_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    hostname,
    port,
    username,
    authMethod,
    password,
    keyId,
    group,
    tags,
    isFavorite,
    jumpHosts,
    startupSnippetId,
    startupCommand,
    lastConnected,
    lastConnectionType,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hosts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Host> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('hostname')) {
      context.handle(
        _hostnameMeta,
        hostname.isAcceptableOrUnknown(data['hostname']!, _hostnameMeta),
      );
    } else if (isInserting) {
      context.missing(_hostnameMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('auth_method')) {
      context.handle(
        _authMethodMeta,
        authMethod.isAcceptableOrUnknown(data['auth_method']!, _authMethodMeta),
      );
    } else if (isInserting) {
      context.missing(_authMethodMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    }
    if (data.containsKey('key_id')) {
      context.handle(
        _keyIdMeta,
        keyId.isAcceptableOrUnknown(data['key_id']!, _keyIdMeta),
      );
    }
    if (data.containsKey('group')) {
      context.handle(
        _groupMeta,
        group.isAcceptableOrUnknown(data['group']!, _groupMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('jump_hosts')) {
      context.handle(
        _jumpHostsMeta,
        jumpHosts.isAcceptableOrUnknown(data['jump_hosts']!, _jumpHostsMeta),
      );
    }
    if (data.containsKey('startup_snippet_id')) {
      context.handle(
        _startupSnippetIdMeta,
        startupSnippetId.isAcceptableOrUnknown(
          data['startup_snippet_id']!,
          _startupSnippetIdMeta,
        ),
      );
    }
    if (data.containsKey('startup_command')) {
      context.handle(
        _startupCommandMeta,
        startupCommand.isAcceptableOrUnknown(
          data['startup_command']!,
          _startupCommandMeta,
        ),
      );
    }
    if (data.containsKey('last_connected')) {
      context.handle(
        _lastConnectedMeta,
        lastConnected.isAcceptableOrUnknown(
          data['last_connected']!,
          _lastConnectedMeta,
        ),
      );
    }
    if (data.containsKey('last_connection_type')) {
      context.handle(
        _lastConnectionTypeMeta,
        lastConnectionType.isAcceptableOrUnknown(
          data['last_connection_type']!,
          _lastConnectionTypeMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Host map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Host(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      hostname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}hostname'],
          )!,
      port:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}port'],
          )!,
      username:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}username'],
          )!,
      authMethod:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}auth_method'],
          )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      ),
      keyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_id'],
      ),
      group: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group'],
      ),
      tags:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tags'],
          )!,
      isFavorite:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_favorite'],
          )!,
      jumpHosts:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}jump_hosts'],
          )!,
      startupSnippetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}startup_snippet_id'],
      ),
      startupCommand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}startup_command'],
      ),
      lastConnected: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_connected'],
      ),
      lastConnectionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_connection_type'],
      ),
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $HostsTable createAlias(String alias) {
    return $HostsTable(attachedDatabase, alias);
  }
}

class Host extends DataClass implements Insertable<Host> {
  final String id;
  final String name;
  final String hostname;
  final int port;
  final String username;
  final String authMethod;
  final String? password;
  final String? keyId;
  final String? group;
  final String tags;
  final bool isFavorite;
  final String jumpHosts;
  final String? startupSnippetId;
  final String? startupCommand;
  final DateTime? lastConnected;
  final String? lastConnectionType;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Host({
    required this.id,
    required this.name,
    required this.hostname,
    required this.port,
    required this.username,
    required this.authMethod,
    this.password,
    this.keyId,
    this.group,
    required this.tags,
    required this.isFavorite,
    required this.jumpHosts,
    this.startupSnippetId,
    this.startupCommand,
    this.lastConnected,
    this.lastConnectionType,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['hostname'] = Variable<String>(hostname);
    map['port'] = Variable<int>(port);
    map['username'] = Variable<String>(username);
    map['auth_method'] = Variable<String>(authMethod);
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    if (!nullToAbsent || keyId != null) {
      map['key_id'] = Variable<String>(keyId);
    }
    if (!nullToAbsent || group != null) {
      map['group'] = Variable<String>(group);
    }
    map['tags'] = Variable<String>(tags);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['jump_hosts'] = Variable<String>(jumpHosts);
    if (!nullToAbsent || startupSnippetId != null) {
      map['startup_snippet_id'] = Variable<String>(startupSnippetId);
    }
    if (!nullToAbsent || startupCommand != null) {
      map['startup_command'] = Variable<String>(startupCommand);
    }
    if (!nullToAbsent || lastConnected != null) {
      map['last_connected'] = Variable<DateTime>(lastConnected);
    }
    if (!nullToAbsent || lastConnectionType != null) {
      map['last_connection_type'] = Variable<String>(lastConnectionType);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HostsCompanion toCompanion(bool nullToAbsent) {
    return HostsCompanion(
      id: Value(id),
      name: Value(name),
      hostname: Value(hostname),
      port: Value(port),
      username: Value(username),
      authMethod: Value(authMethod),
      password:
          password == null && nullToAbsent
              ? const Value.absent()
              : Value(password),
      keyId:
          keyId == null && nullToAbsent ? const Value.absent() : Value(keyId),
      group:
          group == null && nullToAbsent ? const Value.absent() : Value(group),
      tags: Value(tags),
      isFavorite: Value(isFavorite),
      jumpHosts: Value(jumpHosts),
      startupSnippetId:
          startupSnippetId == null && nullToAbsent
              ? const Value.absent()
              : Value(startupSnippetId),
      startupCommand:
          startupCommand == null && nullToAbsent
              ? const Value.absent()
              : Value(startupCommand),
      lastConnected:
          lastConnected == null && nullToAbsent
              ? const Value.absent()
              : Value(lastConnected),
      lastConnectionType:
          lastConnectionType == null && nullToAbsent
              ? const Value.absent()
              : Value(lastConnectionType),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Host.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Host(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      hostname: serializer.fromJson<String>(json['hostname']),
      port: serializer.fromJson<int>(json['port']),
      username: serializer.fromJson<String>(json['username']),
      authMethod: serializer.fromJson<String>(json['authMethod']),
      password: serializer.fromJson<String?>(json['password']),
      keyId: serializer.fromJson<String?>(json['keyId']),
      group: serializer.fromJson<String?>(json['group']),
      tags: serializer.fromJson<String>(json['tags']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      jumpHosts: serializer.fromJson<String>(json['jumpHosts']),
      startupSnippetId: serializer.fromJson<String?>(json['startupSnippetId']),
      startupCommand: serializer.fromJson<String?>(json['startupCommand']),
      lastConnected: serializer.fromJson<DateTime?>(json['lastConnected']),
      lastConnectionType: serializer.fromJson<String?>(
        json['lastConnectionType'],
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'hostname': serializer.toJson<String>(hostname),
      'port': serializer.toJson<int>(port),
      'username': serializer.toJson<String>(username),
      'authMethod': serializer.toJson<String>(authMethod),
      'password': serializer.toJson<String?>(password),
      'keyId': serializer.toJson<String?>(keyId),
      'group': serializer.toJson<String?>(group),
      'tags': serializer.toJson<String>(tags),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'jumpHosts': serializer.toJson<String>(jumpHosts),
      'startupSnippetId': serializer.toJson<String?>(startupSnippetId),
      'startupCommand': serializer.toJson<String?>(startupCommand),
      'lastConnected': serializer.toJson<DateTime?>(lastConnected),
      'lastConnectionType': serializer.toJson<String?>(lastConnectionType),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Host copyWith({
    String? id,
    String? name,
    String? hostname,
    int? port,
    String? username,
    String? authMethod,
    Value<String?> password = const Value.absent(),
    Value<String?> keyId = const Value.absent(),
    Value<String?> group = const Value.absent(),
    String? tags,
    bool? isFavorite,
    String? jumpHosts,
    Value<String?> startupSnippetId = const Value.absent(),
    Value<String?> startupCommand = const Value.absent(),
    Value<DateTime?> lastConnected = const Value.absent(),
    Value<String?> lastConnectionType = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Host(
    id: id ?? this.id,
    name: name ?? this.name,
    hostname: hostname ?? this.hostname,
    port: port ?? this.port,
    username: username ?? this.username,
    authMethod: authMethod ?? this.authMethod,
    password: password.present ? password.value : this.password,
    keyId: keyId.present ? keyId.value : this.keyId,
    group: group.present ? group.value : this.group,
    tags: tags ?? this.tags,
    isFavorite: isFavorite ?? this.isFavorite,
    jumpHosts: jumpHosts ?? this.jumpHosts,
    startupSnippetId:
        startupSnippetId.present
            ? startupSnippetId.value
            : this.startupSnippetId,
    startupCommand:
        startupCommand.present ? startupCommand.value : this.startupCommand,
    lastConnected:
        lastConnected.present ? lastConnected.value : this.lastConnected,
    lastConnectionType:
        lastConnectionType.present
            ? lastConnectionType.value
            : this.lastConnectionType,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Host copyWithCompanion(HostsCompanion data) {
    return Host(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      hostname: data.hostname.present ? data.hostname.value : this.hostname,
      port: data.port.present ? data.port.value : this.port,
      username: data.username.present ? data.username.value : this.username,
      authMethod:
          data.authMethod.present ? data.authMethod.value : this.authMethod,
      password: data.password.present ? data.password.value : this.password,
      keyId: data.keyId.present ? data.keyId.value : this.keyId,
      group: data.group.present ? data.group.value : this.group,
      tags: data.tags.present ? data.tags.value : this.tags,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      jumpHosts: data.jumpHosts.present ? data.jumpHosts.value : this.jumpHosts,
      startupSnippetId:
          data.startupSnippetId.present
              ? data.startupSnippetId.value
              : this.startupSnippetId,
      startupCommand:
          data.startupCommand.present
              ? data.startupCommand.value
              : this.startupCommand,
      lastConnected:
          data.lastConnected.present
              ? data.lastConnected.value
              : this.lastConnected,
      lastConnectionType:
          data.lastConnectionType.present
              ? data.lastConnectionType.value
              : this.lastConnectionType,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Host(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hostname: $hostname, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('authMethod: $authMethod, ')
          ..write('password: $password, ')
          ..write('keyId: $keyId, ')
          ..write('group: $group, ')
          ..write('tags: $tags, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('jumpHosts: $jumpHosts, ')
          ..write('startupSnippetId: $startupSnippetId, ')
          ..write('startupCommand: $startupCommand, ')
          ..write('lastConnected: $lastConnected, ')
          ..write('lastConnectionType: $lastConnectionType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    hostname,
    port,
    username,
    authMethod,
    password,
    keyId,
    group,
    tags,
    isFavorite,
    jumpHosts,
    startupSnippetId,
    startupCommand,
    lastConnected,
    lastConnectionType,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Host &&
          other.id == this.id &&
          other.name == this.name &&
          other.hostname == this.hostname &&
          other.port == this.port &&
          other.username == this.username &&
          other.authMethod == this.authMethod &&
          other.password == this.password &&
          other.keyId == this.keyId &&
          other.group == this.group &&
          other.tags == this.tags &&
          other.isFavorite == this.isFavorite &&
          other.jumpHosts == this.jumpHosts &&
          other.startupSnippetId == this.startupSnippetId &&
          other.startupCommand == this.startupCommand &&
          other.lastConnected == this.lastConnected &&
          other.lastConnectionType == this.lastConnectionType &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HostsCompanion extends UpdateCompanion<Host> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> hostname;
  final Value<int> port;
  final Value<String> username;
  final Value<String> authMethod;
  final Value<String?> password;
  final Value<String?> keyId;
  final Value<String?> group;
  final Value<String> tags;
  final Value<bool> isFavorite;
  final Value<String> jumpHosts;
  final Value<String?> startupSnippetId;
  final Value<String?> startupCommand;
  final Value<DateTime?> lastConnected;
  final Value<String?> lastConnectionType;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HostsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.hostname = const Value.absent(),
    this.port = const Value.absent(),
    this.username = const Value.absent(),
    this.authMethod = const Value.absent(),
    this.password = const Value.absent(),
    this.keyId = const Value.absent(),
    this.group = const Value.absent(),
    this.tags = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.jumpHosts = const Value.absent(),
    this.startupSnippetId = const Value.absent(),
    this.startupCommand = const Value.absent(),
    this.lastConnected = const Value.absent(),
    this.lastConnectionType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HostsCompanion.insert({
    required String id,
    required String name,
    required String hostname,
    this.port = const Value.absent(),
    required String username,
    required String authMethod,
    this.password = const Value.absent(),
    this.keyId = const Value.absent(),
    this.group = const Value.absent(),
    this.tags = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.jumpHosts = const Value.absent(),
    this.startupSnippetId = const Value.absent(),
    this.startupCommand = const Value.absent(),
    this.lastConnected = const Value.absent(),
    this.lastConnectionType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       hostname = Value(hostname),
       username = Value(username),
       authMethod = Value(authMethod);
  static Insertable<Host> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? hostname,
    Expression<int>? port,
    Expression<String>? username,
    Expression<String>? authMethod,
    Expression<String>? password,
    Expression<String>? keyId,
    Expression<String>? group,
    Expression<String>? tags,
    Expression<bool>? isFavorite,
    Expression<String>? jumpHosts,
    Expression<String>? startupSnippetId,
    Expression<String>? startupCommand,
    Expression<DateTime>? lastConnected,
    Expression<String>? lastConnectionType,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (hostname != null) 'hostname': hostname,
      if (port != null) 'port': port,
      if (username != null) 'username': username,
      if (authMethod != null) 'auth_method': authMethod,
      if (password != null) 'password': password,
      if (keyId != null) 'key_id': keyId,
      if (group != null) 'group': group,
      if (tags != null) 'tags': tags,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (jumpHosts != null) 'jump_hosts': jumpHosts,
      if (startupSnippetId != null) 'startup_snippet_id': startupSnippetId,
      if (startupCommand != null) 'startup_command': startupCommand,
      if (lastConnected != null) 'last_connected': lastConnected,
      if (lastConnectionType != null)
        'last_connection_type': lastConnectionType,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HostsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? hostname,
    Value<int>? port,
    Value<String>? username,
    Value<String>? authMethod,
    Value<String?>? password,
    Value<String?>? keyId,
    Value<String?>? group,
    Value<String>? tags,
    Value<bool>? isFavorite,
    Value<String>? jumpHosts,
    Value<String?>? startupSnippetId,
    Value<String?>? startupCommand,
    Value<DateTime?>? lastConnected,
    Value<String?>? lastConnectionType,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HostsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      hostname: hostname ?? this.hostname,
      port: port ?? this.port,
      username: username ?? this.username,
      authMethod: authMethod ?? this.authMethod,
      password: password ?? this.password,
      keyId: keyId ?? this.keyId,
      group: group ?? this.group,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      jumpHosts: jumpHosts ?? this.jumpHosts,
      startupSnippetId: startupSnippetId ?? this.startupSnippetId,
      startupCommand: startupCommand ?? this.startupCommand,
      lastConnected: lastConnected ?? this.lastConnected,
      lastConnectionType: lastConnectionType ?? this.lastConnectionType,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (hostname.present) {
      map['hostname'] = Variable<String>(hostname.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (authMethod.present) {
      map['auth_method'] = Variable<String>(authMethod.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (keyId.present) {
      map['key_id'] = Variable<String>(keyId.value);
    }
    if (group.present) {
      map['group'] = Variable<String>(group.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (jumpHosts.present) {
      map['jump_hosts'] = Variable<String>(jumpHosts.value);
    }
    if (startupSnippetId.present) {
      map['startup_snippet_id'] = Variable<String>(startupSnippetId.value);
    }
    if (startupCommand.present) {
      map['startup_command'] = Variable<String>(startupCommand.value);
    }
    if (lastConnected.present) {
      map['last_connected'] = Variable<DateTime>(lastConnected.value);
    }
    if (lastConnectionType.present) {
      map['last_connection_type'] = Variable<String>(lastConnectionType.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HostsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hostname: $hostname, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('authMethod: $authMethod, ')
          ..write('password: $password, ')
          ..write('keyId: $keyId, ')
          ..write('group: $group, ')
          ..write('tags: $tags, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('jumpHosts: $jumpHosts, ')
          ..write('startupSnippetId: $startupSnippetId, ')
          ..write('startupCommand: $startupCommand, ')
          ..write('lastConnected: $lastConnected, ')
          ..write('lastConnectionType: $lastConnectionType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SshKeysTable extends SshKeys with TableInfo<$SshKeysTable, SshKey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SshKeysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privateKeyMeta = const VerificationMeta(
    'privateKey',
  );
  @override
  late final GeneratedColumn<String> privateKey = GeneratedColumn<String>(
    'private_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passphraseMeta = const VerificationMeta(
    'passphrase',
  );
  @override
  late final GeneratedColumn<String> passphrase = GeneratedColumn<String>(
    'passphrase',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    privateKey,
    publicKey,
    fingerprint,
    passphrase,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ssh_keys';
  @override
  VerificationContext validateIntegrity(
    Insertable<SshKey> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('private_key')) {
      context.handle(
        _privateKeyMeta,
        privateKey.isAcceptableOrUnknown(data['private_key']!, _privateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_privateKeyMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('passphrase')) {
      context.handle(
        _passphraseMeta,
        passphrase.isAcceptableOrUnknown(data['passphrase']!, _passphraseMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SshKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SshKey(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      privateKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}private_key'],
          )!,
      publicKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}public_key'],
          )!,
      fingerprint:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}fingerprint'],
          )!,
      passphrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passphrase'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $SshKeysTable createAlias(String alias) {
    return $SshKeysTable(attachedDatabase, alias);
  }
}

class SshKey extends DataClass implements Insertable<SshKey> {
  final String id;
  final String name;
  final String type;
  final String privateKey;
  final String publicKey;
  final String fingerprint;
  final String? passphrase;
  final DateTime createdAt;
  const SshKey({
    required this.id,
    required this.name,
    required this.type,
    required this.privateKey,
    required this.publicKey,
    required this.fingerprint,
    this.passphrase,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['private_key'] = Variable<String>(privateKey);
    map['public_key'] = Variable<String>(publicKey);
    map['fingerprint'] = Variable<String>(fingerprint);
    if (!nullToAbsent || passphrase != null) {
      map['passphrase'] = Variable<String>(passphrase);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SshKeysCompanion toCompanion(bool nullToAbsent) {
    return SshKeysCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      privateKey: Value(privateKey),
      publicKey: Value(publicKey),
      fingerprint: Value(fingerprint),
      passphrase:
          passphrase == null && nullToAbsent
              ? const Value.absent()
              : Value(passphrase),
      createdAt: Value(createdAt),
    );
  }

  factory SshKey.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SshKey(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      privateKey: serializer.fromJson<String>(json['privateKey']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      passphrase: serializer.fromJson<String?>(json['passphrase']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'privateKey': serializer.toJson<String>(privateKey),
      'publicKey': serializer.toJson<String>(publicKey),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'passphrase': serializer.toJson<String?>(passphrase),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SshKey copyWith({
    String? id,
    String? name,
    String? type,
    String? privateKey,
    String? publicKey,
    String? fingerprint,
    Value<String?> passphrase = const Value.absent(),
    DateTime? createdAt,
  }) => SshKey(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    privateKey: privateKey ?? this.privateKey,
    publicKey: publicKey ?? this.publicKey,
    fingerprint: fingerprint ?? this.fingerprint,
    passphrase: passphrase.present ? passphrase.value : this.passphrase,
    createdAt: createdAt ?? this.createdAt,
  );
  SshKey copyWithCompanion(SshKeysCompanion data) {
    return SshKey(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      privateKey:
          data.privateKey.present ? data.privateKey.value : this.privateKey,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      fingerprint:
          data.fingerprint.present ? data.fingerprint.value : this.fingerprint,
      passphrase:
          data.passphrase.present ? data.passphrase.value : this.passphrase,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SshKey(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('privateKey: $privateKey, ')
          ..write('publicKey: $publicKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('passphrase: $passphrase, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    privateKey,
    publicKey,
    fingerprint,
    passphrase,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SshKey &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.privateKey == this.privateKey &&
          other.publicKey == this.publicKey &&
          other.fingerprint == this.fingerprint &&
          other.passphrase == this.passphrase &&
          other.createdAt == this.createdAt);
}

class SshKeysCompanion extends UpdateCompanion<SshKey> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> privateKey;
  final Value<String> publicKey;
  final Value<String> fingerprint;
  final Value<String?> passphrase;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SshKeysCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.privateKey = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.passphrase = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SshKeysCompanion.insert({
    required String id,
    required String name,
    required String type,
    required String privateKey,
    required String publicKey,
    required String fingerprint,
    this.passphrase = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       privateKey = Value(privateKey),
       publicKey = Value(publicKey),
       fingerprint = Value(fingerprint);
  static Insertable<SshKey> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? privateKey,
    Expression<String>? publicKey,
    Expression<String>? fingerprint,
    Expression<String>? passphrase,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (privateKey != null) 'private_key': privateKey,
      if (publicKey != null) 'public_key': publicKey,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (passphrase != null) 'passphrase': passphrase,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SshKeysCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? privateKey,
    Value<String>? publicKey,
    Value<String>? fingerprint,
    Value<String?>? passphrase,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SshKeysCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      fingerprint: fingerprint ?? this.fingerprint,
      passphrase: passphrase ?? this.passphrase,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (privateKey.present) {
      map['private_key'] = Variable<String>(privateKey.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (passphrase.present) {
      map['passphrase'] = Variable<String>(passphrase.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SshKeysCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('privateKey: $privateKey, ')
          ..write('publicKey: $publicKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('passphrase: $passphrase, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SnippetsTable extends Snippets with TableInfo<$SnippetsTable, Snippet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnippetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commandMeta = const VerificationMeta(
    'command',
  );
  @override
  late final GeneratedColumn<String> command = GeneratedColumn<String>(
    'command',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variablesMeta = const VerificationMeta(
    'variables',
  );
  @override
  late final GeneratedColumn<String> variables = GeneratedColumn<String>(
    'variables',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _groupMeta = const VerificationMeta('group');
  @override
  late final GeneratedColumn<String> group = GeneratedColumn<String>(
    'group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    command,
    variables,
    group,
    tags,
    isFavorite,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snippets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Snippet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('command')) {
      context.handle(
        _commandMeta,
        command.isAcceptableOrUnknown(data['command']!, _commandMeta),
      );
    } else if (isInserting) {
      context.missing(_commandMeta);
    }
    if (data.containsKey('variables')) {
      context.handle(
        _variablesMeta,
        variables.isAcceptableOrUnknown(data['variables']!, _variablesMeta),
      );
    }
    if (data.containsKey('group')) {
      context.handle(
        _groupMeta,
        group.isAcceptableOrUnknown(data['group']!, _groupMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Snippet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Snippet(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      command:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}command'],
          )!,
      variables:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}variables'],
          )!,
      group: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group'],
      ),
      tags:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tags'],
          )!,
      isFavorite:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_favorite'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $SnippetsTable createAlias(String alias) {
    return $SnippetsTable(attachedDatabase, alias);
  }
}

class Snippet extends DataClass implements Insertable<Snippet> {
  final String id;
  final String name;
  final String command;
  final String variables;
  final String? group;
  final String tags;
  final bool isFavorite;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Snippet({
    required this.id,
    required this.name,
    required this.command,
    required this.variables,
    this.group,
    required this.tags,
    required this.isFavorite,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['command'] = Variable<String>(command);
    map['variables'] = Variable<String>(variables);
    if (!nullToAbsent || group != null) {
      map['group'] = Variable<String>(group);
    }
    map['tags'] = Variable<String>(tags);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SnippetsCompanion toCompanion(bool nullToAbsent) {
    return SnippetsCompanion(
      id: Value(id),
      name: Value(name),
      command: Value(command),
      variables: Value(variables),
      group:
          group == null && nullToAbsent ? const Value.absent() : Value(group),
      tags: Value(tags),
      isFavorite: Value(isFavorite),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Snippet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Snippet(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      command: serializer.fromJson<String>(json['command']),
      variables: serializer.fromJson<String>(json['variables']),
      group: serializer.fromJson<String?>(json['group']),
      tags: serializer.fromJson<String>(json['tags']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'command': serializer.toJson<String>(command),
      'variables': serializer.toJson<String>(variables),
      'group': serializer.toJson<String?>(group),
      'tags': serializer.toJson<String>(tags),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Snippet copyWith({
    String? id,
    String? name,
    String? command,
    String? variables,
    Value<String?> group = const Value.absent(),
    String? tags,
    bool? isFavorite,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Snippet(
    id: id ?? this.id,
    name: name ?? this.name,
    command: command ?? this.command,
    variables: variables ?? this.variables,
    group: group.present ? group.value : this.group,
    tags: tags ?? this.tags,
    isFavorite: isFavorite ?? this.isFavorite,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Snippet copyWithCompanion(SnippetsCompanion data) {
    return Snippet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      command: data.command.present ? data.command.value : this.command,
      variables: data.variables.present ? data.variables.value : this.variables,
      group: data.group.present ? data.group.value : this.group,
      tags: data.tags.present ? data.tags.value : this.tags,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Snippet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('command: $command, ')
          ..write('variables: $variables, ')
          ..write('group: $group, ')
          ..write('tags: $tags, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    command,
    variables,
    group,
    tags,
    isFavorite,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Snippet &&
          other.id == this.id &&
          other.name == this.name &&
          other.command == this.command &&
          other.variables == this.variables &&
          other.group == this.group &&
          other.tags == this.tags &&
          other.isFavorite == this.isFavorite &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SnippetsCompanion extends UpdateCompanion<Snippet> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> command;
  final Value<String> variables;
  final Value<String?> group;
  final Value<String> tags;
  final Value<bool> isFavorite;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SnippetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.command = const Value.absent(),
    this.variables = const Value.absent(),
    this.group = const Value.absent(),
    this.tags = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SnippetsCompanion.insert({
    required String id,
    required String name,
    required String command,
    this.variables = const Value.absent(),
    this.group = const Value.absent(),
    this.tags = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       command = Value(command);
  static Insertable<Snippet> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? command,
    Expression<String>? variables,
    Expression<String>? group,
    Expression<String>? tags,
    Expression<bool>? isFavorite,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (command != null) 'command': command,
      if (variables != null) 'variables': variables,
      if (group != null) 'group': group,
      if (tags != null) 'tags': tags,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SnippetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? command,
    Value<String>? variables,
    Value<String?>? group,
    Value<String>? tags,
    Value<bool>? isFavorite,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SnippetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      command: command ?? this.command,
      variables: variables ?? this.variables,
      group: group ?? this.group,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (command.present) {
      map['command'] = Variable<String>(command.value);
    }
    if (variables.present) {
      map['variables'] = Variable<String>(variables.value);
    }
    if (group.present) {
      map['group'] = Variable<String>(group.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnippetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('command: $command, ')
          ..write('variables: $variables, ')
          ..write('group: $group, ')
          ..write('tags: $tags, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PortForwardsTable extends PortForwards
    with TableInfo<$PortForwardsTable, PortForward> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PortForwardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostIdMeta = const VerificationMeta('hostId');
  @override
  late final GeneratedColumn<String> hostId = GeneratedColumn<String>(
    'host_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPortMeta = const VerificationMeta(
    'localPort',
  );
  @override
  late final GeneratedColumn<int> localPort = GeneratedColumn<int>(
    'local_port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteHostMeta = const VerificationMeta(
    'remoteHost',
  );
  @override
  late final GeneratedColumn<String> remoteHost = GeneratedColumn<String>(
    'remote_host',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remotePortMeta = const VerificationMeta(
    'remotePort',
  );
  @override
  late final GeneratedColumn<int> remotePort = GeneratedColumn<int>(
    'remote_port',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bindAddressMeta = const VerificationMeta(
    'bindAddress',
  );
  @override
  late final GeneratedColumn<String> bindAddress = GeneratedColumn<String>(
    'bind_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('127.0.0.1'),
  );
  static const VerificationMeta _autoStartMeta = const VerificationMeta(
    'autoStart',
  );
  @override
  late final GeneratedColumn<bool> autoStart = GeneratedColumn<bool>(
    'auto_start',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_start" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    hostId,
    localPort,
    remoteHost,
    remotePort,
    bindAddress,
    autoStart,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'port_forwards';
  @override
  VerificationContext validateIntegrity(
    Insertable<PortForward> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('host_id')) {
      context.handle(
        _hostIdMeta,
        hostId.isAcceptableOrUnknown(data['host_id']!, _hostIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hostIdMeta);
    }
    if (data.containsKey('local_port')) {
      context.handle(
        _localPortMeta,
        localPort.isAcceptableOrUnknown(data['local_port']!, _localPortMeta),
      );
    } else if (isInserting) {
      context.missing(_localPortMeta);
    }
    if (data.containsKey('remote_host')) {
      context.handle(
        _remoteHostMeta,
        remoteHost.isAcceptableOrUnknown(data['remote_host']!, _remoteHostMeta),
      );
    }
    if (data.containsKey('remote_port')) {
      context.handle(
        _remotePortMeta,
        remotePort.isAcceptableOrUnknown(data['remote_port']!, _remotePortMeta),
      );
    }
    if (data.containsKey('bind_address')) {
      context.handle(
        _bindAddressMeta,
        bindAddress.isAcceptableOrUnknown(
          data['bind_address']!,
          _bindAddressMeta,
        ),
      );
    }
    if (data.containsKey('auto_start')) {
      context.handle(
        _autoStartMeta,
        autoStart.isAcceptableOrUnknown(data['auto_start']!, _autoStartMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PortForward map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PortForward(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      hostId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}host_id'],
          )!,
      localPort:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}local_port'],
          )!,
      remoteHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_host'],
      ),
      remotePort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_port'],
      ),
      bindAddress:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}bind_address'],
          )!,
      autoStart:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}auto_start'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $PortForwardsTable createAlias(String alias) {
    return $PortForwardsTable(attachedDatabase, alias);
  }
}

class PortForward extends DataClass implements Insertable<PortForward> {
  final String id;
  final String name;
  final String type;
  final String hostId;
  final int localPort;
  final String? remoteHost;
  final int? remotePort;
  final String bindAddress;
  final bool autoStart;
  final DateTime createdAt;
  const PortForward({
    required this.id,
    required this.name,
    required this.type,
    required this.hostId,
    required this.localPort,
    this.remoteHost,
    this.remotePort,
    required this.bindAddress,
    required this.autoStart,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['host_id'] = Variable<String>(hostId);
    map['local_port'] = Variable<int>(localPort);
    if (!nullToAbsent || remoteHost != null) {
      map['remote_host'] = Variable<String>(remoteHost);
    }
    if (!nullToAbsent || remotePort != null) {
      map['remote_port'] = Variable<int>(remotePort);
    }
    map['bind_address'] = Variable<String>(bindAddress);
    map['auto_start'] = Variable<bool>(autoStart);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PortForwardsCompanion toCompanion(bool nullToAbsent) {
    return PortForwardsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      hostId: Value(hostId),
      localPort: Value(localPort),
      remoteHost:
          remoteHost == null && nullToAbsent
              ? const Value.absent()
              : Value(remoteHost),
      remotePort:
          remotePort == null && nullToAbsent
              ? const Value.absent()
              : Value(remotePort),
      bindAddress: Value(bindAddress),
      autoStart: Value(autoStart),
      createdAt: Value(createdAt),
    );
  }

  factory PortForward.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PortForward(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      hostId: serializer.fromJson<String>(json['hostId']),
      localPort: serializer.fromJson<int>(json['localPort']),
      remoteHost: serializer.fromJson<String?>(json['remoteHost']),
      remotePort: serializer.fromJson<int?>(json['remotePort']),
      bindAddress: serializer.fromJson<String>(json['bindAddress']),
      autoStart: serializer.fromJson<bool>(json['autoStart']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'hostId': serializer.toJson<String>(hostId),
      'localPort': serializer.toJson<int>(localPort),
      'remoteHost': serializer.toJson<String?>(remoteHost),
      'remotePort': serializer.toJson<int?>(remotePort),
      'bindAddress': serializer.toJson<String>(bindAddress),
      'autoStart': serializer.toJson<bool>(autoStart),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PortForward copyWith({
    String? id,
    String? name,
    String? type,
    String? hostId,
    int? localPort,
    Value<String?> remoteHost = const Value.absent(),
    Value<int?> remotePort = const Value.absent(),
    String? bindAddress,
    bool? autoStart,
    DateTime? createdAt,
  }) => PortForward(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    hostId: hostId ?? this.hostId,
    localPort: localPort ?? this.localPort,
    remoteHost: remoteHost.present ? remoteHost.value : this.remoteHost,
    remotePort: remotePort.present ? remotePort.value : this.remotePort,
    bindAddress: bindAddress ?? this.bindAddress,
    autoStart: autoStart ?? this.autoStart,
    createdAt: createdAt ?? this.createdAt,
  );
  PortForward copyWithCompanion(PortForwardsCompanion data) {
    return PortForward(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      hostId: data.hostId.present ? data.hostId.value : this.hostId,
      localPort: data.localPort.present ? data.localPort.value : this.localPort,
      remoteHost:
          data.remoteHost.present ? data.remoteHost.value : this.remoteHost,
      remotePort:
          data.remotePort.present ? data.remotePort.value : this.remotePort,
      bindAddress:
          data.bindAddress.present ? data.bindAddress.value : this.bindAddress,
      autoStart: data.autoStart.present ? data.autoStart.value : this.autoStart,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PortForward(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('hostId: $hostId, ')
          ..write('localPort: $localPort, ')
          ..write('remoteHost: $remoteHost, ')
          ..write('remotePort: $remotePort, ')
          ..write('bindAddress: $bindAddress, ')
          ..write('autoStart: $autoStart, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    hostId,
    localPort,
    remoteHost,
    remotePort,
    bindAddress,
    autoStart,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PortForward &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.hostId == this.hostId &&
          other.localPort == this.localPort &&
          other.remoteHost == this.remoteHost &&
          other.remotePort == this.remotePort &&
          other.bindAddress == this.bindAddress &&
          other.autoStart == this.autoStart &&
          other.createdAt == this.createdAt);
}

class PortForwardsCompanion extends UpdateCompanion<PortForward> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> hostId;
  final Value<int> localPort;
  final Value<String?> remoteHost;
  final Value<int?> remotePort;
  final Value<String> bindAddress;
  final Value<bool> autoStart;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PortForwardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.hostId = const Value.absent(),
    this.localPort = const Value.absent(),
    this.remoteHost = const Value.absent(),
    this.remotePort = const Value.absent(),
    this.bindAddress = const Value.absent(),
    this.autoStart = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PortForwardsCompanion.insert({
    required String id,
    required String name,
    required String type,
    required String hostId,
    required int localPort,
    this.remoteHost = const Value.absent(),
    this.remotePort = const Value.absent(),
    this.bindAddress = const Value.absent(),
    this.autoStart = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       hostId = Value(hostId),
       localPort = Value(localPort);
  static Insertable<PortForward> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? hostId,
    Expression<int>? localPort,
    Expression<String>? remoteHost,
    Expression<int>? remotePort,
    Expression<String>? bindAddress,
    Expression<bool>? autoStart,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (hostId != null) 'host_id': hostId,
      if (localPort != null) 'local_port': localPort,
      if (remoteHost != null) 'remote_host': remoteHost,
      if (remotePort != null) 'remote_port': remotePort,
      if (bindAddress != null) 'bind_address': bindAddress,
      if (autoStart != null) 'auto_start': autoStart,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PortForwardsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? hostId,
    Value<int>? localPort,
    Value<String?>? remoteHost,
    Value<int?>? remotePort,
    Value<String>? bindAddress,
    Value<bool>? autoStart,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PortForwardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      hostId: hostId ?? this.hostId,
      localPort: localPort ?? this.localPort,
      remoteHost: remoteHost ?? this.remoteHost,
      remotePort: remotePort ?? this.remotePort,
      bindAddress: bindAddress ?? this.bindAddress,
      autoStart: autoStart ?? this.autoStart,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (hostId.present) {
      map['host_id'] = Variable<String>(hostId.value);
    }
    if (localPort.present) {
      map['local_port'] = Variable<int>(localPort.value);
    }
    if (remoteHost.present) {
      map['remote_host'] = Variable<String>(remoteHost.value);
    }
    if (remotePort.present) {
      map['remote_port'] = Variable<int>(remotePort.value);
    }
    if (bindAddress.present) {
      map['bind_address'] = Variable<String>(bindAddress.value);
    }
    if (autoStart.present) {
      map['auto_start'] = Variable<bool>(autoStart.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PortForwardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('hostId: $hostId, ')
          ..write('localPort: $localPort, ')
          ..write('remoteHost: $remoteHost, ')
          ..write('remotePort: $remotePort, ')
          ..write('bindAddress: $bindAddress, ')
          ..write('autoStart: $autoStart, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GitReposTable extends GitRepos with TableInfo<$GitReposTable, GitRepo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GitReposTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostIdMeta = const VerificationMeta('hostId');
  @override
  late final GeneratedColumn<String> hostId = GeneratedColumn<String>(
    'host_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hosts (id)',
    ),
  );
  static const VerificationMeta _remotePathMeta = const VerificationMeta(
    'remotePath',
  );
  @override
  late final GeneratedColumn<String> remotePath = GeneratedColumn<String>(
    'remote_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hostId,
    remotePath,
    label,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'git_repos';
  @override
  VerificationContext validateIntegrity(
    Insertable<GitRepo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('host_id')) {
      context.handle(
        _hostIdMeta,
        hostId.isAcceptableOrUnknown(data['host_id']!, _hostIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hostIdMeta);
    }
    if (data.containsKey('remote_path')) {
      context.handle(
        _remotePathMeta,
        remotePath.isAcceptableOrUnknown(data['remote_path']!, _remotePathMeta),
      );
    } else if (isInserting) {
      context.missing(_remotePathMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GitRepo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GitRepo(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      hostId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}host_id'],
          )!,
      remotePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remote_path'],
          )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $GitReposTable createAlias(String alias) {
    return $GitReposTable(attachedDatabase, alias);
  }
}

class GitRepo extends DataClass implements Insertable<GitRepo> {
  final String id;
  final String hostId;
  final String remotePath;
  final String? label;
  final DateTime createdAt;
  const GitRepo({
    required this.id,
    required this.hostId,
    required this.remotePath,
    this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['host_id'] = Variable<String>(hostId);
    map['remote_path'] = Variable<String>(remotePath);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GitReposCompanion toCompanion(bool nullToAbsent) {
    return GitReposCompanion(
      id: Value(id),
      hostId: Value(hostId),
      remotePath: Value(remotePath),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory GitRepo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GitRepo(
      id: serializer.fromJson<String>(json['id']),
      hostId: serializer.fromJson<String>(json['hostId']),
      remotePath: serializer.fromJson<String>(json['remotePath']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hostId': serializer.toJson<String>(hostId),
      'remotePath': serializer.toJson<String>(remotePath),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GitRepo copyWith({
    String? id,
    String? hostId,
    String? remotePath,
    Value<String?> label = const Value.absent(),
    DateTime? createdAt,
  }) => GitRepo(
    id: id ?? this.id,
    hostId: hostId ?? this.hostId,
    remotePath: remotePath ?? this.remotePath,
    label: label.present ? label.value : this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  GitRepo copyWithCompanion(GitReposCompanion data) {
    return GitRepo(
      id: data.id.present ? data.id.value : this.id,
      hostId: data.hostId.present ? data.hostId.value : this.hostId,
      remotePath:
          data.remotePath.present ? data.remotePath.value : this.remotePath,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GitRepo(')
          ..write('id: $id, ')
          ..write('hostId: $hostId, ')
          ..write('remotePath: $remotePath, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hostId, remotePath, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GitRepo &&
          other.id == this.id &&
          other.hostId == this.hostId &&
          other.remotePath == this.remotePath &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class GitReposCompanion extends UpdateCompanion<GitRepo> {
  final Value<String> id;
  final Value<String> hostId;
  final Value<String> remotePath;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GitReposCompanion({
    this.id = const Value.absent(),
    this.hostId = const Value.absent(),
    this.remotePath = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GitReposCompanion.insert({
    required String id,
    required String hostId,
    required String remotePath,
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hostId = Value(hostId),
       remotePath = Value(remotePath);
  static Insertable<GitRepo> custom({
    Expression<String>? id,
    Expression<String>? hostId,
    Expression<String>? remotePath,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hostId != null) 'host_id': hostId,
      if (remotePath != null) 'remote_path': remotePath,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GitReposCompanion copyWith({
    Value<String>? id,
    Value<String>? hostId,
    Value<String>? remotePath,
    Value<String?>? label,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GitReposCompanion(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      remotePath: remotePath ?? this.remotePath,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hostId.present) {
      map['host_id'] = Variable<String>(hostId.value);
    }
    if (remotePath.present) {
      map['remote_path'] = Variable<String>(remotePath.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GitReposCompanion(')
          ..write('id: $id, ')
          ..write('hostId: $hostId, ')
          ..write('remotePath: $remotePath, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HostsTable hosts = $HostsTable(this);
  late final $SshKeysTable sshKeys = $SshKeysTable(this);
  late final $SnippetsTable snippets = $SnippetsTable(this);
  late final $PortForwardsTable portForwards = $PortForwardsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $GitReposTable gitRepos = $GitReposTable(this);
  late final HostsDao hostsDao = HostsDao(this as AppDatabase);
  late final SshKeysDao sshKeysDao = SshKeysDao(this as AppDatabase);
  late final SnippetsDao snippetsDao = SnippetsDao(this as AppDatabase);
  late final PortForwardsDao portForwardsDao = PortForwardsDao(
    this as AppDatabase,
  );
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final GitReposDao gitReposDao = GitReposDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    hosts,
    sshKeys,
    snippets,
    portForwards,
    appSettings,
    gitRepos,
  ];
}

typedef $$HostsTableCreateCompanionBuilder =
    HostsCompanion Function({
      required String id,
      required String name,
      required String hostname,
      Value<int> port,
      required String username,
      required String authMethod,
      Value<String?> password,
      Value<String?> keyId,
      Value<String?> group,
      Value<String> tags,
      Value<bool> isFavorite,
      Value<String> jumpHosts,
      Value<String?> startupSnippetId,
      Value<String?> startupCommand,
      Value<DateTime?> lastConnected,
      Value<String?> lastConnectionType,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$HostsTableUpdateCompanionBuilder =
    HostsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> hostname,
      Value<int> port,
      Value<String> username,
      Value<String> authMethod,
      Value<String?> password,
      Value<String?> keyId,
      Value<String?> group,
      Value<String> tags,
      Value<bool> isFavorite,
      Value<String> jumpHosts,
      Value<String?> startupSnippetId,
      Value<String?> startupCommand,
      Value<DateTime?> lastConnected,
      Value<String?> lastConnectionType,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$HostsTableReferences
    extends BaseReferences<_$AppDatabase, $HostsTable, Host> {
  $$HostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GitReposTable, List<GitRepo>> _gitReposRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gitRepos,
    aliasName: $_aliasNameGenerator(db.hosts.id, db.gitRepos.hostId),
  );

  $$GitReposTableProcessedTableManager get gitReposRefs {
    final manager = $$GitReposTableTableManager(
      $_db,
      $_db.gitRepos,
    ).filter((f) => f.hostId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gitReposRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HostsTableFilterComposer extends Composer<_$AppDatabase, $HostsTable> {
  $$HostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostname => $composableBuilder(
    column: $table.hostname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authMethod => $composableBuilder(
    column: $table.authMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyId => $composableBuilder(
    column: $table.keyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jumpHosts => $composableBuilder(
    column: $table.jumpHosts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startupSnippetId => $composableBuilder(
    column: $table.startupSnippetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startupCommand => $composableBuilder(
    column: $table.startupCommand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastConnected => $composableBuilder(
    column: $table.lastConnected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastConnectionType => $composableBuilder(
    column: $table.lastConnectionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gitReposRefs(
    Expression<bool> Function($$GitReposTableFilterComposer f) f,
  ) {
    final $$GitReposTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gitRepos,
      getReferencedColumn: (t) => t.hostId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GitReposTableFilterComposer(
            $db: $db,
            $table: $db.gitRepos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HostsTableOrderingComposer
    extends Composer<_$AppDatabase, $HostsTable> {
  $$HostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostname => $composableBuilder(
    column: $table.hostname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authMethod => $composableBuilder(
    column: $table.authMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyId => $composableBuilder(
    column: $table.keyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jumpHosts => $composableBuilder(
    column: $table.jumpHosts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startupSnippetId => $composableBuilder(
    column: $table.startupSnippetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startupCommand => $composableBuilder(
    column: $table.startupCommand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastConnected => $composableBuilder(
    column: $table.lastConnected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastConnectionType => $composableBuilder(
    column: $table.lastConnectionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HostsTable> {
  $$HostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get hostname =>
      $composableBuilder(column: $table.hostname, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get authMethod => $composableBuilder(
    column: $table.authMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get keyId =>
      $composableBuilder(column: $table.keyId, builder: (column) => column);

  GeneratedColumn<String> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jumpHosts =>
      $composableBuilder(column: $table.jumpHosts, builder: (column) => column);

  GeneratedColumn<String> get startupSnippetId => $composableBuilder(
    column: $table.startupSnippetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startupCommand => $composableBuilder(
    column: $table.startupCommand,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastConnected => $composableBuilder(
    column: $table.lastConnected,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastConnectionType => $composableBuilder(
    column: $table.lastConnectionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> gitReposRefs<T extends Object>(
    Expression<T> Function($$GitReposTableAnnotationComposer a) f,
  ) {
    final $$GitReposTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gitRepos,
      getReferencedColumn: (t) => t.hostId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GitReposTableAnnotationComposer(
            $db: $db,
            $table: $db.gitRepos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HostsTable,
          Host,
          $$HostsTableFilterComposer,
          $$HostsTableOrderingComposer,
          $$HostsTableAnnotationComposer,
          $$HostsTableCreateCompanionBuilder,
          $$HostsTableUpdateCompanionBuilder,
          (Host, $$HostsTableReferences),
          Host,
          PrefetchHooks Function({bool gitReposRefs})
        > {
  $$HostsTableTableManager(_$AppDatabase db, $HostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$HostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$HostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$HostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> hostname = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> authMethod = const Value.absent(),
                Value<String?> password = const Value.absent(),
                Value<String?> keyId = const Value.absent(),
                Value<String?> group = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String> jumpHosts = const Value.absent(),
                Value<String?> startupSnippetId = const Value.absent(),
                Value<String?> startupCommand = const Value.absent(),
                Value<DateTime?> lastConnected = const Value.absent(),
                Value<String?> lastConnectionType = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HostsCompanion(
                id: id,
                name: name,
                hostname: hostname,
                port: port,
                username: username,
                authMethod: authMethod,
                password: password,
                keyId: keyId,
                group: group,
                tags: tags,
                isFavorite: isFavorite,
                jumpHosts: jumpHosts,
                startupSnippetId: startupSnippetId,
                startupCommand: startupCommand,
                lastConnected: lastConnected,
                lastConnectionType: lastConnectionType,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String hostname,
                Value<int> port = const Value.absent(),
                required String username,
                required String authMethod,
                Value<String?> password = const Value.absent(),
                Value<String?> keyId = const Value.absent(),
                Value<String?> group = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String> jumpHosts = const Value.absent(),
                Value<String?> startupSnippetId = const Value.absent(),
                Value<String?> startupCommand = const Value.absent(),
                Value<DateTime?> lastConnected = const Value.absent(),
                Value<String?> lastConnectionType = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HostsCompanion.insert(
                id: id,
                name: name,
                hostname: hostname,
                port: port,
                username: username,
                authMethod: authMethod,
                password: password,
                keyId: keyId,
                group: group,
                tags: tags,
                isFavorite: isFavorite,
                jumpHosts: jumpHosts,
                startupSnippetId: startupSnippetId,
                startupCommand: startupCommand,
                lastConnected: lastConnected,
                lastConnectionType: lastConnectionType,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$HostsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({gitReposRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gitReposRefs) db.gitRepos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gitReposRefs)
                    await $_getPrefetchedData<Host, $HostsTable, GitRepo>(
                      currentTable: table,
                      referencedTable: $$HostsTableReferences
                          ._gitReposRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$HostsTableReferences(
                                db,
                                table,
                                p0,
                              ).gitReposRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.hostId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HostsTable,
      Host,
      $$HostsTableFilterComposer,
      $$HostsTableOrderingComposer,
      $$HostsTableAnnotationComposer,
      $$HostsTableCreateCompanionBuilder,
      $$HostsTableUpdateCompanionBuilder,
      (Host, $$HostsTableReferences),
      Host,
      PrefetchHooks Function({bool gitReposRefs})
    >;
typedef $$SshKeysTableCreateCompanionBuilder =
    SshKeysCompanion Function({
      required String id,
      required String name,
      required String type,
      required String privateKey,
      required String publicKey,
      required String fingerprint,
      Value<String?> passphrase,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SshKeysTableUpdateCompanionBuilder =
    SshKeysCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String> privateKey,
      Value<String> publicKey,
      Value<String> fingerprint,
      Value<String?> passphrase,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SshKeysTableFilterComposer
    extends Composer<_$AppDatabase, $SshKeysTable> {
  $$SshKeysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SshKeysTableOrderingComposer
    extends Composer<_$AppDatabase, $SshKeysTable> {
  $$SshKeysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SshKeysTableAnnotationComposer
    extends Composer<_$AppDatabase, $SshKeysTable> {
  $$SshKeysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SshKeysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SshKeysTable,
          SshKey,
          $$SshKeysTableFilterComposer,
          $$SshKeysTableOrderingComposer,
          $$SshKeysTableAnnotationComposer,
          $$SshKeysTableCreateCompanionBuilder,
          $$SshKeysTableUpdateCompanionBuilder,
          (SshKey, BaseReferences<_$AppDatabase, $SshKeysTable, SshKey>),
          SshKey,
          PrefetchHooks Function()
        > {
  $$SshKeysTableTableManager(_$AppDatabase db, $SshKeysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SshKeysTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SshKeysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SshKeysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> privateKey = const Value.absent(),
                Value<String> publicKey = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String?> passphrase = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SshKeysCompanion(
                id: id,
                name: name,
                type: type,
                privateKey: privateKey,
                publicKey: publicKey,
                fingerprint: fingerprint,
                passphrase: passphrase,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required String privateKey,
                required String publicKey,
                required String fingerprint,
                Value<String?> passphrase = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SshKeysCompanion.insert(
                id: id,
                name: name,
                type: type,
                privateKey: privateKey,
                publicKey: publicKey,
                fingerprint: fingerprint,
                passphrase: passphrase,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SshKeysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SshKeysTable,
      SshKey,
      $$SshKeysTableFilterComposer,
      $$SshKeysTableOrderingComposer,
      $$SshKeysTableAnnotationComposer,
      $$SshKeysTableCreateCompanionBuilder,
      $$SshKeysTableUpdateCompanionBuilder,
      (SshKey, BaseReferences<_$AppDatabase, $SshKeysTable, SshKey>),
      SshKey,
      PrefetchHooks Function()
    >;
typedef $$SnippetsTableCreateCompanionBuilder =
    SnippetsCompanion Function({
      required String id,
      required String name,
      required String command,
      Value<String> variables,
      Value<String?> group,
      Value<String> tags,
      Value<bool> isFavorite,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SnippetsTableUpdateCompanionBuilder =
    SnippetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> command,
      Value<String> variables,
      Value<String?> group,
      Value<String> tags,
      Value<bool> isFavorite,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SnippetsTableFilterComposer
    extends Composer<_$AppDatabase, $SnippetsTable> {
  $$SnippetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get command => $composableBuilder(
    column: $table.command,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variables => $composableBuilder(
    column: $table.variables,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SnippetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SnippetsTable> {
  $$SnippetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get command => $composableBuilder(
    column: $table.command,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variables => $composableBuilder(
    column: $table.variables,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SnippetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnippetsTable> {
  $$SnippetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get command =>
      $composableBuilder(column: $table.command, builder: (column) => column);

  GeneratedColumn<String> get variables =>
      $composableBuilder(column: $table.variables, builder: (column) => column);

  GeneratedColumn<String> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SnippetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnippetsTable,
          Snippet,
          $$SnippetsTableFilterComposer,
          $$SnippetsTableOrderingComposer,
          $$SnippetsTableAnnotationComposer,
          $$SnippetsTableCreateCompanionBuilder,
          $$SnippetsTableUpdateCompanionBuilder,
          (Snippet, BaseReferences<_$AppDatabase, $SnippetsTable, Snippet>),
          Snippet,
          PrefetchHooks Function()
        > {
  $$SnippetsTableTableManager(_$AppDatabase db, $SnippetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SnippetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SnippetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SnippetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> command = const Value.absent(),
                Value<String> variables = const Value.absent(),
                Value<String?> group = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnippetsCompanion(
                id: id,
                name: name,
                command: command,
                variables: variables,
                group: group,
                tags: tags,
                isFavorite: isFavorite,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String command,
                Value<String> variables = const Value.absent(),
                Value<String?> group = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnippetsCompanion.insert(
                id: id,
                name: name,
                command: command,
                variables: variables,
                group: group,
                tags: tags,
                isFavorite: isFavorite,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SnippetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnippetsTable,
      Snippet,
      $$SnippetsTableFilterComposer,
      $$SnippetsTableOrderingComposer,
      $$SnippetsTableAnnotationComposer,
      $$SnippetsTableCreateCompanionBuilder,
      $$SnippetsTableUpdateCompanionBuilder,
      (Snippet, BaseReferences<_$AppDatabase, $SnippetsTable, Snippet>),
      Snippet,
      PrefetchHooks Function()
    >;
typedef $$PortForwardsTableCreateCompanionBuilder =
    PortForwardsCompanion Function({
      required String id,
      required String name,
      required String type,
      required String hostId,
      required int localPort,
      Value<String?> remoteHost,
      Value<int?> remotePort,
      Value<String> bindAddress,
      Value<bool> autoStart,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PortForwardsTableUpdateCompanionBuilder =
    PortForwardsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String> hostId,
      Value<int> localPort,
      Value<String?> remoteHost,
      Value<int?> remotePort,
      Value<String> bindAddress,
      Value<bool> autoStart,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PortForwardsTableFilterComposer
    extends Composer<_$AppDatabase, $PortForwardsTable> {
  $$PortForwardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostId => $composableBuilder(
    column: $table.hostId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localPort => $composableBuilder(
    column: $table.localPort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteHost => $composableBuilder(
    column: $table.remoteHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remotePort => $composableBuilder(
    column: $table.remotePort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bindAddress => $composableBuilder(
    column: $table.bindAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoStart => $composableBuilder(
    column: $table.autoStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PortForwardsTableOrderingComposer
    extends Composer<_$AppDatabase, $PortForwardsTable> {
  $$PortForwardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostId => $composableBuilder(
    column: $table.hostId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localPort => $composableBuilder(
    column: $table.localPort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteHost => $composableBuilder(
    column: $table.remoteHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remotePort => $composableBuilder(
    column: $table.remotePort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bindAddress => $composableBuilder(
    column: $table.bindAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoStart => $composableBuilder(
    column: $table.autoStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PortForwardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PortForwardsTable> {
  $$PortForwardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get hostId =>
      $composableBuilder(column: $table.hostId, builder: (column) => column);

  GeneratedColumn<int> get localPort =>
      $composableBuilder(column: $table.localPort, builder: (column) => column);

  GeneratedColumn<String> get remoteHost => $composableBuilder(
    column: $table.remoteHost,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remotePort => $composableBuilder(
    column: $table.remotePort,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bindAddress => $composableBuilder(
    column: $table.bindAddress,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoStart =>
      $composableBuilder(column: $table.autoStart, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PortForwardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PortForwardsTable,
          PortForward,
          $$PortForwardsTableFilterComposer,
          $$PortForwardsTableOrderingComposer,
          $$PortForwardsTableAnnotationComposer,
          $$PortForwardsTableCreateCompanionBuilder,
          $$PortForwardsTableUpdateCompanionBuilder,
          (
            PortForward,
            BaseReferences<_$AppDatabase, $PortForwardsTable, PortForward>,
          ),
          PortForward,
          PrefetchHooks Function()
        > {
  $$PortForwardsTableTableManager(_$AppDatabase db, $PortForwardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PortForwardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PortForwardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$PortForwardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> hostId = const Value.absent(),
                Value<int> localPort = const Value.absent(),
                Value<String?> remoteHost = const Value.absent(),
                Value<int?> remotePort = const Value.absent(),
                Value<String> bindAddress = const Value.absent(),
                Value<bool> autoStart = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PortForwardsCompanion(
                id: id,
                name: name,
                type: type,
                hostId: hostId,
                localPort: localPort,
                remoteHost: remoteHost,
                remotePort: remotePort,
                bindAddress: bindAddress,
                autoStart: autoStart,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required String hostId,
                required int localPort,
                Value<String?> remoteHost = const Value.absent(),
                Value<int?> remotePort = const Value.absent(),
                Value<String> bindAddress = const Value.absent(),
                Value<bool> autoStart = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PortForwardsCompanion.insert(
                id: id,
                name: name,
                type: type,
                hostId: hostId,
                localPort: localPort,
                remoteHost: remoteHost,
                remotePort: remotePort,
                bindAddress: bindAddress,
                autoStart: autoStart,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PortForwardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PortForwardsTable,
      PortForward,
      $$PortForwardsTableFilterComposer,
      $$PortForwardsTableOrderingComposer,
      $$PortForwardsTableAnnotationComposer,
      $$PortForwardsTableCreateCompanionBuilder,
      $$PortForwardsTableUpdateCompanionBuilder,
      (
        PortForward,
        BaseReferences<_$AppDatabase, $PortForwardsTable, PortForward>,
      ),
      PortForward,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$GitReposTableCreateCompanionBuilder =
    GitReposCompanion Function({
      required String id,
      required String hostId,
      required String remotePath,
      Value<String?> label,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$GitReposTableUpdateCompanionBuilder =
    GitReposCompanion Function({
      Value<String> id,
      Value<String> hostId,
      Value<String> remotePath,
      Value<String?> label,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$GitReposTableReferences
    extends BaseReferences<_$AppDatabase, $GitReposTable, GitRepo> {
  $$GitReposTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HostsTable _hostIdTable(_$AppDatabase db) => db.hosts.createAlias(
    $_aliasNameGenerator(db.gitRepos.hostId, db.hosts.id),
  );

  $$HostsTableProcessedTableManager get hostId {
    final $_column = $_itemColumn<String>('host_id')!;

    final manager = $$HostsTableTableManager(
      $_db,
      $_db.hosts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_hostIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GitReposTableFilterComposer
    extends Composer<_$AppDatabase, $GitReposTable> {
  $$GitReposTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$HostsTableFilterComposer get hostId {
    final $$HostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hostId,
      referencedTable: $db.hosts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HostsTableFilterComposer(
            $db: $db,
            $table: $db.hosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GitReposTableOrderingComposer
    extends Composer<_$AppDatabase, $GitReposTable> {
  $$GitReposTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$HostsTableOrderingComposer get hostId {
    final $$HostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hostId,
      referencedTable: $db.hosts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HostsTableOrderingComposer(
            $db: $db,
            $table: $db.hosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GitReposTableAnnotationComposer
    extends Composer<_$AppDatabase, $GitReposTable> {
  $$GitReposTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$HostsTableAnnotationComposer get hostId {
    final $$HostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hostId,
      referencedTable: $db.hosts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HostsTableAnnotationComposer(
            $db: $db,
            $table: $db.hosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GitReposTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GitReposTable,
          GitRepo,
          $$GitReposTableFilterComposer,
          $$GitReposTableOrderingComposer,
          $$GitReposTableAnnotationComposer,
          $$GitReposTableCreateCompanionBuilder,
          $$GitReposTableUpdateCompanionBuilder,
          (GitRepo, $$GitReposTableReferences),
          GitRepo,
          PrefetchHooks Function({bool hostId})
        > {
  $$GitReposTableTableManager(_$AppDatabase db, $GitReposTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$GitReposTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$GitReposTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$GitReposTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hostId = const Value.absent(),
                Value<String> remotePath = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GitReposCompanion(
                id: id,
                hostId: hostId,
                remotePath: remotePath,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hostId,
                required String remotePath,
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GitReposCompanion.insert(
                id: id,
                hostId: hostId,
                remotePath: remotePath,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$GitReposTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({hostId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (hostId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.hostId,
                            referencedTable: $$GitReposTableReferences
                                ._hostIdTable(db),
                            referencedColumn:
                                $$GitReposTableReferences._hostIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GitReposTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GitReposTable,
      GitRepo,
      $$GitReposTableFilterComposer,
      $$GitReposTableOrderingComposer,
      $$GitReposTableAnnotationComposer,
      $$GitReposTableCreateCompanionBuilder,
      $$GitReposTableUpdateCompanionBuilder,
      (GitRepo, $$GitReposTableReferences),
      GitRepo,
      PrefetchHooks Function({bool hostId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HostsTableTableManager get hosts =>
      $$HostsTableTableManager(_db, _db.hosts);
  $$SshKeysTableTableManager get sshKeys =>
      $$SshKeysTableTableManager(_db, _db.sshKeys);
  $$SnippetsTableTableManager get snippets =>
      $$SnippetsTableTableManager(_db, _db.snippets);
  $$PortForwardsTableTableManager get portForwards =>
      $$PortForwardsTableTableManager(_db, _db.portForwards);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$GitReposTableTableManager get gitRepos =>
      $$GitReposTableTableManager(_db, _db.gitRepos);
}
