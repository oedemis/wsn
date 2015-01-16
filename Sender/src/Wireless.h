#ifndef WIRELESS_H
#define WIRELESS_H

/**
 * ------Sending a Message---------
 * nesC defines network types that transparently deal with endian issues for you
 */
 
// nx_struct define the message data format 
typedef nx_struct wireless_msg {
	nx_uint16_t counter;
} wireless_msg_t;

enum {
  // unique active message id 
  AM_WIRELESS_MSG = 23,
};

#endif /* WIRELESS_H */
