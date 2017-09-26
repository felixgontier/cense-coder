import sys
import numpy as np

# Constants: process parameters
sr = 32000
l_frame = 4096
l_hop = l_frame
q = 8

# Load input data
d_filename = sys.argv[1]
x = np.genfromtxt("".join((d_filename,".txt")), delimiter=',')
x = x[0:4096] # Specific to 'sinus_440_emb.txt'
x = np.append(x, x) # Just to get more frames
x = np.append(x, x)
x = np.append(x, x)

if (x.shape[0]-l_frame)%l_hop != 0:
	x = np.append(x, np.zeros(l_hop-(x.shape[0]-l_frame)%l_hop))

# Load third-octave band analysis weights
f = []
H = []
with open("tob_4096.txt") as w_file:
	for line in w_file: # = For each band
		line = line.strip()
		f_temp = line.split(',')
		# Weight array (variable length)
		f_temp = [float(i) for i in f_temp]
		H.append(f_temp[2:])
		# Beginning and end indices
		f_temp = [int(i) for i in f_temp]
		f.append(f_temp[:2])

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
n_frames = int(np.floor((x.shape[0]-l_frame)/l_hop+1));
l_tf = 4
ind_f = 0
q_norm = np.zeros(2)
ind_tf = 0
fft_norm = np.sum(np.square(w))/l_frame
X_tob = np.zeros((len(f), l_tf))

# Open a code file
c_file = open("".join((d_filename,"_enc.txt")), 'w')

# Process
for ind_frame in range(1,n_frames+1):
	# Squared magnitude of RFFT
	X = np.fft.rfft(x[(ind_frame-1)*l_hop:(ind_frame-1)*l_hop+l_frame]*w)
	X = np.square(np.absolute(X))/fft_norm
	# Third-octave band analysis
	for ind_band in range(0,len(f)):
		X_tob[ind_band, ind_f] = np.dot(X[f[ind_band][0]-1:f[ind_band][1]], H[ind_band])
		if X_tob[ind_band, ind_f] == 0:
			X_tob[ind_band, ind_f] = 1e-15
	# dB SPL
	X_tob[:, ind_f] = 10*np.log10(X_tob[:, ind_f])

	# Texture frame complete/End of signal check
	if ind_f == l_tf-1 or ind_frame == n_frames:
		ind_tf = ind_tf+1
		# Normalisation + Quantization
		X_tob = X_tob[:, :ind_f+1]
		q_norm[0] = X_tob.min().min()
		X_tob = X_tob-q_norm[0]
		q_norm[1] = X_tob.max().max()
		X_tob = np.round((np.power(2,q-1)-1)*X_tob/q_norm[1])
		# Delta
		X_delta = np.zeros(X_tob.shape)
		X_delta[:,0] = X_tob[:,0]
		for ind_f_tf in range(1,X_delta.shape[1]):
			X_delta[:,ind_f_tf] = X_tob[:,ind_f_tf]-X_tob[:,ind_f_tf-1]
		# Huffman
		X_delta = X_delta.flatten()
		X_huff = []
		X_huff_l = 0
		for ind_sym_data in range(0,X_delta.shape[0]):
			for ind_sym_dict in range(0,len(d_sym)): # Terrible method
				if X_delta[ind_sym_data] == d_sym[ind_sym_dict]:
					X_huff = np.append(X_huff, d_code[ind_sym_dict])
					X_huff_l = X_huff_l+len(d_code[ind_sym_dict])
				
		X_huff = "".join(X_huff)
		print("Code: ",X_huff)
		print("Code length: ",X_huff_l)
		print("Normalisation values: ", q_norm)
	
		# Save as line in a file
		c_file.write(str(q_norm[0]))
		c_file.write(',')
		c_file.write(str(q_norm[1]))
		c_file.write(',')
		c_file.write(str(X_huff_l))
		c_file.write(',')
		c_file.write(str(X_huff))
		c_file.write('\n')
	
		# Reset analysis frames count
		ind_f = 0
	else:
		ind_f = ind_f+1

c_file.close()

