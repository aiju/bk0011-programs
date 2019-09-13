#!/usr/bin/python3
import numpy as np
import scipy.io.wavfile
import sys

unit = 9

def encode(data):
	bits = np.where(data[:,np.newaxis] & np.array([1,2,4,8,16,32,64,128]) != 0, 1, 0).reshape(-1)
	forms = np.array([[0,1,0,1,-1,-1],[0,0,1,1,0,1]])
	wave = forms[bits, :].reshape(-1)
	return wave[wave >= 0]

data = np.fromfile(sys.argv[1], dtype='uint8')
header = np.zeros(20, np.uint8)
header[0:4] = data[0:4]
data = data[4:]
name = [ord(c) for c in 'GLORY TO USSR']
header[4:4+len(name)] = name
header[4+len(name):] = ord(' ')

checksum = int(np.sum(data))
while checksum > 0xffff:
	checksum = (checksum >> 16) + (checksum & 0xffff)
print('{:o}'.format(checksum))
checksum = np.array([checksum & 0xff, checksum >> 8])

startseq = np.tile([0,1], 0o10000)
startmark = np.tile([0,1], 0o10)
eheader = encode(header)
edata = encode(data)
echecksum = encode(checksum)
endseq = np.tile([0,1], 0o400)
sync = np.array([0,0,0,1,1,1,0,0,1,1,0,1])

wave = np.concatenate((startseq, sync, startmark, sync, eheader, startmark, sync, edata, echecksum, endseq, sync)).repeat(unit)

#sd.play(wave.astype(np.float64), 44100, blocking=True)
scipy.io.wavfile.write(sys.argv[2], 44100, wave.astype(np.int16) * 30000)
