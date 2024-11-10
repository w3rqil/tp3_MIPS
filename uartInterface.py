import time
import serial
import random

BAUDRATE = 19200
PORT = '/dev/ttyUSB1'

ser = serial.Serial(
    port=PORT, 
    baudrate=BAUDRATE,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
)

# ALU commands
ALU_DATA_A_OP =     bytes([0b00001000]) #dato A
ALU_DATA_B_OP =     bytes([0b00010000]) #datoB
ALU_OPERATOR_OP =   bytes([0b00100000]) #OPERACION

# ALU operations
ADD_OP = bytes([0b00100000])
SUB_OP = bytes([0b00100010])
AND_OP = bytes([0b00100100])
OR_OP  = bytes([0b00100101])
XOR_OP = bytes([0b00100110])
SRA_OP = bytes([0b00000011])
SRL_OP = bytes([0b00000010])
NOR_OP = bytes([0b00100111])

# Error Codes
ALU_OPERATOR_ERROR = bytes([0xa1])
INVALID_OPCODE = bytes([0xff])

random.seed(0)

# Function to send data to ALU and get the result
def get_value_alu_test(operator, a_value, b_value):
    
    
    # Send first operand (A)
    #time.sleep(0.1)
    ser.write(ALU_DATA_A_OP) #dato A
    ser.write(bytes([a_value])) #valor
    #time.sleep(0.1)
    
    # Send second operand (B)
    ser.write(ALU_DATA_B_OP) #dato B
    # time.sleep(0.1)
    ser.write(bytes([b_value])) #valor
    #time.sleep(0.1)
    
    # Set operator
    ser.write(ALU_OPERATOR_OP)  #operacion
    # time.sleep(0.1)
    ser.write(operator) # type
    #time.sleep(0.1)

    
    # Receive result
    recv = ser.read(1)
    return recv

# Test all operations
def test_all_operations():
    time.sleep(0.1)
    val = get_value_alu_test(ADD_OP, 0b00001010, 0b00001000)
    #ser.write(ALU_DATA_A_OP)
    #val = ser.read(1)clear
    print(f" ADD Result: {val}")

    val = get_value_alu_test(SUB_OP, 0b00001000, 0b00000001)
    print(f" SUB Result: {val}")



    
# Run all tests
test_all_operations()

ser.close()