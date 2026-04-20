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

/// A field on a user-defined collection. Mirrors a column in `collection_<name>`.
abstract class CollectionField
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CollectionField._({
    this.id,
    required this.collectionDefId,
    required this.name,
    required this.fieldType,
    bool? required,
    int? fieldOrder,
  }) : required = required ?? false,
       fieldOrder = fieldOrder ?? 0;

  factory CollectionField({
    int? id,
    required int collectionDefId,
    required String name,
    required String fieldType,
    bool? required,
    int? fieldOrder,
  }) = _CollectionFieldImpl;

  factory CollectionField.fromJson(Map<String, dynamic> jsonSerialization) {
    return CollectionField(
      id: jsonSerialization['id'] as int?,
      collectionDefId: jsonSerialization['collectionDefId'] as int,
      name: jsonSerialization['name'] as String,
      fieldType: jsonSerialization['fieldType'] as String,
      required: jsonSerialization['required'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['required']),
      fieldOrder: jsonSerialization['fieldOrder'] as int?,
    );
  }

  static final t = CollectionFieldTable();

  static const db = CollectionFieldRepository._();

  @override
  int? id;

  int collectionDefId;

  String name;

  String fieldType;

  bool required;

  int fieldOrder;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CollectionField]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CollectionField copyWith({
    int? id,
    int? collectionDefId,
    String? name,
    String? fieldType,
    bool? required,
    int? fieldOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CollectionField',
      if (id != null) 'id': id,
      'collectionDefId': collectionDefId,
      'name': name,
      'fieldType': fieldType,
      'required': required,
      'fieldOrder': fieldOrder,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CollectionField',
      if (id != null) 'id': id,
      'collectionDefId': collectionDefId,
      'name': name,
      'fieldType': fieldType,
      'required': required,
      'fieldOrder': fieldOrder,
    };
  }

  static CollectionFieldInclude include() {
    return CollectionFieldInclude._();
  }

  static CollectionFieldIncludeList includeList({
    _i1.WhereExpressionBuilder<CollectionFieldTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CollectionFieldTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CollectionFieldTable>? orderByList,
    CollectionFieldInclude? include,
  }) {
    return CollectionFieldIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CollectionField.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CollectionField.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CollectionFieldImpl extends CollectionField {
  _CollectionFieldImpl({
    int? id,
    required int collectionDefId,
    required String name,
    required String fieldType,
    bool? required,
    int? fieldOrder,
  }) : super._(
         id: id,
         collectionDefId: collectionDefId,
         name: name,
         fieldType: fieldType,
         required: required,
         fieldOrder: fieldOrder,
       );

  /// Returns a shallow copy of this [CollectionField]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CollectionField copyWith({
    Object? id = _Undefined,
    int? collectionDefId,
    String? name,
    String? fieldType,
    bool? required,
    int? fieldOrder,
  }) {
    return CollectionField(
      id: id is int? ? id : this.id,
      collectionDefId: collectionDefId ?? this.collectionDefId,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      required: required ?? this.required,
      fieldOrder: fieldOrder ?? this.fieldOrder,
    );
  }
}

class CollectionFieldUpdateTable extends _i1.UpdateTable<CollectionFieldTable> {
  CollectionFieldUpdateTable(super.table);

  _i1.ColumnValue<int, int> collectionDefId(int value) => _i1.ColumnValue(
    table.collectionDefId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> fieldType(String value) => _i1.ColumnValue(
    table.fieldType,
    value,
  );

  _i1.ColumnValue<bool, bool> required(bool value) => _i1.ColumnValue(
    table.required,
    value,
  );

  _i1.ColumnValue<int, int> fieldOrder(int value) => _i1.ColumnValue(
    table.fieldOrder,
    value,
  );
}

class CollectionFieldTable extends _i1.Table<int?> {
  CollectionFieldTable({super.tableRelation})
    : super(tableName: 'collection_field') {
    updateTable = CollectionFieldUpdateTable(this);
    collectionDefId = _i1.ColumnInt(
      'collectionDefId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    fieldType = _i1.ColumnString(
      'fieldType',
      this,
    );
    required = _i1.ColumnBool(
      'required',
      this,
      hasDefault: true,
    );
    fieldOrder = _i1.ColumnInt(
      'fieldOrder',
      this,
      hasDefault: true,
    );
  }

  late final CollectionFieldUpdateTable updateTable;

  late final _i1.ColumnInt collectionDefId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString fieldType;

  late final _i1.ColumnBool required;

  late final _i1.ColumnInt fieldOrder;

  @override
  List<_i1.Column> get columns => [
    id,
    collectionDefId,
    name,
    fieldType,
    required,
    fieldOrder,
  ];
}

class CollectionFieldInclude extends _i1.IncludeObject {
  CollectionFieldInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CollectionField.t;
}

class CollectionFieldIncludeList extends _i1.IncludeList {
  CollectionFieldIncludeList._({
    _i1.WhereExpressionBuilder<CollectionFieldTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CollectionField.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CollectionField.t;
}

class CollectionFieldRepository {
  const CollectionFieldRepository._();

  /// Returns a list of [CollectionField]s matching the given query parameters.
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
  Future<List<CollectionField>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CollectionFieldTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CollectionFieldTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CollectionFieldTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CollectionField>(
      where: where?.call(CollectionField.t),
      orderBy: orderBy?.call(CollectionField.t),
      orderByList: orderByList?.call(CollectionField.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CollectionField] matching the given query parameters.
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
  Future<CollectionField?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CollectionFieldTable>? where,
    int? offset,
    _i1.OrderByBuilder<CollectionFieldTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CollectionFieldTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CollectionField>(
      where: where?.call(CollectionField.t),
      orderBy: orderBy?.call(CollectionField.t),
      orderByList: orderByList?.call(CollectionField.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CollectionField] by its [id] or null if no such row exists.
  Future<CollectionField?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CollectionField>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CollectionField]s in the list and returns the inserted rows.
  ///
  /// The returned [CollectionField]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CollectionField>> insert(
    _i1.DatabaseSession session,
    List<CollectionField> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CollectionField>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CollectionField] and returns the inserted row.
  ///
  /// The returned [CollectionField] will have its `id` field set.
  Future<CollectionField> insertRow(
    _i1.DatabaseSession session,
    CollectionField row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CollectionField>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CollectionField]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CollectionField>> update(
    _i1.DatabaseSession session,
    List<CollectionField> rows, {
    _i1.ColumnSelections<CollectionFieldTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CollectionField>(
      rows,
      columns: columns?.call(CollectionField.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CollectionField]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CollectionField> updateRow(
    _i1.DatabaseSession session,
    CollectionField row, {
    _i1.ColumnSelections<CollectionFieldTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CollectionField>(
      row,
      columns: columns?.call(CollectionField.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CollectionField] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CollectionField?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CollectionFieldUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CollectionField>(
      id,
      columnValues: columnValues(CollectionField.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CollectionField]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CollectionField>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CollectionFieldUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<CollectionFieldTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CollectionFieldTable>? orderBy,
    _i1.OrderByListBuilder<CollectionFieldTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CollectionField>(
      columnValues: columnValues(CollectionField.t.updateTable),
      where: where(CollectionField.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CollectionField.t),
      orderByList: orderByList?.call(CollectionField.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CollectionField]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CollectionField>> delete(
    _i1.DatabaseSession session,
    List<CollectionField> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CollectionField>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CollectionField].
  Future<CollectionField> deleteRow(
    _i1.DatabaseSession session,
    CollectionField row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CollectionField>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CollectionField>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CollectionFieldTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CollectionField>(
      where: where(CollectionField.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CollectionFieldTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CollectionField>(
      where: where?.call(CollectionField.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CollectionField] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CollectionFieldTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CollectionField>(
      where: where(CollectionField.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
