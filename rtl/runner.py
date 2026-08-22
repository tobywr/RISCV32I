import serial
ser = serial.Serial('/dev/ttyUSB2', 115200)  # match your actual baud rate
while True:
    b = ser.read(1)
    print(b, end=' ')