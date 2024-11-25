import tkinter as tk    
from tkinter import scrolledtext, messagebox, filedialog, ttk
import serial
import subprocess
import serial.tools.list_ports
import time


SENDING_INSTRUCTIONS  = bytes([0b00000001])
DEBUG_MODE            = bytes([0b00000010])
CONTINOUS_MODE        = bytes([0b00000100])
STEP_MODE             = bytes([0b00001000])
END_DEBUG_MODE        = bytes([0b00010000])
PORT = '/dev/ttyUSB1'
def connect_serial():
    global ser 
    selected_port = ports_combobox.get()  # Obtener el puerto seleccionado del Combobox
    try:
        ser = serial.Serial(
            port=selected_port, 
            baudrate=19200,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS,
        )
        messagebox.showinfo("Connection", "Connected to " + selected_port)
        print("Connected to " + selected_port)
    except Exception as e:
        messagebox.showerror("Connection", "Error connecting to " + selected_port)
        print("Error connecting to " + selected_port + f" {str(e)} ")


def load_asm_file():
    global bin_file_path
    filepath = filedialog.askopenfilename(filetypes=[("ASM files", "*.asm")])
    if not filepath:
        return
    try:
        with open(filepath, "r", encoding='utf-8') as file:
            content = file.read()
            asm_text.delete(1.0, tk.END)
            asm_text.insert(tk.END, content)
            print(".asm file loaded")
    except:
        messagebox.showerror("File", "Error loading .asm file")
        print("Error loading file")

    bin_file_path = filepath.replace(".asm", ".bin")
    try:
        subprocess.run(["python3", "asm_to_bin.py", filepath, bin_file_path], check=True)
        messagebox.showinfo("File", "File converted to .bin")
        print("File converted to .bin")
    except subprocess.CalledProcessError as e:
        messagebox.showerror("File", "Error converting file to .bin")
        print("Error converting file to .bin")

def send_uart(ser, data):
    if ser and ser.is_open:
        ser.write(data)
        messagebox.showinfo("Data sent", f"Data sent: {data}")
        print("Data sent", f"Data sent: {str(data)}")
    else:
        messagebox.showerror("Connection", "Not connected to serial port")
        print("Not connected to serial port")

    receive_uart()

def get_ports():
    ports = serial.tools.list_ports.comports()
    ports_list = [port.device for port in ports]

    ports_combobox['values'] = ports_list
    if ports_list:
        ports_combobox.current(0)
    else:
        messagebox.showinfo("Ports", "No ports available")

def load_program():
    # if not bin_file_path:
    #     messagebox.showerror("File", "No .bin file loaded")
    if not bin_file_path:
        messagebox.showerror("File", "No .asm file loaded")
        print("No .asm file loaded")
        return
    # Enviar LOAD PROGRAM byte
    ser.write(SENDING_INSTRUCTIONS)

    try:
        with open(bin_file_path, "rb") as bin_file:
            data = bin_file.read(1)
            # print(f"data: {data}")
            while data:
                ser.write(data)
                # print(f"data: {data}")
                # time.sleep(0.01)                        # Pausa de 10 ms
                data = bin_file.read(1)
        messagebox.showinfo("File", "Program loaded")
        print("Program loaded")
    except Exception as e:
        messagebox.showerror("File", f"Error loading program: {str(e)}")
        print(f"Error loading program: {str(e)}")

    # while(ser.in_waiting > 0):
    #     rcv = ser.read(1)
    #     print(f"Received: {rcv.hex()}")
    # print("se termino de recibir data")

def receive_uart():
    # recibe el dato A de 32 bits y actualiza la tabla de registros
    id_ex_data = receive_data("ID_EX", ser)
    if id_ex_data == -1:
        print("Error receiving ID_EX data")
        return
    ex_mem_data = receive_data("EX_MEM", ser)
    if ex_mem_data == -1:
        print("Error receiving EX_MEM data")
        return
    memory_data = receive_data("MEMORY", ser)
    if memory_data == -1:
        print("Error receiving MEMORY data")
        return
    registers_data = receive_data("REGISTERS", ser)
    if registers_data == -1:
        print("Error receiving REGISTERS data")
        return
    control_data = receive_data("CONTROL", ser)
    if control_data == -1:
        print("Error receiving CONTROL data")
        return
    
    id_ex_decoded = decode_data("ID_EX", id_ex_data)
    ex_mem_decoded = decode_data("EX_MEM", ex_mem_data)
    data_decoded = decode_data("DATA", memory_data)
    registers_decoded = decode_data("REGISTERS", registers_data)
    control_decoded = decode_data("CONTROL", control_data)

    #  Actualizar las tablas con los datos recibidos
        # Actualizar la tabla ID_EX
    id_ex_table.delete(*id_ex_table.get_children())  # Limpiar la tabla
    for key, value in id_ex_decoded.items():
        id_ex_table.insert("", "end", values=(key, value))

    # Actualizar la tabla EX_MEM
    ex_mem_table.delete(*ex_mem_table.get_children())  # Limpiar la tabla
    for key, value in ex_mem_decoded.items():
        ex_mem_table.insert("", "end", values=(key, value))

    # Actualizar la tabla CONTROL
    control_table.delete(*control_table.get_children())  # Limpiar la tabla
    for key, value in control_decoded.items():
        control_table.insert("", "end", values=(key, value))

    # Actualizar la tabla DATA MEMORY
    address = data_decoded["Address"]
    data = data_decoded["Data"]
    
    # Buscar la fila que corresponde a la dirección y actualizar el valor
    for item in data_table.get_children():
        item_values = data_table.item(item, "values")
        if int(item_values[0]) == address:  # Comparar la dirección
            data_table.item(item, values=(address, data))  # Actualizar el valor
            break

    # Actualizar la tabla REGISTERS
    address = registers_decoded["Address"]
    register = registers_decoded["Register"]
    write_enable = registers_decoded["Write enable"]

    if(write_enable):
        # Buscar la fila que corresponde al registro y actualizar el valor
        for item in registers_table.get_children():
            item_values = registers_table.item(item, "values")
            if int(item_values[0]) == address:
                registers_table.item(item, values=(address, register))
                break

    print("Tablas actualizadas correctamente")

    
    
def receive_data(type, ser):
    if type == "ID_EX":
        print("receiving ID_EX...")
        rcv = ser.read(18) # Lee los 18 bytes (144 bits) de la ID_EX
    elif type == "EX_MEM":
        print("receiving EX_MEM...")
        rcv = ser.read(4) # Lee los 4 bytes (32 bits) de la EX_MEM
    elif type == "MEMORY":
        print("receiving Data memory...")
        rcv = ser.read(5) # Lee los 5 bytes (40 bits) de la MEMORY
    elif type == "REGISTERS":
        print("receiving register...")
        rcv = ser.read(5) # Lee los 5 bytes (40 bits) de los REGISTERS
    elif type == "CONTROL":
        print("receiving control...")
        rcv = ser.read(2) # Lee los 3 bytes (24 bits) de los CONTROL
    else:
        print("Invalid type")
        return -1
    
    return rcv

def decode_data(type, data):
    # Convertir los bytes en un solo entero
    concatenated_data = int.from_bytes(data, byteorder='big')
    
    if type == "ID_EX":
        # Convertir los bytes en un solo entero
        concatenated_data = int.from_bytes(data, byteorder='big')
        return {
            "RA": (concatenated_data >> 112) & 0xFFFFFFFF,                  # 32 bits en formato decimal
            "RB": (concatenated_data >> 80) & 0xFFFFFFFF,                   # 32 bits en formato decimal
            "Opcode": format((concatenated_data >> 74) & 0x3F, '06b'),      # 6 bits en formato binario
            "rs": format((concatenated_data >> 69) & 0x1F, '05b'),          # 5 bits en formato binario
            "rt": format((concatenated_data >> 64) & 0x1F, '05b'),          # 5 bits en formato binario
            "rd": format((concatenated_data >> 59) & 0x1F, '05b'),          # 5 bits en formato binario
            "shamt": format((concatenated_data >> 54) & 0x1F, '05b'),       # 5 bits en formato binario
            "funct": format((concatenated_data >> 48) & 0x3F, '06b'),       # 6 bits en formato binario
            "imm": (concatenated_data >> 32) & 0xFFFF,                      # 16 bits en formato decimal
            "jump_address": concatenated_data & 0xFFFFFFFF                  # 32 bits en formato decimal
        }
    elif type == "EX_MEM":
        return {
            "ALU result": int.from_bytes(data[0:4], byteorder='big')
        }
    elif type == "DATA":
        return {
            "Data": int.from_bytes(data[0:4], byteorder='big'), # 32 bits en formato decimal
            "Address": data[4] % 32  # 8 bits en formato decimal
        }
    elif type == "REGISTERS":
        concatenated_data = int.from_bytes(data, byteorder='big')
        return {
            "Register": (concatenated_data >> (8)) & 0xFFFFFFFF, # 32 bits en formato decimal
            "Address": (concatenated_data >> 3) & 0x1F,  # 5 bits en formato decimal
            "Write enable": (concatenated_data >> (2)) & 0x1, # 1 bit en formato decimal
        }
    elif type == "CONTROL":
        concatenated_data = int.from_bytes(data, byteorder='big')
        return {
            "jump": (concatenated_data >> 23) & 0x1, # 1 bit en formato decimal
            "branch": (concatenated_data >> 22) & 0x1, # 1 bit en formato decimal
            "regDst": (concatenated_data >> 21) & 0x1, # 1 bit en formato decimal
            "mem2Reg": (concatenated_data >> 20) & 0x1, # 1 bit en formato decimal
            "memRead": (concatenated_data >> 19) & 0x1, # 1 bit en formato decimal
            "memWrite": (concatenated_data >> 18) & 0x1, # 1 bit en formato decimal
            "inmediate flag": (concatenated_data >> 17) & 0x1, # 1 bit en formato decimal
            "sign flag": (concatenated_data >> 16) & 0x1, # 1 bit en formato decimal
            "regWrite": (concatenated_data >> 15) & 0x1, # 1 bit en formato decimal
            "aluSrc": format((concatenated_data >> 13) & 0x3, '02b'), # 2 bits en formato binario
            "width": format((concatenated_data >> 11) & 0x3, '02b'), # 2 bits en formato binario
            "aluOp": format((concatenated_data >> 9) & 0x3, '02b'), # 2 bits en formato binario
            "fwA": format((concatenated_data >> 7) & 0x3, '02b'), # 2 bits en formato binario
            "fwB": format((concatenated_data >> 5) & 0x3, '02b') # 2 bits en formato binario
        }
    return {}  # Devolver un diccionario vacío si el tipo no coincide


ventana = tk.Tk()
ventana.title("DEBUG UNIT")

baudrate = tk.IntVar(value=19200)
port = tk.StringVar(value='/dev/ttyUSB1')

id_ex_registers = {
    "RA": 0,
    "RB": 0,
    "Opcode": 0,
    "rs": 0,
    "rt": 0,
    "rd": 0,
    "shamt": 0,
    "funct": 0,
    "imm": 0,
    "jump_address": 0
    }
ex_mem_registers = {
    "ALU result": 0
}

control_signals = {
    "jump": 0,
    "branch": 0,
    "regDst": 0,
    "mem2Reg": 0,
    "memRead": 0,
    "memWrite": 0,
    "inmediate flag": 0,
    "sign flag": 0,
    "regWrite": 0,
    "aluSrc": 0,
    "width": 0,
    "aluOp": 0,
    "fwA": 0,
    "fwB": 0
}

data_memory = {
    "Address": 0,
    "Data": 0
}

registers_memory = {
    "Address": 0,
    "Register": 0,
    "Write enable": 0
}

get_ports_button = tk.Button(ventana, text="GET PORTS", command=get_ports)
get_ports_button.grid(row=0, column=0, pady=5, padx=5)
ports_combobox = ttk.Combobox(ventana, values=[port.device for port in serial.tools.list_ports.comports()])
ports_combobox.grid(row=0, column=1, pady=5, padx=5)

tk.Label(ventana, text="BAUDRATE:").grid(row=1, column=0, padx=5, pady=5)
baudrate_entry = tk.Entry(ventana, textvariable=baudrate, width=20)
baudrate_entry.grid(row=1, column=1,padx=5,pady=5)

connect_button = tk.Button(ventana, text="CONNECT", command=connect_serial)
connect_button.grid(row=2,column=0, columnspan=2, pady=10, padx=5, sticky="ew")

asm_button = tk.Button(ventana, text="Upload .asm file", command=load_asm_file)
asm_button.grid(row=3,column=0, columnspan=2, pady=10, padx=5, sticky="ew")

tk.Label(ventana, text="ASM FILE:").grid(row=4, column=0, padx=5, pady=5)

asm_text = scrolledtext.ScrolledText(ventana, width=40, height=10)
asm_text.grid(row=5, column=0, columnspan=2, padx=5, pady=5) 

load_button = tk.Button(ventana, text="LOAD", command=(load_program))
load_button.grid(row=6,column=0, columnspan=2, pady=10, padx=5, sticky="ew")

continous_button = tk.Button(ventana, text="CONTINOUS", command=lambda: send_uart(ser, CONTINOUS_MODE))
continous_button.grid(row=0,column=3, pady=10, padx=5, sticky="ew")

debug_button = tk.Button(ventana, text="DEBUG", command=lambda: ser.write(DEBUG_MODE))
debug_button.grid(row=1,column=3, pady=10, padx=5, sticky="ew")

step_button = tk.Button(ventana, text="STEP", command=lambda: send_uart(ser, STEP_MODE))
step_button.grid(row=0,column=4, pady=10, padx=5, sticky="ew")

end_debug_button = tk.Button(ventana, text="END DEBUG", command=lambda: send_uart(ser, END_DEBUG_MODE))
end_debug_button.grid(row=1,column=4, pady=10, padx=5, sticky="ew")

tk.Label(ventana, text="DATA MEMORY").grid(row=2, column=3, pady=5, padx=5)

data_frame = tk.Frame(ventana)
data_table = ttk.Treeview(data_frame, columns=("address", "value"), show='headings')
data_table.heading("address", text="Address")
data_table.heading("value", text="Data")
data_table.column("address", width=60)
data_table.column("value", width=60)
for i in range(32):
    data_table.insert("", tk.END, values=((i), (0)))

data_table.pack()
data_frame.grid(row=3, column=3, rowspan=4, padx=5, pady=5)

tk.Label(ventana, text="REGISTERS MEMORY").grid(row=2, column=4,pady=5, padx=5)
registers_frame = tk.Frame(ventana)
registers_table = ttk.Treeview(registers_frame, columns=("address", "value"), show='headings')
registers_table.heading("address", text="Address")
registers_table.heading("value", text="Register")
registers_table.column("address", width=60)
registers_table.column("value", width=60)
for i in range(32):
    registers_table.insert("", tk.END, values=((i), (0)))

registers_table.pack()
registers_frame.grid(row=3, column=4, rowspan=4, padx=5, pady=5)

# Tabla para ID_EX
tk.Label(ventana, text="ID_EX").grid(row=0, column=5, pady=5, padx=5)
id_ex_frame = tk.Frame(ventana)
id_ex_table = ttk.Treeview(id_ex_frame, columns=("address", "value"), show='headings')
id_ex_table.heading("address", text="Address")
id_ex_table.heading("value", text="Value")
id_ex_table.column("address", width=70)
id_ex_table.column("value", width=70)
# Recorrer las claves y valores del diccionario id_ex_registers
for key, value in id_ex_registers.items():
    id_ex_table.insert("", tk.END, values=(key, value))

id_ex_table.pack(fill=tk.BOTH, expand=1)
id_ex_frame.grid(row=1, column=5, rowspan=7, padx=5, pady=5, sticky="nsew")

# Tabla para EX_MEM
tk.Label(ventana, text="EX_MEM").grid(row=0, column=6, pady=5, padx=5)
ex_mem_frame = tk.Frame(ventana)
ex_mem_table = ttk.Treeview(ex_mem_frame, columns=("address", "value"), show='headings')
ex_mem_table.heading("address", text="Address")
ex_mem_table.heading("value", text="Value")
ex_mem_table.column("address", width=70)
ex_mem_table.column("value", width=70)
# Recorrer las claves y valores del diccionario ex_mem_registers
for key, value in ex_mem_registers.items():
    ex_mem_table.insert("", tk.END, values=(key, value))

ex_mem_table.pack(fill=tk.BOTH, expand=1)
ex_mem_frame.grid(row=1, column=6, rowspan=7, padx=5, pady=5, sticky="nsew")

# Tabla para CONTROL
tk.Label(ventana, text="CONTROL").grid(row=0, column=7, pady=5, padx=5)
control_frame = tk.Frame(ventana)
control_table = ttk.Treeview(control_frame, columns=("address", "value"), show='headings')
control_table.heading("address", text="Address")
control_table.heading("value", text="Value")
control_table.column("address", width=70)
control_table.column("value", width=70)
# Recorrer las claves y valores del diccionario control_signals
for key, value in control_signals.items():
    control_table.insert("", tk.END, values=(key, value))

control_table.pack(fill=tk.BOTH, expand=1)
control_frame.grid(row=1, column=7, rowspan=7, padx=5, pady=5, sticky="nsew")


ser = None
# bin_file_path = None

ventana.mainloop()