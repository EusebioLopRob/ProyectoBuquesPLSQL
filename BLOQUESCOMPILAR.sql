--BLOQUES PARA COMPILAR (F5)
SET SERVEROUTPUT ON;
/*
========================
------ Función 01 ------
========================
*/
CREATE OR REPLACE FUNCTION F_TAMANORELATIVO (v_nombre VARCHAR2)RETURN NUMBER IS
    --Variables que vamos a necesitar
    v_tamavg NUMBER;
    v_tam NUMBER;
    v_resul NUMBER;
    r_regacr BARCO.ACRONIMO_TIP%TYPE;
    --Tipo de registro para recoger ESLORA, CALADO y MANGA
    TYPE TYPE_TAM IS RECORD(
        ESLORA NUMBER(5,2),
        CALADO NUMBER(5,2),
        MANGA NUMBER(5,2)
    );
    r_tambar TYPE_TAM;
BEGIN
    --Obtenemos el tipo de barco mediante un cursor implícito
    SELECT ACRONIMO_TIP INTO r_regacr FROM BARCO WHERE NOMBRE_BARCO=v_nombre; 
    
    --Regogemos en un registro la media de la ESLORA, CALADO y MANGA de todos 
    --los barcos de ese tipo mediante un cursor implícito
    SELECT AVG(ESLORA),AVG(CALADO),AVG(MANGA) INTO r_tamBar FROM BARCO WHERE ACRONIMO_TIP=r_regacr;    
    --Calculamos el tamaño relativo medio de los barcos de ese tipo
    v_tamavg:=r_tambar.ESLORA*r_tambar.CALADO*r_tambar.MANGA;
    --Regogemos en un registro con los valores del barco que queremos evaluar
    SELECT ESLORA,CALADO,MANGA INTO r_tambar FROM BARCO WHERE NOMBRE_BARCO=v_nombre;
    --Calculamos el tamaño relativo del barco a evaluar
    v_tam:=r_tambar.ESLORA*r_tambar.CALADO*r_tambar.MANGA;
    --Calculamos el factor de tamaño con respecto a la media de su clase
    v_resul:=v_tam/v_tamavg;
    --Realizamos una conversión de formato a % positivo o negativo
    IF v_resul>1 THEN
        v_resul:=(v_resul-1)*100;
    ELSE
        v_resul:=(1-v_resul)*(-100);
    END IF;
    --Devolvemos el resultado
    RETURN v_resul;
    EXCEPTION
        --Si el SELECT ha fallado es porque el nombre introducido no existe
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Ha introducido el nombre de un barco que no existe en la base de datos: '||SQLERRM);
            RETURN -1;
        --Captura de excepciones inesperadas
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Se ha producido el siguiente error: '||SQLERRM);
            RETURN -1;
END F_TAMANORELATIVO;
/
/*
========================
------ Función 02 ------
========================
*/
CREATE OR REPLACE FUNCTION F_NUMCOMAND(v_acrtip VARCHAR2,v_acrfac VARCHAR2)RETURN NUMBER IS
    --Tipo de registro para almacenar el número de comandantes
    TYPE TYPE_CUENTA IS RECORD(CUENTA NUMBER(3));
    r_regcuenta TYPE_CUENTA;
    --Registros para la comprobación del tipo de barco y la facción
    r_tipo TIPO_BARCO.ACRONIMO_TIP%TYPE;
    r_faccion FACCION.ACRONIMO%TYPE;     
BEGIN
    --Mediante un cursor implícito comprobamos que el SELECT devuelve un resultado (Tipo de barco correcto)
    SELECT ACRONIMO_TIP INTO r_tipo FROM TIPO_BARCO WHERE ACRONIMO_TIP=v_acrtip;
    --Mediante un cursor implícito comprobamos que el SELECT devuelve un resultado (Facción correcta)
    SELECT ACRONIMO INTO r_faccion FROM FACCION WHERE ACRONIMO=v_acrfac; 
    --Si la ejecución del programa ha pasado de este punto es que los datos son correctos
    --Recuperamos el número de comandantes mediante un cursor implícito
    SELECT COUNT(DISTINCT ID_COM)INTO r_regcuenta FROM BARCO WHERE ACRONIMO_FAC=r_faccion AND ACRONIMO_TIP=r_tipo;  
    --Devolvemos el resultado
    RETURN r_regcuenta.CUENTA;
    EXCEPTION
        --Si salta la excepción NO_DATA_FOUND es porque alguno de los SELECT ha fallado
        WHEN NO_DATA_FOUND THEN 
            --Si el tipo de barco es correcto entonces el problema está en la facción
            --Si el tipo de barco es erroneo no podemos verificar si la facción es correcta o no
            --El caso de ambos argumentos erroneos se tratará como tipo de barco erroneo
            IF r_tipo=v_acrtip THEN
                DBMS_OUTPUT.PUT_LINE('Ha introducido un acrónimo de facción erroneo: '||SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('Ha introducido un acrónimo de tipo de barco erroneo: '||SQLERRM);
            END IF;
            --Independiéntemente de donde esté el fallo devolvemos un -1, que indica que la función ha recibido argumentos erroneos
            RETURN -1;
        --Captura de excepciones inesperadas
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Se ha producido el siguiente error: '||SQLERRM);
            RETURN -1;
END F_NUMCOMAND;
/
/*
==============================
------ Procedimiento 01 ------
==============================
*/
CREATE OR REPLACE PROCEDURE P_LISTACOMPLETA IS
    --Cursor para obtener las contiendas
    CURSOR C_CONTIENDAS IS
        SELECT CODIGO_CONT,NOMBRE_CONT,FECHA_CONT FROM CONTIENDA ORDER BY CODIGO_CONT;
    r_cont C_CONTIENDAS%ROWTYPE;
    
    --Cursor para obtener las facciones de una contienda dado el código de contienda
    CURSOR C_FACCIONES (v_codigo_cont NUMBER) IS
        SELECT DISTINCT bar.ACRONIMO_FAC AS ACRO
        FROM BARCO bar, PARTICIPA par
        WHERE par.CODIGO_CONT=v_codigo_cont
            AND bar.codigo_barco=par.codigo_barco; 
    r_fac C_FACCIONES%ROWTYPE;
    
    --Cursor para obtener los datos de los barcos y los comandantes que 
    --participaron en una determinada contienda y una detarminada facción
    CURSOR C_BARCOSCOMAND (v_fac VARCHAR2,v_codigo_cont NUMBER) IS
        SELECT tip.NOMBRE_TIP AS TIPBAR, bar.NOMBRE_BARCO AS NOMBAR, com.NOMBRE_COM as NOMCOM, com.RANGO AS RANCOM
        FROM BARCO bar, COMANDANTE com, PARTICIPA par, TIPO_BARCO tip
        WHERE par.CODIGO_BARCO=bar.CODIGO_BARCO
            AND bar.ID_COM=com.ID_COM
            AND bar.ACRONIMO_TIP=tip.ACRONIMO_TIP
            AND par.CODIGO_CONT=v_codigo_cont
            AND bar.ACRONIMO_FAC=v_fac        
        ORDER BY bar.ACRONIMO_TIP;
    r_bar C_BARCOSCOMAND%ROWTYPE;
    
    --Variable contador para el número de barcos
    v_contador NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Lista de buques involucrados en las batallas navales de la segunda guerra mundial');
    OPEN C_CONTIENDAS;
    LOOP
        --Comenzamos la lista generando una cabecera por cada contienda con su nombre y fecha
        FETCH C_CONTIENDAS INTO r_cont;
        EXIT WHEN C_CONTIENDAS%NOTFOUND;        
        DBMS_OUTPUT.PUT_LINE('=======================================');
        DBMS_OUTPUT.PUT_LINE(r_cont.NOMBRE_CONT||' - Fecha: '||TO_CHAR(r_cont.FECHA_CONT, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('=======================================');
        OPEN C_FACCIONES(r_cont.CODIGO_CONT);
        LOOP
            --Dendtro de cada una de las contiendas generamos una cabecera por cada facción involucrada 
            FETCH C_FACCIONES INTO r_fac;
            EXIT WHEN C_FACCIONES%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('------------------'||r_fac.ACRO||'------------------');
            --Antes de pasar al siguiente LOOP establecemos el valor del contador a cero
            v_contador:=0;
            OPEN C_BARCOSCOMAND(r_fac.ACRO,r_cont.CODIGO_CONT);
            LOOP
                --Dentro de cada facción generamos una lista con los datos del barco y el comandante
                FETCH C_BARCOSCOMAND INTO r_bar;
                EXIT WHEN C_BARCOSCOMAND%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE(r_bar.TIPBAR||' - '||UPPER(r_bar.NOMBAR)||', comandado por el '||LOWER(r_bar.RANCOM)||' '||r_bar.NOMCOM);
                --Por cada iteración en esta lista incrementamos el contador de barcos
                v_contador:=v_contador+1;
            END LOOP;
            --Al finalizar el bucle que genera la lista de barcos y comandantes mostramos el total de barcos
            DBMS_OUTPUT.PUT_LINE('------------------');
            DBMS_OUTPUT.PUT_LINE(r_fac.ACRO||' - Total de barcos participantes: '||v_contador);
            CLOSE C_BARCOSCOMAND;            
        END LOOP;
        CLOSE C_FACCIONES;
    END LOOP;
    CLOSE C_CONTIENDAS;
    --Captura de excepciones inesperadas
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Se ha producido el siguiente error: '||SQLERRM);    
END P_LISTACOMPLETA;
/
/*
==============================
------ Procedimiento 02 ------
==============================
*/
CREATE OR REPLACE PROCEDURE P_DENOMINACION IS
    --Cursor que obtiene la información de los barcos a modificar
    CURSOR C_BARCOSOBJETIVO IS
        SELECT CODIGO_BARCO, NOMBRE_BARCO, ACRONIMO_FAC
        FROM BARCO 
        WHERE ACRONIMO_FAC IN ('USN','RN') 
            AND NOMBRE_BARCO NOT LIKE 'USS%'
            AND NOMBRE_BARCO NOT LIKE 'HMS%';
        r_barco C_BARCOSOBJETIVO%ROWTYPE;
        --Variable para contador de barcos modificados
        v_contador NUMBER:=0;
        --Variable para guardar el nombre modificado
        v_nombre VARCHAR2(50);
BEGIN
    OPEN C_BARCOSOBJETIVO;
    LOOP
        FETCH C_BARCOSOBJETIVO INTO r_barco;
        EXIT WHEN C_BARCOSOBJETIVO%NOTFOUND;
            --Si el barco pertenece a la US navy, le ponemos "USS" delante
            IF r_barco.ACRONIMO_FAC='USN' THEN
                v_nombre:='USS '||r_barco.NOMBRE_BARCO;
            --En otro caso solo podrá ser de la Royal Navy y le ponemos "HMS"
            ELSE 
                v_nombre:='HMS '||r_barco.NOMBRE_BARCO;
            END IF;
            --Realizamos la actualización del nombre
            UPDATE BARCO SET NOMBRE_BARCO=v_nombre WHERE CODIGO_BARCO=r_barco.CODIGO_BARCO;
            --Incrementamos el contador de modificados
            v_contador:=v_contador+1;
    END LOOP;
    CLOSE C_BARCOSOBJETIVO;
    --Mostramos por pantalla el número de barcos modificados
    DBMS_OUTPUT.PUT_LINE('Se han modificado '||v_contador||' barcos.');
    --Captura de excepciones inesperadas
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Se ha producido el siguiente error: '||SQLERRM);
END P_DENOMINACION; 
/
/*
===============================
-------- Disparador 01 --------
===============================
*/
CREATE OR REPLACE TRIGGER T_BARCO_AUDITORIA 
--Cada vez que se añadan, actualicen o se borren registros en la tabla BARCO se ejecutará este trigger
AFTER INSERT OR UPDATE OR DELETE ON BARCO FOR EACH ROW
DECLARE
    --Variables que necesitamos.
    v_reg_nuevo VARCHAR2(2000);
    v_reg_antiguo VARCHAR2(2000);
    --El tipo de transacción se guardará como un número: 1=INSERT, 2=DELETE, 3=UPDATE
    v_tip NUMBER;
BEGIN
    CASE
        WHEN INSERTING THEN
            v_reg_nuevo:=:NEW.CODIGO_BARCO||'#'||:NEW.NOMBRE_BARCO||'#'||:NEW.CLASE||
            '#'||:NEW.ESLORA||'#'||:NEW.CALADO||'#'||:NEW.MANGA||'#'||:NEW.ARMAMENTO||
            '#'||:NEW.PROPULSION||'#'||:NEW.POTENCIA||'#'||:NEW.AUTONOMIA||'#'||
            :NEW.TRIPULACION||'#'||:NEW.NUM_AERONAVES||'#'||:NEW.ESPECIAL||'#'||
            :NEW.FECHA_BOTADO||'#'||:NEW.DESTINO||'#'||:NEW.ACRONIMO_FAC||'#'||
            :NEW.ACRONIMO_TIP||'#'||:NEW.ID_COM;
            v_tip:=1;
        WHEN DELETING THEN
            v_reg_antiguo:=:OLD.CODIGO_BARCO||'#'||:OLD.NOMBRE_BARCO||'#'||:OLD.CLASE||
            '#'||:OLD.ESLORA||'#'||:OLD.CALADO||'#'||:OLD.MANGA||'#'||:OLD.ARMAMENTO||
            '#'||:OLD.PROPULSION||'#'||:OLD.POTENCIA||'#'||:OLD.AUTONOMIA||'#'||
            :OLD.TRIPULACION||'#'||:OLD.NUM_AERONAVES||'#'||:OLD.ESPECIAL||'#'||
            :OLD.FECHA_BOTADO||'#'||:OLD.DESTINO||'#'||:OLD.ACRONIMO_FAC||'#'||
            :OLD.ACRONIMO_TIP||'#'||:OLD.ID_COM;
            v_tip:=2;
        WHEN UPDATING THEN
            v_reg_nuevo:=:NEW.CODIGO_BARCO||'#'||:NEW.NOMBRE_BARCO||'#'||:NEW.CLASE||
            '#'||:NEW.ESLORA||'#'||:NEW.CALADO||'#'||:NEW.MANGA||'#'||:NEW.ARMAMENTO||
            '#'||:NEW.PROPULSION||'#'||:NEW.POTENCIA||'#'||:NEW.AUTONOMIA||'#'||
            :NEW.TRIPULACION||'#'||:NEW.NUM_AERONAVES||'#'||:NEW.ESPECIAL||'#'||
            :NEW.FECHA_BOTADO||'#'||:NEW.DESTINO||'#'||:NEW.ACRONIMO_FAC||'#'||
            :NEW.ACRONIMO_TIP||'#'||:NEW.ID_COM;
            v_reg_antiguo:=:OLD.CODIGO_BARCO||'#'||:OLD.NOMBRE_BARCO||'#'||:OLD.CLASE||
            '#'||:OLD.ESLORA||'#'||:OLD.CALADO||'#'||:OLD.MANGA||'#'||:OLD.ARMAMENTO||
            '#'||:OLD.PROPULSION||'#'||:OLD.POTENCIA||'#'||:OLD.AUTONOMIA||'#'||
            :OLD.TRIPULACION||'#'||:OLD.NUM_AERONAVES||'#'||:OLD.ESPECIAL||'#'||
            :OLD.FECHA_BOTADO||'#'||:OLD.DESTINO||'#'||:OLD.ACRONIMO_FAC||'#'||
            :OLD.ACRONIMO_TIP||'#'||:OLD.ID_COM;
            v_tip:=3;
    END CASE;
    INSERT INTO BARCO_AUDITORIA VALUES(USER,SYSTIMESTAMP,v_tip,v_reg_nuevo,v_reg_antiguo);
    --Captura de excepciones inesperadas
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Se ha producido el siguiente error: '||SQLERRM);
END T_BARCO_AUDITORIA;
/
/*
===============================
-------- Disparador 02 --------
===============================
*/
CREATE OR REPLACE TRIGGER T_COMANDANTE_AUDITORIA 
--Cada vez que se añadan, actualicen o se borren registros en la tabla COMANDANTE se ejecutará este trigger
AFTER INSERT OR UPDATE OR DELETE ON COMANDANTE FOR EACH ROW
DECLARE
    --Variables que necesitamos.
    v_reg_nuevo VARCHAR2(60);
    v_reg_antiguo VARCHAR2(60);
    --El tipo de transacción se guardará como un número: 1=INSERT, 2=DELETE, 3=UPDATE
    v_tip NUMBER;
BEGIN
    CASE
        WHEN INSERTING THEN
            v_reg_nuevo:=:NEW.ID_COM||'#'||:NEW.NOMBRE_COM||'#'||:NEW.RANGO||'#'||:NEW.FACCION_COM;
            v_tip:=1;
        WHEN DELETING THEN
            v_reg_antiguo:=:OLD.ID_COM||'#'||:OLD.NOMBRE_COM||'#'||:OLD.RANGO||'#'||:OLD.FACCION_COM;
            v_tip:=2;
        WHEN UPDATING THEN
            v_reg_nuevo:=:NEW.ID_COM||'#'||:NEW.NOMBRE_COM||'#'||:NEW.RANGO||'#'||:NEW.FACCION_COM;
            v_reg_antiguo:=:OLD.ID_COM||'#'||:OLD.NOMBRE_COM||'#'||:OLD.RANGO||'#'||:OLD.FACCION_COM;
            v_tip:=3;
    END CASE;
    INSERT INTO COMANDANTE_AUDITORIA VALUES(USER,SYSTIMESTAMP,v_tip,v_reg_nuevo,v_reg_antiguo);
    --Captura de excepciones inesperadas
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Se ha producido el siguiente error: '||SQLERRM);
END T_COMANDANTE_AUDITORIA;
/
/*
===============================
-------- Disparador 03 --------
===============================
*/
CREATE OR REPLACE TRIGGER T_CONTIENDA_AUDITORIA 
--Cada vez que se añadan, actualicen o se borren registros en la tabla CONTIENDA se ejecutará este trigger
AFTER INSERT OR UPDATE OR DELETE ON CONTIENDA FOR EACH ROW
DECLARE
    --Variables que necesitamos.
    v_reg_nuevo VARCHAR2(550);
    v_reg_antiguo VARCHAR2(550);
    --El tipo de transacción se guardará como un número: 1=INSERT, 2=DELETE, 3=UPDATE
    v_tip NUMBER;
BEGIN
    CASE
        WHEN INSERTING THEN
            v_reg_nuevo:=:NEW.CODIGO_CONT||'#'||:NEW.NOMBRE_CONT||'#'||:NEW.FECHA_CONT;
            v_tip:=1;
        WHEN DELETING THEN
            v_reg_antiguo:=:OLD.CODIGO_CONT||'#'||:OLD.NOMBRE_CONT||'#'||:OLD.FECHA_CONT;
            v_tip:=2;
        WHEN UPDATING THEN
            v_reg_nuevo:=:NEW.CODIGO_CONT||'#'||:NEW.NOMBRE_CONT||'#'||:NEW.FECHA_CONT;
            v_reg_antiguo:=:OLD.CODIGO_CONT||'#'||:OLD.NOMBRE_CONT||'#'||:OLD.FECHA_CONT;
            v_tip:=3;
    END CASE;
    INSERT INTO CONTIENDA_AUDITORIA VALUES(USER,SYSTIMESTAMP,v_tip,v_reg_nuevo,v_reg_antiguo);
    --Captura de excepciones inesperadas
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Se ha producido el siguiente error: '||SQLERRM);
END T_CONTIENDA_AUDITORIA;
/
/*
===============================
-------- Disparador 04 --------
===============================
*/
CREATE OR REPLACE TRIGGER T_PARTICIPA_AUDITORIA 
--Cada vez que se añadan, actualicen o se borren registros en la tabla PARTICIPA se ejecutará este trigger
AFTER INSERT OR UPDATE OR DELETE ON PARTICIPA FOR EACH ROW
DECLARE
    --Variables que necesitamos.
    v_reg_nuevo VARCHAR2(550);
    v_reg_antiguo VARCHAR2(550);
    --El tipo de transacción se guardará como un número: 1=INSERT, 2=DELETE, 3=UPDATE
    v_tip NUMBER;
BEGIN
    CASE
        WHEN INSERTING THEN
            v_reg_nuevo:=:NEW.CODIGO_BARCO||'#'||:NEW.CODIGO_CONT;
            v_tip:=1;
        WHEN DELETING THEN
            v_reg_antiguo:=:OLD.CODIGO_BARCO||'#'||:OLD.CODIGO_CONT;
            v_tip:=2;
        WHEN UPDATING THEN
            v_reg_nuevo:=:NEW.CODIGO_BARCO||'#'||:NEW.CODIGO_CONT;
            v_reg_antiguo:=:OLD.CODIGO_BARCO||'#'||:OLD.CODIGO_CONT;
            v_tip:=3;
    END CASE;
    INSERT INTO PARTICIPA_AUDITORIA VALUES(USER,SYSTIMESTAMP,v_tip,v_reg_nuevo,v_reg_antiguo);
    --Captura de excepciones inesperadas
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Se ha producido el siguiente error: '||SQLERRM);
END T_PARTICIPA_AUDITORIA;
/
/*
===============================
-------- Disparador 05 --------
===============================
*/
CREATE OR REPLACE TRIGGER T_TIPOINMODIFICABLE 
BEFORE INSERT OR UPDATE OR DELETE ON TIPO_BARCO
--Trigger de instrucción para bloquear modificaciones en la tabla FACCIÓN
BEGIN
    RAISE_APPLICATION_ERROR(-20001,'No está permitido realizar modificaciones en la tabla TIPO_BARCO');
END T_TIPOINMODIFICABLE;
/
/*
===============================
-------- Disparador 06 --------
===============================
*/
CREATE OR REPLACE TRIGGER T_FACCIONINMODIFICABLE 
BEFORE INSERT OR UPDATE OR DELETE ON FACCION
--Trigger de instrucción para bloquear modificaciones en la tabla FACCIÓN
BEGIN
    RAISE_APPLICATION_ERROR(-20001,'No está permitido realizar modificaciones en la tabla FACCION');
END T_FACCIONINMODIFICABLE;
/
/*
===============================
-------- Disparador 07 --------
===============================
*/
CREATE OR REPLACE TRIGGER T_TAMANOINCORRECTO
BEFORE INSERT ON BARCO FOR EACH ROW
DECLARE
    v_tamtip NUMBER;
    v_resul NUMBER;
    --Tamaño relativo del barco que se pretende introducir
    v_tam NUMBER:=:NEW.ESLORA*:NEW.CALADO*:NEW.MANGA;
    --Tipo de registro para recoger ESLORA, CALADO y MANGA
    TYPE TYPE_TAM IS RECORD(
        ESLORA NUMBER(5,2),
        CALADO NUMBER(5,2),
        MANGA NUMBER(5,2)
    );
    r_tambar TYPE_TAM;
BEGIN
    --Recuperamos los valores medios del tipo de barco que pretendemos introducir mediante un cursor implícito
    SELECT AVG(ESLORA),AVG(CALADO),AVG(MANGA) INTO r_tamBar FROM BARCO WHERE ACRONIMO_TIP=:NEW.ACRONIMO_TIP;
    --Calculamos el tamaño relativo medio de los barcos del tipo que pretendemos introducir
    v_tamtip:=r_tambar.ESLORA*r_tambar.CALADO*r_tambar.MANGA;
    v_resul:=v_tam/v_tamtip;
    --Dependiendo de si el porcentaje de tamaño relativo con respecto a la media es mayor o menor del 60% 
    --se lanzará la excepción adecuada, en caso de no darse ninguna, el trigger permite la inserción
    IF v_resul>1 AND (v_resul-1)>0.6 THEN
        RAISE_APPLICATION_ERROR(-20002,'No está permitido insertar '||:NEW.ACRONIMO_TIP||' con un tamaño relativo por encima del 60% de la media: '||v_tamtip||', revise los valores.');       
    ELSIF v_resul<1 AND v_resul>0.6 THEN
        RAISE_APPLICATION_ERROR(-20002,'No está permitido insertar '||:NEW.ACRONIMO_TIP||' con un tamaño relativo por debajo del 60% de la media: '||v_tamtip||', revise los valores.');        
    END IF;
END T_TAMANOINCORRECTO;



















