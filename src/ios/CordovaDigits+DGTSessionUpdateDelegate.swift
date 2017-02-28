
extension CordovaDigits: DGTSessionUpdateDelegate {

  func digitsSessionHasChanged(_ newSession: DGTSession!) {
    if let session = newSession, command = sessionHasChangedCommand {
      
      	self.getSessionHeaders(session, completion: { headers, err in

				var result: CDVPluginResult? = nil

				if headers != nil {
					result = CDVPluginResult( status: CDVCommandStatus_OK, messageAs: [headers as Any])
				}else {
					let message = err != nil ? err!.localizedDescription: "Error obtaining the session headers"
					result = CDVPluginResult( status: CDVCommandStatus_ERROR, messageAs: message)
				}

				self.commandDelegate!.send(result!, callbackId: command.callbackId)
			})
    }
  }

  func digitsSessionExpired(forUserID userID: String!) {
    if let command = sessionHasChangedCommand {
      	let result = CDVPluginResult( status: CDVCommandStatus_OK, messageAs: userID)
				self.commandDelegate!.send(result!, callbackId: command.callbackId)
			})
    }
  }

  /**
 	*  Listen whe the session was updated, implements the method digitsSessionHasChanged on DGTSessionUpdateDelegate
	*
	*  @param CDVInvokedUrlCommand .
  */
  @objc(onSessionExpire:)
  func onSessionHasChanged(command: CDVInvokedUrlCommand) { 
    self.sessionHasChangedCommand = command
  }

	/**
 	*  Listen whe the session expire, implements the method digitsSessionExpired on DGTSessionUpdateDelegate
	*
	*  @param CDVInvokedUrlCommand .
  */
  @objc(onSessionExpire:)
  func onSessionExpired(command: CDVInvokedUrlCommand) { 
    self.sessionExpiredCommand = command
  }
}