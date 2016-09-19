var exec = require('cordova/exec');

module.exports = {
  setAccount: function (apiKey, accountToken, callback) {
    var connected = false;
    exec(function (result) {
      if (!connected) {
        callback(null, result);
        connected = true;
      } else {
        cordova.fireWindowEvent("cardFlightEvent", result);
      }
    },
    function (error) {
      callback(error)
    }, 'CDVCardFlight', 'setCardFlightAccount', [apiKey, accountToken]);
  },
  getAccount: function (success, error) {
    exec(success, error, "CDVCardFlight", "getAccount", []);
  },
  charge: function (amount, success, error, currency) {
    exec(success, error, "CDVCardFlight", "charge", [amount, currency]);
  },
  refund: function (amount, chargeToken, success, error) {
    exec(success, error, "CDVCardFlight", "refund", [amount, chargeToken]);
  },
  getCurrentCard: function (success, error) {
    exec(success, error, "CDVCardFlight", "getCard", []);
  },
  newSwipe: function (success, error) {
   exec(success, error, "CDVCardFlight", "newSwipe", []);
  },
  setCurrency: function(currency, success, error) {
    exec(success, error, "CDVCardFlight", "setDefaultCurrency", [currency]);
  },
  cancelTransaction: function(success, error) {
    exec(success, error, "CDVCardFlight", "cancelTransaction", []);
  },
  addCardTypedView: function(paymentView, success, error) {
    exec(success, error, "CDVCardFlight", "addCardTypedView", [paymentView]);
  },
  removeCardTypedView: function (success, error) {
    exec(success, error, "CDVCardFlight", "removeCardTypedView", []);
  }
};
