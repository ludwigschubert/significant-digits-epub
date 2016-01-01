SHELL = /bin/bash

.PHONY: download
download: downloader.rb
	ruby downloader.rb

sigdigs.epub: converter.sh sigdigs.css metadata.xml cover.png chapters/*
	./converter.sh

.PHONY: proof
proof: sigdigs.epub
	rm -rf test ;\
	mkdir -p test ;\
	mv sigdigs.epub test/sigdigs.epub ;\
	cd test ;\
	unzip sigdigs.epub ;\


.PHONY: clean
clean:
	rm -r sigdigs.epub