// LightController.h
#ifndef __LIGHT_CONTROLLER_H__
#define __LIGHT_CONTROLLER_H__
#include "WProgram.h"
#include <pins_arduino.h>

#define kGlowActivity 0
#define kCandleActivity 1
#define kRandomActivity 2
#define kAlertActivity 3
#define kStopActivity 4

#define kLightControllerCommandMax 12

class LightController
{
	public:
	
		LightController( int redPin, int greenPin, int bluePin );
		void start ();
		boolean empty ();
		void accept ( char clu );
		void updateLights ();
		void getCommands ( char buffer[80] );
		void doCommand ( char *command);
		void cycleBright ();
		void cycleSpeed ();
		void cycleRed();
		void cycleBlue();
		void cycleGreen();
		void candleEffect();
		void alertEffect();
		void glowEffect();
		void randomEffect();
		
//	protected:
	
		// Reflections of user choices
		
		int mCurrentActivity;
		int mCurrentBrightnessLevel;
		int mCurrentSpeedLevel;
		
		int mHasRed;
		int mHasGreen;
		int mHasBlue;
		
		// The values that are in use now.
		
		int mActualRedValue;
		int mActualBlueValue;
		int mActualGreenValue;
				
		unsigned long mLoopCount;
		unsigned long mActivityBeginCount;
		int mWalkSize;
		
		int mRedPin;
		int mGreenPin;
		int mBluePin;
		
		int mCommandCount;
		char mCommand[kLightControllerCommandMax+1];
		boolean doCommand ();

		void doGlow();
		void doStop();
		void doRandom();
		void doAlert();
		void doCandle();
		
		void present ();
};

#endif		

		
		