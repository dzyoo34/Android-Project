class Client {
  final int id;
  final String name;
  final String contactPerson;
  final String phone;
  final String stage;
  final String lastVisit;

  const Client({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.stage,
    required this.lastVisit,
  });

  // тот же клиент, но с другим id / этапом / датой визита
  Client copyWith({int? id, String? stage, String? lastVisit}) {
    return Client(
      id: id ?? this.id,
      name: name,
      contactPerson: contactPerson,
      phone: phone,
      stage: stage ?? this.stage,
      lastVisit: lastVisit ?? this.lastVisit,
    );
  }
}