"""
Upload audio files to Firebase Storage.

Prerequisites:
  1. Install firebase-admin:  pip install firebase-admin
  2. Download a service account key from Firebase Console:
     Project Settings > Service Accounts > Generate New Private Key
     Save as .jetro/firebase-service-account.json (gitignored)
  3. Run: python .jetro/scripts/upload_audio_to_firebase.py

Output paths in Firebase Storage:
  audio/audio_mantras/{filename}
  audio/guided_meditation/{filename}
  audio/solfeggio_frequencies/{filename}
  audio/sleep_sounds/{filename}
  audio/relaxation_music/{filename}
"""

import os
import sys
import json
from pathlib import Path

WORKSPACE = Path(os.environ.get('JET_WORKSPACE', os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
AUDIO_DIR = WORKSPACE / 'assets' / 'audio'
SA_KEY = WORKSPACE / '.jetro' / 'firebase-service-account.json'
BUCKET = 'mental-mantra-2024.firebasestorage.app'

CATEGORY_MAP = {
    'morning_mantra':       ('audio_mantras', 'Morning Mantra', 600),
    'evening_mantra':       ('audio_mantras', 'Evening Mantra', 600),
    'sleep_mantra':         ('audio_mantras', 'Sleep Mantra', 720),
    'stress_relief':        ('guided_meditation', 'Stress Relief Meditation', 900),
    'recovery_affirmation': ('guided_meditation', 'Recovery Affirmation', 1200),
    'focus_mantra':         ('audio_mantras', 'Focus Mantra', 540),
    'confidence_builder':   ('audio_mantras', 'Confidence Builder', 480),
    'gratitude_meditation': ('guided_meditation', 'Gratitude Meditation', 660),
    'Solfeggio_963Hz':      ('solfeggio_frequencies', '963 Hz Solfeggio', 1800),
    'background':           ('background', 'Background Music', 3600),
}


def upload_all():
    if not SA_KEY.exists():
        print(f"ERROR: Service account key not found at {SA_KEY}")
        print("Download it from Firebase Console > Project Settings > Service Accounts")
        print("Save the JSON file to: .jetro/firebase-service-account.json")
        sys.exit(1)

    import firebase_admin
    from firebase_admin import credentials, storage

    cred = credentials.Certificate(str(SA_KEY))
    firebase_admin.initialize_app(cred, {'storageBucket': BUCKET})

    bucket = storage.bucket()
    manifest = []

    for mp3 in sorted(AUDIO_DIR.glob('*.mp3')):
        stem = mp3.stem
        if stem not in CATEGORY_MAP:
            print(f"  SKIP {mp3.name} (unknown category)")
            continue

        subdir, title, duration = CATEGORY_MAP[stem]
        dest_path = f'audio/{subdir}/{mp3.name}'
        blob = bucket.blob(dest_path)

        print(f"  Uploading {mp3.name} ({mp3.stat().st_size / 1e6:.1f} MB) -> {dest_path} ...")
        blob.upload_from_filename(str(mp3))
        blob.make_public()

        public_url = blob.public_url
        print(f"    => {public_url}")

        manifest.append({
            'id': stem,
            'title': title,
            'filename': mp3.name,
            'storagePath': dest_path,
            'downloadUrl': public_url,
            'durationSeconds': duration,
            'category': subdir,
        })

    manifest_path = WORKSPACE / '.jetro' / 'audio_manifest.json'
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)
    print(f"\nDone! Manifest saved to .jetro/audio_manifest.json")
    print(f"Total files uploaded: {len(manifest)}")


if __name__ == '__main__':
    upload_all()
