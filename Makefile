SHELL = /bin/bash

.PHONY: download
download: downloader.rb
	rm -f chapters/* ;\
	ruby downloader.rb

sigdigs.epub: converter.sh sigdigs.css metadata.xml cover.png chapters/*
	./converter.sh

.PHONY: proof
proof: sigdigs.epub
	rm -rf proof.epub ;\
	mkdir -p proof.epub ;\
	mv sigdigs.epub proof.epub/sigdigs.epub ;\
	cd proof.epub ;\
	unzip sigdigs.epub ;\


.PHONY: clean
clean:
	rm -r sigdigs.epub