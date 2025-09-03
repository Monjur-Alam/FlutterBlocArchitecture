# 📝 BLoC Architecture

## 📂 Bloc ফাইলের গঠন
আমাদের সাধারণত ৩টা অংশ থাকে –
- State → বর্তমান ডেটা কেমন আছে (quotes list, loading state, error ইত্যাদি)
- Event → কোন অ্যাকশন/ইভেন্ট ঘটছে (load, create, update, delete ইত্যাদি)
- Bloc → Event অনুযায়ী State পরিবর্তন করার লজিক

## 1️⃣ QuoteState

```dart
class QuoteState extends Equatable {
  final List<Quote> quotes;
  final bool loading;
  final String? error;

  const QuoteState({this.quotes = const [], this.loading = false, this.error});

  QuoteState copyWith({List<Quote>? quotes, bool? loading, String? error}) {
    return QuoteState(
      quotes: quotes ?? this.quotes,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [quotes, loading, error];
}
```
### 🔎 ব্যাখ্যা:
- List<Quote> quotes → সব কোট লিস্ট এখানে থাকবে।
- bool loading → ডেটা লোড হচ্ছে কি না তা ট্র্যাক করার জন্য।
- String? error → কোনো এরর হলে এখানে সেই মেসেজ রাখা হবে।
- copyWith → নতুন স্টেট তৈরি করার জন্য, কিন্তু আগের ভ্যালুগুলো রেখে শুধু কিছু ভ্যালু পরিবর্তন করতে পারি।
- Equatable → Bloc জানে কবে state আসলেই বদলেছে (অন্যথায় UI বারবার রিবিল্ড হত)।

## 2️⃣ QuoteEvent
```dart
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
```
### 🔎 ব্যাখ্যা:
- LoadQuotes → সব কোট লোড করার জন্য।
- CreateQuote → নতুন কোট তৈরি করার জন্য।
- UpdateQuote → পুরনো কোট আপডেট করার জন্য।
- DeleteQuote → কোনো কোট আইডি দিয়ে মুছে ফেলার জন্য।

👉 মানে: Event = কি করতে চাই

## 3️⃣ QuoteBloc
```dart
class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  QuoteBloc() : super(const QuoteState()) {
    final repo = QuoteRepository(QuoteApi());
```
### 🔎 ব্যাখ্যা:
- Bloc সবসময় Event → State এ কাজ করে।
- শুরুতে আমরা initial state দিচ্ছি QuoteState() (মানে empty list, not loading, no error)।
- repo হলো আমাদের Repository (API call / ডেটা হ্যান্ডেল করার জায়গা)।
### LoadQuotes Event হ্যান্ডলিং
```dart
    on<LoadQuotes>((event, emit) async {
      emit(state.copyWith(loading: true));
      try {
        final data = await repo.getQuotes();
        emit(state.copyWith(loading: false, quotes: data));
      } catch (e) {
        emit(state.copyWith(loading: false, error: e.toString()));
      }
    });
```
### 🔎 ব্যাখ্যা:
- Event এলো → LoadQuotes
- প্রথমে আমরা state আপডেট করলাম → loading: true (UI তে লোডিং ইন্ডিকেটর দেখা যাবে)।
- তারপর API থেকে quotes আনলাম।
- সফল হলে → quotes: data দিয়ে state emit করলাম।
- ব্যর্থ হলে → error: e.toString() দিয়ে state emit করলাম।

## CreateQuote Event হ্যান্ডলিং
```dart
    on<CreateQuote>((event, emit) async {
      try {
        final created = await repo.addQuote(event.quote);
        final updated = List<Quote>.from(state.quotes)..insert(0, created);
        emit(state.copyWith(quotes: updated));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
```
### 🔎 ব্যাখ্যা:
- নতুন কোট API তে পাঠানো হলো।
- যদি সফল হয় → পুরনো লিস্ট কপি করে তার মধ্যে নতুন কোটটা যোগ করা হলো।
- emit করা হলো নতুন state।

## UpdateQuote Event হ্যান্ডলিং
```dart
    on<UpdateQuote>((event, emit) async {
      try {
        final updated = await repo.editQuote(event.quote);
        final list = state.quotes.map((q) => q.id == updated.id ? updated : q).toList();
        emit(state.copyWith(quotes: list));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
```
### 🔎 ব্যাখ্যা:
- যেই কোটের id মিলে গেছে সেটাকে নতুন আপডেটেড কোট দিয়ে রিপ্লেস করা হচ্ছে।
- বাকি লিস্ট একই রইল।

## DeleteQuote Event হ্যান্ডলিং
```dart
    on<DeleteQuote>((event, emit) async {
      try {
        await repo.removeQuote(event.id);
        emit(state.copyWith(quotes: state.quotes.where((q) => q.id != event.id).toList()));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
  }
}
```
### 🔎 ব্যাখ্যা:
- API থেকে quote ডিলিট করার রিকোয়েস্ট পাঠানো হলো।
- তারপর নতুন লিস্ট বানানো হলো যেখানে ওই id বাদ দিয়ে বাকি quotes রাখা হলো।
- emit করে UI তে নতুন লিস্ট পাঠানো হলো।

## 🔄 Workflow Summary
- User Action → Event পাঠায় (যেমন: LoadQuotes, CreateQuote)
- Bloc → সেই Event কে হ্যান্ডেল করে (API call / লজিক চালায়)
- Bloc emit → নতুন State তৈরি করে পাঠায়
- UI (BlocBuilder/BlocListener) → নতুন State শুনে UI রিবিল্ড করে




