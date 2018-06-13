import Foundation
import Capacitor
import LocalAuthentication

@objc(FingerPrintAuthPlugin)
public class FingerPrintAuthPlugin: CAPPlugin {
    
    @objc func available(_ call:CAPPlugin){
        var ctx = LAContext()
        var error:NSError?
        var has = ctx.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: error)
        
        if(error != nil){
            call.reject(["any":false])
            return
        }
        
        call.resolve([
            "any":has,
            "touch": has && ctx.biometryType == LABiometryType.touchID,
            "face": has && ctx.biometryType == LABiometryType.faceID
        ])
    }
    
    @objc func verify(_ call:CAPPlugin){
        var reason = call.getString("reason") ?? ""
        var ctx = LAContext()
        ctx.localizedCancelTitle = cancelTitle
        ctx.localizedFallbackTitle = fallbackTitle
        ctx.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
            DispatchQueue.main.async {
                if(success){
                    print("success")
                    call.resolve()
                }else{
                    call.reject([
                        "code":error.code,
                        "message":error.localizedDescription
                    ])
                }
            }
        }
    }
    
    @objc func verifyWithFallback(_ call:CAPPlugin){
        var cancelTitle = call.getString("cancelTitle") ?? ""
        var fallbackTitle = call.getString("fallbackTitle") ?? ""
        var reason = call.getString("reason") ?? ""
        var ctx = LAContext()
        ctx.localizedCancelTitle = cancelTitle
        ctx.localizedFallbackTitle = fallbackTitle
        ctx.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
            DispatchQueue.main.async {
                if(success){
                    print("success")
                    call.resolve()
                }else{
                    call.reject([
                        "code":error.code,
                        "message":error.localizedDescription
                    ])
                }
            }
        }
    }
}
