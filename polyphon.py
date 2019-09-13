import mido
import numpy as np
import sounddevice as sd

f = mido.MidiFile('Soviet_Anthem_2.mid')

rate = 6100

tracks = []
for t, tn in zip(f.tracks[0:2], ['A', 'B']):
	print('Track{}::'.format(tn))
	curnote = None
	for msg in t:
		if msg.is_meta:
			if msg.type == 'set_tempo':
				tempo = msg.tempo
			continue
		if msg.time != 0:
			if curnote is not None:
				period = rate / (440 * 2**((msg.note - 69) / 12))
				if tn == 'B': period /= 2
				p = int(round(period * 64))
			else:
				p = 65535
			len = msg.time * tempo / (f.ticks_per_beat * 1e6)
			q = round(len * rate)
			print('.Word {:o}'.format(q))
			print('.Word {:o}'.format(p))
		if msg.type == 'note_on':
			curnote = msg.note
		elif msg.type == 'note_off':
			curnote = None
	print('End{}::'.format(tn))
