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

/// A session token issued to an app end-user after sign-in.
abstract class AppSession
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AppSession._({
    this.id,
    required this.token,
    required this.appUserId,
    this.createdAt,
    required this.expiresAt,
  });

  factory AppSession({
    int? id,
    required String token,
    required int appUserId,
    DateTime? createdAt,
    required DateTime expiresAt,
  }) = _AppSessionImpl;

  factory AppSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppSession(
      id: jsonSerialization['id'] as int?,
      token: jsonSerialization['token'] as String,
      appUserId: jsonSerialization['appUserId'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = AppSessionTable();

  static const db = AppSessionRepository._();

  @override
  int? id;

  String token;

  int appUserId;

  DateTime? createdAt;

  DateTime expiresAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AppSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AppSession copyWith({
    int? id,
    String? token,
    int? appUserId,
    DateTime? createdAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppSession',
      if (id != null) 'id': id,
      'token': token,
      'appUserId': appUserId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppSession',
      if (id != null) 'id': id,
      'token': token,
      'appUserId': appUserId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  static AppSessionInclude include() {
    return AppSessionInclude._();
  }

  static AppSessionIncludeList includeList({
    _i1.WhereExpressionBuilder<AppSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppSessionTable>? orderByList,
    AppSessionInclude? include,
  }) {
    return AppSessionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppSession.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AppSession.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppSessionImpl extends AppSession {
  _AppSessionImpl({
    int? id,
    required String token,
    required int appUserId,
    DateTime? createdAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         token: token,
         appUserId: appUserId,
         createdAt: createdAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [AppSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AppSession copyWith({
    Object? id = _Undefined,
    String? token,
    int? appUserId,
    Object? createdAt = _Undefined,
    DateTime? expiresAt,
  }) {
    return AppSession(
      id: id is int? ? id : this.id,
      token: token ?? this.token,
      appUserId: appUserId ?? this.appUserId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class AppSessionUpdateTable extends _i1.UpdateTable<AppSessionTable> {
  AppSessionUpdateTable(super.table);

  _i1.ColumnValue<String, String> token(String value) => _i1.ColumnValue(
    table.token,
    value,
  );

  _i1.ColumnValue<int, int> appUserId(int value) => _i1.ColumnValue(
    table.appUserId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );
}

class AppSessionTable extends _i1.Table<int?> {
  AppSessionTable({super.tableRelation}) : super(tableName: 'app_session') {
    updateTable = AppSessionUpdateTable(this);
    token = _i1.ColumnString(
      'token',
      this,
    );
    appUserId = _i1.ColumnInt(
      'appUserId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final AppSessionUpdateTable updateTable;

  late final _i1.ColumnString token;

  late final _i1.ColumnInt appUserId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime expiresAt;

  @override
  List<_i1.Column> get columns => [
    id,
    token,
    appUserId,
    createdAt,
    expiresAt,
  ];
}

class AppSessionInclude extends _i1.IncludeObject {
  AppSessionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => AppSession.t;
}

class AppSessionIncludeList extends _i1.IncludeList {
  AppSessionIncludeList._({
    _i1.WhereExpressionBuilder<AppSessionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AppSession.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AppSession.t;
}

class AppSessionRepository {
  const AppSessionRepository._();

  /// Returns a list of [AppSession]s matching the given query parameters.
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
  Future<List<AppSession>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AppSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppSessionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AppSession>(
      where: where?.call(AppSession.t),
      orderBy: orderBy?.call(AppSession.t),
      orderByList: orderByList?.call(AppSession.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AppSession] matching the given query parameters.
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
  Future<AppSession?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AppSessionTable>? where,
    int? offset,
    _i1.OrderByBuilder<AppSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppSessionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AppSession>(
      where: where?.call(AppSession.t),
      orderBy: orderBy?.call(AppSession.t),
      orderByList: orderByList?.call(AppSession.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AppSession] by its [id] or null if no such row exists.
  Future<AppSession?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AppSession>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AppSession]s in the list and returns the inserted rows.
  ///
  /// The returned [AppSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AppSession>> insert(
    _i1.DatabaseSession session,
    List<AppSession> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AppSession>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AppSession] and returns the inserted row.
  ///
  /// The returned [AppSession] will have its `id` field set.
  Future<AppSession> insertRow(
    _i1.DatabaseSession session,
    AppSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AppSession>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AppSession]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AppSession>> update(
    _i1.DatabaseSession session,
    List<AppSession> rows, {
    _i1.ColumnSelections<AppSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AppSession>(
      rows,
      columns: columns?.call(AppSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AppSession]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AppSession> updateRow(
    _i1.DatabaseSession session,
    AppSession row, {
    _i1.ColumnSelections<AppSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AppSession>(
      row,
      columns: columns?.call(AppSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AppSession] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AppSession?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<AppSessionUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AppSession>(
      id,
      columnValues: columnValues(AppSession.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AppSession]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AppSession>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AppSessionUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AppSessionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppSessionTable>? orderBy,
    _i1.OrderByListBuilder<AppSessionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AppSession>(
      columnValues: columnValues(AppSession.t.updateTable),
      where: where(AppSession.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppSession.t),
      orderByList: orderByList?.call(AppSession.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AppSession]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AppSession>> delete(
    _i1.DatabaseSession session,
    List<AppSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AppSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AppSession].
  Future<AppSession> deleteRow(
    _i1.DatabaseSession session,
    AppSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AppSession>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AppSession>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AppSessionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AppSession>(
      where: where(AppSession.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AppSessionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AppSession>(
      where: where?.call(AppSession.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AppSession] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AppSessionTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AppSession>(
      where: where(AppSession.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
