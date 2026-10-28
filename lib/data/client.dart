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

  factory Client.fromJson(Map<String, dynamic> j) => Client(
    id: j['id'] as int,
    name: j['name'] as String,
    contactPerson: j['contactPerson'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
    stage: j['stage'] as String? ?? 'Новый лид',
    lastVisit: j['lastVisit'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'contactPerson': contactPerson,
    'phone': phone,
    'stage': stage,
    'lastVisit': lastVisit,
  };

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