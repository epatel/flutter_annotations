info: menu select

menu:
	echo "1 make reset           - flutter clean && flutter pub get"
	echo "2 make format          - dart format ."
	echo "3 make test            - flutter test (all tests)"
	echo "4 make test_units      - run unit tests (dart tests)"
	echo "5 make analyze         - flutter analyze"
	echo "6 make build           - flutter build web"
	echo "7 make run             - flutter run --debug"
	echo "8 make generate        - generate annotations.g.dart & builder.g.dart"
	echo "9 make update_phony    - update .PHONY in Makefile"

select:
	read -p ">>> " P ; make menu | grep "^$$P " | cut -d ' ' -f2-3 ; make menu | grep "^$$P " | cut -d ' ' -f2-3 | bash

.SILENT:

.PHONY: info menu select reset format test test_units analyze build run generate update_phony 

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

generate:
	dart builder/builder.dart lib
	dart format lib/ test/ builder/

update_phony:
	@echo "##### Updating .PHONY targets #####"
	@targets=$$(grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*:' Makefile | grep -v '=' | cut -d: -f1 | tr '\n' ' '); \
	sed -i.bak "s/^\.PHONY:.*/.PHONY: $$targets/" Makefile && \
	echo "Updated .PHONY: $$targets" && \
	rm -f Makefile.bak
