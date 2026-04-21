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

/// Links an `AppUser` to an external OAuth identity. Lets the same
/// account be reached via multiple providers (Google + email, etc).
abstract class UserOAuthLink
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  UserOAuthLink._({
    this.id,
    required this.appUserId,
    required this.provider,
    required this.providerUserId,
    required this.emailAtLink,
    this.linkedAt,
  });

  factory UserOAuthLink({
    int? id,
    required int appUserId,
    required String provider,
    required String providerUserId,
    required String emailAtLink,
    DateTime? linkedAt,
  }) = _UserOAuthLinkImpl;

  factory UserOAuthLink.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserOAuthLink(
      id: jsonSerialization['id'] as int?,
      appUserId: jsonSerialization['appUserId'] as int,
      provider: jsonSerialization['provider'] as String,
      providerUserId: jsonSerialization['providerUserId'] as String,
      emailAtLink: jsonSerialization['emailAtLink'] as String,
      linkedAt: jsonSerialization['linkedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['linkedAt']),
    );
  }

  static final t = UserOAuthLinkTable();

  static const db = UserOAuthLinkRepository._();

  @override
  int? id;

  int appUserId;

  String provider;

  String providerUserId;

  String emailAtLink;

  DateTime? linkedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserOAuthLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserOAuthLink copyWith({
    int? id,
    int? appUserId,
    String? provider,
    String? providerUserId,
    String? emailAtLink,
    DateTime? linkedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserOAuthLink',
      if (id != null) 'id': id,
      'appUserId': appUserId,
      'provider': provider,
      'providerUserId': providerUserId,
      'emailAtLink': emailAtLink,
      if (linkedAt != null) 'linkedAt': linkedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserOAuthLink',
      if (id != null) 'id': id,
      'appUserId': appUserId,
      'provider': provider,
      'providerUserId': providerUserId,
      'emailAtLink': emailAtLink,
      if (linkedAt != null) 'linkedAt': linkedAt?.toJson(),
    };
  }

  static UserOAuthLinkInclude include() {
    return UserOAuthLinkInclude._();
  }

  static UserOAuthLinkIncludeList includeList({
    _i1.WhereExpressionBuilder<UserOAuthLinkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserOAuthLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserOAuthLinkTable>? orderByList,
    UserOAuthLinkInclude? include,
  }) {
    return UserOAuthLinkIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserOAuthLink.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserOAuthLink.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserOAuthLinkImpl extends UserOAuthLink {
  _UserOAuthLinkImpl({
    int? id,
    required int appUserId,
    required String provider,
    required String providerUserId,
    required String emailAtLink,
    DateTime? linkedAt,
  }) : super._(
         id: id,
         appUserId: appUserId,
         provider: provider,
         providerUserId: providerUserId,
         emailAtLink: emailAtLink,
         linkedAt: linkedAt,
       );

  /// Returns a shallow copy of this [UserOAuthLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserOAuthLink copyWith({
    Object? id = _Undefined,
    int? appUserId,
    String? provider,
    String? providerUserId,
    String? emailAtLink,
    Object? linkedAt = _Undefined,
  }) {
    return UserOAuthLink(
      id: id is int? ? id : this.id,
      appUserId: appUserId ?? this.appUserId,
      provider: provider ?? this.provider,
      providerUserId: providerUserId ?? this.providerUserId,
      emailAtLink: emailAtLink ?? this.emailAtLink,
      linkedAt: linkedAt is DateTime? ? linkedAt : this.linkedAt,
    );
  }
}

class UserOAuthLinkUpdateTable extends _i1.UpdateTable<UserOAuthLinkTable> {
  UserOAuthLinkUpdateTable(super.table);

  _i1.ColumnValue<int, int> appUserId(int value) => _i1.ColumnValue(
    table.appUserId,
    value,
  );

  _i1.ColumnValue<String, String> provider(String value) => _i1.ColumnValue(
    table.provider,
    value,
  );

  _i1.ColumnValue<String, String> providerUserId(String value) =>
      _i1.ColumnValue(
        table.providerUserId,
        value,
      );

  _i1.ColumnValue<String, String> emailAtLink(String value) => _i1.ColumnValue(
    table.emailAtLink,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> linkedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.linkedAt,
        value,
      );
}

class UserOAuthLinkTable extends _i1.Table<int?> {
  UserOAuthLinkTable({super.tableRelation})
    : super(tableName: 'user_oauth_link') {
    updateTable = UserOAuthLinkUpdateTable(this);
    appUserId = _i1.ColumnInt(
      'appUserId',
      this,
    );
    provider = _i1.ColumnString(
      'provider',
      this,
    );
    providerUserId = _i1.ColumnString(
      'providerUserId',
      this,
    );
    emailAtLink = _i1.ColumnString(
      'emailAtLink',
      this,
    );
    linkedAt = _i1.ColumnDateTime(
      'linkedAt',
      this,
      hasDefault: true,
    );
  }

  late final UserOAuthLinkUpdateTable updateTable;

  late final _i1.ColumnInt appUserId;

  late final _i1.ColumnString provider;

  late final _i1.ColumnString providerUserId;

  late final _i1.ColumnString emailAtLink;

  late final _i1.ColumnDateTime linkedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    appUserId,
    provider,
    providerUserId,
    emailAtLink,
    linkedAt,
  ];
}

class UserOAuthLinkInclude extends _i1.IncludeObject {
  UserOAuthLinkInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserOAuthLink.t;
}

class UserOAuthLinkIncludeList extends _i1.IncludeList {
  UserOAuthLinkIncludeList._({
    _i1.WhereExpressionBuilder<UserOAuthLinkTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserOAuthLink.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserOAuthLink.t;
}

class UserOAuthLinkRepository {
  const UserOAuthLinkRepository._();

  /// Returns a list of [UserOAuthLink]s matching the given query parameters.
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
  Future<List<UserOAuthLink>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserOAuthLinkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserOAuthLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserOAuthLinkTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserOAuthLink>(
      where: where?.call(UserOAuthLink.t),
      orderBy: orderBy?.call(UserOAuthLink.t),
      orderByList: orderByList?.call(UserOAuthLink.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserOAuthLink] matching the given query parameters.
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
  Future<UserOAuthLink?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserOAuthLinkTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserOAuthLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserOAuthLinkTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserOAuthLink>(
      where: where?.call(UserOAuthLink.t),
      orderBy: orderBy?.call(UserOAuthLink.t),
      orderByList: orderByList?.call(UserOAuthLink.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserOAuthLink] by its [id] or null if no such row exists.
  Future<UserOAuthLink?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserOAuthLink>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserOAuthLink]s in the list and returns the inserted rows.
  ///
  /// The returned [UserOAuthLink]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<UserOAuthLink>> insert(
    _i1.DatabaseSession session,
    List<UserOAuthLink> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<UserOAuthLink>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [UserOAuthLink] and returns the inserted row.
  ///
  /// The returned [UserOAuthLink] will have its `id` field set.
  Future<UserOAuthLink> insertRow(
    _i1.DatabaseSession session,
    UserOAuthLink row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserOAuthLink>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserOAuthLink]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserOAuthLink>> update(
    _i1.DatabaseSession session,
    List<UserOAuthLink> rows, {
    _i1.ColumnSelections<UserOAuthLinkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserOAuthLink>(
      rows,
      columns: columns?.call(UserOAuthLink.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserOAuthLink]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserOAuthLink> updateRow(
    _i1.DatabaseSession session,
    UserOAuthLink row, {
    _i1.ColumnSelections<UserOAuthLinkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserOAuthLink>(
      row,
      columns: columns?.call(UserOAuthLink.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserOAuthLink] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserOAuthLink?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<UserOAuthLinkUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserOAuthLink>(
      id,
      columnValues: columnValues(UserOAuthLink.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserOAuthLink]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserOAuthLink>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<UserOAuthLinkUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserOAuthLinkTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserOAuthLinkTable>? orderBy,
    _i1.OrderByListBuilder<UserOAuthLinkTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserOAuthLink>(
      columnValues: columnValues(UserOAuthLink.t.updateTable),
      where: where(UserOAuthLink.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserOAuthLink.t),
      orderByList: orderByList?.call(UserOAuthLink.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserOAuthLink]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserOAuthLink>> delete(
    _i1.DatabaseSession session,
    List<UserOAuthLink> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserOAuthLink>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserOAuthLink].
  Future<UserOAuthLink> deleteRow(
    _i1.DatabaseSession session,
    UserOAuthLink row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserOAuthLink>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserOAuthLink>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserOAuthLinkTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserOAuthLink>(
      where: where(UserOAuthLink.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserOAuthLinkTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserOAuthLink>(
      where: where?.call(UserOAuthLink.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserOAuthLink] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserOAuthLinkTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserOAuthLink>(
      where: where(UserOAuthLink.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
