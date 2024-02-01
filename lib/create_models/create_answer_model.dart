import 'package:mazad/model/answer_model.dart';

Answer createAnswer(Map<String, dynamic> json) {
  final String id = json['_id'];
  final String name = json['name'];
  final String phone = json['phone'];
  final String area = json['area'];
  final String city = json['city'];
  final String title = json['title'];
  final String description = json['description'];
  final String code = json['code'];

  return Answer(id, name, phone, area, city, title, description, code);
}