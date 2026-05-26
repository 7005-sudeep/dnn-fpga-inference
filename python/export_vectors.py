import torch
import torch.nn as nn
import numpy as np
import os

X_test = np.load('python/X_test.npy')
y_test = np.load('python/y_test.npy')

mask   = ~np.isnan(y_test.astype(float))
X_test = X_test[mask]
y_test = y_test[mask]

class TrafficDNN(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(41, 128), nn.ReLU(),
            nn.Linear(128, 64), nn.ReLU(),
            nn.Linear(64,  5)
        )
    def forward(self, x):
        return self.net(x)

model = TrafficDNN()
model.load_state_dict(torch.load('python/dnn_model.pt'))
model.eval()

def to_fixed(val, frac_bits=8):
    val   = np.clip(val, -128, 127)
    fixed = np.round(val * (2 ** frac_bits)).astype(np.int32)
    fixed = np.clip(fixed, -32768, 32767)
    return fixed

def val_to_hex(v):
    return format(int(v) & 0xFFFF, '04X')

def array_to_hex(arr):
    return ' '.join([val_to_hex(v) for v in arr])

N       = 50
samples = X_test[:N]
labels  = y_test[:N].astype(int)
classes = ['normal', 'dos', 'probe', 'r2l', 'u2r']

print("Generating test vectors...")
os.makedirs('test_vectors', exist_ok=True)

fin  = open('test_vectors/inputs.hex',       'w')
flab = open('test_vectors/labels.hex',       'w')
fout = open('test_vectors/expected_out.hex', 'w')

for i in range(N):
    x   = samples[i]
    x_t = torch.FloatTensor(x).unsqueeze(0)

    with torch.no_grad():
        logits = model(x_t).numpy()[0]

    pred      = np.argmax(logits)
    fixed_in  = to_fixed(x)
    fixed_out = to_fixed(logits)

    fin.write(array_to_hex(fixed_in)  + '\n')
    flab.write(format(labels[i], '02X') + '\n')
    fout.write(array_to_hex(fixed_out) + '\n')

    if i < 3:
        print("Sample " + str(i) + ": true=" + classes[labels[i]] + ", pred=" + classes[pred])
        print("  Input hex first 5: " + str(array_to_hex(fixed_in).split()[:5]))
        print("  Output hex: " + array_to_hex(fixed_out))

fin.close()
flab.close()
fout.close()

print("Saved 50 test vectors to test_vectors/")

print("Exporting weights...")
os.makedirs('weights', exist_ok=True)

layers = [
    ('W1', model.net[0].weight.detach().numpy()),
    ('b1', model.net[0].bias.detach().numpy()),
    ('W2', model.net[2].weight.detach().numpy()),
    ('b2', model.net[2].bias.detach().numpy()),
    ('W3', model.net[4].weight.detach().numpy()),
    ('b3', model.net[4].bias.detach().numpy()),
]

for name, param in layers:
    fixed = to_fixed(param.flatten())
    path  = 'weights/' + name + '.hex'
    f     = open(path, 'w')
    for v in fixed:
        f.write(format(int(v) & 0xFFFF, '04X') + '\n')
    f.close()
    print("  " + name + ": shape=" + str(param.shape) + ", saved " + str(len(fixed)) + " values")

print("All weights exported to weights/")
print("Day 7 complete! Week 1 DONE!")
