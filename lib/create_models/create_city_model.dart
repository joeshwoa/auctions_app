import 'package:mazad/model/city_model.dart';

City createCity(Map<String, dynamic> json) {
  final String name = json['name'];
  final String id = json['_id'];

  return City(name, id);
}