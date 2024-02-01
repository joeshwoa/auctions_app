import 'package:mazad/model/category_model.dart';

Category createCategory(Map<String, dynamic> json) {
  final String name = json['name'];
  final String id = json['_id'];

  return Category(name, id);
}