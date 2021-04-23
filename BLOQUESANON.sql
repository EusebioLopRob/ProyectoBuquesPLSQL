--BLOQUE AN�NIMO PARA PROBAR LAS APLICACIONES PL SQL DE LA BASE DE DATOS DE BUQUES DE LA SEGUNDA GUERRA MUNDIAL

--ANTES de ejecutar el bloque de esta hoja de trabajo:
--1) Ejecutar el script de creaci�n de tablas e inserci�n de datos Proyecto_Buques_guerra.sql utilizando un usuario con permisos de ALL PRIVILEGES
--2) Ejecutar el script de bloques PL SQL que contiene lo c�digos de las funciones, procedimientos y triggers

--EXPLICACI�N: 
/*
    Esta aplicaci�n consta de varios bloques an�nimos en los que se probar�n todas las funcionalidades 
    PL SQL que se han a�adido a esta base de datos. Fuera de los bloques est�n las ejecuciones de los procedimientos. 
    ---
    Se RECOMIENDA ejecutarlos uno por uno, intercalando las intrucciones de consulta para hacer comprobaciones de por medio
    Pero si lo desea PUEDE EJECUTAR EL SCRIPT COMPLETO completo con F5, para ello las consultas han sido comentadas
*/

--Ejecute los siguientes ALTER TRIGGER
ALTER TRIGGER T_BARCO_AUDITORIA DISABLE;
ALTER TRIGGER T_COMANDANTE_AUDITORIA DISABLE;
ALTER TRIGGER T_CONTIENDA_AUDITORIA DISABLE;
ALTER TRIGGER T_PARTICIPA_AUDITORIA DISABLE;
ALTER TRIGGER T_TIPOINMODIFICABLE DISABLE;
ALTER TRIGGER T_FACCIONINMODIFICABLE DISABLE;
ALTER TRIGGER T_TAMANOINCORRECTO DISABLE;

--Ejecute el siguiente bloque an�nimo
DECLARE
    v_nombre VARCHAR2(50);
    v_tamano NUMBER(38,10);
    v_tipo VARCHAR2(3);
    v_faccion VARCHAR2(5);
BEGIN
    DBMS_OUTPUT.PUT_LINE('INICIO DE LA APLICACI�N');
    DBMS_OUTPUT.PUT_LINE('==========================');
    DBMS_OUTPUT.PUT_LINE('Se va a realizar una prueba de la FUNCI�N 01');
    DBMS_OUTPUT.PUT_LINE('Se llamar� 3 veces a la funci�n con las siguientes cadenas de caracteres como entrada: Yamato, Nagato y Paco');
    v_nombre:='Yamato';
    v_tamano:=F_TAMANORELATIVO(v_nombre);
    IF v_tamano>0 THEN
        DBMS_OUTPUT.PUT_LINE('El '||v_nombre||' es un '||TO_CHAR(v_tamano,'99D99')||'% MAYOR que la media de los barcos de su tipo');
    ELSE 
        v_tamano:=v_tamano*(-1);
        DBMS_OUTPUT.PUT_LINE('El '||v_nombre||' es un '||TO_CHAR(v_tamano,'99D99')||'% MENOR que la media de los barcos de su tipo');
    END IF;
    v_nombre:='Nagato';
    v_tamano:=F_TAMANORELATIVO(v_nombre);
    IF v_tamano>0 THEN
        DBMS_OUTPUT.PUT_LINE('El '||v_nombre||' es un '||TO_CHAR(v_tamano,'99D99')||'% MAYOR que la media de los barcos de su tipo');
    ELSE 
        v_tamano:=v_tamano*(-1);
        DBMS_OUTPUT.PUT_LINE('El '||v_nombre||' es un '||TO_CHAR(v_tamano,'99D99')||'% MENOR que la media de los barcos de su tipo');
    END IF;
    DBMS_OUTPUT.PUT_LINE('La cadena Paco es un ejemplo para comprobar c�mo se gestiona la excepci�n de que no exista el nombre del barco');
    --No hace falta el IF ELSE en este caso
    v_nombre:='Paco';
    v_tamano:=F_TAMANORELATIVO(v_nombre);
    DBMS_OUTPUT.PUT_LINE('==========================');
    DBMS_OUTPUT.PUT_LINE('A continuaci�n se realiza una prueba de la FUNCI�N 02');
    v_tipo:='BB';
    v_faccion:='IJN';
    DBMS_OUTPUT.PUT_LINE('Argumentos de entrada: Tipo de barco BB, facci�n IJN');
    DBMS_OUTPUT.PUT_LINE('Hay '||F_NUMCOMAND(v_tipo,v_faccion)||' comandantes que han servido en '||v_tipo||' de la flota '||v_faccion);
    v_tipo:='AS';
    v_faccion:='USN';
    DBMS_OUTPUT.PUT_LINE('Argumentos de entrada: Tipo de barco AS, facci�n USN');
    DBMS_OUTPUT.PUT_LINE('Hay '||F_NUMCOMAND(v_tipo,v_faccion)||' comandantes que han servido en '||v_tipo||' de la flota '||v_faccion);
    DBMS_OUTPUT.PUT_LINE('Se introduce a prop�sito un acr�nimo de tipo de barco erroneo para comprobar la gesti�n de excepciones');
    v_tipo:='XX';
    v_faccion:='USN';
    --Utilizamos v_tamano como variable auxiliar, no queremos guardar el resultado solo probar la excepci�n
    v_tamano:=F_NUMCOMAND(v_tipo,v_faccion);
    DBMS_OUTPUT.PUT_LINE('==========================');
    DBMS_OUTPUT.PUT_LINE('A continuaci�n se realiza una prueba del PROCEDIMIENTO 02');
    DBMS_OUTPUT.PUT_LINE('Este procedimiento a�ade una denominaci�n a los barcos de la USN y la RN');
    DBMS_OUTPUT.PUT_LINE('Para los barcos de la USN a�adir� delante del nombre USS, "United States Ship"');
    DBMS_OUTPUT.PUT_LINE('Para los barcos de la RN a�adir� delante del nombre HMS, "Her Majestry Ship"'); 
    DBMS_OUTPUT.PUT_LINE('Se ejecuta el procedimiento y se muestra una SELECT de los barcos de ambas facciones');
END;
/
EXEC P_DENOMINACION;

--Ejecute el siguientes SELECT para comprobaci�n
--SELECT NOMBRE_BARCO FROM BARCO WHERE ACRONIMO_FAC IN ('USN','RN');

--HABILITAR DISPARADORES
ALTER TRIGGER T_BARCO_AUDITORIA ENABLE;
ALTER TRIGGER T_COMANDANTE_AUDITORIA ENABLE;
ALTER TRIGGER T_CONTIENDA_AUDITORIA ENABLE;
ALTER TRIGGER T_PARTICIPA_AUDITORIA ENABLE;

--Ejecute el siguiente bloque an�nimo
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================');
    DBMS_OUTPUT.PUT_LINE('A continuaci�n se van a probar los DISPARADORES de AUDITOR�A');
    DBMS_OUTPUT.PUT_LINE('Se realizar�n una serie de modificaciones en las tablas BARCO, COMANDANTE, CONTIENDA y PARTICIPA');
    
    INSERT INTO COMANDANTE VALUES(34,'Lancelot Ernest Holland','Vicealmirante','RN');
    INSERT INTO BARCO VALUES('RN_1','Hood','Admiral',262.3,9.8,31.8,
    '8 ca�ones de 381 mm
    14 ca�ones AA 101 mm (7 � 2)
    24 ca�ones AA "pom-pom" de 40 mm (3 � 8)
    20 ametralladoras Vickers de 12,7 mm (5 � 4)
    100 ca�ones "Unrotated Projectile" (5 � 20)
    4 tubos lanzatorpedos de 533 mm (2 � 2) sobre el agua',
    'Turbinas de vapor Brown-Curtis
    24 calderas acuatubulares Yarrow
    4 h�lices de 3 palas de 6m de di�metro',
    10,20372,1325,4,'Radar de alerta a�rea Tipo 279, Radar de tiro Tipo 284',
    TO_DATE('22/8/1918','DD/MM/YYYY'),
    'Hundido por el acorazado Bismarck en la Batalla del Estrecho de Dinamarca',
    'RN','BC',34);
    
    INSERT INTO COMANDANTE VALUES(35,'John Catterall Leach','Capit�n','RN');
    INSERT INTO BARCO VALUES('RN_2','Prince of Wales','King George V',227.1,10.5,31.4,
    '10 ca�ones de 356 mm (1 � 2 + 2 � 4)
    16 ca�ones de 133 mm
    48 ca�ones de 2 libras antia�reos
    18 ca�ones antia�reo de 20 mm Oerlikon
    4 tubos lanzatorpedos a proa
    4 tubos lanzatorpedos a popa',
    '4 turbinas Parsons
    8 calderas Admiralty 3
    4 h�lices',
    110000,27000,2000,4,'Radar Tipo 281 desde enero de 1941',
    TO_DATE('3/5/1939','DD/MM/YYYY'),
    'Hundido el 10 de diciembre de 1941 por ataque aereo japon�s en Kuantan, mar del sur de China',
    'RN','BB',35);
    
    INSERT INTO COMANDANTE VALUES(36,'Gunther Lutjens','Soldado raso','KMS');
    INSERT INTO BARCO VALUES('KMS_1','Bismarck','Bismarck',251,9.9,36,
    '8 ca�ones SK 380 mm/C34 (4 � 2)
    12 ca�ones de 150 mm (6 � 2)
    16 ca�ones SK 105 mm/C33 (8 � 2)
    16 ca�ones SK 37 mm/C30 (8 � 2)
    12 ca�ones de 20 mm FlaK 30 (12 � 1)',
    '2 calderas Wagner
    3 turbinas de vapor Blohm y Voss
    3 h�lices de tres palas 4,70m di�metro',
    170000,16000,200,4,'1 catapulta de doble final',
    TO_DATE('14/2/1939','DD/MM/YYYY'),
    'Hundido el 27 de mayo de 1941 en el Atl�ntico Norte',
    'KMS','FBB',36);
    
    INSERT INTO COMANDANTE VALUES(37,'Helmuth Brinkmann','Vicealmirante','KMS');
    INSERT INTO BARCO VALUES('KMS_2','Prinz Eugen','Admiral Hipper',207.7,7.2,21.7,
    '8 ca�ones de 203 mm
    12 ca�ones de 105 mm
    12 ca�ones AA de 37 mm
    8 ca�ones AA de 20 mm
    12 tubos lanzatorpedo 533 mm',
    '3 turbinas de vapor Blohm y Voss
    3 h�lices de tres palas',
    132000,27000,1382,3,'Radar Tipo 281 desde enero de 1941',
    TO_DATE('3/5/1939','DD/MM/YYYY'),
    'Remolcado hasta el atol�n Kwajalein para ser utilizado como barco objetivo en pruebas de armamento nuclear. Hundido en diciembre de 1946',
    'KMS','CA',37);
    
    INSERT INTO CONTIENDA VALUES(7,'Batalla del Estrecho de Suecia',TO_DATE('24/5/1941','DD/MM/YYYY'));
    INSERT INTO PARTICIPA VALUES('RN_1',7);
    INSERT INTO PARTICIPA VALUES('RN_2',7);
    INSERT INTO PARTICIPA VALUES('KMS_1',7);
    INSERT INTO PARTICIPA VALUES('KMS_2',7);    
    UPDATE BARCO SET POTENCIA=144000 WHERE NOMBRE_BARCO='Hood';
    UPDATE BARCO SET TRIPULACION=2000 WHERE NOMBRE_BARCO='Bismarck';
    UPDATE COMANDANTE SET RANGO='Almirante' WHERE ID_COM=36;
    UPDATE CONTIENDA SET NOMBRE_CONT='Batalla del Estrecho de Dinamarca' WHERE CODIGO_CONT=7;       
    DELETE FROM CONTIENDA WHERE CODIGO_CONT IN (4,5,6);        
END;
/
--Ejecute los siguientes select para comprobaci�nes de AUDITORIA
--SELECT * FROM BARCO_AUDITORIA;
--SELECT * FROM COMANDANTE_AUDITORIA;
--SELECT * FROM CONTIENDA_AUDITORIA;
--SELECT * FROM PARTICIPA_AUDITORIA;

--HABILITAR DISPARADORES
ALTER TRIGGER T_TIPOINMODIFICABLE ENABLE;
ALTER TRIGGER T_FACCIONINMODIFICABLE ENABLE;
ALTER TRIGGER T_TAMANOINCORRECTO ENABLE;
/
--Ejecute los siguientes bloque an�nimos
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================');
    DBMS_OUTPUT.PUT_LINE('A continuaci�n se va a probar los disparadores que impiden realizar cambios en las tablas TIPO_BARCO y FACCION');  
    DBMS_OUTPUT.PUT_LINE('Intento de modificaci�n de la tabla TIPO_BARCO');
    DBMS_OUTPUT.PUT_LINE('IMPORTANTE: ESTE BLOQUE VA A DAR ERROR');
    --Se ejecutan el siguientes UPDATE
    UPDATE TIPO_BARCO SET NOMBRE_TIP='Cacciatorpediniere' WHERE ACRONIMO_TIP='DD';
END; 
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('Intento de modificaci�n de la tabla FACCION');
    DBMS_OUTPUT.PUT_LINE('IMPORTANTE: ESTE BLOQUE VA A DAR ERROR');
    --Se ejecutan el siguientes UPDATE
    UPDATE FACCION SET NACION='P�rfida Alvi�n' WHERE ACRONIMO='RN';
END; 
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('A continuaci�n se va a probar el disparador que no permite insertar barcos con unas dimensiones fuera del rango establecido');
    DBMS_OUTPUT.PUT_LINE('IMPORTANTE: ESTE BLOQUE VA A DAR ERROR');
    --Se ejecuta el siguiente INSERT
    INSERT INTO BARCO VALUES('ELR_1','Eusebio','Eusebio',500,50,100,
        'Muchos ca�ones',
        'Muchas h�lices',
        1,1,1,1,'Este barco no existe',
        TO_DATE('23/4/2021','DD/MM/YYYY'),
        'Su destino es no ser insertado nunca',
        'IJN','BB',1);
END; 
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================');
    DBMS_OUTPUT.PUT_LINE('Finalmente, se va a ejecutar el PROCEDIMIENTO 02');
    DBMS_OUTPUT.PUT_LINE('Este procedimiento crea una lista con todas las contiendas, facciones involucradas, barcos y comandantes');
    DBMS_OUTPUT.PUT_LINE('FIN DE LA APLICACI�N');
END;   
/
EXEC P_LISTACOMPLETA;



