all: mono.wav monty.wav

b/%.obj: %.asm
	macro11/macro11 -l /dev/stdout -o $@ $<

b/%.bin: b/%.obj | link
	./link -o $@ $<

b/monty.obj: polygfx.asm b/liberty.asm b/foot.asm

b/mono.obj: b/monosoviet.asm b/logo.asm

b/liberty.asm: midiread.py midi/liberty.mid
	./midiread.py --staccato midi/liberty_short.mid > $@

b/monosoviet.asm: monophon.py midi/Soviet_Anthem.mid
	./monophon.py midi/Soviet_Anthem.mid > $@

b/logo.asm: logorle.py logosmall.png
	./logorle.py logosmall.png > $@

b/foot.asm: logorle.py foot.png
	./logorle.py foot.png > $@

%.wav: b/%.bin
	./tapeplay.py $< $@
	
link: link.c
	$(CC) -o $@ $<
