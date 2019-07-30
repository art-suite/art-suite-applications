# Art.Markdown

> Goal: simplify Markdown and add alignment options.

Markdown is great, but it also has a few shortcomings. It's design could be better. You know you are done not when there is nothing more to add, but when there is nothing left to remove.

The use-case I'm targeting is from short-form text up to blog-post or article length. Basically, 0 to 10,000 characters or so.

## Markdown Shortcomings

* Too many header levels: Why is this a problem? Editors, viewers and markdown style-sheets can't seem to agree how much emphasis to put on each header level when there are when the 6(!) levels. The result is sometimes the difference between two levels of headers, for example `##` and `###` is insufficient because the style writer needed to squeeze in differences all the way down to `######`. That means markdown-authors sometimes need to skip header levels for adequate contrast between sections and sub-sections. Therefor, ArtMarkdown only supports 2 levels. If a document truely needs more levels, it should be split into multiple documents.

* No way to center or right-align text, and no way to properly cite a quote or an image. Both of the latter are solved with ArtMarkdown's center and right-align options.

* Not mobile-edit-friendly: Because markdown relies on whitespace for layout (actually I love this for desktop, but...) it's not very friendly for the narrow-width screens on mobile phones. It's also not workable for any editor which doesn't have mono-spaced font support. Therefor ArtMarkdown supports an alternative way of specifying levels of indention: repetition; just like markdown-headers.

* Indention rules for code-blocks are confusing.

* <tag> support is trecherous - it is certainly nice to have the option, but most the time it's not a good idea. Mostly people use it to hack-solve the same problem everyone else is solving - like lack of center or right-align. The bigger problem is it means you can't reliably render markdown in no-browser environments.

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

## Coming

Additional support planned:

* github-style syntax-highlighting; however, unlike github, we'll support any textmate syntax highligher you provide
* links - standard markdown links
* images - with enhanced 'contextual' support
* span-formatting - standard markdown basic-formatting - currently bold, italic and other in-paragraph formatting are not supported