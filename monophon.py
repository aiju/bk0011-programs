#!/usr/bin/python3
import sys
import mido
import numpy as np
import sounddevice as sd

f = mido.MidiFile(sys.args[1])


tracks = []
for t in f.tracks:
	curnote = None
	for msg in t:
		
		if msg.is_meta:
			if msg.type == 'set_tempo':
				tempo = msg.tempo
			continue
		if msg.time != 0 and curnote != None:
			period = 1e6 / (440 * 2**((curnote - 69) / 12))
			p1 = int(np.floor((period - 25) / 9))
			p2 = int(np.ceil((period - 25) / 9))
			pp1 = np.abs(p1 * 9 + 25 - period)
			pp2 = np.abs(p2 * 9 + 25 - period)
			if pp1 < pp2:
				p = p1
			else:
				p = p2
			len = msg.time * tempo / f.ticks_per_beat
			q = round(len / period)
			print('.Word {:o}'.format(q))
			print('.Word {:o}'.format(p))
		if msg.type == 'note_on':
			if msg.velocity != 0:
				curnote = msg.note
			else:
				curnote = None
		elif msg.type == 'note_off':
			curnote = None
	break
