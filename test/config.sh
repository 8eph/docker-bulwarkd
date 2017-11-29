#!/bin/bash
set -e

testAlias+=(
	[straks-node:xenial]='straks-node'
)

imageTests+=(
	[straks-node]='
		rpcpassword
	'
)
