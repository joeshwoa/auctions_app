import 'package:mazad/model/brand_model.dart';

Brand createBrand(Map<String, dynamic> json) {
  final String name = json['name'];
  final String id = json['_id'];

  return Brand(name, id);
}