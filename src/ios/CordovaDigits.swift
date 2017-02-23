//
//  Authentication.swift
//  Quanto Plugins
//
//  Created by Bradley Suira on 2/17/17.
//

import Fabric
import DigitsKit

@objc(CordovaDigits) class CordovaDigits : CDVPlugin { 
  
	override func pluginInitialize() {
		NotificationCenter.default.addObserver(self, selector: #selector(finishLaunching), name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
	}

	func finishLaunching() {
			Fabric.with([Digits.self])
			
	}

  @objc(authenticate:)
  func authenticate(command: CDVInvokedUrlCommand) {
     //extract options
    var options: NSDictionary? = nil
    
    if let params = command.argument(at: 0) {
      options = params as? NSDictionary
    }

    self.commandDelegate!.run(inBackground: {
      self.doAuthenticate(command, options)
			
    })
  }

  private func getAuthConfig(_ accountFields: String) -> DGTAuthenticationConfiguration?{
    let configuration: DGTAuthenticationConfiguration?
    switch accountFields {
    case "email":
		  configuration = DGTAuthenticationConfiguration(accountFields: .email)
      break
    case "defaultOptionMask":
		  configuration = DGTAuthenticationConfiguration(accountFields: .defaultOptionMask)
      break
		case "none":
		  configuration = DGTAuthenticationConfiguration(accountFields: .none)
      break
		default:
			configuration = DGTAuthenticationConfiguration(accountFields: .defaultOptionMask)
      break
		}
		
    return configuration
		 
  }

  func doAuthenticate(_ command: CDVInvokedUrlCommand, _ options: NSDictionary? = nil) {
    
    let digits = Digits.sharedInstance()
		let configuration: DGTAuthenticationConfiguration?
    
    if let options = options {
      let accountFields = options.object(forKey: "accountFields") as! String

      configuration = self.getAuthConfig(accountFields) 
      let appearance = DGTAppearance()
      let accentColor = options.object(forKey: "accentColor") as! String 
      let backgroundColor = options.object(forKey: "backgroundColor") as! String 
      appearance.accentColor = self.colorFrom(hex: accentColor)
      appearance.backgroundColor = self.colorFrom(hex: backgroundColor)
      
      configuration?.phoneNumber = options.object(forKey: "phoneNumber") as! String
      configuration?.title = options.object(forKey: "title") as! String
      configuration?.appearance = appearance
			
    }else {

      configuration = self.getAuthConfig("") 
    }

    var result: CDVPluginResult? = nil
		
		digits.authenticate(with: nil, configuration: configuration!) { session, error in
	    
        if (session != nil) {
				//get the auth headers
				let oauthSigning: DGTOAuthSigning = DGTOAuthSigning(authConfig: digits.authConfig, authSession: digits.session())
				let authHeaders = oauthSigning.oAuthEchoHeadersToVerifyCredentials()
				
				do {
					
					let data = try JSONSerialization.data(withJSONObject: authHeaders, options: JSONSerialization.WritingOptions.prettyPrinted)
					let output = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue)
					
        	result = CDVPluginResult( status: CDVCommandStatus_OK, messageAs: [output as Any])

				} catch let loginError as NSError {
					
					print ("Error signing out: \(loginError.localizedDescription)")
					    result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: loginError.localizedDescription)
				}

			} else {
				
				print("Error in auth: \(error!.localizedDescription)")
				result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error!.localizedDescription)
			}

      self.commandDelegate!.send(result!, callbackId: command.callbackId)
		}
  }

  @objc(logOut:)
  func logOut(command: CDVInvokedUrlCommand) { 

    Digits.sharedInstance().logOut()
		let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "OK")
		self.commandDelegate!.send(result!, callbackId: command.callbackId)
  }

 private func colorFrom(hex:String)-> UIColor {
		var rgbValue: CUnsignedInt = 0
		
		let scanner = Scanner(string: hex)
		scanner.scanLocation = 1
		scanner.scanHexInt32(&rgbValue)
		
		return UIColor.init(red:UIColorMasks.redValue(rgbValue), green:UIColorMasks.greenValue(rgbValue), blue:UIColorMasks.blueValue(rgbValue), alpha: 1.0)
	}
}


fileprivate enum UIColorMasks: CUnsignedInt {
	case redMask    = 0xFF0000 
	case greenMask  = 0xFF00
	case blueMask   = 0xFF
	
	static func redValue(_ value: CUnsignedInt) -> CGFloat {
		let i: CUnsignedInt = (value & redMask.rawValue) >> 16
		let f: CGFloat = CGFloat(i)/255.0;
		return f;
	}
	
	static func greenValue(_ value: CUnsignedInt) -> CGFloat {
		let i: CUnsignedInt = (value & greenMask.rawValue) >> 8
		let f: CGFloat = CGFloat(i)/255.0;
		return f;
	}
	
	static func blueValue(_ value: CUnsignedInt) -> CGFloat {
		let i: CUnsignedInt = (value & blueMask.rawValue)
		let f: CGFloat = CGFloat(i)/255.0;
		return f;
	}
}