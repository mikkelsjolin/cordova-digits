var exec = require('cordova/exec');

var CordovaDigits = {
	authenticate: function(options, success, error) {
	    exec(success, error, 'CordovaDigits', 'authenticate', [options]);
	},
	logOut = function(success, error) {
	    exec(success, error, 'CordovaDigits', 'logOut', []);
	},
	isAuthenticated: function(success, error) {
	    exec(success, error, 'CordovaDigits', 'isAuthenticated', []);
	},
	onSessionHasChanged: function(success, error) {
	    exec(success, error, 'CordovaDigits', 'onSessionHasChanged', []);
	},
	onSessionExpired: function(success, error) {
	    exec(success, error, 'CordovaDigits', 'onSessionExpired', []);
	}
};

module.exports = CordovaDigits;