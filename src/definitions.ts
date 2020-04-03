declare global {
  interface PluginRegistry {
    FingerPrintAuthPlugin?: IFingerPrintAuthPlugin;
  }
}

export interface AvailableOptions {
  has: boolean;
  face: boolean;
  touch: boolean;
}

export interface IFingerPrintAuthPlugin {
  available(): Promise<AvailableOptions>;
  verify(): Promise<any>;
  verifyWithFallback(): Promise<any>;
}
