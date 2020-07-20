import Foundation
import Flutter
import Firebase


public class TranslatorPlugin: NSObject, FlutterPlugin {
    var translator: Translator
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zhongboard/translation", binaryMessenger: registrar.messenger())
        let instance = TranslatorPlugin()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public override init() {
        let options = TranslatorOptions(
            sourceLanguage: TranslateLanguage.zh,
            targetLanguage: TranslateLanguage.en);
                
        self.translator = NaturalLanguage.naturalLanguage().translator(options: options)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "downloadModel":
                downloadModel()
                result(nil)
            case "translate":
                let text = call.arguments as! String
                                
                translate(text: text, result: result)
            default:
                result(FlutterMethodNotImplemented)
        }
    }
    
    // TODO
    // We should only download these over wifi unless the user overrides
    // We should also delete unneeded models:
    // See: https://firebase.google.com/docs/ml-kit/ios/translate-text#manage_models
    
    // If this is not successful let's say because the user is not on wifi
    // we need to tell Flutter that
    func downloadModel(){
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        );
                
        translator.downloadModelIfNeeded(with: conditions) {
            error in guard error == nil else {
                // TODO Use FlutterError
                NSLog("\n Error attempting to download model...")
                NSLog("\n \(error!)")
                return
            }
        }
    }
    
    func translate(text: String, result: @escaping FlutterResult) -> Void {
        translator.translate(text) { (translatedText, error) in
            // TODO Handle error
            guard error == nil, let translatedText = translatedText else { return }
            
            result(translatedText)
        }
    }
}


