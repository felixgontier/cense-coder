import sys
import numpy as np
from librosa import core
import matplotlib.pyplot as plt
import soundfile as sf

# Constants: process parameters
sr = 32000
l_frame = 4096
l_hop = l_frame
q = 8

# Load code
d_filename = sys.argv[1]
c_file = open("".join((d_filename,"_enc.txt")), 'r')

# Load approximate third-octave band to spectrogram weights
iH = np.genfromtxt("tob_4096_i.txt", delimiter=',')

# Load Huffman dictionary
d_sym = []
d_code = []
with open("dict.txt") as d_file:
	for line in d_file: # = For each symbol
		line = line.strip()
		d_temp = line.split(',')
		# First expression is the symbol
		d_sym.append(int(d_temp[0]))
		# The rest is the code in binary
		d_code.append("".join(d_temp[1:]))

# Declarations/Initialisations
w = np.ones(l_frame)
l_tf = 4
ind_f = 0
q_norm = np.zeros(2)
ind_tf = 0
fft_norm = np.sum(np.square(w))/l_frame
X_st = np.empty((int(l_frame/2+1),0))

for line in c_file: # Texture frames
	# Read file
	line = line.strip()
	c_temp = line.split(',')
	q_norm[0] = float(c_temp[0])
	q_norm[1] = float(c_temp[1])
	X_huff_l = int(c_temp[2])
	X_huff = c_temp[3]
	# Huffman
	X_delta = []

	while X_huff:
		found = 0
		for ind_sym_dict in range(0,len(d_sym)):
			if X_huff.startswith(d_code[ind_sym_dict]):
				X_delta = np.append(X_delta,d_sym[ind_sym_dict])
				X_huff = X_huff[len(d_code[ind_sym_dict]):]
				found=1
		if (found == 0):
		#didn't found the symbol check if this is the end
			if (len(X_huff) <=  7):
				#ignore the last symbols in this case
				X_huff = [] 
					
	X_delta = [int(i) for i in X_delta]
	X_delta = np.reshape(X_delta,(-1,iH.shape[1])).transpose()
	print(X_delta)
	# Delta
	X_tob = np.zeros(X_delta.shape)
	X_tob[:,0] = X_delta[:,0]
	for ind_f_tf in range(1,X_delta.shape[1]):
		X_tob[:,ind_f_tf] = X_delta[:,ind_f_tf]+X_tob[:,ind_f_tf-1]
	# Normalisation + Quantization
	X_tob = q_norm[1]*X_tob/(np.power(2,q-1)-1)+q_norm[0]
	
	print(X_tob)

	# Third-octave bands to spectrogram
	X_tob = np.power(10,X_tob/10) # Linear amplitude
	X = np.dot(iH,X_tob)
	# Magnitude spectrogram to STFT
	X = np.sqrt(X*fft_norm)
	if X_st.ndim == 1:
		X_st = X
	else:
		X_st = np.concatenate((X_st, X), axis=1)
	
c_file.close()


# Phase recovery and signal synthesis with G&L - Needs 50% overlap minimum
n_iter = 20
n_frames = X_st.shape[1]
x_temp = np.random.randn(l_frame+(n_frames-1)*l_hop)
print(x_temp.shape)
for gl_iter in range(0,n_iter):
	x_stft = core.stft(x_temp, n_fft=l_frame, hop_length=l_hop+1, win_length=None, window='boxcar', center=True, dtype=None, pad_mode='reflect')
	b = X_st*x_stft/(np.absolute(x_stft)+1e-15)
	x_temp = core.istft(b, hop_length=l_hop+1, win_length=l_frame, window='boxcar', center=True, dtype=None, length=None)
		

x = x_temp/np.absolute(x_temp).max()

# Save resulting audio
np.savetxt("".join((d_filename,"_dec.txt")), x, fmt='%.18e', delimiter=',', newline='\n', header='', footer='', comments='# ')


sf.write('sinus_440_emb_dec.ogg', x, sr)


t = np.linspace(0,x_temp.shape[0]/sr, num=x_temp.shape[0])
plt.plot(t, x_temp)
plt.show()

