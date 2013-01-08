//
//  LPEasyScrobble.m
//
//  Created by Adam Drew on 9/5/12.
//  Copyright (c) 2012 Adam Drew, AmStaff Apps. All rights reserved.
//	adam@amstaffapps.com
//
//	EasyScrobble: A stupidly easy Last.fm scrobbler for iOS or Mac OS X Apps
//

#import "LPEasyScrobble.h"

@implementation LPEasyScrobble

@synthesize username;
@synthesize password;
@synthesize sessionKey;
@synthesize APIKey;
@synthesize APISecret;
@synthesize isInDebug;

- (BOOL) setUsername: (NSString*) userNameArg andPassword: (NSString *) passwordArg {
    //Get the information required to log into Last.FM
    
    //Dev API Key and Secret
    //Add yours here
    [self setAPIKey:@"35af9b71263825917eb8dd3087a850bd"];
    [self setAPISecret:@"046d3d5a4c120848db67d359db073797"];
    
    //Username and Password
    [self setUsername:userNameArg];
    [self setPassword:passwordArg];
    
    //Print debug statements if TRUE
    [self setIsInDebug:FALSE];
    
    //Set the default value for session key
    [self setSessionKey:@"NOKEY"];
    
    //Start a session
    return [self startSession];
}

- ( NSString *) scrubString: (NSString *) string{
    //We need to scrub out escaped characters
    
    //Varients of this solution have been posted on so many blogs and StackOverflow answers
    //that I don't know who to give credit to for originating it.
    //Simon Woodside: http://simonwoodside.com/weblog/2009/4/22/how_to_really_url_encode/
    //Darron Schall: http://stackoverflow.com/questions/4814558/how-to-encode-an-url
    //Search the web for CFURLCreateStringByAddingPercentEscapes and URL and you'll see hundreds of
    //results... so, whoever came up with this, thanks.
    
    NSString * encodedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 );
    return encodedString;
    
}


- (BOOL) scrobbleTrack:(SPTrack *)track {
    //Scrobbles a track
    
    [self debugLog:@"Entered scrobbleTrack"];
    
    //Get the Artist Name
    NSString *artist = track.consolidatedArtists;
    
    //Get the Song Name
    NSString *song = track.name;
    
    //Get the Album Name
    NSString *album = track.album.name;
    
    //Get the UNIX time stamp for the scrobble request
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    float UNIXTime = (float)ti;
    int UNIXTimeStamp = (int)UNIXTime;
    NSString *dateString = [NSString stringWithFormat:@"%i", UNIXTimeStamp];
    
    //Build auth.getMobileSession SIG
    NSMutableString *api_sig = [NSMutableString string];
    [api_sig appendString:@"album"];
    [api_sig appendString:album];
    [api_sig appendString:@"api_key"];
    [api_sig appendString:self.APIKey];
    [api_sig appendString:@"artist"];
    [api_sig appendString:artist];
    [api_sig appendString:@"methodtrack.scrobble"];
    [api_sig appendString:@"sk"];
    [api_sig appendString:self.sessionKey];
    [api_sig appendString:@"timestamp"];
    [api_sig appendString:dateString];
    [api_sig appendString:@"track"];
    [api_sig appendString:song];
    [api_sig appendString:self.APISecret];
    
    [self debugLog:@"API Sig (Raw):"];
    [self debugLog:api_sig];
    
    NSString *api_sig_hashed = [self MD5StringOfString:api_sig];
    
    [self debugLog:@"API Sig (Hashed):"];
    [self debugLog:api_sig_hashed];
    
    //Build auth.getMobileSession SIG
    NSMutableString *api_request = [NSMutableString string];
    [api_request appendString:@"album="];
    [api_request appendString:[self scrubString:album]];
    [api_request appendString:@"&api_key="];
    [api_request appendString:self.APIKey];
    [api_request appendString:@"&artist="];
    [api_request appendString: [self scrubString:artist]];
    [api_request appendString:@"&method=track.scrobble"];
    [api_request appendString:@"&sk="];
    [api_request appendString:self.sessionKey];
    [api_request appendString:@"&timestamp="];
    [api_request appendString:dateString];
    [api_request appendString:@"&track="];
    [api_request appendString: [self scrubString:song]];
    [api_request appendString:@"&api_sig="];
    [api_request appendString:api_sig_hashed];
    
    [self debugLog:@"API Request:"];
    [self debugLog:api_request];
    
    //Set the URL
    NSURL *apiURL = [NSURL URLWithString:@"https://ws.audioscrobbler.com/2.0/"];
    
    //Create a URL request for the URL. We want it to be a POST with the conent of the request string and in the right
    //content type
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: apiURL];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [NSData dataWithBytes:[api_request UTF8String] length:[api_request length]]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    //Get the response from the server
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //Convert the response to a string
    NSString *responseString = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
    
    [self debugLog:responseString];
    
    //We want to see if this Scrobble call failed or succeeded
    NSRange startRange = [responseString rangeOfString:@"<lfm status=\"ok\">"];
    
    if (startRange.length > 0) {
        
        [self debugLog:@"Call suceeded"];
        
        return TRUE;
        
    } else {
        
        [self debugLog:@"Call failed"];
        
        
        return FALSE;
        
    }
    
    
    
}

- (BOOL) startSession {
    //The goal of this method is to authenticate with Last.FM and get a session key
    
    [self debugLog:@"Entered startSession"];
    
    //Build auth.getMobileSession SIG
    NSMutableString *api_sig = [NSMutableString string];
    [api_sig appendString:@"api_key"];
    [api_sig appendString:self.APIKey];
    [api_sig appendString:@"methodauth.getMobileSession"];
    [api_sig appendString:@"password"];
    [api_sig appendString:self.password];
    [api_sig appendString:@"username"];
    [api_sig appendString:self.username];
    [api_sig appendString:self.APISecret];
    
    //Hash the sig
    NSString *api_sig_hashed = [self MD5StringOfString:api_sig];
    
    [self debugLog:@"API Sig (raw):"];
    [self debugLog:api_sig];
    [self debugLog:@"API Sig (hashed):"];
    [self debugLog:api_sig_hashed];
    
    //Create the request string
    NSMutableString *api_request = [NSMutableString string];
    [api_request appendString:@"method=auth.getMobileSession&username="];
    [api_request appendString:self.username];
    [api_request appendString:@"&password="];
    [api_request appendString:self.password];
    [api_request appendString:@"&api_key="];
    [api_request appendString:self.APIKey];
    [api_request appendString:@"&api_sig="];
    [api_request appendString:api_sig_hashed];
    
    [self debugLog:@"API Request:"];
    [self debugLog:api_request];
    
    //Set the URL
    NSURL *apiURL = [NSURL URLWithString:@"https://ws.audioscrobbler.com/2.0/"];
    
    //Create a URL request for the URL. We want it to be a POST with the conent of the request string and in the right
    //content type
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: apiURL];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [NSData dataWithBytes:[api_request UTF8String] length:[api_request length]]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    //Get the response from the server
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //Convert the response to a string
    NSString *responseString = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
    
    [self debugLog:responseString];
    
    NSRange startRange = [responseString rangeOfString:@"<key>"];
    
    
    if ( startRange.length > 0  ) {
        
        //This is evil, but Apple's XML parsing is fucking bullshit.
        //This extracts the key. No funny stuff.
        NSRange startRange = [responseString rangeOfString:@"<key>"];
        NSRange endRange = [responseString rangeOfString:@"</key>"];
        NSRange keyRange;
        keyRange.location = (startRange.location + startRange.length);
        keyRange.length = (endRange.location - keyRange.location);
        
        //We now have the key
        NSString *keyString = [responseString substringWithRange:keyRange];
        
        [self debugLog:keyString];
        
        //Load the key into our key property
        [self setSessionKey:keyString];
    }
    
    if ( [self.sessionKey isEqualToString:@"NOKEY"]) {
        //If we've made it this far and the sessionKey wasn't set
        //then something went wrong talking to Last.fm
        return FALSE;
    }
    return TRUE;
    
}

- (NSString*) MD5StringOfString:(NSString*) inputStr;
{
	//I lifted this from Tom Dalling:
    //http://www.tomdalling.com/blog/cocoa/md5-hashes-in-cocoa
    //Tom didn's specify any licensing but he published it on
    //the open web so I'd say it is fair game.
    //Thanks Tom!
    
    NSData* inputData = [inputStr dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char outputData[CC_MD5_DIGEST_LENGTH];
	CC_MD5([inputData bytes], [inputData length], outputData);
    
	NSMutableString* hashStr = [NSMutableString string];
	int i = 0;
	for (i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
		[hashStr appendFormat:@"%02x", outputData[i]];
    
	return hashStr;
}

- (void) debugLog: (NSString*) stringToLog {
    
    if ( self.isInDebug == TRUE) {
        
        NSLog(@"%@", stringToLog);
    }
    
}


@end
