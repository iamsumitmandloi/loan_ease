import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/router.dart';
import '../../data/models/loan_model.dart';
import '../blocs/loan_form/loan_form_cubit.dart';

/// Multi-step loan application form
/// 4 steps: Business Details, Applicant Details, Loan Requirements, Review
class LoanFormScreen extends StatefulWidget {
  const LoanFormScreen({super.key});

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  late LoanFormCubit _formCubit;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _formCubit = getIt<LoanFormCubit>();
    _formCubit.initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _formCubit.close();
    super.dispose();
  }

  void _nextStep() {
    if (_formCubit.validateStep()) {
      _formCubit.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    _formCubit.previousStep();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToStep(int step) {
    _formCubit.goToStep(step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoanFormCubit, LoanFormState>(
      bloc: _formCubit,
      listener: (context, state) {
        if (state.isSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(Routes.loanList);
        }
        if (state.submitError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.submitError!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(state.stepTitle),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitDialog(),
            ),
          ),
          body: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(state.currentStep),
              
              // Form pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _BusinessDetailsStep(
                      formCubit: _formCubit,
                      state: state,
                    ),
                    _ApplicantDetailsStep(
                      formCubit: _formCubit,
                      state: state,
                    ),
                    _LoanRequirementsStep(
                      formCubit: _formCubit,
                      state: state,
                    ),
                    _ReviewStep(
                      formCubit: _formCubit,
                      state: state,
                      onEditStep: _goToStep,
                    ),
                  ],
                ),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          
          return Expanded(
            child: Row(
              children: [
                // Step circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.success
                        : isCurrent
                            ? AppColors.primary
                            : AppColors.divider,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                // Connector line
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppColors.success : AppColors.divider,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons(LoanFormState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (state.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (state.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: state.currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : state.currentStep < 3
                      ? _nextStep
                      : () => _formCubit.submit(),
              child: state.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(state.currentStep < 3 ? 'Next' : 'Submit Application'),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as Draft?'),
        content: const Text(
          'Your progress has been saved as a draft. You can continue later.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _formCubit.clearDraft();
              context.pop();
            },
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Save Draft'),
          ),
        ],
      ),
    );
  }
}

// ==================== STEP 1: BUSINESS DETAILS ====================

class _BusinessDetailsStep extends StatelessWidget {
  final LoanFormCubit formCubit;
  final LoanFormState state;

  const _BusinessDetailsStep({
    required this.formCubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: 'Business Name',
            error: state.validationErrors['businessName'],
            child: TextFormField(
              initialValue: state.formData['businessName'] as String?,
              onChanged: (v) => formCubit.updateField('businessName', v),
              decoration: const InputDecoration(
                hintText: 'Enter business name',
              ),
            ),
          ),
          _FormField(
            label: 'Business Type',
            error: state.validationErrors['businessType'],
            child: DropdownButtonFormField<BusinessType>(
              value: state.formData['businessType'] as BusinessType?,
              onChanged: (v) => formCubit.updateField('businessType', v),
              decoration: const InputDecoration(
                hintText: 'Select type',
              ),
              items: BusinessType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getBusinessTypeLabel(type)),
                );
              }).toList(),
            ),
          ),
          _FormField(
            label: 'Registration Number',
            error: state.validationErrors['registrationNumber'],
            child: TextFormField(
              initialValue: state.formData['registrationNumber'] as String?,
              onChanged: (v) => formCubit.updateField('registrationNumber', v),
              decoration: const InputDecoration(
                hintText: 'UDYAM / CIN number',
              ),
            ),
          ),
          _FormField(
            label: 'Years in Operation',
            error: state.validationErrors['yearsInOperation'],
            child: TextFormField(
              initialValue: state.formData['yearsInOperation']?.toString(),
              onChanged: (v) => formCubit.updateField('yearsInOperation', int.tryParse(v)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'e.g., 5',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBusinessTypeLabel(BusinessType type) {
    switch (type) {
      case BusinessType.soleProprietorship: return 'Sole Proprietorship';
      case BusinessType.partnership: return 'Partnership';
      case BusinessType.pvtLtd: return 'Private Limited';
      case BusinessType.llp: return 'LLP';
    }
  }
}

// ==================== STEP 2: APPLICANT DETAILS ====================

class _ApplicantDetailsStep extends StatelessWidget {
  final LoanFormCubit formCubit;
  final LoanFormState state;

  const _ApplicantDetailsStep({
    required this.formCubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: 'Applicant Name',
            error: state.validationErrors['applicantName'],
            child: TextFormField(
              initialValue: state.formData['applicantName'] as String?,
              onChanged: (v) => formCubit.updateField('applicantName', v),
              decoration: const InputDecoration(
                hintText: 'Full name as per PAN',
              ),
            ),
          ),
          _FormField(
            label: 'PAN Number',
            error: state.validationErrors['pan'],
            child: TextFormField(
              initialValue: state.formData['pan'] as String?,
              onChanged: (v) => formCubit.updateField('pan', v.toUpperCase()),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                hintText: 'ABCDE1234F',
              ),
            ),
          ),
          _FormField(
            label: 'Aadhaar Number',
            error: state.validationErrors['aadhaar'],
            child: TextFormField(
              initialValue: state.formData['aadhaar'] as String?,
              onChanged: (v) => formCubit.updateField('aadhaar', v),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              decoration: const InputDecoration(
                hintText: '12-digit Aadhaar',
              ),
            ),
          ),
          _FormField(
            label: 'Mobile Number',
            error: state.validationErrors['phone'],
            child: TextFormField(
              initialValue: state.formData['phone'] as String?,
              onChanged: (v) => formCubit.updateField('phone', v),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                hintText: '10-digit mobile',
                prefixText: '+91 ',
              ),
            ),
          ),
          _FormField(
            label: 'Email',
            error: state.validationErrors['email'],
            child: TextFormField(
              initialValue: state.formData['email'] as String?,
              onChanged: (v) => formCubit.updateField('email', v),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'email@example.com',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== STEP 3: LOAN REQUIREMENTS ====================

class _LoanRequirementsStep extends StatelessWidget {
  final LoanFormCubit formCubit;
  final LoanFormState state;

  const _LoanRequirementsStep({
    required this.formCubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final amount = (state.formData['requestedAmount'] as double?) ?? AppConstants.minLoanAmount;
    final purposes = (state.formData['purpose'] as List<String>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: 'Loan Amount',
            error: state.validationErrors['requestedAmount'],
            child: Column(
              children: [
                Slider(
                  value: amount.clamp(AppConstants.minLoanAmount, AppConstants.maxLoanAmount),
                  min: AppConstants.minLoanAmount,
                  max: AppConstants.maxLoanAmount,
                  divisions: 99,
                  label: '₹${(amount / 100000).toStringAsFixed(1)}L',
                  onChanged: (v) => formCubit.updateField('requestedAmount', v),
                ),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '(₹50,000 - ₹50,00,000)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          _FormField(
            label: 'Tenure (months)',
            error: state.validationErrors['tenure'],
            child: TextFormField(
              initialValue: state.formData['tenure']?.toString(),
              onChanged: (v) => formCubit.updateField('tenure', int.tryParse(v)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: '6 - 60 months',
              ),
            ),
          ),
          _FormField(
            label: 'Loan Purpose',
            error: state.validationErrors['purpose'],
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['working_capital', 'equipment', 'expansion', 'inventory']
                  .map((purpose) {
                final isSelected = purposes.contains(purpose);
                return FilterChip(
                  label: Text(_getPurposeLabel(purpose)),
                  selected: isSelected,
                  onSelected: (_) {
                    final updated = List<String>.from(purposes);
                    if (isSelected) {
                      updated.remove(purpose);
                    } else {
                      updated.add(purpose);
                    }
                    formCubit.updateField('purpose', updated);
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getPurposeLabel(String purpose) {
    switch (purpose) {
      case 'working_capital': return 'Working Capital';
      case 'equipment': return 'Equipment';
      case 'expansion': return 'Expansion';
      case 'inventory': return 'Inventory';
      default: return purpose;
    }
  }
}

// ==================== STEP 4: REVIEW ====================

class _ReviewStep extends StatelessWidget {
  final LoanFormCubit formCubit;
  final LoanFormState state;
  final Function(int) onEditStep;

  const _ReviewStep({
    required this.formCubit,
    required this.state,
    required this.onEditStep,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewSection(
            title: 'Business Details',
            onEdit: () => onEditStep(0),
            items: [
              _ReviewItem('Business Name', state.formData['businessName']?.toString() ?? '-'),
              _ReviewItem('Type', _getBusinessTypeLabel(state.formData['businessType'])),
              _ReviewItem('Registration', state.formData['registrationNumber']?.toString() ?? '-'),
              _ReviewItem('Years', '${state.formData['yearsInOperation'] ?? '-'} years'),
            ],
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Applicant Details',
            onEdit: () => onEditStep(1),
            items: [
              _ReviewItem('Name', state.formData['applicantName']?.toString() ?? '-'),
              _ReviewItem('PAN', state.formData['pan']?.toString() ?? '-'),
              _ReviewItem('Aadhaar', _maskAadhaar(state.formData['aadhaar']?.toString())),
              _ReviewItem('Phone', '+91 ${state.formData['phone'] ?? '-'}'),
              _ReviewItem('Email', state.formData['email']?.toString() ?? '-'),
            ],
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Loan Details',
            onEdit: () => onEditStep(2),
            items: [
              _ReviewItem('Amount', '₹${state.formData['requestedAmount']?.toStringAsFixed(0) ?? '-'}'),
              _ReviewItem('Tenure', '${state.formData['tenure'] ?? '-'} months'),
              _ReviewItem('Purpose', (state.formData['purpose'] as List?)?.join(', ') ?? '-'),
            ],
          ),
        ],
      ),
    );
  }

  String _getBusinessTypeLabel(BusinessType? type) {
    if (type == null) return '-';
    switch (type) {
      case BusinessType.soleProprietorship: return 'Sole Proprietorship';
      case BusinessType.partnership: return 'Partnership';
      case BusinessType.pvtLtd: return 'Private Limited';
      case BusinessType.llp: return 'LLP';
    }
  }

  String _maskAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.length < 4) return '-';
    return 'XXXX-XXXX-${aadhaar.substring(aadhaar.length - 4)}';
  }
}

// ==================== HELPER WIDGETS ====================

class _FormField extends StatelessWidget {
  final String label;
  final String? error;
  final Widget child;

  const _FormField({
    required this.label,
    this.error,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          child,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                error!,
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final List<_ReviewItem> items;

  const _ReviewSection({
    required this.title,
    required this.onEdit,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
              ),
            ],
          ),
          const Divider(),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.label, style: TextStyle(color: AppColors.textSecondary)),
                Flexible(
                  child: Text(
                    item.value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ReviewItem {
  final String label;
  final String value;
  
  _ReviewItem(this.label, this.value);
}

