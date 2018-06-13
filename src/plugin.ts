import { Plugins } from '@capacitor/core';
import { IFingerPrintAuthPlugin, AvailableOptions } from './definitions';
const { FingerPrintAuthPlugin } = Plugins;
export class FingerPrintAuth implements IFingerPrintAuthPlugin {
  available(): Promise<AvailableOptions> {
    return FingerPrintAuthPlugin.available();
  }
  verify(): Promise<any> {
    return FingerPrintAuthPlugin.verify();
  }
  verifyWithFallback(): Promise<any> {
    return FingerPrintAuthPlugin.verifyWithFallback();
  }
}
