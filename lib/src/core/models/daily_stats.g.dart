// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stats.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyStatsCollection on Isar {
  IsarCollection<DailyStats> get dailyStats => this.collection();
}

const DailyStatsSchema = CollectionSchema(
  name: r'DailyStats',
  id: -7592871651347013517,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.string,
    ),
    r'estimatedViewingTimeSeconds': PropertySchema(
      id: 1,
      name: r'estimatedViewingTimeSeconds',
      type: IsarType.long,
    ),
    r'facebookCount': PropertySchema(
      id: 2,
      name: r'facebookCount',
      type: IsarType.long,
    ),
    r'instagramCount': PropertySchema(
      id: 3,
      name: r'instagramCount',
      type: IsarType.long,
    ),
    r'tiktokCount': PropertySchema(
      id: 4,
      name: r'tiktokCount',
      type: IsarType.long,
    ),
    r'totalCount': PropertySchema(
      id: 5,
      name: r'totalCount',
      type: IsarType.long,
    ),
    r'youtubeCount': PropertySchema(
      id: 6,
      name: r'youtubeCount',
      type: IsarType.long,
    )
  },
  estimateSize: _dailyStatsEstimateSize,
  serialize: _dailyStatsSerialize,
  deserialize: _dailyStatsDeserialize,
  deserializeProp: _dailyStatsDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyStatsGetId,
  getLinks: _dailyStatsGetLinks,
  attach: _dailyStatsAttach,
  version: '3.1.0+1',
);

int _dailyStatsEstimateSize(
  DailyStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.date.length * 3;
  return bytesCount;
}

void _dailyStatsSerialize(
  DailyStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.date);
  writer.writeLong(offsets[1], object.estimatedViewingTimeSeconds);
  writer.writeLong(offsets[2], object.facebookCount);
  writer.writeLong(offsets[3], object.instagramCount);
  writer.writeLong(offsets[4], object.tiktokCount);
  writer.writeLong(offsets[5], object.totalCount);
  writer.writeLong(offsets[6], object.youtubeCount);
}

DailyStats _dailyStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyStats();
  object.date = reader.readString(offsets[0]);
  object.estimatedViewingTimeSeconds = reader.readLong(offsets[1]);
  object.facebookCount = reader.readLong(offsets[2]);
  object.id = id;
  object.instagramCount = reader.readLong(offsets[3]);
  object.tiktokCount = reader.readLong(offsets[4]);
  object.totalCount = reader.readLong(offsets[5]);
  object.youtubeCount = reader.readLong(offsets[6]);
  return object;
}

P _dailyStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyStatsGetId(DailyStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyStatsGetLinks(DailyStats object) {
  return [];
}

void _dailyStatsAttach(IsarCollection<dynamic> col, Id id, DailyStats object) {
  object.id = id;
}

extension DailyStatsByIndex on IsarCollection<DailyStats> {
  Future<DailyStats?> getByDate(String date) {
    return getByIndex(r'date', [date]);
  }

  DailyStats? getByDateSync(String date) {
    return getByIndexSync(r'date', [date]);
  }

  Future<bool> deleteByDate(String date) {
    return deleteByIndex(r'date', [date]);
  }

  bool deleteByDateSync(String date) {
    return deleteByIndexSync(r'date', [date]);
  }

  Future<List<DailyStats?>> getAllByDate(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndex(r'date', values);
  }

  List<DailyStats?> getAllByDateSync(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'date', values);
  }

  Future<int> deleteAllByDate(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'date', values);
  }

  int deleteAllByDateSync(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'date', values);
  }

  Future<Id> putByDate(DailyStats object) {
    return putByIndex(r'date', object);
  }

  Id putByDateSync(DailyStats object, {bool saveLinks = true}) {
    return putByIndexSync(r'date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDate(List<DailyStats> objects) {
    return putAllByIndex(r'date', objects);
  }

  List<Id> putAllByDateSync(List<DailyStats> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'date', objects, saveLinks: saveLinks);
  }
}

extension DailyStatsQueryWhereSort
    on QueryBuilder<DailyStats, DailyStats, QWhere> {
  QueryBuilder<DailyStats, DailyStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DailyStatsQueryWhere
    on QueryBuilder<DailyStats, DailyStats, QWhereClause> {
  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> dateEqualTo(
      String date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> dateNotEqualTo(
      String date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DailyStatsQueryFilter
    on QueryBuilder<DailyStats, DailyStats, QFilterCondition> {
  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'date',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      estimatedViewingTimeSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedViewingTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      estimatedViewingTimeSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimatedViewingTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      estimatedViewingTimeSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimatedViewingTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      estimatedViewingTimeSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimatedViewingTimeSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      facebookCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'facebookCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      facebookCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'facebookCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      facebookCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'facebookCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      facebookCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'facebookCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      instagramCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'instagramCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      instagramCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'instagramCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      instagramCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'instagramCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      instagramCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'instagramCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      tiktokCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tiktokCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      tiktokCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tiktokCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      tiktokCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tiktokCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      tiktokCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tiktokCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> totalCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      totalCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      totalCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> totalCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      youtubeCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'youtubeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      youtubeCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'youtubeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      youtubeCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'youtubeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      youtubeCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'youtubeCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyStatsQueryObject
    on QueryBuilder<DailyStats, DailyStats, QFilterCondition> {}

extension DailyStatsQueryLinks
    on QueryBuilder<DailyStats, DailyStats, QFilterCondition> {}

extension DailyStatsQuerySortBy
    on QueryBuilder<DailyStats, DailyStats, QSortBy> {
  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      sortByEstimatedViewingTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedViewingTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      sortByEstimatedViewingTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedViewingTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByFacebookCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facebookCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByFacebookCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facebookCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByInstagramCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instagramCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      sortByInstagramCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instagramCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByTiktokCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tiktokCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByTiktokCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tiktokCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByTotalCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByYoutubeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'youtubeCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByYoutubeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'youtubeCount', Sort.desc);
    });
  }
}

extension DailyStatsQuerySortThenBy
    on QueryBuilder<DailyStats, DailyStats, QSortThenBy> {
  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      thenByEstimatedViewingTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedViewingTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      thenByEstimatedViewingTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedViewingTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByFacebookCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facebookCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByFacebookCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facebookCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByInstagramCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instagramCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      thenByInstagramCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instagramCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByTiktokCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tiktokCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByTiktokCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tiktokCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByTotalCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByYoutubeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'youtubeCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByYoutubeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'youtubeCount', Sort.desc);
    });
  }
}

extension DailyStatsQueryWhereDistinct
    on QueryBuilder<DailyStats, DailyStats, QDistinct> {
  QueryBuilder<DailyStats, DailyStats, QDistinct> distinctByDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QDistinct>
      distinctByEstimatedViewingTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedViewingTimeSeconds');
    });
  }

  QueryBuilder<DailyStats, DailyStats, QDistinct> distinctByFacebookCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'facebookCount');
    });
  }

  QueryBuilder<DailyStats, DailyStats, QDistinct> distinctByInstagramCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'instagramCount');
    });
  }

  QueryBuilder<DailyStats, DailyStats, QDistinct> distinctByTiktokCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tiktokCount');
    });
  }

  QueryBuilder<DailyStats, DailyStats, QDistinct> distinctByTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCount');
    });
  }

  QueryBuilder<DailyStats, DailyStats, QDistinct> distinctByYoutubeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'youtubeCount');
    });
  }
}

extension DailyStatsQueryProperty
    on QueryBuilder<DailyStats, DailyStats, QQueryProperty> {
  QueryBuilder<DailyStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyStats, String, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyStats, int, QQueryOperations>
      estimatedViewingTimeSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedViewingTimeSeconds');
    });
  }

  QueryBuilder<DailyStats, int, QQueryOperations> facebookCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'facebookCount');
    });
  }

  QueryBuilder<DailyStats, int, QQueryOperations> instagramCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'instagramCount');
    });
  }

  QueryBuilder<DailyStats, int, QQueryOperations> tiktokCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tiktokCount');
    });
  }

  QueryBuilder<DailyStats, int, QQueryOperations> totalCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCount');
    });
  }

  QueryBuilder<DailyStats, int, QQueryOperations> youtubeCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'youtubeCount');
    });
  }
}
