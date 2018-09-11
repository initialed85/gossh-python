#!/bin/bash

which go 2>/dev/null 1>/dev/null
if [[ $? -ne 0 ]]; then
    echo "error: failed to find go binary- do you have Go 1.9, Go 1.10 or Go1.11 installed?"
    exit 1
fi

GOVERSION=`go version`
if [[ $GOVERSION != *"go1.9"* ]] && [[ $GOVERSION != *"go1.10"* ]] && [[ $GOVERSION != *"go1.11"* ]]; then
    echo "error: Go version is not 1.9 or 1.10 (was $GOVERSION)"
    exit 1
fi

export GOPATH=`pwd`

export PYTHONPATH=`pwd`/src/github.com/go-python/gopy/

echo "cleaning up output folder"
rm -frv gossh_python/*.pyc
rm -frv gossh_python/py2/*.pyc
rm -frv gossh_python/py2/*.so
rm -frv gossh_python/py2/*.c
rm -frv gossh_python/cffi/*.pyc
rm -frv gossh_python/cffi/*.so
rm -frv gossh_python/cffi/*.c
rm -frv gossh_python/cffi/gossh_python.py
echo ""

if [[ "$1" == "clean" ]]; then
    exit 0
fi

if [[ "$1" != "fast" ]]; then
    echo "getting assert"
    go get -v -a github.com/stretchr/testify/assert
    echo ""

    echo "getting gossh"
    go get -v -a golang.org/x/crypto/ssh
    echo ""

    echo "building gossh"
    go build -a -x golang.org/x/crypto/ssh
    echo ""

    echo "getting gopy"
    go get -v -a github.com/go-python/gopy
    echo ""

    echo "installing gopy"
    go install -v -a github.com/go-python/gopy
    echo ""

    echo "building gopy"
    go build -x -a github.com/go-python/gopy
    echo ""

    echo "building gossh_python"
    go build -x -a gossh_python
    echo ""
fi

echo "build gossh_python bindings for py2"
./gopy bind -lang="py2" -output="gossh_python/py2" -symbols=true -work=false gossh_python
echo ""

# gopy doesn't seem to support Python3 as yet
# echo "build gossh_python bindings for py3"
# ./gopy bind -lang="py3" -output="gossh_python/py3" -symbols=true -work=false gossh_python
# echo ""

echo "build gossh_python bindings for cffi"
./gopy bind -lang="cffi" -output="gossh_python/cffi" -symbols=true -work=false gossh_python
echo ""

echo "cleaning up"
find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf
echo ""
