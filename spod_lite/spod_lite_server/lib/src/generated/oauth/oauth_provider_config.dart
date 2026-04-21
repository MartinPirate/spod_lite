/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

/// Admin-managed OAuth provider credentials. One row per provider
/// (google, github, apple). clientSecret is stored plaintext — access
/// is restricted to admin-scoped endpoints. If you need at-rest
/// encryption, hold the secret in an env var and leave this row blank
/// for that provider; the provider resolves clientSecret from env
/// when the column is null.
abstract class OAuthProviderConfig
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  OAuthProviderConfig._({
    this.id,
    required this.provider,
    required this.clientId,
    this.clientSecret,
    bool? enabled,
    this.createdAt,
    this.updatedAt,
  }) : enabled = enabled ?? true;

  factory OAuthProviderConfig({
    int? id,
    required String provider,
    required String clientId,
    String? clientSecret,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OAuthProviderConfigImpl;

  factory OAuthProviderConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return OAuthProviderConfig(
      id: jsonSerialization['id'] as int?,
      provider: jsonSerialization['provider'] as String,
      clientId: jsonSerialization['clientId'] as String,
      clientSecret: jsonSerialization['clientSecret'] as String?,
      enabled: jsonSerialization['enabled'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = OAuthProviderConfigTable();

  static const db = OAuthProviderConfigRepository._();

  @override
  int? id;

  String provider;

  String clientId;

  String? clientSecret;

  bool enabled;

  DateTime? createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [OAuthProviderConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OAuthProviderConfig copyWith({
    int? id,
    String? provider,
    String? clientId,
    String? clientSecret,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OAuthProviderConfig',
      if (id != null) 'id': id,
      'provider': provider,
      'clientId': clientId,
      if (clientSecret != null) 'clientSecret': clientSecret,
      'enabled': enabled,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OAuthProviderConfig',
      if (id != null) 'id': id,
      'provider': provider,
      'clientId': clientId,
      if (clientSecret != null) 'clientSecret': clientSecret,
      'enabled': enabled,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static OAuthProviderConfigInclude include() {
    return OAuthProviderConfigInclude._();
  }

  static OAuthProviderConfigIncludeList includeList({
    _i1.WhereExpressionBuilder<OAuthProviderConfigTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OAuthProviderConfigTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OAuthProviderConfigTable>? orderByList,
    OAuthProviderConfigInclude? include,
  }) {
    return OAuthProviderConfigIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OAuthProviderConfig.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(OAuthProviderConfig.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OAuthProviderConfigImpl extends OAuthProviderConfig {
  _OAuthProviderConfigImpl({
    int? id,
    required String provider,
    required String clientId,
    String? clientSecret,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         provider: provider,
         clientId: clientId,
         clientSecret: clientSecret,
         enabled: enabled,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [OAuthProviderConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OAuthProviderConfig copyWith({
    Object? id = _Undefined,
    String? provider,
    String? clientId,
    Object? clientSecret = _Undefined,
    bool? enabled,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return OAuthProviderConfig(
      id: id is int? ? id : this.id,
      provider: provider ?? this.provider,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret is String? ? clientSecret : this.clientSecret,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class OAuthProviderConfigUpdateTable
    extends _i1.UpdateTable<OAuthProviderConfigTable> {
  OAuthProviderConfigUpdateTable(super.table);

  _i1.ColumnValue<String, String> provider(String value) => _i1.ColumnValue(
    table.provider,
    value,
  );

  _i1.ColumnValue<String, String> clientId(String value) => _i1.ColumnValue(
    table.clientId,
    value,
  );

  _i1.ColumnValue<String, String> clientSecret(String? value) =>
      _i1.ColumnValue(
        table.clientSecret,
        value,
      );

  _i1.ColumnValue<bool, bool> enabled(bool value) => _i1.ColumnValue(
    table.enabled,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class OAuthProviderConfigTable extends _i1.Table<int?> {
  OAuthProviderConfigTable({super.tableRelation})
    : super(tableName: 'oauth_provider_config') {
    updateTable = OAuthProviderConfigUpdateTable(this);
    provider = _i1.ColumnString(
      'provider',
      this,
    );
    clientId = _i1.ColumnString(
      'clientId',
      this,
    );
    clientSecret = _i1.ColumnString(
      'clientSecret',
      this,
    );
    enabled = _i1.ColumnBool(
      'enabled',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final OAuthProviderConfigUpdateTable updateTable;

  late final _i1.ColumnString provider;

  late final _i1.ColumnString clientId;

  late final _i1.ColumnString clientSecret;

  late final _i1.ColumnBool enabled;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    provider,
    clientId,
    clientSecret,
    enabled,
    createdAt,
    updatedAt,
  ];
}

class OAuthProviderConfigInclude extends _i1.IncludeObject {
  OAuthProviderConfigInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => OAuthProviderConfig.t;
}

class OAuthProviderConfigIncludeList extends _i1.IncludeList {
  OAuthProviderConfigIncludeList._({
    _i1.WhereExpressionBuilder<OAuthProviderConfigTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OAuthProviderConfig.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => OAuthProviderConfig.t;
}

class OAuthProviderConfigRepository {
  const OAuthProviderConfigRepository._();

  /// Returns a list of [OAuthProviderConfig]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<OAuthProviderConfig>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OAuthProviderConfigTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OAuthProviderConfigTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OAuthProviderConfigTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OAuthProviderConfig>(
      where: where?.call(OAuthProviderConfig.t),
      orderBy: orderBy?.call(OAuthProviderConfig.t),
      orderByList: orderByList?.call(OAuthProviderConfig.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [OAuthProviderConfig] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<OAuthProviderConfig?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OAuthProviderConfigTable>? where,
    int? offset,
    _i1.OrderByBuilder<OAuthProviderConfigTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OAuthProviderConfigTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OAuthProviderConfig>(
      where: where?.call(OAuthProviderConfig.t),
      orderBy: orderBy?.call(OAuthProviderConfig.t),
      orderByList: orderByList?.call(OAuthProviderConfig.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OAuthProviderConfig] by its [id] or null if no such row exists.
  Future<OAuthProviderConfig?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OAuthProviderConfig>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OAuthProviderConfig]s in the list and returns the inserted rows.
  ///
  /// The returned [OAuthProviderConfig]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<OAuthProviderConfig>> insert(
    _i1.DatabaseSession session,
    List<OAuthProviderConfig> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<OAuthProviderConfig>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [OAuthProviderConfig] and returns the inserted row.
  ///
  /// The returned [OAuthProviderConfig] will have its `id` field set.
  Future<OAuthProviderConfig> insertRow(
    _i1.DatabaseSession session,
    OAuthProviderConfig row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<OAuthProviderConfig>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [OAuthProviderConfig]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<OAuthProviderConfig>> update(
    _i1.DatabaseSession session,
    List<OAuthProviderConfig> rows, {
    _i1.ColumnSelections<OAuthProviderConfigTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<OAuthProviderConfig>(
      rows,
      columns: columns?.call(OAuthProviderConfig.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OAuthProviderConfig]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OAuthProviderConfig> updateRow(
    _i1.DatabaseSession session,
    OAuthProviderConfig row, {
    _i1.ColumnSelections<OAuthProviderConfigTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<OAuthProviderConfig>(
      row,
      columns: columns?.call(OAuthProviderConfig.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OAuthProviderConfig] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OAuthProviderConfig?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<OAuthProviderConfigUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<OAuthProviderConfig>(
      id,
      columnValues: columnValues(OAuthProviderConfig.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OAuthProviderConfig]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<OAuthProviderConfig>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<OAuthProviderConfigUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<OAuthProviderConfigTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OAuthProviderConfigTable>? orderBy,
    _i1.OrderByListBuilder<OAuthProviderConfigTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<OAuthProviderConfig>(
      columnValues: columnValues(OAuthProviderConfig.t.updateTable),
      where: where(OAuthProviderConfig.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OAuthProviderConfig.t),
      orderByList: orderByList?.call(OAuthProviderConfig.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [OAuthProviderConfig]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<OAuthProviderConfig>> delete(
    _i1.DatabaseSession session,
    List<OAuthProviderConfig> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<OAuthProviderConfig>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [OAuthProviderConfig].
  Future<OAuthProviderConfig> deleteRow(
    _i1.DatabaseSession session,
    OAuthProviderConfig row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OAuthProviderConfig>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<OAuthProviderConfig>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<OAuthProviderConfigTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<OAuthProviderConfig>(
      where: where(OAuthProviderConfig.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OAuthProviderConfigTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<OAuthProviderConfig>(
      where: where?.call(OAuthProviderConfig.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OAuthProviderConfig] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<OAuthProviderConfigTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OAuthProviderConfig>(
      where: where(OAuthProviderConfig.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
