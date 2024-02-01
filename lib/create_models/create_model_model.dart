import 'package:mazad/model/car_model_model.dart';

CarModel createCarModel(Map<String, dynamic> json) {
  final String year = json['year'].toString();
  final String id = json['_id'];

  return CarModel(year, id);
}