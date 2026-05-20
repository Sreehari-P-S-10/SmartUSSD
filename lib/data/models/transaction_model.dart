class TransactionModel {
  final int? id;
  final String merchant;
  final double amount;
  final String type; // 'sent' | 'received' | 'failed'
  final DateTime timestamp;
  final String? reference;
  final String? ussdCode;
  final String? iconKey;

  const TransactionModel({
    this.id,
    required this.merchant,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.reference,
    this.ussdCode,
    this.iconKey,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      merchant: map['merchant'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      reference: map['reference'] as String?,
      ussdCode: map['ussd_code'] as String?,
      iconKey: map['icon_key'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'merchant': merchant,
      'amount': amount,
      'type': type,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'reference': reference,
      'ussd_code': ussdCode,
      'icon_key': iconKey,
    };
  }

  TransactionModel copyWith({
    int? id,
    String? merchant,
    double? amount,
    String? type,
    DateTime? timestamp,
    String? reference,
    String? ussdCode,
    String? iconKey,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      reference: reference ?? this.reference,
      ussdCode: ussdCode ?? this.ussdCode,
      iconKey: iconKey ?? this.iconKey,
    );
  }

  bool get isSent => type == 'sent';
  bool get isReceived => type == 'received';
  bool get isFailed => type == 'failed';
}
