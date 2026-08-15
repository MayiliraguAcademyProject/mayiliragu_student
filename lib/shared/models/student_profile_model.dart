class StudentProfileModel {
  final String id;
  final String userId;
  final String studentId;
  final String? gender;
  final String? dob;
  final String? bloodGroup;
  final String? aadhaarNumber;
  final String nationality;
  final String? category;
  final String? mobileNumber;
  final String? whatsappNumber;
  final String? parentName;
  final String? parentMobile;
  final String? emergencyContact;
  final String? currentAddress;
  final String? permanentAddress;
  final String? city;
  final String? district;
  final String state;
  final String? pinCode;
  final String? highestQualification;
  final String? degree;
  final String? college;
  final int? yearOfPassing;
  final double? percentage;
  final String? mediumOfEducation;
  final bool isPremium;

  StudentProfileModel({
    required this.id,
    required this.userId,
    required this.studentId,
    this.gender,
    this.dob,
    this.bloodGroup,
    this.aadhaarNumber,
    required this.nationality,
    this.category,
    this.mobileNumber,
    this.whatsappNumber,
    this.parentName,
    this.parentMobile,
    this.emergencyContact,
    this.currentAddress,
    this.permanentAddress,
    this.city,
    this.district,
    required this.state,
    this.pinCode,
    this.highestQualification,
    this.degree,
    this.college,
    this.yearOfPassing,
    this.percentage,
    this.mediumOfEducation,
    this.isPremium = false,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    final paymentsList = json['payments'] as List?;
    double totalPaid = 0.0;
    if (paymentsList != null && paymentsList.isNotEmpty) {
      for (var p in paymentsList) {
        if (p is Map && p['amountPaid'] != null) {
          totalPaid += (p['amountPaid'] as num).toDouble();
        }
      }
    }

    final rawIsPremium =
        (json['isPremium'] ?? json['is_premium']) as bool? ?? false;
    final bool calculatedIsPremium = paymentsList != null
        ? (rawIsPremium && paymentsList.isNotEmpty && totalPaid > 0)
        : rawIsPremium;

    return StudentProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      studentId: json['studentId'] as String,
      gender: json['gender'] as String?,
      dob: json['dob'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      aadhaarNumber: json['aadhaarNumber'] as String?,
      nationality: json['nationality'] as String? ?? 'Indian',
      category: json['category'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      parentName: json['parentName'] as String?,
      parentMobile: json['parentMobile'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      currentAddress: json['currentAddress'] as String?,
      permanentAddress: json['permanentAddress'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String? ?? 'Tamil Nadu',
      pinCode: json['pinCode'] as String?,
      highestQualification: json['highestQualification'] as String?,
      degree: json['degree'] as String?,
      college: json['college'] as String?,
      yearOfPassing: json['yearOfPassing'] as int?,
      percentage: (json['percentage'] as num?)?.toDouble(),
      mediumOfEducation: json['mediumOfEducation'] as String?,
      isPremium: calculatedIsPremium,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'studentId': studentId,
      'gender': gender,
      'dob': dob,
      'bloodGroup': bloodGroup,
      'aadhaarNumber': aadhaarNumber,
      'nationality': nationality,
      'category': category,
      'mobileNumber': mobileNumber,
      'whatsappNumber': whatsappNumber,
      'parentName': parentName,
      'parentMobile': parentMobile,
      'emergencyContact': emergencyContact,
      'currentAddress': currentAddress,
      'permanentAddress': permanentAddress,
      'city': city,
      'district': district,
      'state': state,
      'pinCode': pinCode,
      'highestQualification': highestQualification,
      'degree': degree,
      'college': college,
      'yearOfPassing': yearOfPassing,
      'percentage': percentage,
      'mediumOfEducation': mediumOfEducation,
      'isPremium': isPremium,
    };
  }
}
