info: menu select

menu:
	echo "1 make reset           - flutter clean && flutter pub get"
	echo "2 make format          - dart format ."
	echo "3 make test            - flutter test"
	echo "4 make analyze         - flutter analyze"
	echo "5 make build           - flutter build web"
	echo "6 make run             - flutter run --debug"
	echo "7 make update_phony    - update .PHONY in Makefile"

select:
	read -p ">>> " P ; make menu | grep "^$$P " | cut -d ' ' -f2-3 ; make menu | grep "^$$P " | cut -d ' ' -f2-3 | bash

.SILENT:

.PHONY: info menu select reset format test analyze build run deploy update_phony 

reset:
	flutter clean && flutter pub get

format:
	dart format .

test:
	flutter test

analyze:
	flutter analyze

build:
	echo "##### Clean build #####"
	flutter clean
	rm -fvr build
	echo "##### Build for web #####"
	flutter build web

run:
	flutter run --debug

update_phony:
	@echo "##### Updating .PHONY targets #####"
	@targets=$$(grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*:' Makefile | grep -v '=' | cut -d: -f1 | tr '\n' ' '); \
	sed -i.bak "s/^\.PHONY:.*/.PHONY: $$targets/" Makefile && \
	echo "Updated .PHONY: $$targets" && \
	rm -f Makefile.bak
