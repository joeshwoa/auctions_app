import 'package:mazad/model/shape_model.dart';

Shape createShape(Map<String, dynamic> json) {
  final String name = json['name'];
  final String id = json['_id'];

  return Shape(name, id);
}