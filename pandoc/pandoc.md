---
title: "Title"
subtitle: "SubTitle"
author: "Author"
date: "Date"
subject: "Markdown"
fontsize: 10.5pt
listingTitle: "コード"
figPrefix: "図"
tblPrefix: "表"
eqnPrefix: "式"
lstPrefix: "コード"
header-includes:
  - \usepackage{longtable}
  - \usepackage{booktabs}
---

\renewcommand{\figurename}{図}
\renewcommand{\tablename}{表}

# 図

　[@fig:icon]で図の参照．

![GitHub Icon](https://avatars2.githubusercontent.com/u/40430090?s=460&u=8c140320a0b0b1848656742192cdc9860e2bfcd6&v=4){#fig:icon height=60mm}

# 表

　[@tbl:example]で表の参照．

| コマンド | オプション | 効果       |
| :------: | :--------: | :--------: |
| ls       | la         | いろいろな |
| mkdir    | p          | 表が       |
| cd       | none       | 作れる     |
:表example {#tbl:example}

# コード

　[@lst:rust]でコードの参照．

```{.Rust #lst:rust .numberLines caption="Rust"}
fn main() {
    println!("Hello, world!");
}
```

# 式

　[@eq:euler]で式の参照．

$$ e^{i\theta} = \cos\theta + i\sin\theta $${#eq:euler}

# 注釈

　注釈をつける[^r]

[^r]: 注釈内容

# 参考文献 {-}
`{-}` をつけるとこのセクションには見出しに通し番号がつかなくなる

- 箇条書き
- 箇条書き
    - ネスト
    - ネスト
    - ネスト