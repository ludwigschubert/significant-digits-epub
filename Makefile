SHELL = /bin/bash

.PHONY: download
download: downloader.rb
	ruby downloader.rb

sigdigs.epub: converter.sh sigdigs.css metadata.xml cover.png chapters/*
	./converter.sh

.PHONY: clean
clean:
	rm -r sigdigs.epub