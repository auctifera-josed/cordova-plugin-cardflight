# CardFlight Plugin

Cordova plugin for [CardFlight](http://www.cardflight.com)

## Security
Remember that all cordova code is exposed (client side) and you shouldn't store any private keys in code.

## Use
This plugin defines global **cardFlight** object.

Although in the global scope, it is not available until after the deviceready event.
```javascript
document.addEventListener("deviceready", onDeviceReady, false);
function onDeviceReady() {
    console.log(cardFlight);
}
```

Note: Plugin requires the following frameworks, although plugin adds them, recheck that are properly referenced in xcode project:

- AVFoundation
- AudioToolbox
- MediaPlayer
- MessageUI
- ExternalAccessory
- **CoreGraphics**
- libstdc++.6.0.9.dylib

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

## Reference
Available methods

1. [setAccount](README.md#setaccount) //Should be called first, calls readerInit
2. [getAccount](README.md#getaccount)
3. [charge](README.md#charge)
4. [refund](README.md#refund)
5. [getCurrentCard](README.md#getcurrentcard)
6. [newSwipe](README.md#newswipe)
7. [setCurrency](README.md#setcurrency)
8. [cancelTransaction](README.md#canceltransaction)
9. [addCardTypedView](README.md#addcardtypedview)
10. [removeCardTypedView](README.md#removecardtypedview)
11. [setLogging](README.md#setlogging)
12. [readerInit](README.md#readerinit)
13. [cardFlightEvent](README.md#cardflightevents)

## API

### [setAccount](#setaccount)
The `setAccount(apiKey, accountToken, callback)` function sets the key, token and initializes the reader object.`

**you need to set the account before using any other method**

#### apiKey*
The CardFlight's Test/Production API key
#### accountToken*
The Merchant Account's token
#### callback
function(err,res){}

### [Charge](#charge)
The `charge(amount, success, error[, currency])` function creates a charge of the given amount to the last swiped/typed credit card. Throws error if card is null

#### amount*
The amount to be charged

#### currency
Optional string to modify the currency, default is 'USD'

### [Refund](#refund)
The `refund(amount, chargeToken, success, error)` function allows to refund the charge of the given token

#### amount*
The amount to be refunded

#### chargeToken* 
The CardFlight's charge token (e.g ch_Wqi19gebijL-********)

### [Get Current Card](#getcurrentcard)
The `getCurrentCard(success, error)` function returns a string containing the last 4 chars of the current credit card

### [New Swipe](#newswipe)
The `newSwipe(success, error)` function sets the system to allow a new swipe

Note: - Convenient method to use if there is a **Swipe Error** event
      - Note that this method is called in the **readerIsConnected** event

### [Set Currency](#setcurrency)
The `setCurrency(currency, success, error)` function to set the default currency for all future charges

#### currency*
A [ISO 4217](http://www.iso.org/iso/home/standards/currency_codes.htm) Currency Code (e.g USD, EUR)

### [Get Account](#getaccount)
The `getAccount(success, error)` function returns the current account token from the session manager

### [Cancel Transaction](#canceltransaction)
The `cancelTransaction(success, error)` function manually cancel the swipe process before the timeout duration has been reached or cancels an EMV transaction. Additionally it sets to null the reader, paymentView and card objects.

Note: This method should be call anytime the reader shouldn't be expecting a swipe to avoid weird behaviour.

### [Add Card Typed View](#addcardtypedview)
The `addCardTypedView(paymentView, success, error)` function adds a CFTPaymentView to accept user input with card information. It takes a paymentView object to create the view.

**This method overrides any previous view with the new one.**

#### paymentView*
An object to create a paymentView, e.g:
```javascript
{
  "x": 20,
  "y": 20,
  "width": 200,
  "height": 20,
  "keyboardAppearance": "dark",
  "border-color": {
    "red": 1.0,
    "green": 1.0,
    "blue": 1.0,
    "alpha": 1.0
  },
  "focus" : true
}
```
x*,y*: position on screen
width*, height*: size
keyboardApperance options:
  - dark
  - alert
  - default
  - light
focus*: indicates if view should be focus uppon creation

### [Remove Card Typed View](#removecardtypedview)
The `removeCardTypedView(success, error)` function removes from the super view the last created view with the method 'addCardTypedView'

### [Set Logging](#setlogging)
The `setLogging(logging, success, error)` function switches the logging to on/off, convenient method for debugging.

#### logging*
True activates logging, false deactivates it

### [Reader Init](#readerinit)
The `readerInit(success, error)` function initializes the reader object to start detecting CardFlight card reader.

**This method is called from setAccount function**

### [CardFlight events](#cardflightevents)

Listen to reader and card events as cases of the **cardFlightEvent** event, cases are:
1. reader
  1. attached
  1. connected
  1. disconnected
  1. swipe
2. card
  2. Swipe error
  2. XXXX //4 last card digits
3. refund
4. charge
5. error

Charge and Refund events return a charge object:

```javascript
{ 
  "amount": xxx,
  "amountRefunded": xxx,
  "createdDate": "YYYY-MM-DD HH:MM:SS Z",
  "isRefunded": bool,
  "token": "charge_secret_token"
 }
```

```javascript
window.addEventListener('cardFlightEvent', function (e) {
  switch (e.dataType) {
    case 'reader':
      break;
    case 'card':
      break;
    case ...:
      ...
    default:
      console.log(e);
  }
});
```