import Foundation
import Capacitor
import LocalAuthentication

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
    
    @objc func verify(_ call:CAPPluginCall){
        let reason = call.getString("reason") ?? "Scan your finger"
        let cancelTitle = call.getString("cancelTitle") ?? ""
        let fallbackTitle = call.getString("fallbackTitle") ?? ""
        let ctx = LAContext()
        ctx.localizedCancelTitle = cancelTitle
        ctx.localizedFallbackTitle = fallbackTitle
        ctx.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
            DispatchQueue.main.async {
                if(success){
                    print("success")
                    call.resolve()
                }else{
                    call.reject(error!.localizedDescription,error)
                }
            }
        }
    }
    
    @objc func verifyWithFallback(_ call:CAPPluginCall){
        let cancelTitle = call.getString("cancelTitle") ?? ""
        let fallbackTitle = call.getString("fallbackTitle") ?? ""
        let reason = call.getString("reason") ?? "Scan your finger"
        let ctx = LAContext()
        ctx.localizedCancelTitle = cancelTitle
        ctx.localizedFallbackTitle = fallbackTitle
        ctx.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
            DispatchQueue.main.async {
                if(success){
                    print("success")
                    call.resolve()
                }else{
                    call.reject(error!.localizedDescription)
                }
            }
        }
    }
}
