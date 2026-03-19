# README

Make sure you have the following files in this folder

- pass_type.pem
- pass_type_private.key
- wwdr.pem

Also make sure you have the right environment variables set. I use [direnv](https://direnv.net)
and you can follow the `envrc-sample` file.

Once you have them, you can create a pass by running

```
./build_pash.sh
```

Then you can airdrop the resulting `test.pkpass` to the phone.
If it can be added to the wallet, it's all valid.

## Files

- pass_type.pem: is the Apple issued certificate in .PEM format
- pass_type_private.key: the key for the above certificate
- wwdr.pem: a `.pem` version of the apple `AppleWWDRCAG4.cer` certificate downloaded from https://developer.apple.com/support/expiration/
    - result of `openssl x509 -inform DER -in AppleWWDRCAG*.cer -out wwdr.pem`
