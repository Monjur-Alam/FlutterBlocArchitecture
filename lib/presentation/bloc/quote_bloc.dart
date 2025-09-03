import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/remote/quote_api.dart';
import '../../data/models/quote.dart';
import '../../data/repositories/quote_repository.dart';

/// ---------- State ----------
class QuoteState extends Equatable {
  final List<Quote> quotes;
  final bool loading;
  final String? error;

  const QuoteState({this.quotes = const [], this.loading = false, this.error});

  QuoteState copyWith({
    List<Quote>? quotes,
    bool? loading,
    String? error,
  }) {
    
    return QuoteState(
      quotes: quotes ?? this.quotes,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [quotes, loading, error];
}

/// ---------- Events ----------
abstract class QuoteEvent extends Equatable {
  const QuoteEvent();
  @override
  List<Object?> get props => [];
}

class LoadQuotes extends QuoteEvent {}
class CreateQuote extends QuoteEvent {
  final Quote quote;
  const CreateQuote(this.quote);
  @override
  List<Object?> get props => [quote];
}
class UpdateQuote extends QuoteEvent {
  final Quote quote;
  const UpdateQuote(this.quote);
  @override
  List<Object?> get props => [quote];
}
class DeleteQuote extends QuoteEvent {
  final int id;
  const DeleteQuote(this.id);
  @override
  List<Object?> get props => [id];
}

/// ---------- Bloc ----------
class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  late final QuoteRepository _repo;

  QuoteBloc({QuoteRepository? repo}) : super(const QuoteState()) {
    _repo = repo ?? QuoteRepository(QuoteApi());

    on<LoadQuotes>(_onLoad);
    on<CreateQuote>(_onCreate);
    on<UpdateQuote>(_onUpdate);
    on<DeleteQuote>(_onDelete);
  }

  Future<void> _onLoad(LoadQuotes event, Emitter<QuoteState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await _repo.getQuotes();
      emit(state.copyWith(loading: false, quotes: data, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onCreate(CreateQuote event, Emitter<QuoteState> emit) async {
    try {
      final created = await _repo.addQuote(event.quote);
      final updated = [created, ...state.quotes];
      emit(state.copyWith(quotes: updated, error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateQuote event, Emitter<QuoteState> emit) async {
    try {
      final updated = await _repo.editQuote(event.quote);
      final list = state.quotes
          .map((q) => q.id == updated.id ? updated : q)
          .toList();
      emit(state.copyWith(quotes: list, error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteQuote event, Emitter<QuoteState> emit) async {
    try {
      await _repo.removeQuote(event.id);
      final list = state.quotes.where((q) => q.id != event.id).toList();
      emit(state.copyWith(quotes: list, error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
