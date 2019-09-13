all: mono.wav polyb.wav

%.obj: %.asm
	macro11/macro11 -l /dev/stdout -o $@ $<

%.bin: %.obj | link
	./link -o $@ $<

mono.obj: monodata.asm
polyb.obj: polydata.asm
polyd.obj: polydata.asm

monodata.asm: monophon.py
	python3 monophon.py > $@

polydata.asm: polyphon.py
	python3 polyphon.py > $@

logo.asm: logorle.py logo.png
	python3 logorle.py > $@


%.wav: %.bin
	./tapeplay.py $< $@
	
link: link.c
	$(CC) -o $@ $<
