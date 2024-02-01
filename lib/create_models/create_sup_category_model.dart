import 'package:mazad/model/sup_category_model.dart';

SupCategory createSupCategory(Map<String, dynamic> json) {
  final String name = json['name'];
  final String id = json['_id'];

  return SupCategory(name, id);
}