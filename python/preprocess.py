import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
import pickle #used for serilization and deserilization

train_df = pd.read_csv('python/train_raw.csv')
test_df  = pd.read_csv('python/test_raw.csv')

# Encode categorical features
cat_cols = ['protocol_type', 'service', 'flag']
for col in cat_cols:
    le = LabelEncoder()
    train_df[col] = le.fit_transform(train_df[col])
    test_df[col]  = le.transform(test_df[col])

# Encode labels
label_map = {'normal':0, 'dos':1, 'probe':2, 'r2l':3, 'u2r':4}
train_df['attack_class'] = train_df['attack_class'].map(label_map)
test_df['attack_class']  = test_df['attack_class'].map(label_map)

# Drop unused columns
drop_cols = ['label', 'difficulty']
train_df = train_df.drop(columns=drop_cols)
test_df  = test_df.drop(columns=drop_cols)

# Split features and labels
X_train = train_df.drop(columns=['attack_class']).values
y_train = train_df['attack_class'].values
X_test  = test_df.drop(columns=['attack_class']).values
y_test  = test_df['attack_class'].values

# Normalize
scaler  = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test  = scaler.transform(X_test)

# Save
np.save('python/X_train.npy', X_train)
np.save('python/y_train.npy', y_train)
np.save('python/X_test.npy',  X_test)
np.save('python/y_test.npy',  y_test)

with open('python/scaler.pkl', 'wb') as f:
    pickle.dump(scaler, f)

print("Input shape:", X_train.shape)
print("Labels:", np.unique(y_train))
print("Day 3 complete!")
