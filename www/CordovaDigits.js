var exec = require('cordova/exec');

exports.authenticate = function(options, success, error) {
    exec(success, error, "CordovaDigits", "authenticate", [options]);
};


