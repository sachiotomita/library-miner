#!/bin/bash

# ヘルプメッセージ
usage() {
  echo "Usage: $PROGNAME -e arg -c 100"
  echo
  echo "オプション:"
  echo "  -h, --help"
  echo "  -e <ARG>     <必須> (development/production)"
  echo "  -from <DATE> ex. 20150101"
  echo "  -to <DATE> ex. 20150101"
  echo "  -days <ARG> ex. 3"
  echo
  exit 1
}

PROGNAME=$(basename $0)
HELP_MSG="'$PROGNAME -h'と指定することでヘルプを見ることができます"

# オプション解析
for OPT in "$@"
do
  case "$OPT" in
    # ヘルプメッセージ
    '-h'|'--help' )
    usage
    exit 1
    ;;

    # 環境指定
    '-e' )
    FLG_ENV=1
    # オプションに引数がなかった場合（必須）
    if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
      echo "$PROGNAME:「$1」オプションには引数(development または production)が必要です" 1>&2
      exit 1
    fi
    ARG_ENV="$2"
    if [[ "$ARG_ENV" != "development" ]] && [[ "$ARG_ENV" != "production" ]]; then
      echo "$PROGNAME:「$1」オプションにはdevelopment または productionが使用できます" 1>&2
      exit 1
    fi
    shift 2
    ;;

    '-from' )
    FROM="$2"
    shift 2
    ;;

    '-to' )
    TO="$2"
    shift 2
    ;;

  esac
done

# -e パラメータがない場合
if [ -z $FLG_ENV ]; then
  echo "$PROGNAME:「-e」オプションは必須です。正しいオプションを指定してください" 1>&2
  echo $HELP_MSG 1>&2
  exit 1
fi

current=$(date -j -f %Y%m%d "$FROM" +%Y%m%d)
end=$(date -j -v+1d -f %Y%m%d "$TO" +%Y%m%d)

while [ "$end" != "$current" ]
do
  echo $current
  current=$( date -j -v+1d -f %Y%m%d $current +%Y%m%d)
done

# 起動処理
#bundle exec rails runner "GithubProjectDetailCrawler.perform_later(\"$FLG_COUNT\")" -e $ARG_ENV
