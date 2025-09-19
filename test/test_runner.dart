import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';

class TestResult {
  final String fileName;
  final String testType;
  final int passed;
  final int failed;
  final double executionTime;
  final bool success;
  final String? errorMessage;

  TestResult({
    required this.fileName,
    required this.testType,
    required this.passed,
    required this.failed,
    required this.executionTime,
    required this.success,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'testType': testType,
    'passed': passed,
    'failed': failed,
    'executionTime': executionTime,
    'success': success,
    'errorMessage': errorMessage,
  };
}

class TestSummary {
  final List<TestResult> results;
  final int totalPassed;
  final int totalFailed;
  final double totalTime;
  final bool allPassed;

  TestSummary({
    required this.results,
    required this.totalPassed,
    required this.totalFailed,
    required this.totalTime,
    required this.allPassed,
  });

  Map<String, dynamic> toJson() => {
    'results': results.map((r) => r.toJson()).toList(),
    'summary': {
      'totalPassed': totalPassed,
      'totalFailed': totalFailed,
      'totalTime': totalTime,
      'allPassed': allPassed,
    },
  };
}

class TestRunner {
  final bool verbose;
  final bool dartOnly;
  final bool flutterOnly;
  final String format;

  TestRunner({
    this.verbose = false,
    this.dartOnly = false,
    this.flutterOnly = false,
    this.format = 'table',
  });

  Future<TestSummary> runAllTests() async {
    final testFiles = await _getTestFiles();
    final results = <TestResult>[];

    if (verbose) {
      print('Found ${testFiles.length} test files to run\n');
    }

    for (final testFile in testFiles) {
      if (verbose) {
        print('Running ${testFile.testType} test: ${testFile.fileName}...');
      }

      final result = await _runSingleTest(testFile);
      results.add(result);

      if (verbose) {
        print(
          '  Result: ${result.success ? "PASS" : "FAIL"} '
          '(${result.passed} passed, ${result.failed} failed, '
          '${result.executionTime.toStringAsFixed(2)}s)\n',
        );
      }
    }

    final totalPassed = results.fold(0, (sum, r) => sum + r.passed);
    final totalFailed = results.fold(0, (sum, r) => sum + r.failed);
    final totalTime = results.fold(0.0, (sum, r) => sum + r.executionTime);
    final allPassed = results.every((r) => r.success);

    return TestSummary(
      results: results,
      totalPassed: totalPassed,
      totalFailed: totalFailed,
      totalTime: totalTime,
      allPassed: allPassed,
    );
  }

  Future<List<({String fileName, String testType})>> _getTestFiles() async {
    final testDir = Directory('test');
    final testFiles = <({String fileName, String testType})>[];

    await for (final entity in testDir.list()) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final fileName = entity.path.split('/').last.replaceAll('.dart', '');

        // Skip the test runner itself
        if (fileName == 'test_runner') continue;

        // Determine test type based on content
        final content = await entity.readAsString();
        final isFlutterTest =
            content.contains('flutter_test') ||
            content.contains('testWidgets') ||
            content.contains('WidgetTester');

        final testType = isFlutterTest ? 'Flutter' : 'Dart';

        // Apply filters
        if (dartOnly && isFlutterTest) continue;
        if (flutterOnly && !isFlutterTest) continue;

        testFiles.add((fileName: fileName, testType: testType));
      }
    }

    // Sort by name for consistent output
    testFiles.sort((a, b) => a.fileName.compareTo(b.fileName));
    return testFiles;
  }

  Future<TestResult> _runSingleTest(
    ({String fileName, String testType}) testFile,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final isFlutterTest = testFile.testType == 'Flutter';
      final command = isFlutterTest ? 'flutter' : 'dart';
      final args = isFlutterTest
          ? ['test', 'test/${testFile.fileName}.dart']
          : ['test/${testFile.fileName}.dart'];

      final result = await Process.run(command, args);
      stopwatch.stop();

      final output = result.stdout as String;
      final errorOutput = result.stderr as String;

      if (verbose && output.isNotEmpty) {
        print('  Output: $output');
      }
      if (verbose && errorOutput.isNotEmpty) {
        print('  Error: $errorOutput');
      }

      final success = result.exitCode == 0;
      int passed = 0;
      int failed = 0;
      String? errorMessage;

      if (isFlutterTest) {
        // Parse Flutter test output
        final lines = output.split('\n');
        for (final line in lines) {
          if (line.contains('All tests passed!')) {
            // Count tests from summary line
            final testCountMatch = RegExp(
              r'(\d+) tests? passed',
            ).firstMatch(output);
            if (testCountMatch != null) {
              passed = int.parse(testCountMatch.group(1)!);
            } else {
              passed = 1; // Default assumption
            }
          } else if (line.contains('failed')) {
            failed = 1; // Simplified failure detection
          }
        }
        if (passed == 0 && failed == 0 && success) {
          passed = 1; // Default for successful test
        }
      } else {
        // Parse Dart test output - these tests use print statements, not test framework
        if (success) {
          passed = 1; // Simple Dart scripts that complete successfully
        } else {
          failed = 1;
          errorMessage = errorOutput.isNotEmpty ? errorOutput : 'Test failed';
        }
      }

      return TestResult(
        fileName: testFile.fileName,
        testType: testFile.testType,
        passed: passed,
        failed: failed,
        executionTime: stopwatch.elapsedMilliseconds / 1000.0,
        success: success,
        errorMessage: errorMessage,
      );
    } catch (e) {
      stopwatch.stop();
      return TestResult(
        fileName: testFile.fileName,
        testType: testFile.testType,
        passed: 0,
        failed: 1,
        executionTime: stopwatch.elapsedMilliseconds / 1000.0,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  void printResults(TestSummary summary) {
    switch (format.toLowerCase()) {
      case 'json':
        print(JsonEncoder.withIndent('  ').convert(summary.toJson()));
        break;
      case 'csv':
        _printCsv(summary);
        break;
      default:
        _printTable(summary);
    }
  }

  void _printTable(TestSummary summary) {
    // Table formatting
    const int fileNameWidth = 25;
    const int typeWidth = 8;
    const int passedWidth = 6;
    const int failedWidth = 6;
    const int statusWidth = 9;
    const int timeWidth = 8;

    // Top border
    print(
      '╔${'═' * fileNameWidth}╤${'═' * typeWidth}╤${'═' * passedWidth}╤${'═' * failedWidth}╤${'═' * timeWidth}╤${'═' * statusWidth}╗',
    );

    // Header
    print(
      '║${'Test File'.padRight(fileNameWidth)}│${'Type'.padRight(typeWidth)}│${'Passed'.padRight(passedWidth)}│${'Failed'.padRight(failedWidth)}│${'Time(s)'.padRight(timeWidth)}│${'Status'.padRight(statusWidth)}║',
    );

    // Header separator
    print(
      '╠${'═' * fileNameWidth}╪${'═' * typeWidth}╪${'═' * passedWidth}╪${'═' * failedWidth}╪${'═' * timeWidth}╪${'═' * statusWidth}╣',
    );

    // Data rows
    for (final result in summary.results) {
      final fileName = result.fileName.length > fileNameWidth - 1
          ? '${result.fileName.substring(0, fileNameWidth - 4)}...'
          : result.fileName.padRight(fileNameWidth);
      final type = result.testType.padRight(typeWidth);
      final passed = result.passed.toString().padRight(passedWidth);
      final failed = result.failed.toString().padRight(failedWidth);
      final time = result.executionTime.toStringAsFixed(2).padRight(timeWidth);
      final status = (result.success ? '✅ PASS' : '❌ FAIL').padRight(
        statusWidth - 1,
      );

      print('║$fileName│$type│$passed│$failed│$time│$status║');
    }

    // Bottom border
    print(
      '╚${'═' * fileNameWidth}╧${'═' * typeWidth}╧${'═' * passedWidth}╧${'═' * failedWidth}╧${'═' * timeWidth}╧${'═' * statusWidth}╝',
    );

    // Summary
    print(
      '\nSummary: ${summary.totalPassed} tests passed, ${summary.totalFailed} failed',
    );
    print('Total execution time: ${summary.totalTime.toStringAsFixed(2)}s');
    print(
      'Overall result: ${summary.allPassed ? '✅ ALL TESTS PASSED' : '❌ SOME TESTS FAILED'}',
    );

    // Error details for failed tests
    final failedTests = summary.results.where((r) => !r.success).toList();
    if (failedTests.isNotEmpty) {
      print('\n📋 Failed Test Details:');
      for (final test in failedTests) {
        print('  • ${test.fileName}: ${test.errorMessage ?? 'Unknown error'}');
      }
    }
  }

  void _printCsv(TestSummary summary) {
    print('FileName,Type,Passed,Failed,ExecutionTime,Status,ErrorMessage');
    for (final result in summary.results) {
      final status = result.success ? 'PASS' : 'FAIL';
      final errorMsg = result.errorMessage?.replaceAll(',', ';') ?? '';
      print(
        '${result.fileName},${result.testType},${result.passed},${result.failed},${result.executionTime},$status,"$errorMsg"',
      );
    }
  }
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('verbose', abbr: 'v', help: 'Show detailed output')
    ..addFlag('dart-only', help: 'Run only Dart tests')
    ..addFlag('flutter-only', help: 'Run only Flutter tests')
    ..addOption(
      'format',
      abbr: 'f',
      defaultsTo: 'table',
      allowed: ['table', 'json', 'csv'],
      help: 'Output format',
    )
    ..addFlag('help', abbr: 'h', help: 'Show help');

  try {
    final results = parser.parse(arguments);

    if (results['help']) {
      print(
        'Test Runner - Aggregate and display test results in a table format\n',
      );
      print('Usage: dart test/test_runner.dart [options]\n');
      print(parser.usage);
      print('\nExamples:');
      print(
        '  dart test/test_runner.dart                    # Run all tests with table output',
      );
      print(
        '  dart test/test_runner.dart --dart-only        # Run only Dart tests',
      );
      print('  dart test/test_runner.dart --format json      # Output as JSON');
      print(
        '  dart test/test_runner.dart --verbose          # Show detailed output',
      );
      return;
    }

    final runner = TestRunner(
      verbose: results['verbose'],
      dartOnly: results['dart-only'],
      flutterOnly: results['flutter-only'],
      format: results['format'],
    );

    if (runner.format == 'table') {
      print('🚀 Running all tests...\n');
    }

    final summary = await runner.runAllTests();

    if (runner.format == 'table') {
      print('📊 Test Results:\n');
    }

    runner.printResults(summary);

    // Exit with appropriate code
    exit(summary.allPassed ? 0 : 1);
  } catch (e) {
    print('Error: $e');
    print('\nUse --help for usage information');
    exit(1);
  }
}
