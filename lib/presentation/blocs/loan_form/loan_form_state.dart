part of 'loan_form_cubit.dart';

/// Loan form state
class LoanFormState extends Equatable {
  final int currentStep; // 0-3
  final Map<String, dynamic> formData;
  final Map<String, String> validationErrors;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? submitError;
  final bool hasDraft;

  const LoanFormState({
    this.currentStep = 0,
    this.formData = const {},
    this.validationErrors = const {},
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.submitError,
    this.hasDraft = false,
  });

  LoanFormState copyWith({
    int? currentStep,
    Map<String, dynamic>? formData,
    Map<String, String>? validationErrors,
    bool? isSubmitting,
    bool? isSubmitted,
    String? submitError,
    bool? hasDraft,
  }) {
    return LoanFormState(
      currentStep: currentStep ?? this.currentStep,
      formData: formData ?? this.formData,
      validationErrors: validationErrors ?? this.validationErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submitError: submitError,
      hasDraft: hasDraft ?? this.hasDraft,
    );
  }

  /// Get step title
  String get stepTitle {
    switch (currentStep) {
      case 0:
        return 'Business Details';
      case 1:
        return 'Applicant Details';
      case 2:
        return 'Loan Requirements';
      case 3:
        return 'Review & Submit';
      default:
        return '';
    }
  }

  /// Check if can proceed to next step
  bool get canProceed => validationErrors.isEmpty;

  @override
  List<Object?> get props => [
    currentStep,
    formData,
    validationErrors,
    isSubmitting,
    isSubmitted,
    submitError,
    hasDraft,
  ];
}

