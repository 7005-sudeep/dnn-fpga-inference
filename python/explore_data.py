import pandas as pd
import numpy as np

# Column names for NSL-KDD
col_names = [
    "duration","protocol_type","service","flag","src_bytes","dst_bytes","land",
    "wrong_fragment","urgent","hot","num_failed_logins","logged_in","num_compromised",
    "root_shell","su_attempted","num_root","num_file_creations","num_shells",
    "num_access_files","num_outbound_cmds","is_host_login","is_guest_login","count",
    "srv_count","serror_rate","srv_serror_rate","rerror_rate","srv_rerror_rate",
    "same_srv_rate","diff_srv_rate","srv_diff_host_rate","dst_host_count",
    "dst_host_srv_count","dst_host_same_srv_rate","dst_host_diff_srv_rate",
    "dst_host_same_src_port_rate","dst_host_srv_diff_host_rate","dst_host_serror_rate",
    "dst_host_srv_serror_rate","dst_host_rerror_rate","dst_host_srv_rerror_rate",
    "label","difficulty"
]

# Download directly
train_url = "https://raw.githubusercontent.com/defcom17/NSL_KDD/master/KDDTrain+.txt"
test_url  = "https://raw.githubusercontent.com/defcom17/NSL_KDD/master/KDDTest+.txt"

print("Downloading NSL-KDD dataset...")
train_df = pd.read_csv(train_url, header=None, names=col_names)
test_df  = pd.read_csv(test_url,  header=None, names=col_names)
print("Download complete!")

# Basic exploration
print("\n--- TRAIN SET ---")
print("Shape:", train_df.shape)
print("\nFirst 3 rows:")
print(train_df.head(3))

print("\n--- CLASS DISTRIBUTION (train) ---")
print(train_df['label'].value_counts())

print("\n--- FEATURE TYPES ---")
print(train_df.dtypes.value_counts())

print("\n--- NUMERIC FEATURE STATS ---")
print(train_df.describe().T[['min','max','mean']].head(10))

# Simplify labels to 5 classes
def map_label(label):
    if label == 'normal': return 'normal'
    dos    = ['neptune','back','land','pod','smurf','teardrop','apache2',
              'udpstorm','processtable','worm']
    probe  = ['satan','ipsweep','nmap','portsweep','mscan','saint']
    r2l    = ['guess_passwd','ftp_write','imap','phf','multihop','warezmaster',
              'warezclient','spy','xlock','xsnoop','snmpguess','snmpgetattack',
              'httptunnel','sendmail','named']
    u2r    = ['buffer_overflow','loadmodule','rootkit','perl','sqlattack',
              'xterm','ps']
    if label in dos:   return 'dos'
    if label in probe: return 'probe'
    if label in r2l:   return 'r2l'
    if label in u2r:   return 'u2r'
    return 'other'

train_df['attack_class'] = train_df['label'].apply(map_label)
test_df['attack_class']  = test_df['label'].apply(map_label)

print("\n--- 5-CLASS DISTRIBUTION ---")
print(train_df['attack_class'].value_counts())

# Save cleaned files
train_df.to_csv('python/train_raw.csv', index=False)
test_df.to_csv('python/test_raw.csv', index=False)
print("\nSaved: python/train_raw.csv and python/test_raw.csv")
print("\nDay 2 complete!")
