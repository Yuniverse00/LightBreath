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


/** This is an auto generated class representing the DataPoint type in your schema. */
class DataPoint {
  final String? _sensorType;
  final double? _value1;
  final double? _value2;
  final double? _value3;
  final String? _time;

  String get sensorType {
    try {
      return _sensorType!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get value1 {
    try {
      return _value1!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get value2 {
    try {
      return _value2!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get value3 {
    try {
      return _value3!;
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
  
  const DataPoint._internal({required sensorType, required value1, required value2, required value3, required time}): _sensorType = sensorType, _value1 = value1, _value2 = value2, _value3 = value3, _time = time;
  
  factory DataPoint({required String sensorType, required double value1, required double value2, required double value3, required String time}) {
    return DataPoint._internal(
      sensorType: sensorType,
      value1: value1,
      value2: value2,
      value3: value3,
      time: time);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DataPoint &&
      _sensorType == other._sensorType &&
      _value1 == other._value1 &&
      _value2 == other._value2 &&
      _value3 == other._value3 &&
      _time == other._time;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("DataPoint {");
    buffer.write("sensorType=" + "$_sensorType" + ", ");
    buffer.write("value1=" + (_value1 != null ? _value1!.toString() : "null") + ", ");
    buffer.write("value2=" + (_value2 != null ? _value2!.toString() : "null") + ", ");
    buffer.write("value3=" + (_value3 != null ? _value3!.toString() : "null") + ", ");
    buffer.write("time=" + "$_time");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  DataPoint copyWith({String? sensorType, double? value1, double? value2, double? value3, String? time}) {
    return DataPoint._internal(
      sensorType: sensorType ?? this.sensorType,
      value1: value1 ?? this.value1,
      value2: value2 ?? this.value2,
      value3: value3 ?? this.value3,
      time: time ?? this.time);
  }
  
  DataPoint copyWithModelFieldValues({
    ModelFieldValue<String>? sensorType,
    ModelFieldValue<double>? value1,
    ModelFieldValue<double>? value2,
    ModelFieldValue<double>? value3,
    ModelFieldValue<String>? time
  }) {
    return DataPoint._internal(
      sensorType: sensorType == null ? this.sensorType : sensorType.value,
      value1: value1 == null ? this.value1 : value1.value,
      value2: value2 == null ? this.value2 : value2.value,
      value3: value3 == null ? this.value3 : value3.value,
      time: time == null ? this.time : time.value
    );
  }
  
  DataPoint.fromJson(Map<String, dynamic> json)  
    : _sensorType = json['sensorType'],
      _value1 = (json['value1'] as num?)?.toDouble(),
      _value2 = (json['value2'] as num?)?.toDouble(),
      _value3 = (json['value3'] as num?)?.toDouble(),
      _time = json['time'];
  
  Map<String, dynamic> toJson() => {
    'sensorType': _sensorType, 'value1': _value1, 'value2': _value2, 'value3': _value3, 'time': _time
  };
  
  Map<String, Object?> toMap() => {
    'sensorType': _sensorType,
    'value1': _value1,
    'value2': _value2,
    'value3': _value3,
    'time': _time
  };

  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "DataPoint";
    modelSchemaDefinition.pluralName = "DataPoints";
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'sensorType',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'value1',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'value2',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'value3',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'time',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
  });
}