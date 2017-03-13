//
//  CordovaDigits.swift
//  Quanto Plugins
//
//  Created by Bradley Suira on 2/17/17.
//

import Fabric
import DigitsKit

@objc(CordovaDigits) class CordovaDigits : CDVPlugin { 
  
	var sessionHasChangedCommand: CDVInvokedUrlCommand?
	var sessionExpiredCommand: CDVInvokedUrlCommand?

	override func pluginInitialize() {
		super.pluginInitialize()
		NotificationCenter.default.addObserver(self, selector: #selector(finishLaunching), name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
	}

	//setup the digits sdk
	func finishLaunching() {
			Fabric.with([Digits.self])
	}

	/**
 	*  Authenticate the user using the digits native sdk, and then return the oauth headers 
	*
	*  @param CDVInvokedUrlCommand.
  */

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

	/**
 	*  Verify if exists a session and return the oauth headers
	*
	*  @param CDVInvokedUrlCommand .
	*  @param optioins Configuration options for custom appearance
  */

  private func doAuthenticate(_ command: CDVInvokedUrlCommand, _ options: NSDictionary? = nil) {
    
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
				
				self.getSessionHeaders(session!, completion: { headers, err in

					if headers != nil {
						 	result = CDVPluginResult( status: CDVCommandStatus_OK, messageAs: [headers as Any])
					}else {
						let message = err != nil ? err!.localizedDescription: "Error obtaining the session headers"
						 result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message)
					}
				})

			} else {
				
				print("Error in auth: \(error!.localizedDescription)")
				result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error!.localizedDescription)
			}

      self.commandDelegate!.send(result!, callbackId: command.callbackId)
		}
  }
	
	/**
 	*  Close the current session
	*
	*  @param CDVInvokedUrlCommand .
  */
  @objc(logOut:)
  func logOut(command: CDVInvokedUrlCommand) { 

    Digits.sharedInstance().logOut()
		let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "OK")
		self.commandDelegate!.send(result!, callbackId: command.callbackId)
  }

	/**
 	*  Verify if exists a session and return the oauth headers
	*
	*  @param CDVInvokedUrlCommand .
  */
	@objc(isAuthenticated:)
  func isAuthenticated(command: CDVInvokedUrlCommand) { 
		var result: CDVPluginResult? = nil
		print("isAuthenticated called")
		
    if let session = Digits.sharedInstance().session() {
				print("current Session: \(session)")
				self.getSessionHeaders(session, completion: { headers, err in

				if headers != nil {
					result = CDVPluginResult( status: CDVCommandStatus_OK, messageAs: [headers as Any])
				}else {
					let message = err != nil ? err!.localizedDescription: "Error obtaining the session headers"
					result = CDVPluginResult( status: CDVCommandStatus_ERROR, messageAs: message)
				}

				self.commandDelegate!.send(result!, callbackId: command.callbackId)
			})

		} else {
				print("no session found")
				result = CDVPluginResult( status: CDVCommandStatus_ERROR, messageAs: "No Active Session")
				self.commandDelegate!.send(result!, callbackId: command.callbackId)
		}
  }

	/**
 	*  Get the auth configuration based on the accounts field passed
	*
  *  @param accountFields	String 
  *  @returns DGTAuthenticationConfiguration
  */
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


 /**
 	*  Get the oauth headers form digits the session passed
	*
  *  @param session	current DGTSession 
  *  @param completion	Block called after the auth headers extraction.
  */
	private func getSessionHeaders(_ session: DGTSession, completion: (Any?, Error? ) -> Void){
		
		let digits = Digits.sharedInstance()
		
		let oauthSigning: DGTOAuthSigning = DGTOAuthSigning(authConfig: digits.authConfig, authSession: session)
		
		let authHeaders = oauthSigning.oAuthEchoHeadersToVerifyCredentials()
		
		do {
			
			let data = try JSONSerialization.data(withJSONObject: authHeaders, options: JSONSerialization.WritingOptions.prettyPrinted)
			let str = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue)
			print("getSessionHeaders return \(str)")
			completion(str as Any, nil)
			
		} catch let error as NSError {
			
			print ("Error in getSessionHeaders: \(error.localizedDescription)")
			completion(nil, error)
		}
	}

	/**
	*	Get a UIColor for the hexadecimal value 
	*
  *  @param hex: String	Hexadecimal value of a color.
	*  @returns UIColor
  */
	private func colorFrom(hex: String)-> UIColor {
		var rgbValue: CUnsignedInt = 0
		
		let scanner = Scanner(string: hex)
		scanner.scanLocation = 1
		scanner.scanHexInt32(&rgbValue)
		
		return UIColor.init(red:UIColorMasks.redValue(rgbValue), green:UIColorMasks.greenValue(rgbValue), blue:UIColorMasks.blueValue(rgbValue), alpha: 1.0)
	}
}
/*
* For Hex Color convertion
*/
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