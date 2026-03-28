import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';

class SpecialtyModel {
  final String id;
  final String name;
  final String imageUrl;
  final Color color;

  const SpecialtyModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.color,
  });

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      color: Color(json['color'] as int? ?? 0xFF2096A4),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'color': color.toARGB32(),
    };
  }

  static List<SpecialtyModel> defaults = [
    SpecialtyModel(
      id: 'general_surgery',
      name: 'General Surgery',
      imageUrl: Assets.images.png.doc.path,
      color: Color(0xFF6FA8DC),
    ),
    SpecialtyModel(
      id: 'orthopedics',
      name: 'Orthopedics',
      imageUrl: Assets.images.png.doc.path,
      color: Color(0xFF7ECEC1),
    ),
    SpecialtyModel(
      id: 'cardiology',
      name: 'Cardiology',
      imageUrl: Assets.images.png.doc.path,
      color: Color(0xFFE8A09A),
    ),
    SpecialtyModel(
      id: 'obstetrics',
      name: 'Obstetrics & Gynecology',
      imageUrl: Assets.images.png.doc.path,
      color: Color(0xFF4A7C6F),
    ),
    SpecialtyModel(
      id: 'pediatrics',
      name: 'Pediatrics',
      imageUrl: Assets.images.png.doc.path,
      color: Color(0xFFD45B5B),
    ),
    SpecialtyModel(
      id: 'neurology',
      name: 'Neurology',
      imageUrl: Assets.images.png.doc.path,
      color: Color(0xFF3D8B37),
    ),
  ];
}
