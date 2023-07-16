class LeaveRequestModel {
  String leaveRequestId;
  String userAuthUid;
  String reason;
  String fromDate;
  String toDate;
  String description;
  Map<String, dynamic> applicationStatus;

  LeaveRequestModel({
    required this.leaveRequestId,
    required this.userAuthUid,
    required this.reason,
    required this.fromDate,
    required this.toDate,
    required this.description,
    required this.applicationStatus,
  });

  factory LeaveRequestModel.empty() {
    return LeaveRequestModel(
      leaveRequestId: '',
      userAuthUid: '',
      reason: '',
      fromDate: '',
      toDate: '',
      description: '',
      applicationStatus: {},
    );
  }

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      leaveRequestId: json['leaveRequestId'],
      userAuthUid: json['userAuthUid'],
      reason: json['reason'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      description: json['description'],
      applicationStatus: json['applicationStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaveRequestId': leaveRequestId,
      'userAuthUid': userAuthUid,
      'reason': reason,
      'fromDate': fromDate,
      'toDate': toDate,
      'description': description,
      'applicationStatus': applicationStatus,
    };
  }
}
