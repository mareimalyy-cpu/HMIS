import 'package:flutter/material.dart';

class SpecialtyModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String imageUrl;
  final Color color;

  const SpecialtyModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.imageUrl,
    required this.color,
  });

  String get name => nameEn;

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      color: Color(json['color'] as int? ?? 0xFF2096A4),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'imageUrl': imageUrl,
        'color': color.toARGB32(),
      };

  static const _base = 'https://img.icons8.com/color/96';

  static List<SpecialtyModel> get defaults => [
        SpecialtyModel(
          id: 'general_surgery',
          nameAr: 'جراحة عامة',
          nameEn: 'General Surgery',
          imageUrl: '$_base/scalpel.png',
          color: const Color(0xFF6FA8DC),
        ),
        SpecialtyModel(
          id: 'orthopedics',
          nameAr: 'العظام',
          nameEn: 'Orthopedics',
          imageUrl: '$_base/skeleton.png',
          color: const Color(0xFF7ECEC1),
        ),
        SpecialtyModel(
          id: 'cardiology',
          nameAr: 'القلب والأوعية الدموية',
          nameEn: 'Cardiology',
          imageUrl: '$_base/heart-with-pulse.png',
          color: const Color(0xFFE8A09A),
        ),
        SpecialtyModel(
          id: 'obstetrics',
          nameAr: 'النساء والتوليد',
          nameEn: 'Obstetrics & Gynecology',
          imageUrl: '$_base/pregnant.png',
          color: const Color(0xFF4A7C6F),
        ),
        SpecialtyModel(
          id: 'pediatrics',
          nameAr: 'طب الأطفال',
          nameEn: 'Pediatrics',
          imageUrl: '$_base/baby.png',
          color: const Color(0xFFD45B5B),
        ),
        SpecialtyModel(
          id: 'neurology',
          nameAr: 'طب الأعصاب',
          nameEn: 'Neurology',
          imageUrl: '$_base/brain-3.png',
          color: const Color(0xFF3D8B37),
        ),
        SpecialtyModel(
          id: 'dermatology',
          nameAr: 'الجلدية',
          nameEn: 'Dermatology',
          imageUrl: '$_base/skin.png',
          color: const Color(0xFFB5838D),
        ),
        SpecialtyModel(
          id: 'ophthalmology',
          nameAr: 'طب العيون',
          nameEn: 'Ophthalmology',
          imageUrl: '$_base/visible.png',
          color: const Color(0xFF6B9AC4),
        ),
        SpecialtyModel(
          id: 'ent',
          nameAr: 'الأذن والأنف والحنجرة',
          nameEn: 'ENT',
          imageUrl: '$_base/ear.png',
          color: const Color(0xFF9B59B6),
        ),
        SpecialtyModel(
          id: 'urology',
          nameAr: 'المسالك البولية',
          nameEn: 'Urology',
          imageUrl: '$_base/kidney.png',
          color: const Color(0xFF1ABC9C),
        ),
        SpecialtyModel(
          id: 'psychiatry',
          nameAr: 'الطب النفسي',
          nameEn: 'Psychiatry',
          imageUrl: '$_base/mental-health.png',
          color: const Color(0xFFE67E22),
        ),
        SpecialtyModel(
          id: 'oncology',
          nameAr: 'الأورام',
          nameEn: 'Oncology',
          imageUrl: '$_base/dna-helix.png',
          color: const Color(0xFFC0392B),
        ),
        SpecialtyModel(
          id: 'endocrinology',
          nameAr: 'الغدد الصماء',
          nameEn: 'Endocrinology',
          imageUrl: '$_base/thyroid-gland.png',
          color: const Color(0xFF8E44AD),
        ),
        SpecialtyModel(
          id: 'gastroenterology',
          nameAr: 'الجهاز الهضمي',
          nameEn: 'Gastroenterology',
          imageUrl: '$_base/stomach.png',
          color: const Color(0xFF27AE60),
        ),
        SpecialtyModel(
          id: 'nephrology',
          nameAr: 'الكلى',
          nameEn: 'Nephrology',
          imageUrl: '$_base/kidney.png',
          color: const Color(0xFF2980B9),
        ),
        SpecialtyModel(
          id: 'pulmonology',
          nameAr: 'الرئة والجهاز التنفسي',
          nameEn: 'Pulmonology',
          imageUrl: '$_base/lungs.png',
          color: const Color(0xFF16A085),
        ),
        SpecialtyModel(
          id: 'rheumatology',
          nameAr: 'الروماتيزم',
          nameEn: 'Rheumatology',
          imageUrl: '$_base/skeleton.png',
          color: const Color(0xFFF39C12),
        ),
        SpecialtyModel(
          id: 'dentistry',
          nameAr: 'طب الأسنان',
          nameEn: 'Dentistry',
          imageUrl: '$_base/dentist.png',
          color: const Color(0xFF2C3E50),
        ),
      ];
}
