# Art.Markdown

> Initialized by Art.Build.Configurator

## Install

```coffeescript
npm install art-markdown
```

## Art-Flavored Markdown

### Changes from Markdown

* Major additions are "-" and "--" suffixis for right and center alignment respectively.
* Major deprications: "-" cannot be used to start an unordered list; use astricks
* Simplification: Only two levels of bullets, two levels of headers.

### Spec

Basically, we have 4 kinds of indentions:

```
^   - plain
*   - bullet
1.  - list
>   - quote
```

All intentions have two levels indicated by repeating their symbol one or two times:

```
^^
>>
**
1..
```

^ and > indentions have two alignment options each:

```
^-    centered
^--   right
>-    centered
>--   right
```

NOTE: bullets and lists do not have alignment options

There is also the bare, paragraph-text alignment options:

```
-     centered
--    right
```

We have two levels of headings and their alignment options:

```
#     H1
#-      center
#--     right
##    H2
##-     center
##--    right
```

Code-blocks can start with:

```
Start with lines starting with ```:
  ```       normal
  ^```      just indented 1
  ^^```     just indented 2

End with a line containing only:
  ```
```

Block termination

Markdown blocks are terminated by a new block starting OR
two or more new-lines.
```

## FUTURE

Should code-blocks support bullets?

```
*```    intented with bullet
1.```   indented with list
```

NOTE: code-blocks cannot be in a quote.
