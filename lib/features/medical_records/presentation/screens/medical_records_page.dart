import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/services/helper.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/my_text_filed.dart';
import '../../../../core/widgets/section_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/medical_record_model.dart';
import '../providers/medical_record_provider.dart';

class MedicalRecordsPage extends ConsumerStatefulWidget {

  const MedicalRecordsPage({
    required this.patientId, required this.patientName, super.key,
  });
  static const routeName = '/medical-records';

  final String patientId;
  final String patientName;

  @override
  ConsumerState<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends ConsumerState<MedicalRecordsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(medicalRecordProvider.notifier)
          .loadRecordsForPatient(widget.patientId);
    });
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddRecordSheet(
        onSave: (diagnosis, symptoms, treatment) {
          final doctor = ref.read(authProvider).value?.currentUser;
          if (doctor == null) return;
          ref.read(medicalRecordProvider.notifier).addRecord(
                patientId: widget.patientId,
                doctorId: doctor.id,
                doctorName: doctor.name,
                createdBy: doctor.id,
                diagnosis: diagnosis,
                symptoms: symptoms,
                treatment: treatment,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(medicalRecordProvider);

    ref.listen(medicalRecordProvider, (_, next) {
      final msg = next.value?.errorMessage;
      if (msg != null) GlassySnackbar.showError(context, msg);
    });

    return Scaffold(
      appBar: SectionAppBar(
        title: widget.patientName,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: Text(LocaleKeys.add_medical_record.tr()),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('${LocaleKeys.error_e.tr()}: $e')),
        data: (state) {
          if (state.records.isEmpty) {
            return Center(
              child: Text(
                LocaleKeys.no_medical_records.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.records.length,
            itemBuilder: (_, i) => _RecordCard(record: state.records[i]),
          );
        },
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});
  final MedicalRecordModel record;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.visitDate,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                Text(
                  LocaleKeys.visit_date.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 16),
            _InfoRow(
                label: LocaleKeys.diagnosis.tr(), value: record.diagnosis),
            const SizedBox(height: 6),
            _InfoRow(
                label: LocaleKeys.symptoms.tr(), value: record.symptoms),
            const SizedBox(height: 6),
            _InfoRow(
                label: LocaleKeys.treatment.tr(), value: record.treatment),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: 8),
        Text('$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class _AddRecordSheet extends StatefulWidget {

  const _AddRecordSheet({required this.onSave});
  final void Function(String diagnosis, String symptoms, String treatment)
      onSave;

  @override
  State<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<_AddRecordSheet> {
  final _diagnosisCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _symptomsCtrl.dispose();
    _treatmentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.add_medical_record.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            MyTextField(
              controller: _diagnosisCtrl,
              hintText: LocaleKeys.diagnosis.tr(),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: _symptomsCtrl,
              hintText: LocaleKeys.symptoms.tr(),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: _treatmentCtrl,
              hintText: LocaleKeys.treatment.tr(),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            AppButton.primary(
              text: LocaleKeys.save.tr(),
              onPressed: () {
                if (_diagnosisCtrl.text.trim().isEmpty) return;
                Navigator.pop(context);
                widget.onSave(
                  _diagnosisCtrl.text.trim(),
                  _symptomsCtrl.text.trim(),
                  _treatmentCtrl.text.trim(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
