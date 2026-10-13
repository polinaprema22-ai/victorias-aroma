#!/bin/zsh
# Выложить сайт Виктории на GitHub Pages (victorias-aroma.ru). Запуск: ~/victorias-aroma-site/publish.sh
set -e
cd "$(dirname "$0")"
T=$(grep '^GITHUB_TOKEN_POLINA=' ~/.claude/secrets/tokens.env | cut -d= -f2)
git add -A
git -c commit.gpgsign=false commit -q -m "Обновление сайта $(date '+%d.%m.%Y %H:%M')" || { echo "Изменений нет"; exit 0; }
git -c http.version=HTTP/1.1 push -q "https://x-access-token:$T@github.com/polinaprema22-ai/victorias-aroma.git" main
echo "Опубликовано (обновится через 1–2 минуты)"
