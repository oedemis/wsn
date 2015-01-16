configuration EasyDisseminationAppC{
}
implementation{
  components MainC;
  EasyDisseminationC.Boot -> MainC;
  components LedsC;
  EasyDisseminationC.Leds -> LedsC;
  components new TimerMilliC();
  EasyDisseminationC.Timer -> TimerMilliC;

  components EasyDisseminationC;
  components DisseminationC;
  EasyDisseminationC.DisseminationControl -> DisseminationC;

  components new DisseminatorC(uint16_t, 0x1234) as Diss16C;
  EasyDisseminationC.Value1 -> Diss16C;
  EasyDisseminationC.Update1 -> Diss16C;
  components new DisseminatorC(uint8_t, 0x5678) as Diss8C;
  EasyDisseminationC.Value2 -> Diss8C;
  EasyDisseminationC.Update2 -> Diss8C;

  components ActiveMessageC;
  EasyDisseminationC.RadioControl -> ActiveMessageC;
}