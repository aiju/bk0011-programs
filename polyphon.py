import mido
import numpy as np
import sounddevice as sd

f = mido.MidiFile('/home/aiju/Downloads/Fugue1.mid')

rate = 6100
tempo = 500000

tracks = []
for t, tn in zip(f.tracks[1:3], ['A', 'B']):
	print('Track{}::'.format(tn))
	notes = set()
	for msg in t[0:1000]:
		if msg.is_meta:
			if msg.type == 'set_tempo':
				tempo = msg.tempo
			continue
		if msg.time != 0:
			if notes:
				period = rate / (440 * 2**((max(notes) - 69) / 12))
				if tn == 'B': period /= 2
				p = int(round(period * 64))
			else:
				p = 65535
			len = msg.time * tempo / (f.ticks_per_beat * 1e6)
			q = round(len * rate)
			print('.Word {:o}'.format(q))
			print('.Word {:o}'.format(p))
		if msg.type == 'note_on':
			if msg.velocity != 0:
				notes.add(msg.note)
			elif msg.note in notes:
				notes.remove(msg.note)
		elif msg.type == 'note_off':
			if msg.note in notes:
				notes.remove(msg.note)
	print('End{}::'.format(tn))
