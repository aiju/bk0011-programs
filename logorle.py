import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

im = Image.open('logosmall.png')
pixels = ~np.asarray(im.convert('1'))
a = pixels.reshape((-1,8)).astype(np.int)
a *= [1,2,4,8,16,32,64,128]
a = np.sum(a,1)
for i in a:
	print('.Byte {:o}'.format(i))
