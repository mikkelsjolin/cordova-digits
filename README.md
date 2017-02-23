# cordova-digits
Cordova plugin for Digits native mobile SDK ([https://get.digits.com](https://get.digits.com))

## Characteristics
Support login and logout for native Digits SDK, with options for customization:
- accentColor
- backgroundColor
- phoneNumer (pre-populate)
- title: Custom title in the top navbar
- accountFields: used if you want to get only the phone number or also email for example

## Installation
```
cordova plugin add https://github.com/red-quanto/cordova-digits --save --variable FABRIC_API_KEY=your_api_key --variable FABRIC_API_SECRET=your_api_secret

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

The result in success Callback has the two headers for user verification:
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

## Contributors
This plugin is based on ideas and code from other repos:
- [https://github.com/JimmyMakesThings/cordova-plugin-digits](https://github.com/JimmyMakesThings/cordova-plugin-digits).
- [https://github.com/cosmith/cordova-digits](https://github.com/cosmith/cordova-digits).


