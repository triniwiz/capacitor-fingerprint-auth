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

## Example Image

| IOS                                     | Android                                     |
| --------------------------------------- | ------------------------------------------- |
| Coming Soon | Coming Soon |

