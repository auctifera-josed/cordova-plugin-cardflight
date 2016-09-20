//
//  CordovaCardFlight.h
//  
//
//  Created by Jose Angarita on 9/13/16.
//
//

#import <Cordova/CDVPlugin.h>
#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import "CardFlight.h"

@interface CDVCardFlight : CDVPlugin <CFTReaderDelegate, CFTPaymentViewDelegate>

- (void)setCardFlightAccount:(CDVInvokedUrlCommand *)command;
- (void)getAccount:(CDVInvokedUrlCommand *)command;
- (void)setDefaultCurrency:(CDVInvokedUrlCommand *)command;
- (void)charge:(CDVInvokedUrlCommand *)command;
- (void)refund:(CDVInvokedUrlCommand *)command;
- (void)getCard:(CDVInvokedUrlCommand *)command;
- (void)newSwipe:(CDVInvokedUrlCommand *)command;
- (void)cancelTransaction:(CDVInvokedUrlCommand *)command;
- (void)addCardTypedView:(CDVInvokedUrlCommand *)command;
- (void)removeCardTypedView:(CDVInvokedUrlCommand *)command;
- (void)setLogging:(CDVInvokedUrlCommand *)command;
- (void)readerInit:(CDVInvokedUrlCommand *)command;
@end
