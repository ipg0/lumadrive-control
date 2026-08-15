// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SavedDevicesTable extends SavedDevices
    with TableInfo<$SavedDevicesTable, SavedDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _advNameMeta = const VerificationMeta(
    'advName',
  );
  @override
  late final GeneratedColumn<String> advName = GeneratedColumn<String>(
    'adv_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastConnectedMeta = const VerificationMeta(
    'lastConnected',
  );
  @override
  late final GeneratedColumn<DateTime> lastConnected =
      GeneratedColumn<DateTime>(
        'last_connected',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [remoteId, advName, lastConnected];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('adv_name')) {
      context.handle(
        _advNameMeta,
        advName.isAcceptableOrUnknown(data['adv_name']!, _advNameMeta),
      );
    } else if (isInserting) {
      context.missing(_advNameMeta);
    }
    if (data.containsKey('last_connected')) {
      context.handle(
        _lastConnectedMeta,
        lastConnected.isAcceptableOrUnknown(
          data['last_connected']!,
          _lastConnectedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastConnectedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  SavedDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedDevice(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
      advName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adv_name'],
      )!,
      lastConnected: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_connected'],
      )!,
    );
  }

  @override
  $SavedDevicesTable createAlias(String alias) {
    return $SavedDevicesTable(attachedDatabase, alias);
  }
}

class SavedDevice extends DataClass implements Insertable<SavedDevice> {
  final String remoteId;
  final String advName;
  final DateTime lastConnected;
  const SavedDevice({
    required this.remoteId,
    required this.advName,
    required this.lastConnected,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['adv_name'] = Variable<String>(advName);
    map['last_connected'] = Variable<DateTime>(lastConnected);
    return map;
  }

  SavedDevicesCompanion toCompanion(bool nullToAbsent) {
    return SavedDevicesCompanion(
      remoteId: Value(remoteId),
      advName: Value(advName),
      lastConnected: Value(lastConnected),
    );
  }

  factory SavedDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedDevice(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      advName: serializer.fromJson<String>(json['advName']),
      lastConnected: serializer.fromJson<DateTime>(json['lastConnected']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'advName': serializer.toJson<String>(advName),
      'lastConnected': serializer.toJson<DateTime>(lastConnected),
    };
  }

  SavedDevice copyWith({
    String? remoteId,
    String? advName,
    DateTime? lastConnected,
  }) => SavedDevice(
    remoteId: remoteId ?? this.remoteId,
    advName: advName ?? this.advName,
    lastConnected: lastConnected ?? this.lastConnected,
  );
  SavedDevice copyWithCompanion(SavedDevicesCompanion data) {
    return SavedDevice(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      advName: data.advName.present ? data.advName.value : this.advName,
      lastConnected: data.lastConnected.present
          ? data.lastConnected.value
          : this.lastConnected,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedDevice(')
          ..write('remoteId: $remoteId, ')
          ..write('advName: $advName, ')
          ..write('lastConnected: $lastConnected')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(remoteId, advName, lastConnected);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedDevice &&
          other.remoteId == this.remoteId &&
          other.advName == this.advName &&
          other.lastConnected == this.lastConnected);
}

class SavedDevicesCompanion extends UpdateCompanion<SavedDevice> {
  final Value<String> remoteId;
  final Value<String> advName;
  final Value<DateTime> lastConnected;
  final Value<int> rowid;
  const SavedDevicesCompanion({
    this.remoteId = const Value.absent(),
    this.advName = const Value.absent(),
    this.lastConnected = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedDevicesCompanion.insert({
    required String remoteId,
    required String advName,
    required DateTime lastConnected,
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       advName = Value(advName),
       lastConnected = Value(lastConnected);
  static Insertable<SavedDevice> custom({
    Expression<String>? remoteId,
    Expression<String>? advName,
    Expression<DateTime>? lastConnected,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (advName != null) 'adv_name': advName,
      if (lastConnected != null) 'last_connected': lastConnected,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedDevicesCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? advName,
    Value<DateTime>? lastConnected,
    Value<int>? rowid,
  }) {
    return SavedDevicesCompanion(
      remoteId: remoteId ?? this.remoteId,
      advName: advName ?? this.advName,
      lastConnected: lastConnected ?? this.lastConnected,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (advName.present) {
      map['adv_name'] = Variable<String>(advName.value);
    }
    if (lastConnected.present) {
      map['last_connected'] = Variable<DateTime>(lastConnected.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedDevicesCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('advName: $advName, ')
          ..write('lastConnected: $lastConnected, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SavedDevicesTable savedDevices = $SavedDevicesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [savedDevices];
}

typedef $$SavedDevicesTableCreateCompanionBuilder =
    SavedDevicesCompanion Function({
      required String remoteId,
      required String advName,
      required DateTime lastConnected,
      Value<int> rowid,
    });
typedef $$SavedDevicesTableUpdateCompanionBuilder =
    SavedDevicesCompanion Function({
      Value<String> remoteId,
      Value<String> advName,
      Value<DateTime> lastConnected,
      Value<int> rowid,
    });

class $$SavedDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedDevicesTable> {
  $$SavedDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get advName => $composableBuilder(
    column: $table.advName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastConnected => $composableBuilder(
    column: $table.lastConnected,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedDevicesTable> {
  $$SavedDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get advName => $composableBuilder(
    column: $table.advName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastConnected => $composableBuilder(
    column: $table.lastConnected,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedDevicesTable> {
  $$SavedDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get advName =>
      $composableBuilder(column: $table.advName, builder: (column) => column);

  GeneratedColumn<DateTime> get lastConnected => $composableBuilder(
    column: $table.lastConnected,
    builder: (column) => column,
  );
}

class $$SavedDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedDevicesTable,
          SavedDevice,
          $$SavedDevicesTableFilterComposer,
          $$SavedDevicesTableOrderingComposer,
          $$SavedDevicesTableAnnotationComposer,
          $$SavedDevicesTableCreateCompanionBuilder,
          $$SavedDevicesTableUpdateCompanionBuilder,
          (
            SavedDevice,
            BaseReferences<_$AppDatabase, $SavedDevicesTable, SavedDevice>,
          ),
          SavedDevice,
          PrefetchHooks Function()
        > {
  $$SavedDevicesTableTableManager(_$AppDatabase db, $SavedDevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> advName = const Value.absent(),
                Value<DateTime> lastConnected = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedDevicesCompanion(
                remoteId: remoteId,
                advName: advName,
                lastConnected: lastConnected,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String advName,
                required DateTime lastConnected,
                Value<int> rowid = const Value.absent(),
              }) => SavedDevicesCompanion.insert(
                remoteId: remoteId,
                advName: advName,
                lastConnected: lastConnected,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedDevicesTable,
      SavedDevice,
      $$SavedDevicesTableFilterComposer,
      $$SavedDevicesTableOrderingComposer,
      $$SavedDevicesTableAnnotationComposer,
      $$SavedDevicesTableCreateCompanionBuilder,
      $$SavedDevicesTableUpdateCompanionBuilder,
      (
        SavedDevice,
        BaseReferences<_$AppDatabase, $SavedDevicesTable, SavedDevice>,
      ),
      SavedDevice,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SavedDevicesTableTableManager get savedDevices =>
      $$SavedDevicesTableTableManager(_db, _db.savedDevices);
}
