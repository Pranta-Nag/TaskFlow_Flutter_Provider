import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/main.dart';
import 'package:taskflow/providers/task_provider.dart';

void main() {
  testWidgets('TaskManager initial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TaskProvider(),
        child: const MyApp(),
      ),
    );

    // Verify brand title is displayed
    expect(find.text('Taskflow'), findsOneWidget);

    // Verify statistics cards are present
    expect(find.text('Total'), findsWidgets);
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Pending'), findsWidgets);
  });
}
