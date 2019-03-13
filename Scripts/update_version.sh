#!/bin/bash

VERSION="$1"
SEARCHTERM="VersionCommand.version"
TARGET=Sources/Playground-Butler/main.swift
SEMVER_REGEX="$SEARCHTERM\\ =\ \"[0-9]*\.[0-9]*\.[0-9]*\""
sed "s/$SEMVER_REGEX/$SEARCHTERM\ = \"$VERSION\"/" $TARGET > tmpMain
mv -f tmpMain $TARGET