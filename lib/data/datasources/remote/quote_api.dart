import 'dart:async';
import '../../models/quote.dart';

class QuoteApi {
  final _store = <Quote>[
    Quote(id: 1, text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
    Quote(id: 2, text: "Simplicity is the soul of efficiency.", author: "Austin Freeman"),
  ];
  int _nextId = 3;

  Future<List<Quote>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<Quote>.from(_store);
  }

  Future<Quote> create(Quote q) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final created = q.copyWith(id: _nextId++);
    _store.insert(0, created);
    return created;
  }

  Future<Quote> update(Quote q) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _store.indexWhere((e) => e.id == q.id);
    if (idx == -1) throw Exception("Quote not found");
    _store[idx] = q;
    return q;
  }

  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _store.removeWhere((e) => e.id == id);
  }
}
