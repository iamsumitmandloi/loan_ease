import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/repositories/loan_repository.dart';

part 'loan_form_state.dart';

/// Loan Form Cubit - handles multi-step form wizard
/// Using Cubit because state changes are straightforward
class LoanFormCubit extends Cubit<LoanFormState> {
  final LoanRepository _repository;

  LoanFormCubit(this._repository) : super(const LoanFormState());

  /// Initialize - check for existing draft
  void initialize() {
    final draft = _repository.getDraft();
    if (draft != null) {
      emit(state.copyWith(
        currentStep: draft.step,
        formData: draft.data,
        hasDraft: true,
      ));
    }
  }

  /// Go to next step
  void nextStep() {
    if (state.currentStep < 3) {
      final newStep = state.currentStep + 1;
      emit(state.copyWith(currentStep: newStep));
      _saveDraft();
    }
  }

  /// Go to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  /// Go to specific step (for edit from review)
  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      emit(state.copyWith(currentStep: step));
    }
  }

  /// Update form field
  void updateField(String key, dynamic value) {
    final newData = Map<String, dynamic>.from(state.formData);
    newData[key] = value;
    emit(state.copyWith(formData: newData));
    _saveDraft();
  }

  /// Update multiple fields at once
  void updateFields(Map<String, dynamic> fields) {
    final newData = Map<String, dynamic>.from(state.formData);
    newData.addAll(fields);
    emit(state.copyWith(formData: newData));
    _saveDraft();
  }

  /// Validate current step
  bool validateStep() {
    final errors = <String, String>{};
    
    switch (state.currentStep) {
      case 0: // Business Details
        if ((state.formData['businessName'] as String?)?.isEmpty ?? true) {
          errors['businessName'] = 'Business name is required';
        }
        if (state.formData['businessType'] == null) {
          errors['businessType'] = 'Select business type';
        }
        if (!_isValidRegistrationNumber(state.formData['registrationNumber'] as String?)) {
          errors['registrationNumber'] = 'Invalid registration number (min 6 alphanumeric)';
        }
        if (!_isValidYearsInOperation(state.formData['yearsInOperation'] as int?)) {
          errors['yearsInOperation'] = 'Years must be between 0 and 100';
        }
        break;
        
      case 1: // Applicant Details
        if ((state.formData['applicantName'] as String?)?.isEmpty ?? true) {
          errors['applicantName'] = 'Applicant name is required';
        }
        if (!_isValidPan(state.formData['pan'] as String?)) {
          errors['pan'] = 'Invalid PAN format';
        }
        if (!_isValidAadhaar(state.formData['aadhaar'] as String?)) {
          errors['aadhaar'] = 'Invalid Aadhaar (12 digits required)';
        }
        if (!_isValidPhone(state.formData['phone'] as String?)) {
          errors['phone'] = 'Invalid phone number';
        }
        if (!_isValidEmail(state.formData['email'] as String?)) {
          errors['email'] = 'Invalid email';
        }
        break;
        
      case 2: // Loan Requirements
        final amount = state.formData['requestedAmount'] as double?;
        if (amount == null || amount < 50000 || amount > 5000000) {
          errors['requestedAmount'] = 'Amount must be between ₹50,000 and ₹50,00,000';
        }
        final tenure = state.formData['tenure'] as int?;
        if (tenure == null || tenure < 6 || tenure > 60) {
          errors['tenure'] = 'Tenure must be 6-60 months';
        }
        final purpose = state.formData['purpose'] as List?;
        if (purpose == null || purpose.isEmpty) {
          errors['purpose'] = 'Select at least one purpose';
        }
        break;
    }
    
    emit(state.copyWith(validationErrors: errors));
    return errors.isEmpty;
  }

  /// Submit the application
  Future<void> submit() async {
    if (!validateStep()) return;
    
    emit(state.copyWith(isSubmitting: true));
    
    try {
      await _repository.createLoan(
        businessName: state.formData['businessName'] as String,
        businessType: state.formData['businessType'] as BusinessType,
        registrationNumber: state.formData['registrationNumber'] as String,
        yearsInOperation: state.formData['yearsInOperation'] as int,
        applicantName: state.formData['applicantName'] as String,
        pan: state.formData['pan'] as String,
        aadhaar: state.formData['aadhaar'] as String,
        phone: state.formData['phone'] as String,
        email: state.formData['email'] as String,
        requestedAmount: state.formData['requestedAmount'] as double,
        tenure: state.formData['tenure'] as int,
        purpose: List<String>.from(state.formData['purpose'] as List),
      );
      
      // Clear draft after successful submission
      await _repository.clearDraft();
      
      emit(state.copyWith(
        isSubmitting: false,
        isSubmitted: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        submitError: 'Failed to submit application',
      ));
    }
  }

  /// Clear draft and reset form
  Future<void> clearDraft() async {
    await _repository.clearDraft();
    emit(const LoanFormState());
  }

  /// Save draft to local storage
  Future<void> _saveDraft() async {
    await _repository.saveDraft(state.currentStep, state.formData);
  }

  // Validation helpers
  bool _isValidPan(String? pan) {
    if (pan == null || pan.isEmpty) return false;
    // PAN format: 5 letters + 4 digits + 1 letter (e.g., ABCDE1234F)
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan.toUpperCase());
  }

  bool _isValidAadhaar(String? aadhaar) {
    if (aadhaar == null) return false;
    final digits = aadhaar.replaceAll(RegExp(r'[^0-9]'), '');
    // Aadhaar: 12 digits, cannot start with 0 or 1
    return digits.length == 12 && RegExp(r'^[2-9]').hasMatch(digits);
  }

  bool _isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    // Indian mobile: starts with 6-9, total 10 digits
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  bool _isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidRegistrationNumber(String? regNo) {
    if (regNo == null || regNo.isEmpty) return false;
    // Basic validation: at least 6 characters alphanumeric
    return regNo.length >= 6 && RegExp(r'^[A-Z0-9]+$').hasMatch(regNo.toUpperCase());
  }

  bool _isValidYearsInOperation(int? years) {
    if (years == null) return false;
    // Must be between 0 and 100 years
    return years >= 0 && years <= 100;
  }
}

