# cordova-digits
Cordova plugin for Digits native mobile SDK ([https://get.digits.com](https://get.digits.com))

*Letting Cordova chat with Digits*

## Characteristics
Support login and logout for native Digits SDK, with options for customization:
- accentColor
- backgroundColor
- phoneNumer (pre-populate)
- title: Custom title in the top navbar
- accountFields: used if you want to get only the phone number or also email for example

## Installation
```
cordova plugin add cordova-digits --save --variable FABRIC_API_KEY=your_api_key --variable FABRIC_API_SECRET=your_api_secret

```
## Suported Plaforms
- iOS
- Android (soon)

## Usage

### Authenticate

`CordovaDigits.authenticate(options, successCallback(result), errorCallback(error))`

Example:
```
var options = {
    accentColor: '#0389D1',
    backgroundColor: '#FFFFFF',
    phoneNumber: '+507', //pre populate with country prefix or phone number
    title: 'YOUR TITLE',
    accountFields: 'defaultOptionMask' //can be email, defaultOptionMask, none
};

CordovaDigits.authenticate(
    options,
    function (result) {

        console.log('[Digits]', 'login result', result);
        //your code

    },
    function (error) {
        console.warn('[Digits]', 'login error', err);
        //your code
    }
);
```

The result in success callback has the two headers for user verification:
```
{
  "X-Verify-Credentials-Authorization" : "OAuth oauth_signature="OAUTH_SIGNATURE\",oauth_nonce=\"OAUTH_NONCE\",oauth_timestamp=\"1487784750\",oauth_consumer_key=\"CONSUMER_KEY\",oauth_token=\"OAUTH_TOKEN\",oauth_version=\"1.0\",oauth_signature_method=\"HMAC-SHA1\"",
  "X-Auth-Service-Provider" : "https:\/\/api.digits.com\/1.1\/sdk\/account.json"
}
```

### LogOut

```
CordovaDigits.logOut();
```


### IsAuthenticated
Get the current digits session if it exists

`CordovaDigits.isAuthenticated(successCallback(result), errorCallback(error))`

Example:
```

CordovaDigits.isAuthenticated(
    function (result) {

        console.log('[Digits]', 'user is authenticated', result);
        //your code

    },
    function (error) {
        console.warn('[Digits]', 'user not authenticated', err);
        //your code
    }
);
```

The result in success callback is similar to the authenticate() method:

### onSessionHasChanged
Listener for session updated event, for example when the phone number has changed, [more info...](https://docs.fabric.io/apple/digits/advanced-setup.html#digitssessionhaschanged)

**Not tested yet** 

### onSessionExpired
Listener for session expired event, [more info...](https://docs.fabric.io/apple/digits/advanced-setup.html#digitssessionexpiredforuserid)

**Not tested yet**

## Contributors
This plugin is based on ideas and code from other repos:
- [https://github.com/JimmyMakesThings/cordova-plugin-digits](https://github.com/JimmyMakesThings/cordova-plugin-digits).
- [https://github.com/cosmith/cordova-digits](https://github.com/cosmith/cordova-digits).


