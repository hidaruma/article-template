#!/usr/bin/env bash

# Jenkinsから呼び出されて、articlesの中にあるフォルダへ移動して`make`を実行します。
# `make`に成功した場合、PDFはpushされた日時とコミットIDに基づいて表示用のフォルダへコピーされます。

set -ex

# Checkout the branch
git checkout "$branch"
git submodule update --init --recursive

# Determine the article's directory
cd articles
for i in *; do
  if [ "$i" != "hinagata" ] && [ "$i" != "back_cover" ] && [ "$article_dir" = "" ]; then
    article_dir="$i"
  elif [ "$i" != "hinagata" ] && [ "$i" != "back_cover" ]; then
    echo "There are some aritcle's directories. Aborting."
    exit 1
  fi
done

if [ -z "$article_dir" ]; then
  echo "Article's directory not found. Aborting."
  exit 1
fi

# cd and make
cd "$article_dir"
WORD_FONT=hiragino-pron make

# Copy the artifact
if [ -e main.pdf ]; then
  mkdir -p "$WORKSPACE/artifacts/$repository/$branch"
  cp main.pdf "$WORKSPACE/artifacts/$repository/$branch/${push_date}_${revision:0:7}.pdf"
fi
