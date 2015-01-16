module EasyCollectionC {
	uses interface Boot;
	uses interface SplitControl as RadioControl;
	uses interface StdControl as RoutingControl;
	uses interface Send;
	uses interface Leds;
	uses interface Timer<TMilli>;
	uses interface RootControl;
	uses interface Receive;
}
implementation {
	message_t packet;
	bool sendBusy = FALSE;

	typedef nx_struct EasyCollectionMsg {
		nx_uint16_t data;
	} EasyCollectionMsg;

	event void Boot.booted() {
		call RadioControl.start();
	}

	event void RadioControl.startDone(error_t err) {
		if(err != SUCCESS) 
			call RadioControl.start();
		else {
			// Once we are sure that the radio is on,
			// Routing Sub-System to generate the collection tree
			call RoutingControl.start();
			if(TOS_NODE_ID == 1) 
				call RootControl.setRoot(); //Collector (Base station)
			else 
				call Timer.startPeriodic(2000); // other nodes generates every 2sec data and send it to the base station
		}
	}

	event void RadioControl.stopDone(error_t err) {
	}

	void sendMessage() {
		EasyCollectionMsg * msg = (EasyCollectionMsg * ) call Send.getPayload(&packet,
				sizeof(EasyCollectionMsg));
		msg->data = 0xAAAA;

		if(call Send.send(&packet, sizeof(EasyCollectionMsg)) != SUCCESS) 
			call Leds.led0On();
		else 
			sendBusy = TRUE;
	}

	event void Timer.fired() {
		call Leds.led2Toggle();
		if( ! sendBusy) 
			sendMessage();
	}

	event void Send.sendDone(message_t * m, error_t err) {
		if(err != SUCCESS) 
			call Leds.led0On();
		sendBusy = FALSE; 
	}

	 // receive event will be only called in the root of the tree, that is, in the base station.
	event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
		call Leds.led1Toggle(); // green
		return msg;
	}

}