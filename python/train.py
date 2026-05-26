import torch
import torch.nn as nn
import numpy as np
from torch.utils.data import DataLoader, TensorDataset

# Load data
X_train = np.load('python/X_train.npy')
y_train = np.load('python/y_train.npy')
X_test  = np.load('python/X_test.npy')
y_test  = np.load('python/y_test.npy')

# Convert to tensors
X_train = torch.FloatTensor(X_train)
y_train = torch.LongTensor(y_train)
X_test  = torch.FloatTensor(X_test)
y_test  = torch.LongTensor(y_test)

# DataLoaders
train_ds = TensorDataset(X_train, y_train)
test_ds  = TensorDataset(X_test, y_test)
train_dl = DataLoader(train_ds, batch_size=256, shuffle=True)
test_dl  = DataLoader(test_ds,  batch_size=256)

# DNN Model — 3 layers
class TrafficDNN(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(41, 128), nn.ReLU(),
            nn.Linear(128, 64), nn.ReLU(),
            nn.Linear(64, 5)
        )
    def forward(self, x):
        return self.net(x)

model     = TrafficDNN()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
criterion = nn.CrossEntropyLoss()

# Train
print("Training...")
for epoch in range(20):
    model.train()
    total_loss = 0
    for xb, yb in train_dl:
        optimizer.zero_grad()
        loss = criterion(model(xb), yb)
        loss.backward()
        optimizer.step()
        total_loss += loss.item()
    if (epoch+1) % 5 == 0:
        print(f"Epoch {epoch+1}/20 loss: {total_loss/len(train_dl):.4f}")

# Evaluate
model.eval()
correct = 0
with torch.no_grad():
    for xb, yb in test_dl:
        preds = model(xb).argmax(dim=1)
        correct += (preds == yb).sum().item()

acc = correct / len(y_test) * 100
print(f"\nTest Accuracy: {acc:.2f}%")

# Save model
torch.save(model.state_dict(), 'python/dnn_model.pt')
print("Model saved: python/dnn_model.pt")
print("\nLayer shapes:")
for name, param in model.named_parameters():
    print(f"  {name}: {param.shape}")
print("\nDay 4 complete!")
