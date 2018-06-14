# Capacitor FingerPrint Auth

[![npm](https://img.shields.io/npm/v/capacitor-fingerprint-auth.svg)](https://www.npmjs.com/package/capacitor-fingerprint-auth)
[![npm](https://img.shields.io/npm/dt/capacitor-fingerprint-auth.svg?label=npm%20downloads)](https://www.npmjs.com/package/capacitor-fingerprint-auth)
[![Build Status](https://travis-ci.org/triniwiz/capacitor-fingerprint-auth.svg?branch=master)](https://travis-ci.org/triniwiz/capacitor-fingerprint-auth)

## Installation

* `npm i capacitor-fingerprint-auth`

## Usage

```ts
import { FingerPrintAuth } from 'capacitor-fingerprint-auth';
const auth = new FingerPrintAuth();
const data = await auth.available();
//
const hasFingerPrintOrFaceAuth = data.has;
const touch = data.touch;
const face = data.face;

await auth.verify();

await auth.verifyWithFallback(); //Falls back to password on IOS
```

## Api

| Method                                   | Default | Type                         | Description                                           |
| ---------------------------------------- | ------- | ---------------------------- | ----------------------------------------------------- |
| available() |         | `Promise<any>`                     | Checks if the device has fingerprint/touch id / faceid support |
| verify()                  |         | `Promise<any>`                 | Shows the prompt |
| verifyWithFallback()  |         | `Promise<any>` | Falls back to passcode *IOS*   |


### verify

```
fingerprintAuth.verify(
	{
	  title: 'Android title', // optional title (used only on Android)
	  message: 'Scan your finger', // optional (used on both platforms) - for FaceID on iOS see the notes about NSFaceIDUsageDescription
	  authenticationValidityDuration: 10, // optional (used on Android, default 5)
	  useCustomAndroidUI: false // set to true to use a different authentication screen (see below)
      fallbackTitle: "Enter your PaSsWorD " //The localized title for the fallback button in the dialog presented to the user during authentication.
      cancelTitle:"Get me out //The localized title for the cancel button in the dialog presented to the user during authentication"
	})
	.then(() => console.log("Biometric ID OK"))
	.catch(err => console.log(`Biometric ID NOT OK: ${JSON.stringify(err)}`));
```


## Face ID (iOS)
iOS 11 added support for Face ID and was first supported by the iPhone X. The developer needs to provide a value for NSFaceIDUsageDescription, otherwise your app may crash.

You can provide this value (the reason for using Face ID) by adding something like this to App/info.plist:

```xml
<key>NSFaceIDUsageDescription</key>
<string>For easy authentication with our app.</string>
```

## Example Image

| IOS                                     | Android                                     |
| --------------------------------------- | ------------------------------------------- |
| Coming Soon | Coming Soon |

