import torch
import torch.nn as nn
import numpy as np

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

# Q8.8 fixed point conversion
def to_fixed(val, int_bits=8, frac_bits=8):
    scale   = 2 ** frac_bits
    val     = np.clip(val, -128, 127)
    fixed   = np.round(val * scale).astype(np.int32)
    fixed   = np.clip(fixed, -32768, 32767).astype(np.int16)
    return fixed

# Take 50 samples
N       = 50
samples = X_test[:N]
labels  = y_test[:N].astype(int)

classes = ['normal','dos','probe','r2l','u2r']

# Generate test vectors
print("Generating test vectors...")
import os
os.makedirs('test_vectors', exist_ok=True)

with open('test_vectors/inputs.hex', 'w') as fin, \
     open('test_vectors/labels.hex', 'w') as flab, \
     open('test_vectors/expected_out.hex', 'w') as fout:

    for i in range(N):
        x      = samples[i]
        fixed  = to_fixed(x)
        x_t    = torch.FloatTensor(x).unsqueeze(0)

        with torch.no_grad():
            logits = model(x_t).numpy()[0]

        pred       = np.argmax(logits)
        fixed_out  = to_fixed(logits)

        # Write input features as hex
        hex_in  = ' '.join([f'{v & 0xFFFF:04X}' for v in fixed])
        hex_out = ' '.join([f'{v & 0xFFFF:04X}' for v in fixed_out])

        fin.write(hex_in  + '\n')
        flab.write(f'{labels[i]:02X}\n')
        fout.write(hex_out + '\n')

        if i < 3:
            print(f"\nSample {i}: true={classes[labels[i]]}, pred={classes[pred]}")
            print(f"  Input hex (first 5): {hex_in.split()[:5]}")
            print(f"  Output hex: {hex_out}")

print(f"\nSaved {N} test vectors to test_vectors/")

# Export weights as hex
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
            f.write(f'{v & 0xFFFF:04X}\n')
    print(f"  {name}: shape={param.shape}, saved {len(fixed)} hex values")

print("\nAll weights exported to weights/")
print("\nDay 7 complete! Week 1 DONE! 🎉")
