info: menu select

menu:
	echo "1 make reset           - flutter clean && flutter pub get"
	echo "2 make format          - dart format ."
	echo "3 make test            - flutter test (all tests)"
	echo "4 make test_units      - run unit tests (dart tests)"
	echo "5 make test_table      - run all tests with table results"
	echo "6 make test_json       - run tests with JSON output"
	echo "7 make analyze         - flutter analyze"
	echo "8 make build           - flutter build web"
	echo "9 make run             - flutter run --debug"
	echo "10 make generate       - generate annotations.g.dart & builder.g.dart"
	echo "11 make update_phony   - update .PHONY in Makefile"

select:
	read -p ">>> " P ; make menu | grep "^$$P " | cut -d ' ' -f2-3 ; make menu | grep "^$$P " | cut -d ' ' -f2-3 | bash

.SILENT:

.PHONY: info menu select reset format test test_units test_table test_json analyze build run generate update_phony 

reset:
	flutter clean && flutter pub get

format:
	dart format lib/ test/ builder/

test:
	flutter test

test_units:
	dart test/json_serializable_test.dart
	dart test/usage_test.dart
	dart test/initializer_test.dart
	dart test/equality_test.dart

test_table:
	dart test/test_runner.dart

test_json:
	dart test/test_runner.dart --format json

analyze:
	flutter analyze

build:
	echo "##### Clean build #####"
	flutter clean
	rm -fvr build
	echo "##### Build for web #####"
	flutter build web

run:
	flutter run --debug -d chrome

builder/builder.exe:
	cd builder && dart compile exe builder.dart

generate: builder/builder.exe
	builder/builder.exe lib
	dart format lib/ test/ builder/

update_phony:
	@echo "##### Updating .PHONY targets #####"
	@targets=$$(grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*:' Makefile | grep -v '=' | cut -d: -f1 | tr '\n' ' '); \
	sed -i.bak "s/^\.PHONY:.*/.PHONY: $$targets/" Makefile && \
	echo "Updated .PHONY: $$targets" && \
	rm -f Makefile.bak
