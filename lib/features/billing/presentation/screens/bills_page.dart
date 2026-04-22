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
import '../../data/models/bill_model.dart';
import '../../data/models/bills_states.dart';
import '../providers/bills_provider.dart';

class BillsPage extends ConsumerWidget {
  const BillsPage({super.key});

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    final creatorId = ref.read(authProvider).value?.currentUser?.id ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CreateBillSheet(
        onSave: (patientId, patientName, appointmentId, amount) {
          ref.read(billsProvider.notifier).createBill(
                patientId: patientId,
                patientName: patientName,
                appointmentId: appointmentId,
                totalAmount: amount,
                createdBy: creatorId,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(billsProvider);

    ref.listen(billsProvider, (_, next) {
      final msg = next.value?.errorMessage;
      if (msg != null) GlassySnackbar.showError(context, msg);
    });

    return Scaffold(
      appBar: SectionAppBar(
        title: LocaleKeys.bills_title.tr(),
        showBackButton: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context, ref),
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: Text(LocaleKeys.create_bill.tr()),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('${LocaleKeys.error_e.tr()}: $e')),
        data: (state) => RefreshIndicator(
          onRefresh: () => ref.read(billsProvider.notifier).refresh(),
          child: Column(
            children: [
              _RevenueHeader(state: state),
              Expanded(
                child: state.bills.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              LocaleKeys.no_records_yet.tr(),
                              style:
                                  const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: state.bills.length,
                        itemBuilder: (_, i) => _BillCard(
                          bill: state.bills[i],
                          isLoading: state.isLoading,
                          onMarkPaid: state.bills[i].isPaid
                              ? null
                              : () => ref
                                  .read(billsProvider.notifier)
                                  .markAsPaid(state.bills[i].id),
                          onDelete: () => ref
                              .read(billsProvider.notifier)
                              .deleteBill(state.bills[i].id),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Revenue header ────────────────────────────────────────────────────────

class _RevenueHeader extends StatelessWidget {
  const _RevenueHeader({required this.state});
  final BillsStates state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            LocaleKeys.total_revenue.tr(),
            style:
                const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.totalRevenue.toStringAsFixed(0)} EGP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniStat(
                label: LocaleKeys.paid.tr(),
                value: state.paidBills.length.toString(),
                color: AppColors.success,
              ),
              const SizedBox(width: 24),
              _MiniStat(
                label: LocaleKeys.pending_payment.tr(),
                value: state.pendingBills.length.toString(),
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

// ─── Bill card ──────────────────────────────────────────────────────────────

class _BillCard extends StatelessWidget {

  const _BillCard({
    required this.bill,
    required this.isLoading,
    required this.onMarkPaid,
    required this.onDelete,
  });
  final BillModel bill;
  final bool isLoading;
  final VoidCallback? onMarkPaid;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!bill.isPaid) ...[
                    AppButton(
                      text: LocaleKeys.mark_as_paid.tr(),
                      isLoading: isLoading,
                      onPressed: isLoading ? null : onMarkPaid,
                      height: 34,
                      fontSize: 11,
                    ),
                    const SizedBox(height: 4),
                  ],
                  AppButton.danger(
                    text: LocaleKeys.delete.tr(),
                    onPressed: isLoading ? null : onDelete,
                    height: 34,
                    fontSize: 11,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bill.patientName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bill.totalAmount.toStringAsFixed(0)} EGP',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: bill.isPaid
                        ? AppColors.success.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bill.isPaid
                        ? LocaleKeys.paid.tr()
                        : LocaleKeys.pending_payment.tr(),
                    style: TextStyle(
                      color: bill.isPaid
                          ? AppColors.success
                          : Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Create Bill sheet ──────────────────────────────────────────────────────

class _CreateBillSheet extends StatefulWidget {

  const _CreateBillSheet({required this.onSave});
  final void Function(
    String patientId,
    String patientName,
    String appointmentId,
    double amount,
  ) onSave;

  @override
  State<_CreateBillSheet> createState() => _CreateBillSheetState();
}

class _CreateBillSheetState extends State<_CreateBillSheet> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdCtrl = TextEditingController();
  final _patientNameCtrl = TextEditingController();
  final _appointmentIdCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    _patientNameCtrl.dispose();
    _appointmentIdCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      GlassySnackbar.showError(context, 'Invalid amount');
      return;
    }
    Navigator.pop(context);
    widget.onSave(
      _patientIdCtrl.text.trim(),
      _patientNameCtrl.text.trim(),
      _appointmentIdCtrl.text.trim(),
      amount,
    );
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                LocaleKeys.create_bill.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              MyTextField(
                controller: _patientNameCtrl,
                hintText: LocaleKeys.bill_patient.tr(),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? LocaleKeys.required_field.tr()
                        : null,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: _patientIdCtrl,
                hintText: LocaleKeys.appointment_id_label.tr(),
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: _appointmentIdCtrl,
                hintText: LocaleKeys.appointment_id_label.tr(),
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: _amountCtrl,
                hintText: LocaleKeys.bill_amount_label.tr(),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return LocaleKeys.required_field.tr();
                  }
                  if (double.tryParse(v.trim()) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppButton.primary(
                text: LocaleKeys.create_bill.tr(),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
