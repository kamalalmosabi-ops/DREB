class BankAccountModel {
  final int bankAccountId;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;
  final String? logoUrl;

  BankAccountModel({
    required this.bankAccountId,
    this.bankName,
    this.accountNumber,
    this.accountHolderName,
    this.logoUrl,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      bankAccountId: json['bankAccountId'] ?? 0,
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      accountHolderName: json['accountHolderName'],
      logoUrl: json['logoUrl'],
    );
  }
}