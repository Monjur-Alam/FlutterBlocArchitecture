import '../datasources/remote/quote_api.dart';
import '../models/quote.dart';

class QuoteRepository {
  final QuoteApi api;
  QuoteRepository(this.api);

  Future<List<Quote>> getQuotes() => api.fetchAll();
  Future<Quote> addQuote(Quote q) => api.create(q);
  Future<Quote> editQuote(Quote q) => api.update(q);
  Future<void> removeQuote(int id) => api.delete(id);
}
