import 'package:flutter/foundation.dart';

class VisitNote {
  final int clientId;
  final String text;
  final String stage;
  final String date;
  final String? imageUrl;

  const VisitNote({
    required this.clientId,
    required this.text,
    required this.stage,
    required this.date,
    this.imageUrl,
  });
}

class NotesModel extends ChangeNotifier {
  final List<VisitNote> _notes = [];

  List<VisitNote> get notes => List.unmodifiable(_notes);
  int get count => _notes.length;

  List<VisitNote> forClient(int clientId) {
    return _notes.where((n) => n.clientId == clientId).toList();
  }

  void add(VisitNote note) {
    _notes.add(note);
    notifyListeners();
  }
}