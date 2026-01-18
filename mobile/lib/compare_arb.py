import json

def load_arb(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

en = load_arb(r'd:\Projects\efteqad-strefqa\mobile\lib\l10n\app_en.arb')
ar = load_arb(r'd:\Projects\efteqad-strefqa\mobile\lib\l10n\app_ar.arb')

en_keys = set(k for k in en.keys() if not k.startswith('@'))
ar_keys = set(k for k in ar.keys() if not k.startswith('@'))

missing_in_ar = en_keys - ar_keys
missing_in_en = ar_keys - en_keys

print("Missing in Arabic:")
for k in missing_in_ar:
    print(f"- {k}: {en[k]}")

print("\nMissing in English:")
for k in missing_in_en:
    print(f"- {k}: {ar[k]}")
