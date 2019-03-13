update_version:
	Scripts/./update_version.sh $(argument)

build:
	swift build -c release -Xswiftc -static-stdlib

install: build
	cp -f .build/release/Playground-Butler /usr/local/bin/butler