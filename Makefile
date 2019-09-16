all: mono.wav polyb.wav

b/%.obj: %.asm
	macro11/macro11 -l /dev/stdout -o $@ $<

b/%.bin: b/%.obj | link
	./link -o $@ $<

b/monty.obj: polygfx.asm b/liberty.asm b/foot.asm

b/liberty.asm: midiread.py midi/liberty.mid
	./midiread.py --staccato midi/liberty_short.mid > $@

b/foot.asm: logorle.py foot.png
	./logorle.py foot.png > $@

%.wav: b/%.bin
	./tapeplay.py $< $@
	
link: link.c
	$(CC) -o $@ $<
