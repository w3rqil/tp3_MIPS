# tp3_MIPS




# Pipeline

## instruction fetch

En esta etapa interactúan los módulos:
- program counter
- instructio_fetch
- xilinx_one_port_ram_async

La idea intuitiva de esta etapa es buscar instrucciones en la memoria de instrucciones y enviarlas al resto del pipeline.


## Instruction Decode

En esta etapa se decodifican las instrucciones, y se generan las respectivas señales de control para cada caso. En una primera instancia esta etapa solo generaba señales de control, pero a medida que se fue desarrollando el pipeline se tuvieron que agregar nuevas funciones. 
### Saltos
En la etapa instruction decode se realiza el manejo de saltos, en caso de que el salto sea inmediato, o la condición de salto se cumpla, se actualizan las señales "_o_jump, o_jump_cases y o_addr2jump_". La señal jump_cases cambia de estado y se utilizará luego para generar los stall necesarios en la hazard_detection_unit.
El calculo de la dirección de saltos varía en los distintos escenarios.
- JR o JALR: 
    - addr2jump= dato A
- BEQ o BNE
    - addr2jump = i_pcounter4 + (w_immediat << 2) + 4
- JAL o J
    - addr2jump = {i_pcounter4[NB_DATA-1:NB_DATA-4], i_instruction[25:0], 2'b00}

Es importante tener en cuenta que, a la hora de la ejecución de un programa en nuestro pipeline, siempre que se tenga una instrucción de salto se deberá agregar una instrucción "NOP" seguida de la misma. Esto se debe a que en el caso contrario va a ejecutar la instrucción de salto, y la etapa instruction_fetch va a enviar la siguiente instrucción antes de actualizar el program counter con la nueva dirección, generando que se ejecute una instrucción más antes de saltar.
Luego nos dimos cuenta que esto pudo haber sido arreglado generando un control de saltos en la etapa instruction_fetch y así evitando tener que utilizar una instrucción NOP después de cada salto.

### Escritura
En la etapa instruction_decode se realiza también, la escritura de nuvos valores en la memoria de registros. Estos valores provienen de la etapa write_back.


## Instruction Execute

En esta etapa se ejecutan las instrucciones realizando operaciones en la ALU y teniendo en cuenta las señales que provienen de la etapa instruction_decode.
Esta etapa se compone de tres multiplexores que interactúan tanto con las señales que provienen de las otras etapas, como con la unidad de cortocircuitos "forwarding_unit".

Los dos primeros multiplexores tienen en cuenta el estado de la unidad de cortocircuitos para determinar el valor los datos A y B. También teniendo en cuenta que en las operaciones tipo JAL y JARL no se realiza un cortocircuitos. 
En el caso especial del dato B, para cuando se tiene una operación "tipo inmediata" se da: dato B = valor inmediato.

El tercer multiplexor determina la dirección que se va a escribir en la etapa write_back. Cuando la entrada _"i_regDst"_ proveniente de la etapa anterior esté seteada en 1, la dirección a escribirse será la guardada en el registro rt, caso contrarió será la especificada por el valor de rd.

## memory acces

## write back

