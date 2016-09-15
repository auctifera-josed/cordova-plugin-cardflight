# CardFlight Plugin

Cordova plugin for [CardFlight](http://www.cardflight.com)

## Use
This plugin defines global **cardFlight** object.

Although in the global scope, it is not available until after the deviceready event.
```javascript
document.addEventListener("deviceready", onDeviceReady, false);
function onDeviceReady() {
    console.log(cardFlight);
}
```

## Install

Install using `cordova plugin add https://git-codecommit.us-east-1.amazonaws.com/v1/repos/cordova-plugin-cardflight`

## Example
```javascript
cardFlight.setAccount('be*********************', 'acc_****************', function(err, res) {
    if (err) console.log(err);
    else console.log(res);
})
```
```javascript
cardFlight.charge(100, 'USD', function(res) {
    console.log(res);
}, function(res) {
    console.log(res);
})
```
true = success | false = error

## API

### setAccount
The `setAccount(apiKey, accountToken, callback)` function sets the key, token and initializes the reader object.`

**you need to set the account before using any other method**

#### apiKey*
The CardFlight's Test/Production API key
#### accountToken*
The Merchant Account's token
#### callback
function(err,res){}

### Charge
The `charge(amount, success, error[, currency])` function creates a charge of the given amount to the last swiped (typed) credit card.

#### amount*
The amount to be charged

#### currency
Optional string to modify the currency, default is 'USD'

### Refund
The `refund(amount, chargeToken, success, error)` function allows to refund the charge of the given token

#### amount*
The amount to be refunded

#### chargeToken* 
The CardFlight's charge token (e.g ch_Wqi19gebijL-********)

### Get Current Card
The `getCurrentCard(success, error)` function returns a string containing the last 4 chars of the current credit card

### New Swipe
The `newSwipe(success, error)` function sets the system to allow a new swipe

Note: - Convenient method to use if there is a **Swipe Error** event
      - Note that this method is called in the **readerIsConnected** event

### Set Currency
The `setCurrency(currency, success, error)` function to set the default currency for all future charges

#### currency*
A ISO 4217 Currency Code (e.g USD, EUR)

### Get Account
The `getAccount(success, error)` function returns the current account token from the session manager

### CardFlight events

Listen to printer events as cases of the **cardFlightEvent** event, cases are:
- reader
- card
- refund
- charge
- error

```javascript
window.addEventListener('cardFlightEvent', function (e) {
  switch (e.dataType) {
    case 'reader':
      break;
    case 'card':
      break;
    default:
      console.log(e);
  }
});
```