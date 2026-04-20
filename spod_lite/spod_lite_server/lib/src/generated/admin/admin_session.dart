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

/// A dashboard session token issued after successful admin sign-in.
abstract class AdminSession
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AdminSession._({
    this.id,
    required this.token,
    required this.adminUserId,
    this.createdAt,
    required this.expiresAt,
  });

  factory AdminSession({
    int? id,
    required String token,
    required int adminUserId,
    DateTime? createdAt,
    required DateTime expiresAt,
  }) = _AdminSessionImpl;

  factory AdminSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminSession(
      id: jsonSerialization['id'] as int?,
      token: jsonSerialization['token'] as String,
      adminUserId: jsonSerialization['adminUserId'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = AdminSessionTable();

  static const db = AdminSessionRepository._();

  @override
  int? id;

  String token;

  int adminUserId;

  DateTime? createdAt;

  DateTime expiresAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AdminSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminSession copyWith({
    int? id,
    String? token,
    int? adminUserId,
    DateTime? createdAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminSession',
      if (id != null) 'id': id,
      'token': token,
      'adminUserId': adminUserId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminSession',
      if (id != null) 'id': id,
      'token': token,
      'adminUserId': adminUserId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  static AdminSessionInclude include() {
    return AdminSessionInclude._();
  }

  static AdminSessionIncludeList includeList({
    _i1.WhereExpressionBuilder<AdminSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AdminSessionTable>? orderByList,
    AdminSessionInclude? include,
  }) {
    return AdminSessionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AdminSession.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AdminSession.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminSessionImpl extends AdminSession {
  _AdminSessionImpl({
    int? id,
    required String token,
    required int adminUserId,
    DateTime? createdAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         token: token,
         adminUserId: adminUserId,
         createdAt: createdAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [AdminSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminSession copyWith({
    Object? id = _Undefined,
    String? token,
    int? adminUserId,
    Object? createdAt = _Undefined,
    DateTime? expiresAt,
  }) {
    return AdminSession(
      id: id is int? ? id : this.id,
      token: token ?? this.token,
      adminUserId: adminUserId ?? this.adminUserId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class AdminSessionUpdateTable extends _i1.UpdateTable<AdminSessionTable> {
  AdminSessionUpdateTable(super.table);

  _i1.ColumnValue<String, String> token(String value) => _i1.ColumnValue(
    table.token,
    value,
  );

  _i1.ColumnValue<int, int> adminUserId(int value) => _i1.ColumnValue(
    table.adminUserId,
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

class AdminSessionTable extends _i1.Table<int?> {
  AdminSessionTable({super.tableRelation}) : super(tableName: 'admin_session') {
    updateTable = AdminSessionUpdateTable(this);
    token = _i1.ColumnString(
      'token',
      this,
    );
    adminUserId = _i1.ColumnInt(
      'adminUserId',
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

  late final AdminSessionUpdateTable updateTable;

  late final _i1.ColumnString token;

  late final _i1.ColumnInt adminUserId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime expiresAt;

  @override
  List<_i1.Column> get columns => [
    id,
    token,
    adminUserId,
    createdAt,
    expiresAt,
  ];
}

class AdminSessionInclude extends _i1.IncludeObject {
  AdminSessionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => AdminSession.t;
}

class AdminSessionIncludeList extends _i1.IncludeList {
  AdminSessionIncludeList._({
    _i1.WhereExpressionBuilder<AdminSessionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AdminSession.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AdminSession.t;
}

class AdminSessionRepository {
  const AdminSessionRepository._();

  /// Returns a list of [AdminSession]s matching the given query parameters.
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
  Future<List<AdminSession>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AdminSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AdminSessionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AdminSession>(
      where: where?.call(AdminSession.t),
      orderBy: orderBy?.call(AdminSession.t),
      orderByList: orderByList?.call(AdminSession.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AdminSession] matching the given query parameters.
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
  Future<AdminSession?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AdminSessionTable>? where,
    int? offset,
    _i1.OrderByBuilder<AdminSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AdminSessionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AdminSession>(
      where: where?.call(AdminSession.t),
      orderBy: orderBy?.call(AdminSession.t),
      orderByList: orderByList?.call(AdminSession.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AdminSession] by its [id] or null if no such row exists.
  Future<AdminSession?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AdminSession>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AdminSession]s in the list and returns the inserted rows.
  ///
  /// The returned [AdminSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AdminSession>> insert(
    _i1.DatabaseSession session,
    List<AdminSession> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AdminSession>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AdminSession] and returns the inserted row.
  ///
  /// The returned [AdminSession] will have its `id` field set.
  Future<AdminSession> insertRow(
    _i1.DatabaseSession session,
    AdminSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AdminSession>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AdminSession]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AdminSession>> update(
    _i1.DatabaseSession session,
    List<AdminSession> rows, {
    _i1.ColumnSelections<AdminSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AdminSession>(
      rows,
      columns: columns?.call(AdminSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AdminSession]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AdminSession> updateRow(
    _i1.DatabaseSession session,
    AdminSession row, {
    _i1.ColumnSelections<AdminSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AdminSession>(
      row,
      columns: columns?.call(AdminSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AdminSession] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AdminSession?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<AdminSessionUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AdminSession>(
      id,
      columnValues: columnValues(AdminSession.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AdminSession]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AdminSession>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AdminSessionUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AdminSessionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminSessionTable>? orderBy,
    _i1.OrderByListBuilder<AdminSessionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AdminSession>(
      columnValues: columnValues(AdminSession.t.updateTable),
      where: where(AdminSession.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AdminSession.t),
      orderByList: orderByList?.call(AdminSession.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AdminSession]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AdminSession>> delete(
    _i1.DatabaseSession session,
    List<AdminSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AdminSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AdminSession].
  Future<AdminSession> deleteRow(
    _i1.DatabaseSession session,
    AdminSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AdminSession>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AdminSession>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AdminSessionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AdminSession>(
      where: where(AdminSession.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AdminSessionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AdminSession>(
      where: where?.call(AdminSession.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AdminSession] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AdminSessionTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AdminSession>(
      where: where(AdminSession.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
