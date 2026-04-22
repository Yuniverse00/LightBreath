/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'package:collection/collection.dart';


/** This is an auto generated class representing the SensorData type in your schema. */
class SensorData extends amplify_core.Model {
  static const classType = const _SensorDataModelType();
  final String id;
  final String? _username;
  final String? _activity;
  final String? _time;
  final List<DataPoint>? _data;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @override
  String getId() {
    return id;
  }

  String get username {
    try {
      return _username!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }

  String get activity {
    try {
      return _activity!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }

  String get time {
    try {
      return _time!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }

  List<DataPoint> get data {
    try {
      return _data!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }

  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }

  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const SensorData._internal({required this.id, required username, required activity, required time, required data, createdAt, updatedAt}): _username = username, _activity = activity, _time = time, _data = data, _createdAt = createdAt, _updatedAt = updatedAt;

  factory SensorData({String? id, required String username, required String activity, required String time, required List<DataPoint> data}) {
    return SensorData._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      username: username,
      activity: activity,
      time: time,
      data: data != null ? List<DataPoint>.unmodifiable(data) : data);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SensorData &&
      id == other.id &&
      _username == other._username &&
      _activity == other._activity &&
      _time == other._time &&
      DeepCollectionEquality().equals(_data, other._data);
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("SensorData {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("username=" + "$_username" + ", ");
    buffer.write("activity=" + "$_activity" + ", ");
    buffer.write("time=" + "$_time" + ", ");
    buffer.write("data=" + (_data != null ? _data!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");

    return buffer.toString();
  }

  SensorData copyWith({String? id, String? username, String? activity, String? time, List<DataPoint>? data}) {
    return SensorData._internal(
      id: id ?? this.id,
      username: username ?? this.username,
      activity: activity ?? this.activity,
      time: time ?? this.time,
      data: data ?? this.data);
  }

  SensorData copyWithModelFieldValues({
    ModelFieldValue<String>? id,
    ModelFieldValue<String>? username,
    ModelFieldValue<String>? activity,
    ModelFieldValue<String>? time,
    ModelFieldValue<List<DataPoint>>? data
  }) {
    return SensorData._internal(
      id: id == null ? this.id : id.value,
      username: username == null ? this.username : username.value,
      activity: activity == null ? this.activity : activity.value,
      time: time == null ? this.time : time.value,
      data: data == null ? this.data : data.value
    );
  }

  SensorData.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _username = json['username'],
      _activity = json['activity'],
      _time = json['time'],
      _data = json['data'] is List
        ? (json['data'] as List)
          .where((e) => e != null)
          .map((e) => DataPoint.fromJson(new Map<String, dynamic>.from(e['serializedData'] ?? e)))
          .toList()
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;

  Map<String, dynamic> toJson() => {
    'id': id, 'username': _username, 'activity': _activity, 'time': _time, 'data': _data?.map((DataPoint? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'username': _username,
    'activity': _activity,
    'time': _time,
    'data': _data,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERNAME = amplify_core.QueryField(fieldName: "username");
  static final ACTIVITY = amplify_core.QueryField(fieldName: "activity");
  static final TIME = amplify_core.QueryField(fieldName: "time");
  static final DATA = amplify_core.QueryField(fieldName: "data");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "SensorData";
    modelSchemaDefinition.pluralName = "SensorData";

    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];

    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());

    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SensorData.USERNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));

    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SensorData.ACTIVITY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));

    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SensorData.TIME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));

    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.embedded(
      fieldName: 'data',
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.embeddedCollection, ofCustomTypeName: 'DataPoint')
    ));

    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));

    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _SensorDataModelType extends amplify_core.ModelType<SensorData> {
  const _SensorDataModelType();

  @override
  SensorData fromJson(Map<String, dynamic> jsonData) {
    return SensorData.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'SensorData';
  }
}