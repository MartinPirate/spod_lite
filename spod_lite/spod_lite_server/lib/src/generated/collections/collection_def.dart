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

/// A user-defined collection. Each row corresponds to a dynamic `collection_<name>` table in Postgres.
abstract class CollectionDef
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CollectionDef._({
    this.id,
    required this.name,
    required this.label,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
    this.createdAt,
  }) : listRule = listRule ?? 'admin',
       viewRule = viewRule ?? 'admin',
       createRule = createRule ?? 'admin',
       updateRule = updateRule ?? 'admin',
       deleteRule = deleteRule ?? 'admin';

  factory CollectionDef({
    int? id,
    required String name,
    required String label,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
    DateTime? createdAt,
  }) = _CollectionDefImpl;

  factory CollectionDef.fromJson(Map<String, dynamic> jsonSerialization) {
    return CollectionDef(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      label: jsonSerialization['label'] as String,
      listRule: jsonSerialization['listRule'] as String?,
      viewRule: jsonSerialization['viewRule'] as String?,
      createRule: jsonSerialization['createRule'] as String?,
      updateRule: jsonSerialization['updateRule'] as String?,
      deleteRule: jsonSerialization['deleteRule'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = CollectionDefTable();

  static const db = CollectionDefRepository._();

  @override
  int? id;

  String name;

  String label;

  String listRule;

  String viewRule;

  String createRule;

  String updateRule;

  String deleteRule;

  DateTime? createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CollectionDef]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CollectionDef copyWith({
    int? id,
    String? name,
    String? label,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CollectionDef',
      if (id != null) 'id': id,
      'name': name,
      'label': label,
      'listRule': listRule,
      'viewRule': viewRule,
      'createRule': createRule,
      'updateRule': updateRule,
      'deleteRule': deleteRule,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CollectionDef',
      if (id != null) 'id': id,
      'name': name,
      'label': label,
      'listRule': listRule,
      'viewRule': viewRule,
      'createRule': createRule,
      'updateRule': updateRule,
      'deleteRule': deleteRule,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  static CollectionDefInclude include() {
    return CollectionDefInclude._();
  }

  static CollectionDefIncludeList includeList({
    _i1.WhereExpressionBuilder<CollectionDefTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CollectionDefTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CollectionDefTable>? orderByList,
    CollectionDefInclude? include,
  }) {
    return CollectionDefIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CollectionDef.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CollectionDef.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CollectionDefImpl extends CollectionDef {
  _CollectionDefImpl({
    int? id,
    required String name,
    required String label,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         label: label,
         listRule: listRule,
         viewRule: viewRule,
         createRule: createRule,
         updateRule: updateRule,
         deleteRule: deleteRule,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CollectionDef]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CollectionDef copyWith({
    Object? id = _Undefined,
    String? name,
    String? label,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
    Object? createdAt = _Undefined,
  }) {
    return CollectionDef(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      listRule: listRule ?? this.listRule,
      viewRule: viewRule ?? this.viewRule,
      createRule: createRule ?? this.createRule,
      updateRule: updateRule ?? this.updateRule,
      deleteRule: deleteRule ?? this.deleteRule,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class CollectionDefUpdateTable extends _i1.UpdateTable<CollectionDefTable> {
  CollectionDefUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> label(String value) => _i1.ColumnValue(
    table.label,
    value,
  );

  _i1.ColumnValue<String, String> listRule(String value) => _i1.ColumnValue(
    table.listRule,
    value,
  );

  _i1.ColumnValue<String, String> viewRule(String value) => _i1.ColumnValue(
    table.viewRule,
    value,
  );

  _i1.ColumnValue<String, String> createRule(String value) => _i1.ColumnValue(
    table.createRule,
    value,
  );

  _i1.ColumnValue<String, String> updateRule(String value) => _i1.ColumnValue(
    table.updateRule,
    value,
  );

  _i1.ColumnValue<String, String> deleteRule(String value) => _i1.ColumnValue(
    table.deleteRule,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class CollectionDefTable extends _i1.Table<int?> {
  CollectionDefTable({super.tableRelation})
    : super(tableName: 'collection_def') {
    updateTable = CollectionDefUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    label = _i1.ColumnString(
      'label',
      this,
    );
    listRule = _i1.ColumnString(
      'listRule',
      this,
      hasDefault: true,
    );
    viewRule = _i1.ColumnString(
      'viewRule',
      this,
      hasDefault: true,
    );
    createRule = _i1.ColumnString(
      'createRule',
      this,
      hasDefault: true,
    );
    updateRule = _i1.ColumnString(
      'updateRule',
      this,
      hasDefault: true,
    );
    deleteRule = _i1.ColumnString(
      'deleteRule',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final CollectionDefUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnString label;

  late final _i1.ColumnString listRule;

  late final _i1.ColumnString viewRule;

  late final _i1.ColumnString createRule;

  late final _i1.ColumnString updateRule;

  late final _i1.ColumnString deleteRule;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    label,
    listRule,
    viewRule,
    createRule,
    updateRule,
    deleteRule,
    createdAt,
  ];
}

class CollectionDefInclude extends _i1.IncludeObject {
  CollectionDefInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CollectionDef.t;
}

class CollectionDefIncludeList extends _i1.IncludeList {
  CollectionDefIncludeList._({
    _i1.WhereExpressionBuilder<CollectionDefTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CollectionDef.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CollectionDef.t;
}

class CollectionDefRepository {
  const CollectionDefRepository._();

  /// Returns a list of [CollectionDef]s matching the given query parameters.
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
  Future<List<CollectionDef>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CollectionDefTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CollectionDefTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CollectionDefTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CollectionDef>(
      where: where?.call(CollectionDef.t),
      orderBy: orderBy?.call(CollectionDef.t),
      orderByList: orderByList?.call(CollectionDef.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CollectionDef] matching the given query parameters.
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
  Future<CollectionDef?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CollectionDefTable>? where,
    int? offset,
    _i1.OrderByBuilder<CollectionDefTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CollectionDefTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CollectionDef>(
      where: where?.call(CollectionDef.t),
      orderBy: orderBy?.call(CollectionDef.t),
      orderByList: orderByList?.call(CollectionDef.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CollectionDef] by its [id] or null if no such row exists.
  Future<CollectionDef?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CollectionDef>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CollectionDef]s in the list and returns the inserted rows.
  ///
  /// The returned [CollectionDef]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CollectionDef>> insert(
    _i1.DatabaseSession session,
    List<CollectionDef> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CollectionDef>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CollectionDef] and returns the inserted row.
  ///
  /// The returned [CollectionDef] will have its `id` field set.
  Future<CollectionDef> insertRow(
    _i1.DatabaseSession session,
    CollectionDef row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CollectionDef>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CollectionDef]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CollectionDef>> update(
    _i1.DatabaseSession session,
    List<CollectionDef> rows, {
    _i1.ColumnSelections<CollectionDefTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CollectionDef>(
      rows,
      columns: columns?.call(CollectionDef.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CollectionDef]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CollectionDef> updateRow(
    _i1.DatabaseSession session,
    CollectionDef row, {
    _i1.ColumnSelections<CollectionDefTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CollectionDef>(
      row,
      columns: columns?.call(CollectionDef.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CollectionDef] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CollectionDef?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CollectionDefUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CollectionDef>(
      id,
      columnValues: columnValues(CollectionDef.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CollectionDef]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CollectionDef>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CollectionDefUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CollectionDefTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CollectionDefTable>? orderBy,
    _i1.OrderByListBuilder<CollectionDefTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CollectionDef>(
      columnValues: columnValues(CollectionDef.t.updateTable),
      where: where(CollectionDef.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CollectionDef.t),
      orderByList: orderByList?.call(CollectionDef.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CollectionDef]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CollectionDef>> delete(
    _i1.DatabaseSession session,
    List<CollectionDef> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CollectionDef>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CollectionDef].
  Future<CollectionDef> deleteRow(
    _i1.DatabaseSession session,
    CollectionDef row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CollectionDef>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CollectionDef>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CollectionDefTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CollectionDef>(
      where: where(CollectionDef.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CollectionDefTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CollectionDef>(
      where: where?.call(CollectionDef.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CollectionDef] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CollectionDefTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CollectionDef>(
      where: where(CollectionDef.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
