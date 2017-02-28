var exec = require('cordova/exec');

exports.authenticate = function(options, success, error) {
    exec(success, error, 'CordovaDigits', 'authenticate', [options]);
};

exports.logOut = function(success, error) {
    exec(success, error, 'CordovaDigits', 'logOut', []);
};

exports.isAuthenticated = function(success, error) {
    exec(success, error, 'CordovaDigits', 'isAuthenticated', []);
};

exports.onSessionHasChanged = function(success, error) {
    exec(success, error, 'CordovaDigits', 'onSessionHasChanged', []);
};

exports.onSessionExpired = function(success, error) {
    exec(success, error, 'CordovaDigits', 'onSessionExpired', []);
};


