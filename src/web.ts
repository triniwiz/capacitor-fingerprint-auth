import { WebPlugin } from '@capacitor/core';
import { IFingerPrintAuthPlugin, AvailableOptions } from './definitions';

export class FingerPrintAuthPluginWeb extends WebPlugin
  implements IFingerPrintAuthPlugin {
  constructor() {
    super({
      name: 'FingerPrintAuth',
      platforms: ['web']
    });
  }
  available(): Promise<AvailableOptions> {
    return new Promise(() => {});
  }
  verify(): Promise<any> {
    return new Promise(() => {});
  }
  verifyWithFallback(): Promise<any> {
    return new Promise(() => {});
  }
}

const FingerPrintAuthWebPlugin = new FingerPrintAuthPluginWeb();

export { FingerPrintAuthWebPlugin };
