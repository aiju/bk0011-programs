#!/usr/bin/python3
import mido
import itertools

class DeltaList:
	def __init__(self):
		self.l = []
	def add(self, time, it):
		t = 0
		for i, (dt, m) in enumerate(self.l):
			if t+dt > time:
				self.l[i] = (t + dt - time, m)
				self.l.insert(i, ((time - t), it))
				return
			t += dt
		self.l.append((time - t, it))
	def pop(self):
		return self.l.pop(0)
	def __str__(self):
		return self.l.__str__()
	def __len__(self):
		return self.l.__len__()
	
def staccato(f, g=2):
	for t in f.tracks:
		notes = {}
		tim = 0
		for m in t:
			tim += m.time
			m.time = tim
			if m.type == 'note_on' and m.velocity != 0:
				notes[m.note] = tim
			elif m.type == 'note_on' or m.type == 'note_off':
				if m.note in notes:
					if tim - notes[m.note] > g:
						m.time -= g
					del notes[m.note]
		t.sort(key=lambda x: m.time)
		tim = 0
		for m in t:
			m.time, tim = m.time - tim, m.time
	return f

def readmidi(f):
	tracks = [t[:] for t in f.tracks]
	nt = len(f.tracks)
	trackidx = [0] * nt
	tempo = 500000
	head = DeltaList()
	for i, t in enumerate(tracks):
		if len(t) != 0:
			head.add(t[0].time, (i, t[0]))
			trackidx[i] = 1
	notes = set()
	res = []
	abstime = 0
	ltime = 0
	while len(head) != 0:
		t, (i, m) = head.pop()
		if trackidx[i] < len(tracks[i]):
			head.add(tracks[i][trackidx[i]].time, (i, tracks[i][trackidx[i]]))
			trackidx[i] += 1
		if t != 0:
			res.append((abstime - ltime, notes.copy()))
			ltime = abstime
			abstime += t * tempo * 1e-6 / f.ticks_per_beat
		if m.type == 'set_tempo':
			tempo = m.tempo
		elif m.type == 'note_on':
			if m.velocity != 0:
				notes.add((i, m.note))
			elif (i, m.note) in notes:
				notes.remove((i, m.note))
		elif m.type == 'note_off':
			if (i, m.note) in notes:
				notes.remove((i, m.note))
	res.append((abstime - ltime, notes.copy()))
	return(res)

def cutoff(l, tim):
	t = 0
	for i, (dt, _) in enumerate(l):
		t += dt
		if t >= tim:
			return l[:i] + [(t - tim, set())]
	return l

def selectnotes(l, nchan=3):
	r = []
	for tim, n in l:
		ch = {}
		for t, v in n:
			if t not in ch:
				ch[t] = []
			ch[t].append(v)
		for t in ch:
			ch[t].sort(reverse=True)
		m = [None] * nchan
		while len(ch) != 0 and None in m:
			picked = set()
			for t in sorted(ch.keys()):
				if m[t%nchan] is None:
					m[t%nchan] = ch[t].pop(0)
					picked.add(t)
					if len(ch[t]) == 0:
						del ch[t]
			if None in m:
				for t in sorted(ch.keys()):
					if t in picked:
						continue
					m[m.index(None)] = ch[t].pop(0)
					picked.add(t)
					if len(ch[t]) == 0:
						del ch[t]
					if None not in m:
						break
		r.append((tim, m))
	return r

def splitchans(l):
	nchan = len(l[0][1])
	chans = [[(tim, m[i]) for tim, m in l] for i in range(nchan)]
	res = []
	for c in chans:
		r = [c[0]]
		to = 0
		for t, n in c[1:]:
			to += t
			if n != r[-1][1]:
				r.append((to, n))
		res.append(r)
	return res

def noteval(note, rate):
	if note is None:
		return 65535
	else:
		return round(64 * rate / (440 * 2**((note - 69) / 12.0)))

def convert(l, rate=6000):
	res = []
	for ch in l:
		r = [(round(tim * rate), noteval(note, rate)) for tim, note in ch]
		r = [(ntim - tim, note) for ((tim, note), (ntim, _)) in zip(r, r[1:]) if tim != ntim]
		res.append(r)
	tots = [sum([tim for tim, note in ch]) for ch in res]
	tot = max(tots)
	for i in range(len(l)):
		if tots[i] < tot:
			res[i].append([tot - tots[i], 65535])
	return res

def simulate(l, rate=6000):
	import numpy as np
	import sounddevice as sd
	chans = []
	for chan in l:
		slices = []
		for tim, note in chan:
			ind = np.arange(note, tim * 64, note)
			slice = np.zeros(int(tim))
			slice[ind // 64] = 1
			slices.append(slice)
		chans.append(np.concatenate(tuple(slices)))
	samp = np.where(np.sum(np.array(chans), 0) > 0, 1, 0)
	sd.play(samp.astype(np.float), rate, blocking=True)

def output(l):
	for ch, n in zip(l, ['A', 'B', 'C']):
		print('Track{}::'.format(n))
		for tim, note in ch:
			if note > 65535:
				raise(ValueError)
			while tim > 65535:
				print('.Word {:o}'.format(65535))
				print('.Word {:o}'.format(note))
				tim -= 65535
			print('.Word {:o}'.format(tim))
			print('.Word {:o}'.format(note))
		print('End{}::'.format(n))

f = mido.MidiFile('/home/aiju/Downloads/liberty_fixed.mid')
f = staccato(f)
n = readmidi(f)
#n = cutoff(n, 60)
n = selectnotes(n)
n = splitchans(n)
n = convert(n)
#simulate(n)
output(n)
