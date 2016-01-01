#!/usr/bin/env bash

pandoc -f html-native_divs --epub-cover-image="cover.png" --epub-stylesheet="sigdigs.css" --epub-embed-font="fonts/*" --toc -S --epub-metadata=metadata.xml --epub-chapter-level=3 -o "sigdigs.epub" chapters/*.html