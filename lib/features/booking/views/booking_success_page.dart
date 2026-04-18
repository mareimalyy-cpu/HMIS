import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';

class BookingSuccessPage extends StatelessWidget {
  static const routeName = '/booking-success';

  const BookingSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 120,
                color: Colors.lightBlue[300],
              ),
              const SizedBox(height: 24),
              Text(
                'booking_successful'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 40),
              AppButton.primary(
                text: 'back_to_home'.tr(),
                onPressed: () => context.go('/patient-home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
