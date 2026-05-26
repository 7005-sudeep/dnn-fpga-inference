import torch
import torch.nn as nn
import numpy as np
from torch.utils.data import DataLoader, TensorDataset
from sklearn.metrics import classification_report

X_train = np.load('python/X_train.npy')
y_train = np.load('python/y_train.npy')
X_test  = np.load('python/X_test.npy')
y_test  = np.load('python/y_test.npy')

mask   = ~np.isnan(y_test.astype(float))
X_test = X_test[mask]
y_test = y_test[mask]

X_train_t = torch.FloatTensor(X_train)
y_train_t = torch.LongTensor(y_train)
X_test_t  = torch.FloatTensor(X_test)
y_test_t  = torch.LongTensor(y_test)

train_ds = TensorDataset(X_train_t, y_train_t)
train_dl = DataLoader(train_ds, batch_size=512, shuffle=True)

# NO BatchNorm — clean for hardware
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

model     = TrafficDNN()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=20, gamma=0.5)
criterion = nn.CrossEntropyLoss()

print("Training (no BatchNorm)...")
for epoch in range(60):
    model.train()
    total_loss = 0
    for xb, yb in train_dl:
        optimizer.zero_grad()
        loss = criterion(model(xb), yb)
        loss.backward()
        optimizer.step()
        total_loss += loss.item()
    scheduler.step()
    if (epoch+1) % 10 == 0:
        print(f"Epoch {epoch+1}/60 loss: {total_loss/len(train_dl):.4f}")

model.eval()
with torch.no_grad():
    preds = model(X_test_t).argmax(dim=1).numpy()

acc = (preds == y_test).mean() * 100
print(f"\nTest Accuracy: {acc:.2f}%")
print("\nPer-class breakdown:")
print(classification_report(y_test, preds,
      target_names=['normal','dos','probe','r2l','u2r']))

torch.save(model.state_dict(), 'python/dnn_model.pt')
print("Model saved!")
print("\nLayer shapes:")
for name, param in model.named_parameters():
    print(f"  {name}: {param.shape}")
print("\nDay 6 step 1 complete!")
