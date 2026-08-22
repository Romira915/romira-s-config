#!/usr/bin/env python3
"""TOML設定ファイルからローカル状態を除いたクリーン版をstdoutへ出力する。

使い方: filter_toml.py <path-to-toml> または filter_toml.py -（標準入力）

tomlkit 等の依存を増やさず、コメント・書式をそのまま保つため、
フルパースではなく行/テーブルヘッダ単位のテキストフィルタで実装している。
新しいノイズキー・テーブルが増えたら EXCLUDE_* に追記する。
"""
import re
import sys

# テーブル全体を除外するヘッダ行の正規表現（[header] / [[header]] にマッチ）
EXCLUDE_TABLE_PATTERNS = [
    r'^\[tui\.model_availability_nux\]$',
    r'^\[marketplaces\.openai-bundled\]$',
    r'^\[marketplaces\.openai-primary-runtime\]$',
    r'^\[mcp_servers\.node_repl(\..+)?\]$',
    r'^\[mcp_servers\.computer-use\]$',
    r'^\[shell_environment_policy\.set\]$',
    r'^\[hooks\.state(\..+)?\]$',
    r'^\[desktop\]$',
    r'^\[projects\..+\]$',
]

# 残すテーブル内でも行単位で除外するキー
EXCLUDE_LINE_PATTERNS = [
    r'^last_updated\s*=',
    r'^last_revision\s*=',
]

# どのテーブルにも属さないルートレベルで除外するキー
# モデル選択や推論強度は環境ごとの運用で頻繁に変わるため、共有設定に残すと
# 本来同期したい設定との差分を埋もれさせる。このルールを追加し、毎回の手動選別に頼らない。
EXCLUDE_ROOT_KEY_PATTERNS = [
    r'^notify\s*=',
    r'^model\s*=',
    r'^model_reasoning_effort\s*=',
    r'^plan_mode_reasoning_effort\s*=',
    r'^service_tier\s*=',
]

HEADER_RE = re.compile(r'^\[+[^\]]+\]+\s*$')


def is_excluded_header(header_line):
    return any(re.match(p, header_line) for p in EXCLUDE_TABLE_PATTERNS)


def filter_toml(lines):
    out = []
    in_root = True
    skipping_table = False

    for line in lines:
        stripped = line.strip()

        if HEADER_RE.match(stripped):
            in_root = False
            skipping_table = is_excluded_header(stripped)
            if skipping_table:
                continue
            out.append(line)
            continue

        if skipping_table:
            continue

        if in_root and any(re.match(p, stripped) for p in EXCLUDE_ROOT_KEY_PATTERNS):
            continue

        if any(re.match(p, stripped) for p in EXCLUDE_LINE_PATTERNS):
            continue

        out.append(line)

    # 除外ブロックの跡地にできる連続空行を1行に圧縮する
    cleaned = []
    prev_blank = False
    for line in out:
        blank = line.strip() == ''
        if blank and prev_blank:
            continue
        cleaned.append(line)
        prev_blank = blank

    # 除外したテーブルが末尾にあった場合に残る末尾の空行を落とす
    while cleaned and cleaned[-1].strip() == '':
        cleaned.pop()

    return cleaned


def main():
    if len(sys.argv) != 2:
        print('usage: filter_toml.py <path-to-toml> | -', file=sys.stderr)
        sys.exit(1)

    if sys.argv[1] == '-':
        lines = sys.stdin.read().splitlines()
    else:
        with open(sys.argv[1], encoding='utf-8') as f:
            lines = f.read().splitlines()

    cleaned = filter_toml(lines)
    sys.stdout.write('\n'.join(cleaned) + '\n')


if __name__ == '__main__':
    main()
