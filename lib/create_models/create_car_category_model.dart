import 'package:mazad/model/car_category_model.dart';

CarCategory createCarCategory(Map<String, dynamic> json) {
  final String name = json['name'];
  final String id = json['_id'];

  return CarCategory(name, id);
}