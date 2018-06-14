import Foundation
import Capacitor
import LocalAuthentication

var keychainItemIdentifier = "CapTouchIDKey"
var keychainItemServiceName: String?;

@objc(FingerPrintAuthPlugin)
public class FingerPrintAuthPlugin: CAPPlugin {
    @objc func available(_ call:CAPPluginCall){
        let ctx = LAContext()
        var error:NSError?
        var obj = JSObject()
        
        let has = ctx.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if(error != nil){
            obj["any"] = false
            call.resolve(obj)
            return
        }
        obj["has"] = true
        if #available(iOS 11.0, *) {
            obj["touch"] = has && ctx.biometryType == LABiometryType.touchID
        } else {
            obj["touch"] = true
        }
        if #available(iOS 11.0, *) {
            obj["face"] = ctx.biometryType == LABiometryType.faceID
        } else {
            obj["face"] = false
        }
        
        call.resolve(obj)
    }
    
    @objc func didFingerprintDatabaseChange(_ call: CAPPluginCall) {
        
        var obj = JSObject()
        
        let laContext = LAContext();
        var error: NSError?
        // we expect the dev to have checked 'isAvailable' already so this should not return an error,
        // we do however need to run canEvaluatePolicy here in order to get a non-nil evaluatedPolicyDomainState
        
        let supported = !laContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if(error != nil){
            if (supported) {
                call.reject("Not available");
                return;
            }
            
            // only supported on iOS9+, so check this.. if not supported just report back as false
            if #available(iOS 9.0, *) {
                obj["value"] = false;
                call.resolve(obj)
            }
            
            let CapFingerprintDatabaseStateKey = "CapFingerprintDatabaseStateKey";
            let state = laContext.evaluatedPolicyDomainState;
            if (state != nil) {
                
                let stateStr = state?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0));
                let standardUserDefaults = UserDefaults()
                let storedState = standardUserDefaults.string(forKey:CapFingerprintDatabaseStateKey);
                
                // Store enrollment
                standardUserDefaults.setValue(stateStr, forKey: CapFingerprintDatabaseStateKey)
                standardUserDefaults.synchronize();
                
                // whenever a finger is added/changed/removed the value of the storedState changes,
                // so compare agains a value we previously stored in the context of this app
                let changed = storedState != nil && stateStr != storedState;
                obj["value"] = changed;
                call.resolve(obj);
            }else{
                obj["value"] = false;
                call.resolve(obj)
            }
        }
    }
    
    @objc func verify(_ call:CAPPluginCall){
        let message = call.getString("message") ?? "Scan your finger"
        
        if (keychainItemServiceName == nil) {
            
            let bundleID = Bundle.main.infoDictionary!["CFBundleIdentifier"]
            if(bundleID == nil){
                call.reject("")
            }
            keychainItemServiceName =  bundleID as! String + ".TouchId"
        }
        
        if (!FingerPrintAuthPlugin.createKeyChainEntry()) {
            verifyWithFallback(call);
            return;
        }
        
        let query = NSMutableDictionary()
        query.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        query.setValue(keychainItemIdentifier, forKey: kSecAttrAccount as String)
        query.setValue(keychainItemServiceName, forKey: kSecAttrService as String)
        
        // Note that you can only do this for Touch ID; for Face ID you need to tweak the plist value of NSFaceIDUsageDescription
        query.setValue(message, forKey: kSecUseOperationPrompt as String)
        
        // Start the query and the fingerprint scan and/or device passcode validation
        let res = SecItemCopyMatching(query, nil);
        if (res == 0) {
            call.resolve();
        } else {
            call.reject("");
        }
        
    }
    
    @objc func verifyWithFallback(_ call:CAPPluginCall){
        let cancelTitle = call.getString("cancelTitle") ?? ""
        let fallbackTitle = call.getString("fallbackTitle ") ?? ""
        let message = call.getString("message") ?? "Scan your finger"
        let ctx = LAContext()
        if(fallbackTitle != ""){
            ctx.localizedFallbackTitle = fallbackTitle
        }
        
        if(cancelTitle != ""){
            ctx.localizedCancelTitle = cancelTitle
        }
        
        ctx.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: message) { (success, error) in
            DispatchQueue.main.async {
                if(success){
                    call.resolve()
                }else{
                    call.reject(error!.localizedDescription)
                }
            }
        }
        
    }
    
    
    private static func createKeyChainEntry() -> Bool{
        let attributes = NSMutableDictionary();
        attributes.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        attributes.setValue(keychainItemIdentifier as String, forKey:kSecAttrAccount as String);
        attributes.setValue(keychainItemServiceName,forKey: kSecAttrService as String);
        
        let accessControlRef = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            SecAccessControlCreateFlags.userPresence,
            nil
        );
        
        if (accessControlRef == nil) {
            // print("Can't store identifier " + keychainItemIdentifier +  "in the KeyChain: " + accessControlError + ".");
            
            return false;
        } else {
            attributes.setValue(accessControlRef, forKey: kSecAttrAccessControl as String)
            // The content of the password is not important
            let content = NSString.init(string:String(arc4random()))
            let nsData = content.data(using: String.Encoding.utf8.rawValue)
            attributes.setValue(nsData, forKey: kSecValueData as String)
            
            SecItemAdd(attributes, nil);
            return true;
        }
    }
}
