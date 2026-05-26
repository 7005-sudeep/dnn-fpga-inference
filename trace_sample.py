import torch
import torch.nn as nn
import numpy as np

# Load data
X_test = np.load('python/X_test.npy')
y_test = np.load('python/y_test.npy')

# Rebuild model architecture
class TrafficDNN(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(41, 128), nn.BatchNorm1d(128), nn.ReLU(),
            nn.Linear(128, 64), nn.BatchNorm1d(64),  nn.ReLU(),
            nn.Linear(64, 5)
        )
    def forward(self, x):
        return self.net(x)

# Load trained weights
model = TrafficDNN()
model.load_state_dict(torch.load('python/dnn_model.pt'))
model.eval()

# Pick one sample
sample  = torch.FloatTensor(X_test[0:1])
label   = int(y_test[0])
classes = ['normal', 'dos', 'probe', 'r2l', 'u2r']

print("=== MANUAL TRACE OF ONE SAMPLE ===")
print(f"True label: {classes[label]} ({label})")
print(f"Input shape: {sample.shape}")
print(f"Input values (first 5 features): {sample[0,:5].tolist()}")

# Extract weights and biases manually
W1 = model.net[0].weight.detach().numpy()  # (128, 41)
b1 = model.net[0].bias.detach().numpy()    # (128,)
W2 = model.net[3].weight.detach().numpy()  # (64, 128)
b2 = model.net[3].bias.detach().numpy()    # (64,)
W3 = model.net[6].weight.detach().numpy()  # (5, 64)
b3 = model.net[6].bias.detach().numpy()    # (5,)

print(f"\nW1 shape: {W1.shape} — Layer 1 weights")
print(f"W2 shape: {W2.shape} — Layer 2 weights")
print(f"W3 shape: {W3.shape} — Layer 3 weights")

# Manual forward pass using NumPy
x = sample[0].numpy()  # (41,)

# Layer 1: Linear + ReLU (ignoring BatchNorm for now)
z1 = W1 @ x + b1       # (128,)
a1 = np.maximum(0, z1) # ReLU
print(f"\nAfter Layer 1 (ReLU): shape={a1.shape}, first 5={a1[:5].round(4)}")

# Layer 2: Linear + ReLU
z2 = W2 @ a1 + b2      # (64,)
a2 = np.maximum(0, z2) # ReLU
print(f"After Layer 2 (ReLU): shape={a2.shape}, first 5={a2[:5].round(4)}")

# Layer 3: Linear (no activation)
z3 = W3 @ a2 + b3      # (5,)
print(f"After Layer 3 (logits): {z3.round(4)}")

# Predicted class
pred = np.argmax(z3)
print(f"\nPredicted class: {classes[pred]} ({pred})")
print(f"True class:      {classes[label]} ({label})")
print(f"Match: {pred == label}")

# Compare with PyTorch output
with torch.no_grad():
    pytorch_out = model(sample).numpy()[0]
print(f"\nPyTorch logits:  {pytorch_out.round(4)}")
print(f"NumPy logits:    {z3.round(4)}")
print("\nDay 5 complete!")
