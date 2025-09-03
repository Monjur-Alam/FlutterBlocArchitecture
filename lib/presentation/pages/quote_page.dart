import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/quote.dart';
import '../bloc/quote_bloc.dart';

class QuotePage extends StatelessWidget {
  const QuotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuoteBloc()..add(LoadQuotes()),
      child: BlocListener<QuoteBloc, QuoteState>(
        listenWhen: (prev, curr) => prev.error != curr.error && curr.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Quotes (BLoC)"),
            actions: [
              IconButton(
                onPressed: () => context.read<QuoteBloc>().add(LoadQuotes()),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: BlocBuilder<QuoteBloc, QuoteState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.quotes.isEmpty) {
                return const Center(child: Text("No quotes. Add some!"));
              }
              return ListView.separated(
                itemCount: state.quotes.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, i) {
                  final q = state.quotes[i];
                  return ListTile(
                    title: Text(q.text),
                    subtitle: Text("— ${q.author}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Edit",
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditDialog(context, q),
                        ),
                        IconButton(
                          tooltip: "Delete",
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () => context.read<QuoteBloc>().add(DeleteQuote(q.id)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add),
            label: const Text("Add"),
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final text = TextEditingController();
    final author = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Quote"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: text, decoration: const InputDecoration(labelText: "Text")),
            TextField(controller: author, decoration: const InputDecoration(labelText: "Author")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final q = Quote(id: 0, text: text.text.trim(), author: author.text.trim());
              context.read<QuoteBloc>().add(CreateQuote(q));
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Quote quote) {
    final text = TextEditingController(text: quote.text);
    final author = TextEditingController(text: quote.author);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Quote"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: text, decoration: const InputDecoration(labelText: "Text")),
            TextField(controller: author, decoration: const InputDecoration(labelText: "Author")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final updated = quote.copyWith(
                text: text.text.trim(),
                author: author.text.trim(),
              );
              context.read<QuoteBloc>().add(UpdateQuote(updated));
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
