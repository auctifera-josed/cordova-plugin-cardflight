//
//  CordovaCardFlight.m
//
//
//  Created by Jose Angarita on 9/13/16.
//
//

#import "CordovaCardFlight.h"

@interface CordovaCardFlight()

@property (nonatomic) CFTCard *swipedCard;
@property (nonatomic) CFTReader *reader;

@end

@implementation CordovaCardFlight

static NSString *dataCallbackId = nil;

- (void)setCardFlightAccount:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = nil;
    NSString 	*apiToken = nil,
				*accountToken = nil;
    
    if (command.arguments.count > 0) {
        apiToken = [command.arguments objectAtIndex:0];
        accountToken = [command.arguments objectAtIndex:1];
    }
    
    if (apiToken && accountToken){
        [[CFTSessionManager sharedInstance] setApiToken:apiToken
                                           accountToken:accountToken
                                              completed:^(BOOL emvReady){}];
        
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing arguments"];
    }
    
    [[CFTSessionManager sharedInstance] setLogging:YES];
    dataCallbackId = command.callbackId;
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:dataCallbackId];
}

- (void)charge:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = nil;
    NSDecimalNumber *amount = nil;
    NSString *currency = @"USD";
    
    if (command.arguments.count > 0) {
        amount = [NSDecimalNumber decimalNumberWithString:[command.arguments objectAtIndex:0]];
        currency = [command.arguments objectAtIndex:1];
    }
    
    if (amount){
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing arguments"];
    }
    [self.commandDelegate sendPluginResult:result callbackId:dataCallbackId];
}

// - (void)getCard:(CDVInvokedUrlCommand *)command {
//     CDVPluginResult *result = nil;
//     if (self.swipedCard) {
//         NSString *cardString = @"************%@", self.swipedCard.last4;
//         result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:cardString];
//     } else {
//        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
//     }
//     [self.commandDelegate sendPluginResult:result callbackId:dataCallbackId];
// }

#pragma mark - Reader Events

- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error {
    if (isConnected ) {
        [self sendData:@"reader" data:@"Reader Connected"];
    } else {
        [self sendData:@"reader" data:@"Reader Error"];
    }
}

- (void)readerIsConnecting {
    [self sendData:@"reader" data:@"Reader Attached, Connecting"];
}

- (void)readerIsDisconnected {
    [self sendData:@"reader" data:@"Reader Not Connected"];
}

- (void)readerSwipeDetected {
    [self sendData:@"reader" data:@"Reader Attached, Connecting"];
}

- (void)readerIsAttached {
    [self sendData:@"reader" data:@"Reader Attached, Connecting"];
}
- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error {
    if (card) {
        self.swipedCard = card;
    } else {
        [self sendData:@"card" data:error.localizedDescription];
    }
}
- (void)readerNotDetected {
    [self sendData:@"reader" data:@"Reader Not Detected"];
}


#pragma mark - Private Methods

- (void)chargeCard:(CFTCard *)card
                         withAmount:(NSDecimalNumber *)amount
                           currency:(NSString *)currency
                     andDescription:(NSString *)description {
    
//    NSMutableDictionary *response = @{@"success":NO, }
    
    if (card) {
        NSDictionary *paymentInfo = @{@"amount":amount,
                                      @"currency":currency,
                                      @"description":description ? description : [NSNull null]};
        
        [card chargeCardWithParameters:paymentInfo
                               success:^(CFTCharge *charge) {
                                   NSLog(@"%@", charge.amount);
                               }
                               failure:^(NSError *error) {
                                   NSLog(@"%@", error.localizedDescription);
                               }];
    } else {
        NSLog(@"Error - No card to charge");
    }
}

//- (NSMutableDictionary *)chargeToDictionary:(CFTCharge *)charge {
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    [dict setObject:charge.amount forKey:@"amount"];
//    [dict setObject:[portInfo macAddress] forKey:@"macAddress"];
//    [dict setObject:[portInfo modelName] forKey:@"modelName"];
//    return dict;
//}

- (void)sendData:(NSString *)dataType data:(NSString *)data {
    if (dataCallbackId != nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:dataType forKey:@"dataType"];
        if (data != nil) {
            [dict setObject:data forKey:@"data"];
        }
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:dataCallbackId];
    }
}

@end
