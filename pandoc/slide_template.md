---
title: "Title"
subtitle: "SubTitle"
author: "Author"
date: "\\today"
subject: "Markdown"
fontsize: 10.5pt
figureTitle: "図"
tableTitle: "表"
listingTitle: "コード"
figPrefix: "図"
tblPrefix: "表"
eqnPrefix: "式"
lstPrefix: "コード"
header-includes:
  - \usepackage{longtable}
  - \usepackage{booktabs}
  - \usepackage{luatexja-fontspec}
---

# 図

[@fig:icon]で図の参照

![github](https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png){#fig:icon height=60mm}

# 表

[@tbl:example]で表の参照

| コマンド | オプション |    効果    |
| :------: | :--------: | :--------: |
|    ls    |     la     | いろいろな |
|  mkdir   |     p      |    表が    |
|    cd    |    none    |   作れる   |
:example {#tbl:example}

# コード

[@lst:rust]でコードの参照

```{.Rust #lst:rust .numberLines}
fn main() {
    println!("test");
}
```

# 式

[@eq:euler]で式の参照．

$$ e^{i\theta} = \cos\theta + i\sin\theta $${#eq:euler}

# 注釈

注釈をつける[^r]

[^r]: 注釈内容

# メインタイトル

## サブタイトル

- 中身
  - インデント