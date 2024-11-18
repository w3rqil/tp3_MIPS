import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext
import serial
import subprocess

class ModernUARTApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Interfaz UART Moderna")
        self.root.geometry("600x600")
        self.root.configure(bg="#F5F5F5")
        self.root.resizable(False, False)

        # Variables de puerto y baudrate
        self.port = tk.StringVar()
        self.baudrate = tk.IntVar(value=19200)

        # Estilo y fuente
        self.font_style = ("Helvetica", 11)
        self.btn_font = ("Helvetica", 10, "bold")

        # Título
        title_label = tk.Label(
            root, text="Configuración de UART", bg="#F5F5F5", fg="#3B82F6", font=("Helvetica", 16, "bold")
        )
        title_label.pack(pady=10)

        # Marco de configuración de UART
        config_frame = tk.Frame(root, bg="#F5F5F5")
        config_frame.pack(pady=10)

        tk.Label(config_frame, text="Puerto:", bg="#F5F5F5", fg="#1E293B", font=self.font_style).grid(row=0, column=0, pady=5, padx=5, sticky="e")
        self.port_entry = tk.Entry(config_frame, textvariable=self.port, bg="#E2E8F0", fg="#000", font=self.font_style, relief="flat")
        self.port_entry.grid(row=0, column=1, pady=5, padx=5)

        tk.Label(config_frame, text="Baudrate:", bg="#F5F5F5", fg="#1E293B", font=self.font_style).grid(row=1, column=0, pady=5, padx=5, sticky="e")
        self.baudrate_entry = tk.Entry(config_frame, textvariable=self.baudrate, bg="#E2E8F0", fg="#000", font=self.font_style, relief="flat")
        self.baudrate_entry.grid(row=1, column=1, pady=5, padx=5)

        self.connect_button = tk.Button(root, text="Conectar", command=self.connect_serial, bg="#3B82F6", fg="white", font=self.btn_font, relief="flat", borderwidth=0)
        self.connect_button.pack(pady=10)

        # Campo para mostrar el contenido del archivo .asm
        file_label = tk.Label(root, text="Contenido del archivo .asm:", bg="#F5F5F5", fg="#1E293B", font=("Helvetica", 12))
        file_label.pack(pady=5)

        self.asm_text = scrolledtext.ScrolledText(root, width=70, height=15, bg="#F0F4F8", fg="#000", wrap="word", font=self.font_style)
        self.asm_text.pack(pady=5)

        self.load_button = tk.Button(root, text="Cargar Archivo .asm", command=self.load_asm_file, bg="#3B82F6", fg="white", font=self.btn_font, relief="flat", borderwidth=0)
        self.load_button.pack(pady=10)

        # Marco de botones de control
        control_frame = tk.Frame(root, bg="#F5F5F5")
        control_frame.pack(pady=10)

        self.load_program_button = self.create_button(control_frame, "LOAD PROGRAM", self.load_program, 0, 0)
        self.debug_mode_button = self.create_button(control_frame, "DEBUG MODE", lambda: self.send_uart(0b00000010), 0, 1)
        self.continuous_mode_button = self.create_button(control_frame, "CONTINUOUS MODE", lambda: self.send_uart(0b00000100), 1, 0)
        self.step_button = self.create_button(control_frame, "STEP", lambda: self.send_uart(0b00001000), 1, 1)

        self.end_debug_mode_button = tk.Button(root, text="END DEBUG MODE", command=lambda: self.send_uart(0b00010000), bg="#3B82F6", fg="white", font=self.btn_font, relief="flat", borderwidth=0)
        self.end_debug_mode_button.pack(pady=10)

        # Objeto serial (sin conexión inicial)
        self.ser = None
        self.bin_file_path = None

    # Método para crear botones con esquinas redondeadas
    def create_button(self, parent, text, command, row, col):
        button = tk.Button(parent, text=text, command=command, bg="#3B82F6", fg="white", font=self.btn_font, relief="flat", borderwidth=0)
        button.grid(row=row, column=col, padx=10, pady=5)
        return button

    # Método para conectar al puerto serie
    def connect_serial(self):
        try:
            self.ser = serial.Serial(
                port=self.port.get(),
                baudrate=self.baudrate.get(),
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                bytesize=serial.EIGHTBITS
            )
            messagebox.showinfo("Conexión", "Conexión establecida correctamente")
            print(f"Conexión establecida en el puerto: {self.port.get()} con baudrate: {self.baudrate.get()}")
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo conectar: {str(e)}")
            print(f"Error de conexión: {str(e)}")

    # Método para cargar y mostrar un archivo .asm
    def load_asm_file(self):
        filepath = filedialog.askopenfilename(filetypes=[("ASM files", "*.asm")])
        if not filepath:
            return

        # Mostrar el contenido del archivo .asm en la GUI
        try:
            with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read()
                self.asm_text.delete(1.0, tk.END)
                self.asm_text.insert(tk.END, content)
                print("Archivo .asm cargado y mostrado en pantalla")
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo leer el archivo: {str(e)}")
            print(f"Error al leer el archivo .asm: {str(e)}")

        # Convertir archivo .asm a binario
        self.bin_file_path = filepath.replace(".asm", ".bin")
        try:
            subprocess.run(["python3", "asm_to_bin.py", filepath, self.bin_file_path], check=True)
            messagebox.showinfo("Éxito", "Archivo procesado y convertido a binario")
            print("Archivo .asm convertido a binario con éxito")
        except subprocess.CalledProcessError as e:
            messagebox.showerror("Error", f"No se pudo procesar el archivo: {str(e)}")
            print(f"Error al convertir el archivo .asm a binario: {str(e)}")

    # Método para enviar datos por UART
    def send_uart(self, data):
        if self.ser and self.ser.is_open:
            self.ser.write(data.to_bytes(1, byteorder='big'))
            messagebox.showinfo("Enviado", f"Se enviaron los datos: {bin(data)}")
            print(f"Datos enviados por UART: {bin(data)}")
        else:
            messagebox.showerror("Error", "No hay conexión UART establecida")
            print("Error: No hay conexión UART establecida")

    # Método para cargar el programa y enviar el archivo binario
    def load_program(self):
        if not self.bin_file_path:
            messagebox.showerror("Error", "No se ha cargado ningún archivo .asm")
            print("Error: No se ha cargado ningún archivo .asm")
            return

        # Enviar LOAD PROGRAM byte
        self.send_uart(0b00000001)

        # Enviar archivo binario por UART en bloques de 8 bits
        try:
            with open(self.bin_file_path, "rb") as bin_file:
                byte = bin_file.read(1)
                while byte:
                    self.ser.write(byte)
                    byte = bin_file.read(1)
            messagebox.showinfo("Enviado", "Archivo binario enviado con éxito")
            print("Archivo binario enviado por UART con éxito")
        except Exception as e:
            messagebox.showerror("Error", f"Error al enviar el archivo binario: {str(e)}")
            print(f"Error al enviar el archivo binario: {str(e)}")

# Inicializar la aplicación
if __name__ == "__main__":
    root = tk.Tk()
    app = ModernUARTApp(root)
    root.mainloop()
