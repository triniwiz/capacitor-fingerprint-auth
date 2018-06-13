package co.fitcom.fingerprintauth;

import android.annotation.SuppressLint;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.Intent;
import android.hardware.fingerprint.FingerprintManager;
import android.os.Build;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.security.keystore.UserNotAuthenticatedException;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.jesusm.kfingerprintmanager.KFingerprintManager;

import java.io.IOException;
import java.lang.reflect.Array;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.KeyGenerator;
import javax.crypto.NoSuchPaddingException;


@NativePlugin(
        requestCodes = {FingerPrintAuthPlugin.REQUEST_CODE_CONFIRM_DEVICE_CREDENTIALS}
)
public class FingerPrintAuthPlugin extends Plugin {
    private static String KEY_NAME = "capfingerprintauth";
    private static byte[] SECRET_BYTE_ARRAY = new byte[16];
    KFingerprintManager fingerPrintManager;
    KeyguardManager keyguardManager;
    public static final int REQUEST_CODE_CONFIRM_DEVICE_CREDENTIALS = 788;
    private PluginCall call;

    @Override
    public void load() {
        super.load();
        this.keyguardManager = (KeyguardManager) getActivity().getSystemService(Context.KEYGUARD_SERVICE);
    }

    @SuppressLint("NewApi")
    @PluginMethod()
    public void available(PluginCall call) {
        JSObject obj = new JSObject();

        if (Build.VERSION.SDK_INT >= 23) {
            FingerprintManager manager = (FingerprintManager) getActivity().getSystemService(Context.FINGERPRINT_SERVICE);

            if (keyguardManager == null || !keyguardManager.isKeyguardSecure()) {
                obj.put("has", false);
                call.resolve(obj);
            } else {
                if (!manager.isHardwareDetected()) {
                    call.reject("Device doesn't support fingerprint authentication");
                } else if (!manager.hasEnrolledFingerprints()) {
                    call.reject("User hasn't enrolled any fingerprints to authenticate with");
                } else {
                    obj.put("has", false);
                    obj.put("touch", true);
                    call.resolve(obj);
                }
            }
        } else {
            call.reject("Api version not supported");
        }

    }


    private void verifyWithCustomAndroidUI(PluginCall call, KFingerprintManager.AuthenticationCallback authenticationCallback) {
        this.call = call;
        this.fingerPrintManager.authenticate(
                authenticationCallback,
                getActivity().getSupportFragmentManager());
    }

    @PluginMethod()
    public void verify(final PluginCall call) {

        if (this.fingerPrintManager == null) {
            this.fingerPrintManager = new com.jesusm.kfingerprintmanager.KFingerprintManager(getActivity().getApplicationContext(), KEY_NAME);
        }

        boolean useCustomAndroidUI = call.getBoolean("useCustomAndroidUI", false);
        if (useCustomAndroidUI) {
            KFingerprintManager.AuthenticationCallback callback = new com.jesusm.kfingerprintmanager.KFingerprintManager.AuthenticationCallback() {
                public int attempts = 0;

                @Override
                public void onAuthenticationFailedWithHelp(String s) {
                    if (++this.attempts < 3) {

                    } else {
                        call.reject(s);
                    }
                }

                @Override
                public void onAuthenticationSuccess() {
                    call.resolve();
                }

                @Override
                public void onSuccessWithManualPassword(String s) {
                    call.resolve();
                }

                @Override
                public void onFingerprintNotAvailable() {
                    call.reject("Secure lock screen hasn't been set up.\\n Go to \\\"Settings -> Security -> Screenlock\\\" to set up a lock screen");
                }

                @Override
                public void onFingerprintNotRecognized() {
                    call.reject("Fingerprint not recognized.");
                }

                @Override
                public void onCancelled() {
                    call.reject("Cancelled by user");
                }
            };
            this.verifyWithCustomAndroidUI(call, callback);
        } else {
            if (this.keyguardManager == null) {
                call.reject("Keyguard manager not available.");
            }
            if (this.keyguardManager == null || !this.keyguardManager.isKeyguardSecure()) {
                call.reject("Secure lock screen hasn't been set up.\n Go to \"Settings -> Security -> Screenlock\" to set up a lock screen.");
            }

            int duration = call.getInt("authenticationValidityDuration", 5);
            createKey(duration);
            this.call = call;
            String tryEncryptResult = tryEncrypt(call);
            if (tryEncryptResult.contains("none")) {
                // this one is async
            } else if (tryEncryptResult.contains("true")) {
                call.resolve();
            } else {
                call.reject("See the console for error logs.");
            }
        }
    }


    @Override
    protected void handleOnActivityResult(int requestCode, int resultCode, Intent data) {
        super.handleOnActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE_CONFIRM_DEVICE_CREDENTIALS) {
            if (resultCode == android.app.Activity.RESULT_OK) { // OK = -1
                // the user has just authenticated via the ConfirmDeviceCredential activity
                this.call.resolve();
                this.call = null;
            } else {
                // the user has quit the activity without providing credentials
                this.call.reject("User cancelled.");
                this.call = null;
            }
        }
    }

    @SuppressLint("InlinedApi")
    private String tryEncrypt(PluginCall call) {
        try {
            KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
            keyStore.load(null);
            Key secretKey = keyStore.getKey(KEY_NAME, null);

            Cipher cipher = Cipher.getInstance(KeyProperties.KEY_ALGORITHM_AES + "/" + KeyProperties.BLOCK_MODE_CBC + "/" + KeyProperties.ENCRYPTION_PADDING_PKCS7);
            cipher.init(Cipher.ENCRYPT_MODE, secretKey);
            cipher.doFinal(SECRET_BYTE_ARRAY);
            return "true";
        } catch (UserNotAuthenticatedException e) {
            this.showAuthenticationScreen(call);
            return "none";
        } catch (KeyStoreException | IOException | CertificateException | NoSuchAlgorithmException | UnrecoverableKeyException | IllegalBlockSizeException | BadPaddingException | NoSuchPaddingException | InvalidKeyException e) {
            return "false";
        }
    }


    private void showAuthenticationScreen(PluginCall call) {
        Intent intent = keyguardManager.createConfirmDeviceCredentialIntent(
                call.getString("title"),
                call.getString("message")
        );
        if (intent != null) {
            getActivity().startActivityForResult(intent, REQUEST_CODE_CONFIRM_DEVICE_CREDENTIALS);
        }
    }


    @SuppressLint("NewApi")
    private static void createKey(int duration) {
        try {
            KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
            keyStore.load(null);
            KeyGenerator keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore");

            keyGenerator.init(
                    new KeyGenParameterSpec.Builder(KEY_NAME, KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
                            .setBlockModes(KeyProperties.BLOCK_MODE_CBC)
                            .setUserAuthenticationRequired(true)
                            .setUserAuthenticationValidityDurationSeconds(duration)
                            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_PKCS7).build());
            keyGenerator.generateKey();
        } catch (IOException | CertificateException | NoSuchAlgorithmException | NoSuchProviderException | KeyStoreException | InvalidAlgorithmParameterException e) {
            e.printStackTrace();
        }
    }


    @PluginMethod()
    public void verifyWithFallback(PluginCall call) {
        verify(call);
    }
}
