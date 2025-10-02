import 'package:flutter_annotations/index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Annotations'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: CounterDisplay(),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => context.read<CounterProvider>().increment(),
            heroTag: 'increment',
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: AppSpacing.xs),
          FloatingActionButton(
            onPressed: () => context.read<CounterProvider>().decrement(),
            heroTag: 'decrement',
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: AppSpacing.xs),
          FloatingActionButton.small(
            onPressed: () => context.read<CounterProvider>().reset(),
            heroTag: 'reset',
            tooltip: 'Reset',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
