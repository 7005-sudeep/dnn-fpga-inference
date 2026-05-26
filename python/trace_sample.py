import torch
import torch.nn as nn
import numpy as np

X_test = np.load('python/X_test.npy')
y_test = np.load('python/y_test.npy')

mask   = ~np.isnan(y_test.astype(float))
X_test = X_test[mask]
y_test = y_test[mask]

# NO BatchNorm
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

sample  = torch.FloatTensor(X_test[0:1])
label   = int(y_test[0])
classes = ['normal','dos','probe','r2l','u2r']

# Extract weights
W1 = model.net[0].weight.detach().numpy()
b1 = model.net[0].bias.detach().numpy()
W2 = model.net[2].weight.detach().numpy()
b2 = model.net[2].bias.detach().numpy()
W3 = model.net[4].weight.detach().numpy()
b3 = model.net[4].bias.detach().numpy()

# Manual NumPy forward pass
x  = sample[0].numpy()
z1 = W1 @ x  + b1
a1 = np.maximum(0, z1)
z2 = W2 @ a1 + b2
a2 = np.maximum(0, z2)
z3 = W3 @ a2 + b3

pred = np.argmax(z3)

print("=== GOLDEN REFERENCE TRACE ===")
print(f"True label:      {classes[label]} ({label})")
print(f"Predicted:       {classes[pred]} ({pred})")
print(f"Match:           {pred == label}")

# Critical check — must match exactly
with torch.no_grad():
    pytorch_out = model(sample).numpy()[0]

print(f"\nPyTorch logits:  {pytorch_out.round(6)}")
print(f"NumPy logits:    {z3.round(6)}")
print(f"\nMax difference:  {np.max(np.abs(pytorch_out - z3)):.10f}")
print("\nIf max difference < 0.000001 — golden model is VERIFIED ✅")
print("\nDay 6 complete!")
