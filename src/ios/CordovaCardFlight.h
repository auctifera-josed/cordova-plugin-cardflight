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

@interface CordovaCardFlight : CDVPlugin <CFTReaderDelegate> {}

- (void)setCardFlightAccount:(CDVInvokedUrlCommand *)command;
- (void)charge:(CDVInvokedUrlCommand *)command;
- (void)refund:(CDVInvokedUrlCommand *)command;
- (void)getCard:(CDVInvokedUrlCommand *)command;

@end
