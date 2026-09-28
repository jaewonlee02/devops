#!/bin/bash
cd "$(dirname "$0")" || exit 1
export MODEL ="qwen3:0.6b"
export PORT=8000
exec ./start.sh
