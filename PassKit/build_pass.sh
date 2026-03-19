#!/usr/bin/env bash
set -euo pipefail

PASS_TYPE_CERTIFICATE_PEM='pass_type.pem'
APPLE_CERTIFICATE_PEM=wwdr.pem
PASS_TYPE_PRIVATE_KEY='pass_type_private.key'

## Clean previous output files
rm -f test.pkpass
rm -f test.pass/manifest.json
rm -f test.pass/pass.json
rm -f test.pass/signature

WORKDIR="$(mktemp -d)"
PASSDIR="./test.pass"

######## Create JSON conent
echo "Create pass.json"

# pass.json (Store Card is often used for loyalty; generic also works)
cat > "${PASSDIR}/pass.json" <<JSON
{
  "formatVersion": 1,
  "passTypeIdentifier": "$PASS_TYPE_ID",
  "serialNumber": "$SERIAL_NUMBER",
  "teamIdentifier": "$TEAM_ID",
  "organizationName": "$ORGANIZATION_NAME",
  "description": "Crafting Swift PassKit Example",
  "foregroundColor": "rgb(255,255,255)",
  "backgroundColor": "rgb(24,7,45)",
  "labelColor": "rgb(236,112,50)",
  "barcode": {
    "format": "PKBarcodeFormatQR",
    "message": "https://www.youtube.com/@CraftingSwift",
    "messageEncoding": "iso-8859-1"
  },
  "storeCard": {
    "auxiliaryFields": [
      {
            "key": "memberName",
            "label": "Name",
            "value": "Felipe"
        },
        {
            "key": "memberNumber",
            "label": "Member Number",
            "value": "7337"
        }
    ],
    "backFields": [
        {
            "key": "customer-service",
            "label": "Customer service",
            "value": "(800) 555-5555"
        },
        {
            "key": "terms",
            "label": "Membership Terms and Conditions",
            "value": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        }
    ]
  }
}
JSON

######### MAKE Manifest file
echo "Make manifest file"

# Build manifest.json (SHA-1 hashes)
# Apple’s classic tooling uses SHA-1 for the manifest.
MANIFEST_TMP="${WORKDIR}/manifest.json"
(
  cd "$PASSDIR" || exit 1

  echo "{" > "$MANIFEST_TMP"
  first=1

  find . -type f \
    ! -name 'manifest.json' \
    ! -name 'signature' \
    ! -name '.DS_Store' \
    -print0 | sort -z |
  while IFS= read -r -d '' file; do
    rel="${file#./}"
    [[ -z "$rel" ]] && continue

    hash=$(shasum -a 1 "$rel" | awk '{print $1}')

    if [[ $first -eq 1 ]]; then
      first=0
    else
      echo "," >> "$MANIFEST_TMP"
    fi

    printf '  "%s": "%s"' "$rel" "$hash" >> "$MANIFEST_TMP"
  done

  echo "" >> "$MANIFEST_TMP"
  echo "}" >> "$MANIFEST_TMP"
)

mv "$MANIFEST_TMP" "${PASSDIR}/manifest.json"


# ================ MAKE Signature
echo "Make signature"
OUT_PKPASS="../test.pkpass"

openssl smime -binary -sign \
  -signer "$PASS_TYPE_CERTIFICATE_PEM" \
  -inkey "$PASS_TYPE_PRIVATE_KEY" \
  -certfile "$APPLE_CERTIFICATE_PEM" \
  -in "${PASSDIR}/manifest.json" \
  -out "${PASSDIR}/signature" \
  -outform DER \
  -md sha1

# Zip into .pkpass
echo "Bundle everything"
(
  cd "$PASSDIR"
  rm -f .DS_Store
  zip -r -X "$OUT_PKPASS" .
)

echo "Created: $OUT_PKPASS"

