import 'package:flutter_application_stage_project/models/fields/FieldListView..dart';

class DataFieldGroup {
  final int id;
  final String alias;
  final bool hidden;
  final bool required;
  final bool uniqueValue;
  final String field_type;
  final String placeholder;
  final int reference;
  final int multiple;
  final int module;
  final bool read_only;
  List<FieldListView> listfieldsview;
  DataFieldGroup({
    required this.id,
    required this.alias,
    required this.hidden,
    required this.required,
    required this.uniqueValue,
    required this.field_type,
    required this.placeholder,
    required this.reference,
    required this.multiple,
    required this.module,
    required this.listfieldsview,
    required this.read_only,
  });
  factory DataFieldGroup.fromJson(Map<String, dynamic> json) {
    return DataFieldGroup(
      id: json["id"],
      alias: json["alias"],
      hidden: json["hidden"] ??
          false, // Si la valeur est null, utilisez false par défaut
      required: json["required"] ??
          false, // Si la valeur est null, utilisez false par défaut
      uniqueValue: json["uniqueValue"] ??
          false, // Si la valeur est null, utilisez false par défaut
      field_type: json["field_type"],
      placeholder: json["placeholder"] ?? "",
      reference: json["reference"],
      multiple: json["multiple"],

      module: json["module"] ?? 0,
      listfieldsview: (json["field_list_value"] as List)
              .map((list) => FieldListView.formJson(list))
              .toList() ??
          [],
      read_only:json['read_only'] ,   
    );
  }
}
