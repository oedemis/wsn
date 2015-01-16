#include <Timer.h>

module EasyDisseminationC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli>;

  uses interface StdControl as DisseminationControl;
  uses interface DisseminationValue<uint16_t> as Value1;   // Consumer
  uses interface DisseminationUpdate<uint16_t> as Update1; // Producer
  uses interface DisseminationValue<uint8_t> as Value2;
  uses interface DisseminationUpdate<uint8_t> as Update2;

  uses interface SplitControl as RadioControl;
}
implementation {
  uint16_t counter1;
  uint8_t counter2;
	
  task void showCounter() {
    if (counter1 & 0x1)
      call Leds.led0On();
    else
      call Leds.led0Off();

    if (counter2 & 0x1)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }
  
  event void Timer.fired() {
    if ( TOS_NODE_ID  == 1 ) {
      counter1 = counter1 + 1;
      counter2 = counter2 + 1;
      call Update1.change(&counter1);
      call Update2.change(&counter2);
    }
  }
  
  event void Value1.changed() {
    const uint16_t* newVal = call Value1.get();
    if (TOS_NODE_ID != 1) {
      counter1 = *newVal;
    }
    post showCounter();
  }

  event void Value2.changed() {
    const uint8_t* newVal = call Value2.get();
    if (TOS_NODE_ID != 1) {
      counter2 = *newVal;
    }
    post showCounter();
  }
  
  event void Boot.booted() {
    call RadioControl.start();
  }
  
  event void RadioControl.startDone(error_t err) {
    if (err != SUCCESS) 
      call RadioControl.start();
    else {
      call DisseminationControl.start();
      counter1 = counter2 = 0;
      if ( TOS_NODE_ID  == 1 ) 
        call Timer.startPeriodic(2000);
    }
  }

  event void RadioControl.stopDone(error_t er) {}
  
  	
}