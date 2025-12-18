// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanModelAdapter extends TypeAdapter<LoanModel> {
  @override
  final int typeId = 2;

  @override
  LoanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanModel(
      id: fields[0] as String,
      applicationNumber: fields[1] as String,
      status: fields[2] as LoanStatus,
      businessName: fields[3] as String,
      businessType: fields[4] as BusinessType,
      registrationNumber: fields[5] as String,
      yearsInOperation: fields[6] as int,
      applicantName: fields[7] as String,
      pan: fields[8] as String,
      aadhaar: fields[9] as String,
      phone: fields[10] as String,
      email: fields[11] as String,
      requestedAmount: fields[12] as double,
      approvedAmount: fields[13] as double?,
      tenure: fields[14] as int,
      interestRate: fields[15] as double?,
      purpose: (fields[16] as List).cast<String>(),
      rejectionReason: fields[17] as String?,
      createdAt: fields[18] as DateTime,
      updatedAt: fields[19] as DateTime,
      disbursementDate: fields[20] as DateTime?,
      isLocal: fields[21] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LoanModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.applicationNumber)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.businessName)
      ..writeByte(4)
      ..write(obj.businessType)
      ..writeByte(5)
      ..write(obj.registrationNumber)
      ..writeByte(6)
      ..write(obj.yearsInOperation)
      ..writeByte(7)
      ..write(obj.applicantName)
      ..writeByte(8)
      ..write(obj.pan)
      ..writeByte(9)
      ..write(obj.aadhaar)
      ..writeByte(10)
      ..write(obj.phone)
      ..writeByte(11)
      ..write(obj.email)
      ..writeByte(12)
      ..write(obj.requestedAmount)
      ..writeByte(13)
      ..write(obj.approvedAmount)
      ..writeByte(14)
      ..write(obj.tenure)
      ..writeByte(15)
      ..write(obj.interestRate)
      ..writeByte(16)
      ..write(obj.purpose)
      ..writeByte(17)
      ..write(obj.rejectionReason)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt)
      ..writeByte(20)
      ..write(obj.disbursementDate)
      ..writeByte(21)
      ..write(obj.isLocal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatusOverrideAdapter extends TypeAdapter<StatusOverride> {
  @override
  final int typeId = 3;

  @override
  StatusOverride read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatusOverride(
      loanId: fields[0] as String,
      status: fields[1] as LoanStatus,
      reason: fields[2] as String?,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StatusOverride obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.loanId)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.reason)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusOverrideAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoanStatusAdapter extends TypeAdapter<LoanStatus> {
  @override
  final int typeId = 0;

  @override
  LoanStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LoanStatus.pending;
      case 1:
        return LoanStatus.underReview;
      case 2:
        return LoanStatus.approved;
      case 3:
        return LoanStatus.rejected;
      case 4:
        return LoanStatus.disbursed;
      default:
        return LoanStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, LoanStatus obj) {
    switch (obj) {
      case LoanStatus.pending:
        writer.writeByte(0);
        break;
      case LoanStatus.underReview:
        writer.writeByte(1);
        break;
      case LoanStatus.approved:
        writer.writeByte(2);
        break;
      case LoanStatus.rejected:
        writer.writeByte(3);
        break;
      case LoanStatus.disbursed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BusinessTypeAdapter extends TypeAdapter<BusinessType> {
  @override
  final int typeId = 1;

  @override
  BusinessType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BusinessType.soleProprietorship;
      case 1:
        return BusinessType.partnership;
      case 2:
        return BusinessType.pvtLtd;
      case 3:
        return BusinessType.llp;
      default:
        return BusinessType.soleProprietorship;
    }
  }

  @override
  void write(BinaryWriter writer, BusinessType obj) {
    switch (obj) {
      case BusinessType.soleProprietorship:
        writer.writeByte(0);
        break;
      case BusinessType.partnership:
        writer.writeByte(1);
        break;
      case BusinessType.pvtLtd:
        writer.writeByte(2);
        break;
      case BusinessType.llp:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
