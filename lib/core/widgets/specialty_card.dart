import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../features/patient/data/models/specialty_model.dart';

class SpecialtyCard extends StatelessWidget {

  const SpecialtyCard({
    required this.specialty, required this.onTap, super.key,
  });
  final SpecialtyModel specialty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lang = EasyLocalization.of(context)?.locale.languageCode ?? 'ar';
    final isNetwork = specialty.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: specialty.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: isNetwork
                    ? Image.network(
                        specialty.imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.medical_services_outlined,
                          color: Colors.white,
                          size: 48,
                        ),
                      )
                    : Image.asset(
                        specialty.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                specialty.localizedName(lang),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
