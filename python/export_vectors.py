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

def to_hex(fixed_array):
    return ' '.join([f'{int(v) & 0xFFFF:04X}' for v in fixed_array])

N       = 50
samples = X_test[:N]
labels  = y_test[:N].astype(int)
classes = ['normal','dos','probe','r2l','u2r']

print("Generating test vectors...")
os.makedirs('test_vectors', exist_ok=True)

with open('test_vectors/inputs.hex',       'w') as fin, \
     open('test_vectors/labels.hex',       'w') as flab, \
     open('test_vectors/expected_out.hex', 'w') as fout:

    for i in range(N):
        x     = samples[i]
        x_t   = torch.FloatTensor(x).unsqueeze(0)

        with torch.no_grad():
            logits = model(x_t).numpy()[0]

        pred      = np.argmax(logits)
        fixed_in  = to_fixed(x)
        fixed_out = to_fixed(logits)

        fin.write(to_hex(fixed_in)  + '\n')
        flab.write(f'{labels[i]:02X}\n')
        fout.write(to_hex(fixed_out) + '\n')

        if i < 3:
            print(f"\nSample {i}: true={classes[labels[i]]}, pred={classes[pred]}")
            print(f"  Input hex (first 5): {to_hex(fixed_in).split()[:5]}")
            print(f"  Output hex: {to_hex(fixed_out)}")

print(f"\nSaved {N} test vectors to test_vectors/")

print("\nExporting weights...")
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
    with open(f'weights/{name}.hex', 'w') as f:
        for v in fixed:
            f.write(f'{int(v)
