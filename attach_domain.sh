#!/bin/zsh
# Ждёт, пока victorias-aroma.ru начнёт указывать на GitHub Pages, затем привязывает домен и включает HTTPS.
cd "$(dirname "$0")"
T=$(grep '^GITHUB_TOKEN_POLINA=' ~/.claude/secrets/tokens.env | cut -d= -f2)
API=https://api.github.com/repos/polinaprema22-ai/victorias-aroma/pages
for i in $(seq 1 360); do
  ip=$(dig +short @8.8.8.8 victorias-aroma.ru A | head -1)
  echo "$(date '+%H:%M') dns: ${ip:-нет}"
  [[ "$ip" == 185.199.* ]] && break
  sleep 120
done
[[ "$ip" == 185.199.* ]] || { echo "Домен так и не заработал за 12 часов"; exit 1; }
echo "victorias-aroma.ru" > docs/CNAME
./publish.sh
sleep 60
curl -s --http1.1 -m 30 -X PUT -H "Authorization: Bearer $T" -H "Accept: application/vnd.github+json" $API -d '{"cname":"victorias-aroma.ru"}' -o /dev/null -w "cname set: %{http_code}\n"
for i in $(seq 1 40); do
  st=$(curl -s --http1.1 -m 30 -H "Authorization: Bearer $T" $API | python3 -c "import sys,json; print((json.load(sys.stdin).get('https_certificate') or {}).get('state'))")
  echo "cert: $st"; [ "$st" = "approved" ] && break; sleep 30
done
curl -s --http1.1 -m 30 -X PUT -H "Authorization: Bearer $T" -H "Accept: application/vnd.github+json" $API -d '{"cname":"victorias-aroma.ru","https_enforced":true}' -o /dev/null -w "https enforced: %{http_code}\n"
curl -s -o /dev/null -m 30 -w "https://victorias-aroma.ru → %{http_code}\n" -L https://victorias-aroma.ru/
curl -s -o /dev/null -m 30 -w "https://victorias-aroma.ru/test/ → %{http_code}\n" -L https://victorias-aroma.ru/test/
