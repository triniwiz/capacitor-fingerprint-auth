declare global {
  interface PluginRegistry {
    FingerPrintAuthPlugin?: IFingerPrintAuthPlugin;
  }
}

export interface AvailableOptions {
  has: boolean;
  faceId: boolean;
  touchId: boolean;
}

export interface IFingerPrintAuthPlugin {
  available(): Promise<AvailableOptions>;
  verify(): Promise<any>;
  verifyWithFallback(): Promise<any>;
}
