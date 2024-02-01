import 'package:mazad/model/area_model.dart';

Area createArea(Map<String, dynamic> json) {
  final String name = json['name'];
  final String id = json['_id'];

  return Area(name, id);
}