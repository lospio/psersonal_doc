1. 单个packet限定大小
	```cpp
	  /*

		Big packets are handled by splitting them in packets of MAX_PACKET_LENGTH
	
		length. The last packet is always a packet that is < MAX_PACKET_LENGTH.
	
		(The last packet may even have a length of 0)
	
	  */
	
	  while (len >= MAX_PACKET_LENGTH) {
	
		const ulong z_size = MAX_PACKET_LENGTH;
	
		int3store(buff, z_size);
	
		buff[3] = (uchar)net->pkt_nr++;
	
		if (net_write_buff(net, buff, NET_HEADER_SIZE) ||
	
			net_write_buff(net, packet, z_size)) {
	
		  return true;
	
		}
	
		packet += z_size;
	
		len -= z_size;
	
	  }
	```