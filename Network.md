- ■ Interface: The term interface port refers to the physical network connector. The term

	interface or link refers to the logical instance of a network interface port, as seen and con

	figured by the OS. (Not all OS interfaces are backed by hardware: some are virtual.)

- ■ Packet: The term packet refers to a message in a packet-switched network, such as IP

	packets.

- ■ Frame: A physical network-level message, for example an Ethernet frame.

- ■ Socket: An API originating from BSD for network endpoints.

- ■ Bandwidth: The maximum rate of data transfer for the network type, usually measured

	in bits per second. “100 GbE” is Ethernet with a bandwidth of 100 Gbits/s. There may be

	bandwidth limits for each direction, so a 100 GbE may be capable of 100 Gbits/s transmit

	and 100 Gbit/s receive in parallel (200 Gbit/sec total throughput).

- ■ Throughput: The current data transfer rate between the network endpoints, measured in

	bits per second or bytes per second.

- ■ Latency: Network latency can refer to the time it takes for a message to make a round-trip
	
	between endpoints, or the time required to establish a connection (e.g., TCP handshake),
	
	excluding the data transfer time that follows.

Messages at different layers also use different terminology. Using the OSI model: at the transport
layer a message is a segment or datagram; at the network layer a message is a packet; and at the data
link layer a message is a frame.