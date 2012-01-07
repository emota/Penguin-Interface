// LightController.cpp
//
// Control lighting effects
// Effects are glow, random, candle and alert
//
// The effect currently in place is determined by doCommand()
// which sets the values that control the light.
//
// Besides each of the four effects, each color can be toggled
// to be on or off. Each effect causes changes in the colors that
// are toggled on.
//
// The main loop calls updateLights() periodically. The action depends
// on the current settings and on the time. Each time is measured in units.
// Each call to updateLights() is a unit of time.
// 
#include "LightController.h"
#include <avr/pgmspace.h>
#include <string.h>

// Brightness is 0 through 0xFF
// These correspond to brightness levels 1, 2, 3
// Level 0 is off.
static int kBrightnessValues[] = { 0x0, 0x1F, 0x3F, 0xFF };

// These are used to translate between speed levels of 1, 2, 3
// and the number of time units in each of the effects.
// Speed level 0 is inactive.
static int kRandomPeriodValues[] = { 0, 20, 10, 5 }; 
static int kAlertPeriodValues[] = { 0, 20, 10, 5 };
static int kCandlePeriodValues[] = { 0, 200, 100, 50 };
static int kCandleColorVariation = 10;

static int randomUnder ( int top )
{
	return random ( top / 2, top );
}


LightController :: LightController( int redPin, int greenPin, int bluePin )
	: mRedPin(redPin), mGreenPin(greenPin), mBluePin(bluePin),
	mCurrentActivity(kGlowActivity), mCurrentBrightnessLevel(2), mCurrentSpeedLevel(2),
	mHasRed(true), mHasGreen(false), mHasBlue(false),
	mWalkSize(1)
{
}

void LightController :: accept ( char clu )
{
	size_t length = strlen ( mCommand );
	if ( strchr ( "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456780", clu ) 
		&& length < kLightControllerCommandMax )
	{
		mCommand[length++];
		mCommand[length] = '\0';
	}
	else if ( length > 0 )
	{
		doCommand();
		mCommand[0] = '\0';
	}
}		

void LightController :: getCommands ( char buffer[80] )
{
	buffer[0] = '\0';
	switch ( mCurrentActivity )
	{
		case kAlertActivity:
			strcat ( buffer, "alert" );
			break;
		case kGlowActivity:
			strcat ( buffer, "glow" );
			break;
		case kRandomActivity:
			strcat ( buffer, "random" );
			break;
		case kCandleActivity:
			strcat ( buffer, "candle" );
			break;
		default:
			break;
	}
	if ( mHasRed )
		strcat ( buffer, " redon" );
	else
		strcat ( buffer, " redoff" );
	if ( mHasGreen )
		strcat ( buffer, " greenon" );
	else
		strcat ( buffer, " greenoff" );
	if ( mHasBlue )
		strcat ( buffer, " blueon" );
	else
		strcat ( buffer, " blueoff" );
}
		
void LightController :: start ()
{
	mCommandCount = 0;
}

boolean LightController :: empty ()
{
	return mCommandCount == 0;
}

void LightController :: doCommand ( char *command )
{
	strcpy ( mCommand, command );
	doCommand();
}
	
boolean LightController :: doCommand ()
// For each command assign memeber values to be used in updateLights()
{	
	Serial.println ( mCommand );
	if ( ! strcmp ( mCommand, "alert" ) )
	{
		Serial.println ( "it's alert" );
		mCurrentActivity = kAlertActivity;
	}
	else if ( ! strcmp ( mCommand, "blueoff" ) )
		mHasBlue = false;
	else if ( ! strcmp ( mCommand, "blueon" ) )
		mHasBlue = true;
	else if ( ! strcmp ( mCommand, "bright1" ) )
		mCurrentBrightnessLevel = 1;
	else if ( ! strcmp ( mCommand, "bright2" ) )
		mCurrentBrightnessLevel = 2;
	else if ( ! strcmp ( mCommand, "bright3" ) )
		mCurrentBrightnessLevel = 3;
	else if ( ! strcmp ( mCommand, "candle" ) )
	{
		Serial.println ( "it's candle" );
		mCurrentActivity = kCandleActivity;
	}
	else if ( ! strcmp ( mCommand, "glow" ) )
	{
		Serial.println ( "its glow" );
		mCurrentActivity = kGlowActivity;
	}
	else if ( ! strcmp ( mCommand, "greenon" ) )
		mHasGreen = true;
	else if ( ! strcmp ( mCommand, "greenoff" ) )
		mHasGreen = false;
	else if ( ! strcmp ( mCommand, "random" ) )
	{
		Serial.println ( "it's random" );
		mCurrentActivity = kRandomActivity;
	}
	else if ( ! strcmp ( mCommand, "redon" ) )
		mHasRed = true;
	else if ( ! strcmp ( mCommand, "redoff" ) )
		mHasRed = false;
	else if ( ! strcmp ( mCommand, "speed1" ) )
		mCurrentSpeedLevel = 1;
	else if ( ! strcmp ( mCommand, "speed2" ) )
		mCurrentSpeedLevel = 2;
	else if ( ! strcmp ( mCommand, "speed3" ) )
		mCurrentSpeedLevel = 3;
	else if ( ! strcmp ( mCommand, "stop" ) )
		mCurrentActivity = kStopActivity;		
	else if ( ! strcmp ( mCommand, "get" ) )
		;	// Do nothing. Just to make request count go to 1 for update request
	else 
	{
		Serial.println();
		return false;
	}
	mCommandCount++;
	mActivityBeginCount = mLoopCount;
	return true;
}


void LightController :: updateLights()
{
	mLoopCount++;
	if ( (mLoopCount % 100) == 0 )
	{
//		Serial.print ( "update lights " );
//		Serial.println ( mCurrentActivity );
	}
	switch ( mCurrentActivity )
	{
		case kAlertActivity:
			doAlert();
			break;
		case kCandleActivity:
			doCandle();
			break;
		case kGlowActivity:
			doGlow();
			break;
		case kRandomActivity:
			doRandom();
			break;
		case kStopActivity:
			doStop();
			break;
	}
	present();
}
				
void LightController :: doGlow()
{
	mActualRedValue = kBrightnessValues[mCurrentBrightnessLevel];
	mActualGreenValue = kBrightnessValues[mCurrentBrightnessLevel];
	mActualBlueValue = kBrightnessValues[mCurrentBrightnessLevel];	
}

void LightController :: doStop()
{
	mActualRedValue = 0;
	mActualGreenValue = 0;
	mActualBlueValue = 0;
	mCurrentBrightnessLevel = 0;
}

void LightController :: doRandom()
{
	if ( mCurrentSpeedLevel == 0 )
		return;	
	if ( mWalkSize-- < 0 )
	{
		int periodValue = kRandomPeriodValues[mCurrentSpeedLevel];
		mWalkSize = randomUnder ( periodValue );
		mActualRedValue = randomUnder ( kBrightnessValues [mCurrentBrightnessLevel] );
		mActualBlueValue  = randomUnder ( kBrightnessValues [mCurrentBrightnessLevel] );
		mActualGreenValue = randomUnder ( kBrightnessValues [mCurrentBrightnessLevel] );
	}		
}

void LightController :: doCandle()
{
	if ( mCurrentSpeedLevel == 0 )
		return;	
	if ( mWalkSize-- < 0 )
	{
		int periodValue = kRandomPeriodValues[mCurrentSpeedLevel];
		mWalkSize = randomUnder ( periodValue );
		int brightness = kBrightnessValues [mCurrentBrightnessLevel];
		mActualRedValue = brightness + randomUnder ( kCandleColorVariation );
		mActualBlueValue  = randomUnder ( kCandleColorVariation );
		mActualGreenValue = randomUnder ( kCandleColorVariation );
	}		
}

void LightController :: doAlert()
{
	unsigned long periodLength = kAlertPeriodValues[ mCurrentSpeedLevel];
	int periodTime = mLoopCount % periodLength;
	int brightness = kBrightnessValues [mCurrentBrightnessLevel];
	unsigned long distanceFromBeginningOfPeriod = periodTime < periodLength / 2 
		? periodTime : periodLength - periodTime;
	brightness = distanceFromBeginningOfPeriod * brightness * 2 / periodLength;
	mActualRedValue = brightness;
	mActualGreenValue = brightness;
	mActualBlueValue = brightness;
}

void LightController :: present ()
{
	analogWrite ( mRedPin, mHasRed ? mActualRedValue : 0x0 );
	analogWrite ( mGreenPin, mHasGreen ? mActualGreenValue : 0x0 );
	analogWrite ( mBluePin, mHasBlue ? mActualBlueValue : 0x0 );
}

void LightController :: cycleBright ()
{
	mCurrentBrightnessLevel++;
	if ( mCurrentBrightnessLevel > 3 )
		mCurrentBrightnessLevel = 1;
	Serial.print ( "cycleBright to "); Serial.println ( mCurrentBrightnessLevel );
}

void LightController :: cycleSpeed ()
{
	mCurrentSpeedLevel++;
	if ( mCurrentSpeedLevel > 3 )
		mCurrentSpeedLevel = 1;
	Serial.print ( "cycleSpeed to "); Serial.println ( mCurrentSpeedLevel );
}

void LightController :: cycleRed()
{
	mHasRed = !mHasRed;
	Serial.print ( "cycleRed to " ); Serial.println ( mHasRed );
}
void LightController :: cycleBlue()
{
	mHasBlue = !mHasBlue;
	Serial.print ( "cycleBlue to " ); Serial.println ( mHasBlue );
}

void LightController :: cycleGreen()
{
	mHasGreen = !mHasGreen;
	Serial.print ( "cycleGreen to " ); Serial.println ( mHasGreen );
}



void LightController :: candleEffect()
{
	mCurrentActivity = kCandleActivity;
	Serial.println ( "candle" );
}

void LightController :: alertEffect()
{
	mCurrentActivity = kAlertActivity;
	Serial.println ( "alert" );
}

void LightController :: glowEffect()
{
	mCurrentActivity = kGlowActivity;
	Serial.println ( "glow" );
}

void LightController :: randomEffect()
{
	mCurrentActivity = kRandomActivity;
	Serial.println ( "random" );
}

