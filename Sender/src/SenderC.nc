#include "Timer.h"
#include "Wireless.h"


module SenderC{
   uses interface Leds;
   uses interface Boot;
   uses interface AMSend;
   uses interface Timer<TMilli> as TimerWireless;
   // many networking commands take long time (ms) -> non blocking way
   // As SplitControll -> eventgetrieben ActiveMessegeC
   uses interface SplitControl as AMControl; 
   uses interface Packet;
}
implementation{
	// store the packets content
	message_t packet;
	
	bool locked;
	uint16_t counter = 0;
	
	event void Boot.booted(){
		call AMControl.start();
	}
	
	event void AMControl.startDone(error_t err) {
	    if (err == SUCCESS) {
	      call TimerWireless.startPeriodic(250);
	    }
	    else {
	      call AMControl.start();
	    }
  	}
  	
  	event void AMControl.stopDone(error_t err) {
    	// do nothing
  	}
  	
  	event void TimerWireless.fired() {
  		counter++;
  		if (locked) {
      		return;
    	}
    	else {
    		// Get the packtets payload and cast it to your message type
    		wireless_msg_t* rcm = (wireless_msg_t*)call Packet.getPayload(&packet, sizeof(wireless_msg_t));
    		if (rcm == NULL) {
				return;
      		}
      		// store your data
      		rcm->counter = counter;
      		// Finally send packet with AMSend, returns if the request to send is succeeds
      		if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(wireless_msg_t)) == SUCCESS) {
				locked = TRUE;
      		}
		}
	}
	
	// Signaled in response to an accepted send request.
	 event void AMSend.sendDone(message_t* bufPtr, error_t error) {
	    if (&packet == bufPtr) {
	      locked = FALSE;
	    }
  	}
}