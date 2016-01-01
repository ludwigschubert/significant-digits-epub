SHELL = /bin/bash

filter: filter.hs
	ghc -o filter --make filter.hs

.PHONY: download
download: downloader.rb
	ruby downloader.rb

sigdigs.epub: converter.sh filter sigdigs.css metadata.xml cover.png chapters/*
	./converter.sh

.PHONY: clean
clean:
	rm -r sigdigs.epub