//
//  CordovaCardFlight.m
//
//
//  Created by Jose Angarita on 9/13/16.
//
//

#import "CDVCardFlight.h"

@interface CDVCardFlight()

@property (nonatomic, strong) CFTCard *card;
@property (nonatomic, strong) CFTReader *reader;
@property (nonatomic, strong) CFTPaymentView *paymentView;
@property (nonatomic, strong) NSMutableString *currency;

@end

@implementation CDVCardFlight

- (NSMutableString *)currency {
    if (!_currency) _currency = [NSMutableString stringWithFormat:@"USD"];
    return _currency;
}

static NSString *dataCallbackId = nil;

- (void)setCardFlightAccount:(CDVInvokedUrlCommand *)command {
    //    [self.commandDelegate runInBackground:^{
    CDVPluginResult *result = nil;
    NSString    *apiToken = nil,
    *accountToken = nil;
    
    if (command.arguments.count > 0) {
        apiToken = [command.arguments objectAtIndex:0];
        accountToken = [command.arguments objectAtIndex:1];
    }
    
    if (apiToken && accountToken){
        [[CFTSessionManager sharedInstance] setApiToken:apiToken
                                           accountToken:accountToken
                                              completed:^(BOOL emvReady){}];
        self.reader = nil;
        self.reader = [[CFTReader alloc] initWithReader:0];
        self.reader.delegate = self;
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing arguments"];
    }
    
    // [[CFTSessionManager sharedInstance] setLogging:YES];
    dataCallbackId = command.callbackId;
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:dataCallbackId];
    //    }];
}

- (void)getAccount:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[CFTSessionManager sharedInstance] accountToken]];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }];
}

- (void)setDefaultCurrency:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *result = nil;
        
        if ([command.arguments count]){
            self.currency = [command.arguments objectAtIndex:0];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing arguments"];
        }
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)charge:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *result = nil;
        NSDecimalNumber *amount = nil;
        
        if (command.arguments.count > 0) {
            NSString *amountString = [NSString stringWithFormat:@"%@",[command.arguments objectAtIndex:0]];
            amount = [NSDecimalNumber decimalNumberWithString:amountString];
            if ([command.arguments objectAtIndex:1])
                self.currency = [command.arguments objectAtIndex:1];
        }
        
        if (amount){
            BOOL response = [self chargeCard:self.card withAmount:amount currency:self.currency];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:response];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing arguments"];
        }
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void) refund:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *result = nil;
        NSDecimalNumber *amount = nil;
        NSString *token = nil;
        
        if (command.arguments.count > 0) {
            amount = [NSDecimalNumber decimalNumberWithString:[command.arguments objectAtIndex:0]];
            token = [command.arguments objectAtIndex:1];
        }
        
        if (amount && token){
            [CFTCharge refundChargeWithToken:token
                                   andAmount:amount
                                     success:^(CFTCharge *charge) {
                                         [self sendData:@"refund" withData:[NSString stringWithFormat:@"%@",charge.amountRefunded]];
                                     }
                                     failure:^(NSError *error) {
                                         NSLog(@"%@", error.localizedDescription);
                                         [self sendData:@"error" withData:error.localizedDescription];
                                     }];
            
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing arguments"];
        }
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)getCard:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        
        CDVPluginResult *result = nil;
        if (self.card) {
            NSString *cardString = [NSString stringWithFormat:@"************%@", self.card.last4];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:cardString];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
        }
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)newSwipe:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        [self.reader beginSwipe];
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES] callbackId:command.callbackId];
    }];
}

- (void)cancelTransaction:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    [self.reader cancelTransaction];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES] callbackId:command.callbackId];
  }];
}

- (void)addCardTypedView:(CDVInvokedUrlCommand *)command {
  // [self.commandDelegate runInBackground:^{
    CDVPluginResult *result = nil;
    NSDictionary *paymentViewInfo = nil;
    NSDictionary *bc = nil;
    
    if (command.arguments.count > 0) {
      paymentViewInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[command.arguments objectAtIndex:0] options:0 error:nil];
      bc = paymentViewInfo[@"border-color"];
    }

    if (paymentViewInfo){
      CGRect rect = CGRectMake( [paymentViewInfo[@"x"] intValue], 
                                [paymentViewInfo[@"y"] intValue], 
                                [paymentViewInfo[@"width"] intValue], 
                                [paymentViewInfo[@"height"] intValue]);
      self.paymentView = nil;
      //Init with dimensions
      self.paymentView = [[CFTPaymentView alloc] initWithFrame:rect];
      self.paymentView.delegate = self;
      //Keyboard Appearance
      [self.paymentView useKeyboardAppearance:[self getKeyboardAppearance:paymentViewInfo[@"keyboardAppearance"]]];
      //Border Color
      [self.paymentView useBorderColor:[UIColor colorWithRed:[bc[@"red"] floatValue] green:[bc[@"green"] floatValue] blue:[bc[@"blue"] floatValue] alpha:[bc[@"alpha"] floatValue]]];
      [self.webView.superview addSubview:self.paymentView];
      //Focus
      if ([paymentViewInfo[@"focus"] boolValue])
        [self.paymentView becomeFirstResponder];
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    } else {
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing arguments"];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  // }];
}
- (void)removeCardTypedView:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    [self.paymentView removeFromSuperview];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES] callbackId:command.callbackId];
  }];
}

- (void)setLogging:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    CDVPluginResult *result = nil;
    BOOL logging = YES;
    if (command.arguments.count > 0) {
      logging = [[command.arguments objectAtIndex:0] boolValue];
      [[CFTSessionManager sharedInstance] setLogging:logging];
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    } else
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing arguments"];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }];
}

#pragma mark - Payment View Delegate

- (void)keyedCardResponse:(CFTCard *)card {
    
    if (card) {
        self.card = card;
        [self sendData:@"card" withData:[NSString stringWithFormat:@"************%@", self.card.last4]];
    }
}

#pragma mark - Reader Delegate

- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error {
    if (isConnected ) {
        [self sendData:@"reader" withData:@"connected"];
        [self.reader swipeHasTimeout:NO];
        [self.reader beginSwipe];
    } else {
        [self sendData:@"reader" withData:@"reader_error"];
    }
}

- (void)readerIsConnecting {
    [self sendData:@"reader" withData:@"connecting"];
}

- (void)readerIsDisconnected {
    [self sendData:@"reader" withData:@"disconnected"];
}

- (void)readerSwipeDetected {
    [self sendData:@"reader" withData:@"swipe"];
}

- (void)readerIsAttached {
    [self sendData:@"reader" withData:@"attached"];
}
- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error {
    if (card) {
        self.card = card;
        [self sendData:@"card" withData:[NSString stringWithFormat:@"************%@", self.card.last4]];
    } else {
        [self sendData:@"card" withData:error.localizedDescription];
    }
}
- (void)readerNotDetected {
    [self sendData:@"reader" withData:@"not_detected"];
}


#pragma mark - Private Methods

- (BOOL)chargeCard:(CFTCard *)card
        withAmount:(NSDecimalNumber *)amount
          currency:(NSString *)currency {
    BOOL success = YES;
    NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
    
    if (card) {
        NSDictionary *paymentInfo = @{@"amount":amount,
                                      @"currency":currency};
        
        [card chargeCardWithParameters:paymentInfo
                               success:^(CFTCharge *charge) {
                                   [response setObject:[NSNumber numberWithBool:YES] forKey:@"success"];
                                   [response addEntriesFromDictionary:[CDVCardFlight chargeToDictionary:charge]];
                                   self.card = nil;
                                   [self sendData:@"charge" withDictionary:response];
                               }
                               failure:^(NSError *error) {
                                   NSLog(@"%@", error.localizedDescription);
                                   [self sendData:@"error" withData:error.localizedDescription];
                               }];
    } else {
        success = NO;
        NSLog(@"Error - No card to charge");
        [self sendData:@"error" withData:@"no_card"];
    }
    return success;
}

+ (NSMutableDictionary *)chargeToDictionary:(CFTCharge *)charge {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:charge.amount forKey:@"amount"];
    [dict setObject:charge.token forKey:@"token"];
    [dict setObject:[NSNumber numberWithBool:charge.isRefunded] forKey:@"isRefunded"];
    [dict setObject:charge.amountRefunded forKey:@"amountRefunded"];
    [dict setObject:[NSString stringWithFormat:@"%@", charge.created] forKey:@"createdDate"];
    return dict;
}

- (UIKeyboardAppearance)getKeyboardAppearance:(NSString *)appearance {
  if (appearance){
    if ([appearance isEqualToString:@"dark"])
      return UIKeyboardAppearanceDark;
    else if ([appearance isEqualToString:@"default"])
      return UIKeyboardAppearanceDefault;
    else if ([appearance isEqualToString:@"alert"])
      return UIKeyboardAppearanceAlert;
    else if ([appearance isEqualToString:@"light"])
      return UIKeyboardAppearanceLight;
  } else
    return UIKeyboardAppearanceDark;
}

- (void)sendData:(NSString *)dataType withData:(NSString *)data {
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

- (void)sendData:(NSString *)dataType withDictionary:(NSDictionary *)dictionary {
    if (dataCallbackId != nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:dataType forKey:@"dataType"];
        if (dictionary != nil) {
            [dict setObject:dictionary forKey:@"data"];
        }
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:dataCallbackId];
    }
}

@end