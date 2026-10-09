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
}

const mockClients = [
  Client(
    id: 1,
    name: 'ООО Молдтранс',
    contactPerson: 'Виктор Белый',
    phone: '+373 69 123 456',
    stage: 'Новый лид',
    lastVisit: '10.09.2026',
  ),
  Client(
    id: 2,
    name: 'Агростиль SRL',
    contactPerson: 'Даниил Дрига',
    phone: '+373 68 234 567',
    stage: 'Встреча назначена',
    lastVisit: '05.09.2026',
  ),
  Client(
    id: 3,
    name: 'Vinaria Bostavan',
    contactPerson: 'Олег Хамуев',
    phone: '+373 79 345 678',
    stage: 'Переговоры',
    lastVisit: '01.09.2026',
  ),
  Client(
    id: 4,
    name: 'FreshMarket SRL',
    contactPerson: 'Дмитрий Згурский',
    phone: '+373 60 456 789',
    stage: 'Закрыт',
    lastVisit: '28.08.2026',
  ),
  Client(
    id: 5,
    name: 'BuildPro Construct',
    contactPerson: 'Эдуард Бурмак',
    phone: '+373 67 567 890',
    stage: 'Закрыт',
    lastVisit: '20.08.2026',
  ),
  Client(
    id: 6,
    name: 'TehnoServis SRL',
    contactPerson: 'Владислав Зубак',
    phone: '+373 78 678 901',
    stage: 'Новый лид',
    lastVisit: '15.08.2026',
  ),
];