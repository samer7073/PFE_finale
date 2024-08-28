class Bookingsdata {
  final String Pipeline;
  final String id;
  final String owner;
  final String ownerAvatar;
  final int stageId;
  final String createdAt;
  final String? roomId;
  final String label;
  final String channels;
  final String process;
  final int pipelineId;
  final String account;
  final String channelCategory;
  final String expireLe;
  final String checkIn;
  final String checkOut;
  final List<dynamic>? totalAmount;
  final String contacts;
  final String status;
  final String reference;
  final String products;
  final String supplier;
  final String supplierAccount;
  final String language;
  final String referenceSupplier;
  final String? users;
  final String? testField;

  Bookingsdata({
    required this.Pipeline,
    required this.id,
    required this.owner,
    required this.ownerAvatar,
    required this.stageId,
    required this.createdAt,
    this.roomId,
    required this.label,
    required this.channels,
    required this.process,
    required this.pipelineId,
    required this.account,
    required this.channelCategory,
    required this.expireLe,
    required this.checkIn,
    required this.checkOut,
    this.totalAmount,
    required this.contacts,
    required this.status,
    required this.reference,
    required this.products,
    required this.supplier,
    required this.supplierAccount,
    required this.language,
    required this.referenceSupplier,
    this.users,
    this.testField,
  });

  factory Bookingsdata.fromJson(Map<String, dynamic> json) {
    return Bookingsdata(
      Pipeline:json['pipeline']?? "",
      id: json['id'] ?? '',
      owner: json['owner'] ?? '',
      ownerAvatar: json['owner_avatar'] ?? '',
      stageId: json['stage_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      roomId: json['room_id'],
      label: json['label'] ?? '',
      channels: json['channels'] ?? '',
      process: json['process'] ?? '',
      pipelineId: json['pipeline_id'] ?? 0,
      account: json['Account'] ?? '',
      channelCategory: json['channel_category'] ?? '',
      expireLe: json['expire_le'] ?? '',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      totalAmount: json['total_amount'] ?? [],
      contacts: json['contacts'] ?? '',
      status: json['status'] ?? '',
      reference: json['reference'] ?? '',
      products: json['products'] ?? '',
      supplier: json['supplier'] ?? '',
      supplierAccount: json['supplier_account'] ?? '',
      language: json['language'] ?? '',
      referenceSupplier: json['reference_supplier'] ?? '',
      users: json['users'],
      testField: json['test_field'],
    );
  }
}