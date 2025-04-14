.PHONY: test build run

build:
	mix escript.build

run:
	./work_report -m 5 -d 3 test/sample/report-1.md

test:
	mix test --exclude=integration

# with integration tests
test-all:
	mix test
