/*
CREACIÓN DE TABLAS
*/
CREATE TABLE FACCION(
ACRONIMO VARCHAR2(5) CONSTRAINT FAC_ACR_PK PRIMARY KEY,
NOMBRE_FAC VARCHAR2(50) CONSTRAINT FAC_NOM_UK UNIQUE,
NACION VARCHAR2(50) CONSTRAINT FAC_NAC_NN NOT NULL,
BANDO VARCHAR(10) 
);
CREATE TABLE COMANDANTE(
ID_COM NUMBER(3) CONSTRAINT COM_ID_PK PRIMARY KEY,
NOMBRE_COM VARCHAR2(30) CONSTRAINT COM_NOM_UNK UNIQUE,
RANGO VARCHAR(20),
FACCION_COM VARCHAR2(5) CONSTRAINT COM_FAC_FK REFERENCES FACCION
);
CREATE TABLE CONTIENDA(
CODIGO_CONT NUMBER(3) CONSTRAINT CONT_COD_PK PRIMARY KEY,
NOMBRE_CONT VARCHAR2(500) CONSTRAINT CONT_NOM_UK UNIQUE,
FECHA_CONT DATE CONSTRAINT CONT_FEC_NN NOT NULL
);
CREATE TABLE TIPO_BARCO(
ACRONIMO_TIP VARCHAR2(3) CONSTRAINT TIP_ACR_PK PRIMARY KEY,
NOMBRE_TIP VARCHAR(30) CONSTRAINT TIP_NOM_NN NOT NULL,
NOMBRE_ENG VARCHAR(30) CONSTRAINT TIP_ENG_NN NOT NULL
);
CREATE TABLE BARCO(
CODIGO_BARCO VARCHAR2(20) CONSTRAINT BAR_COD_PK PRIMARY KEY,
NOMBRE_BARCO VARCHAR2(50) CONSTRAINT BAR_NOM_UK UNIQUE,
CLASE VARCHAR2(50) CONSTRAINT BAR_CLA_NN NOT NULL,
ESLORA NUMBER(5,2) CONSTRAINT BAR_ESL_NN NOT NULL,
CALADO NUMBER(5,2) CONSTRAINT BAR_CAL_NN NOT NULL,
MANGA NUMBER(5,2) CONSTRAINT BAR_MAN_NN NOT NULL,
ARMAMENTO VARCHAR2(500),
PROPULSION VARCHAR2(500),
POTENCIA NUMBER(10),
AUTONOMIA NUMBER(10),
TRIPULACION NUMBER(10) CONSTRAINT BAR_TRI_CK CHECK (TRIPULACION>0),
NUM_AERONAVES NUMBER(3),
ESPECIAL VARCHAR2(500),
FECHA_BOTADO DATE CONSTRAINT BAR_FEC_NN NOT NULL,
DESTINO VARCHAR2(500),
ACRONIMO_FAC VARCHAR2(5) CONSTRAINT BAR_FAC_FK REFERENCES FACCION,
ACRONIMO_TIP VARCHAR2(3) CONSTRAINT BAR_TIP_FK REFERENCES TIPO_BARCO,
ID_COM NUMBER(3) CONSTRAINT BAR_COM_FK REFERENCES COMANDANTE
);
CREATE TABLE PARTICIPA(
CODIGO_BARCO VARCHAR2(20) CONSTRAINT PAR_BAR_FK REFERENCES BARCO,
CODIGO_CONT NUMBER(3) CONSTRAINT PAR_CON_FK REFERENCES CONTIENDA,
CONSTRAINT PAR_COD_PK PRIMARY KEY(CODIGO_BARCO,CODIGO_CONT) 
);

/*
CREACIÓN DE AUDITORÍAS
*/
CREATE TABLE BARCO_AUDITORIA(
    USUARIO VARCHAR2(50),
    FECHA DATE,
    TIPO_TRANSACCION NUMBER(1),
    REGISTRO_NUEVO VARCHAR2(2000),
    REGISTRO_ANTIGUO VARCHAR2(2000)
);
CREATE TABLE COMANDANTE_AUDITORIA(
    USUARIO VARCHAR2(50),
    FECHA DATE,
    TIPO_TRANSACCION NUMBER(1),
    REGISTRO_NUEVO VARCHAR2(60),
    REGISTRO_ANTIGUO VARCHAR2(60)    
);
CREATE TABLE CONTIENDA_AUDITORIA(
    USUARIO VARCHAR2(50),
    FECHA DATE,
    TIPO_TRANSACCION NUMBER(1),
    REGISTRO_NUEVO VARCHAR2(550),
    REGISTRO_ANTIGUO VARCHAR2(550)
);
CREATE TABLE PARTICIPA_AUDITORIA(
    USUARIO VARCHAR2(50),
    FECHA DATE,
    TIPO_TRANSACCION NUMBER(1),
    REGISTRO_NUEVO VARCHAR2(30),
    REGISTRO_ANTIGUO VARCHAR2(30)
);
/*
INSERCIÓN DE VALORES 
*/
--INSERCION DE DATOS DE FACCION
INSERT INTO faccion VALUES ('IJN','Flota imperial japonesa','Imperio de Japón','Eje');
INSERT INTO faccion VALUES ('KMS','Kriegsmarine','Alemania nazi','Eje');
INSERT INTO faccion VALUES ('RM','Regia Marina','Reino de Italia','Eje');
INSERT INTO faccion VALUES ('RN','Royal Navy','Imperio Británico','Aliados');
INSERT INTO faccion VALUES ('USN','United States Navy','Estados Unidos de América','Aliados');
INSERT INTO faccion VALUES ('VMF','Armada Soviética','Unión de Repúblicas Socialistas Soviéticas','Aliados');
INSERT INTO faccion VALUES ('MN','Marina Nacional francesa','República de Francia','Aliados');

--INSERCIÓN DE DATOS DE TIPO DE BARCO
INSERT INTO tipo_barco VALUES ('DD','Destructor','Destroyer');
INSERT INTO tipo_barco VALUES ('DE','Destructor escolta','Destroyer Escort');
INSERT INTO tipo_barco VALUES ('CL','Crucero ligero','Light Cruiser');
INSERT INTO tipo_barco VALUES ('CA','Crucero pesado','Heavy Cruiser');
INSERT INTO tipo_barco VALUES ('CAV','Crucero de aviación','Aviation Cruiser');
INSERT INTO tipo_barco VALUES ('BB','Acorazado','Battleship');
INSERT INTO tipo_barco VALUES ('BC','Crucero de batalla','Battlecruiser');
INSERT INTO tipo_barco VALUES ('FBB','Acorazado rápido','Fast Battleship');
INSERT INTO tipo_barco VALUES ('BBV','Acorazado de aviación','Aviation Battleship');
INSERT INTO tipo_barco VALUES ('CV','Portaviones','Aircraft Carrier');
INSERT INTO tipo_barco VALUES ('CVL','Portaviones ligero','Light Aircraft Carrier');
INSERT INTO tipo_barco VALUES ('CVB','Portaviones blindado','Armored Aircraft Carrier');
INSERT INTO tipo_barco VALUES ('CVE','Portaviones escolta','Aircraft Carrier Escort');
INSERT INTO tipo_barco VALUES ('AV','Portahidroaviones','Seaplane Tender');
INSERT INTO tipo_barco VALUES ('AO','Buque nodriza','Fleet Oiler');
INSERT INTO tipo_barco VALUES ('AS','Buque nodriza de submarinos','Submarine Tender');
INSERT INTO tipo_barco VALUES ('LHA','Buque de asalto anfibio','Landing Helicoper Assault');
INSERT INTO tipo_barco VALUES ('AR','Buque de reparación','Repair Ship');
INSERT INTO tipo_barco VALUES ('CT','Crucero de entrenamiento','Training Cruiser');
INSERT INTO tipo_barco VALUES ('CLT','Crucero torpedero','Torpedo Cruiser');
INSERT INTO tipo_barco VALUES ('SS','Submarino','Submarine');
INSERT INTO tipo_barco VALUES ('SSV','Submarino de aviación','Aviation Submarine');

/*INSERCIÓN DE DATOS DE BARCOS Y COMANDANTES*/
INSERT INTO COMANDANTE VALUES(1,'Isoroku Yamamoto','Almirante','IJN');
INSERT INTO BARCO VALUES('IJN_1','Yamato','Yamato',256,11,38.9,
'9 cañones de 460 mm (3×3), 6 cañones de 155 mm (2×3), 24 cañones de 127 mm (12×2), 162 cañones de 25 mm (52×3, 6×1), 4 cañones de 13 mm (2×2)',
'12 calderas Kampon, 4 turbinas de vapor, 4 hélices de tres palas',
150000,13000,2800,7,'Tiene 2 catapultas para hidroaviones',
TO_DATE('8/8/1940','DD/MM/YYYY'),
'Hundido el 7 de abril de 1945 al norte de Okinawa por masivo ataque aéreo',
'IJN','BB',1);

INSERT INTO COMANDANTE VALUES(2,'Takeo Kurita','Vicealmirante','IJN');
INSERT INTO BARCO VALUES('IJN_2','Musashi','Yamato',256,10.86,36.9,
'9 cañones de 460 mm (3x3),6 cañones de 155 mm (2x3),12 cañones de 127 mm (6x2),130 cañones de 25 mm AA (32x3, 34x1),4 cañones de 13,2 mm AA (2x2)',
'12 calderas Kampon, 4 turbinas de vapor, 4 hélices de tres palas',
150000,13000,2800,7,'Tiene 2 catapultas para hidroaviones',
TO_DATE('1/11/1940','DD/MM/YYYY'),
'Hundido el 24 de octubre de 1944 durante la batalla del mar de Sibuyán.',
'IJN','BB',2);

INSERT INTO COMANDANTE VALUES(3,'Hideo Yano','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_3','Nagato','Nagato',221.03,9.5,34.59,
'8 cañones de 410 mm, 18 cañones de 140 mm, 8 cañones AA de 127 mm, 98 cañones antiaéreos de 25 mm',
'4 hélices de tres palas',
80000,10200,1368,3,null,
TO_DATE('9/11/1919','DD/MM/YYYY'),
'Hundido como barco objetivo en prueba nuclear en 1946 (Operación Crossroads).',
'IJN','BB',3);

INSERT INTO COMANDANTE VALUES(4,'Gunji Kogure','Contraalmirante','IJN');
INSERT INTO BARCO VALUES('IJN_4','Mutsu','Nagato',221.03,9.5,34.59,
'8 cañones de 410 mm, 18 cañones de 140 mm, 8 cañones AA de 127 mm, 98 cañones antiaéreos de 25 mm',
'4 hélices de tres palas',
80000,10200,1368,3,null,
TO_DATE('31/5/1920','DD/MM/YYYY'),
'Hundido el 8 de junio de 1943 por explosión interna',
'IJN','BB',4);

INSERT INTO COMANDANTE VALUES(5,'Nishizou Tsukahara','Almirante','IJN');
INSERT INTO BARCO VALUES('IJN_5','Akagi','Akagi',260.68,8.71,31.32,
'10 (después 6) cañones de 200 mm, 12 cañones de 120 mm, 28 cañones antiaéreos de 25 mm',
'Turbinas de vapor, 19 calderas, 4 hélices de 3 palas',
133000,15200,1630,66+25,null,
TO_DATE('22/4/1925','DD/MM/YYYY'),
'Hundido por ataque aéreo norteamericano en la Batalla de Midway',
'IJN','CV',5);

INSERT INTO COMANDANTE VALUES(6,'Jisaku Okada','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_6','Kaga','Kaga',260.7,8.7,31.3,
'10 cañones de 200 mm, 16 cañones de 127 mm, 22 cañones antiaéreos de 25 mm',
'8 Calderas Kanpon, 4 Turbinas de vapor, 4 hélices de 3 palas',
91000,13000,2000,72+18,null,
TO_DATE('17/11/1921','DD/MM/YYYY'),
'Hundido por ataque aéreo norteamericano en la Batalla de Midway',
'IJN','CV',6);

INSERT INTO COMANDANTE VALUES(7,'Ryusaku Yanagimoto','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_7','Souryuu','Souryuu',222.7,7.44,21,
'12 cañones de 127 mm, 26 cañones antiaéreos de 25 mm, 15 ametralladoras antiaéreas de 13,2 mm',
'Turbinas de vapor, 4 hélices',
152000,14353,1250,71,null,
TO_DATE('23/12/1935','DD/MM/YYYY'),
'Hundido por ataque aéreo norteamericano en la Batalla de Midway',
'IJN','CV',7);

INSERT INTO COMANDANTE VALUES(8,'Tamon Yamaguchi','Contraalmirante','IJN');
INSERT INTO BARCO VALUES('IJN_8','Hiryuu','Souryuu',222,7.74,22.3,
'12 cañones de 127 mm, 31 cañones antiaéreos de 25 mm',
'Turbinas de vapor, 4 hélices',
152000,14353,1101,73,null,
TO_DATE('15/11/1937','DD/MM/YYYY'),
'Hundido por ataque aéreo norteamericano en la Batalla de Midway',
'IJN','CV',8);

INSERT INTO COMANDANTE VALUES(9,'Raymond Spruance','Almirante','USN');
INSERT INTO BARCO VALUES('USN_1','Enterprise','	Yorktown',251.4,7.91,33.4,
'8 cañones simples 127 mm/38, 16 cañones 1.1"/75 (4 × 4), 24 ametralladoras de 12,7 mm, 24 cañones Oerlikon 20 mm añadidos a principios de 1942.',
'9 calderas Babcock y Wilcox, 4 turbinas Parsons, 4 ejes',
120000,23150,2217,90,'3 ascensores, 2 catapultas hidrahulicas en la cubierta de vuelo, 1 catapulta hidráulica en la cubierta del hangar',
TO_DATE('23/10/1936','DD/MM/YYYY'),
'Desguazado entre 1958 y 1960',
'USN','CV',9);

INSERT INTO COMANDANTE VALUES(10,'Elliott Buckmaster','Vicealmirante','USN');
INSERT INTO BARCO VALUES('USN_2','Yorktown','Yorktown',251.4,7.91,33.4,
'8 cañones simples 127 mm/38, 16 cañones 1.1"/75 (4 × 4), 24 ametralladoras de 12,7 mm, 24 cañones Oerlikon 20 mm añadidos a principios de 1942.',
'9 calderas Babcock y Wilcox, 4 turbinas Parsons, 4 ejes',
120000,23150,2217,90,'3 ascensores, 2 catapultas hidrahulicas en la cubierta de vuelo, 1 catapulta hidráulica en la cubierta del hangar',
TO_DATE('4/4/1936','DD/MM/YYYY'),
'Hundido por ataque aéreo japonés en la batalla de Midway',
'USN','CV',10);

INSERT INTO COMANDANTE VALUES(11,'Charles Perry Mason','Vicealmirante','USN');
INSERT INTO BARCO VALUES('USN_3','Hornet','Yorktown',251.4,7.91,33.4,
'8 cañones simples 127 mm/38, 16 cañones 1.1"/75 (4 × 4), 24 ametralladoras de 12,7 mm, 24 cañones Oerlikon 20 mm añadidos a principios de 1942.',
'9 calderas Babcock y Wilcox, 4 turbinas Parsons, 4 ejes',
120000,23150,2217,90,'3 ascensores, 2 catapultas hidrahulicas en la cubierta de vuelo, 1 catapulta hidráulica en la cubierta del hangar',
TO_DATE('14/12/1940','DD/MM/YYYY'),
'Hundido en la Batalla de las islas de Santa Cruz',
'USN','CV',11);

INSERT INTO COMANDANTE VALUES(12,'Arimoto Terumichi','Comandante','IJN');
INSERT INTO BARCO VALUES('IJN_9','Akigumo','Kagerou',118.5,3.76,10.8,
'Seis cañones de 127 mm, Hasta 28 cañones antiaéreos de 25 mm, Hasta 10 ametralladoras antiaéreas de 13 mm, 16 cargas de profundidad, Ocho tubos lanzatorpedos de 610 mm en dos lanzadores cuádruples.',
'Tres calderas, dos turbinas, dos hélices tripala',
52000,9260,240,0,null,
TO_DATE('11/4/1940','DD/MM/YYYY'),
'Hundido el 11 de abril de 1944',
'IJN','DD',12);

INSERT INTO COMANDANTE VALUES(13,'Nishio Hidehiko','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_10','Chikuma','Tone',201.5,6.47,18.5,
'Ocho cañones de 203 mm en 4 torretas dobles (todas a proa), ocho cañones (superficie y AA) de 127 mm en 4 torretas dobles, doce antiaéreos de 25 mm, doce tubos lanzatorpedos de 610 mm en cuatro montajes triples',
'ocho calderas, cuatro turbinas Gihon de 152.000 CV, 4 hélices',
80000,14816,850,4,'2 radares de superficie Tipo 21, 1 radar aéreo Tipo 20, 1 radar aéreo Tipo 13.',
TO_DATE('19/3/1938','DD/MM/YYYY'),
'Hundido el 25 de octubre de 1944 tras la batalla de Samar',
'IJN','CAV',13);

INSERT INTO COMANDANTE VALUES(14,'Hara Teizo','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_11','Tone','Tone',198.75,6.4,18.5,
'Ocho cañones de 203 mm en 4 torretas dobles (todas a proa), ocho cañones (superficie y AA) de 127 mm en 4 torretas dobles, doce antiaéreos de 25 mm, doce tubos lanzatorpedos de 610 mm en cuatro montajes triples',
'ocho calderas, cuatro turbinas Gihon de 152.000 CV, 4 hélices',
80000,22224,850,4,'2 radares de superficie Tipo 21, 1 radar aéreo Tipo 20, 1 radar aéreo Tipo 13.',
TO_DATE('21/11/1937','DD/MM/YYYY'),
'Hundido en el puerto de Kure en julio de 1945',
'IJN','CAV',14);


INSERT INTO COMANDANTE VALUES(15,'Beppu Akitomo','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_12','Chiyoda','Chitose',192.5,7.21,18.8,
'4 cañones doble uso de 127 mm en cuatro montajes dobles Tipo 89, 12 cañones antiaéreos de 25 mm en seis montajes dobles',
'4 calderas, dos turbinas de vapor, dos motores diésel, dos hélices, un timón',
44000,14816,800,24,'12 Type A, B or C mini submarinos',
TO_DATE('19/11/1937','DD/MM/YYYY'),
'Hundido el 25 de octubre de 1944',
'IJN','AV',15);

INSERT INTO COMANDANTE VALUES(16,'Ikeuchi Masamichi','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_13','Chitose','Chitose',192.5,7.21,18.8,
'4 cañones doble uso de 127 mm en cuatro montajes dobles Tipo 89, 12 cañones antiaéreos de 25 mm en seis montajes dobles',
'4 calderas, dos turbinas de vapor, dos motores diésel, dos hélices, un timón',
44000,14816,800,24,'12 Type A, B or C mini submarinos',
TO_DATE('29/11/1936','DD/MM/YYYY'),
'Hundido el 25 de octubre de 1944',
'IJN','AV',16);

INSERT INTO COMANDANTE VALUES(17,'Kouzou Satou','Almirante','IJN');
INSERT INTO BARCO VALUES('IJN_14','Fusou','Fusou',205,8.69,28.65,
'12 cañones de 356 mm (6 × 2), 14 cañones de 152 mm, 2 cañones AA de 127 mm, 95 cañones AA de 25 mm',
'6 calderas Kanpon acuatubulares, 4 turbinas de vapor, 4 hélices',
75000,20372,1400,3,'1 radar tipo 21, 1 radar tipo 13, 1 catapulta',
TO_DATE('28/3/1914','DD/MM/YYYY'),
'Hundido el 25 de octubre de 1944 en la batalla del estrecho de Surigao',
'IJN','BBV',17);


INSERT INTO COMANDANTE VALUES(18,'Shitsuda Teiichiro','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_15','Yamashiro','Fusou',212.75,9.69,30.64,
'12 cañones de 356 mm (6 × 2), 14 cañones de 152 mm, 8 cañones AA de 127 mm, 37 cañones AA de 25 mm',
'6 calderas Kanpon acuatubulares, 4 turbinas de vapor, 4 hélices',
75000,21853,1400,3,'1 radar tipo 21, 1 radar tipo 13, 1 catapulta',
TO_DATE('3/11/1915','DD/MM/YYYY'),
'Hundido el 25 de octubre de 1944 en la batalla del estrecho de Surigao',
'IJN','BBV',18);

INSERT INTO COMANDANTE VALUES(19,'Funakoshi Kajishiro','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_16','Haruna','Kongou',222,9.7,31,
'8 x 356 mm (4x2), 16 x 152 mm (8x2), 8 x 127 mm (4x2), 118 x 25 mm antiaéreos',
'Turbinas de vapor, 4 hélices de 3 palas',
136000,17594,1360,3,null,
TO_DATE('14/12/1913','DD/MM/YYYY'),
'Hundido el 28 de julio de 1945 por ataque aéreo en su amarre de Kure, desguazado en 1946',
'IJN','FBB',19);

INSERT INTO COMANDANTE VALUES(20,'Nakano Naoe','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_17','Kongou','Kongou',222,9.7,31,
'8 x 356 mm (4x2), 16 x 152 mm (8x2), 8 x 127 mm (4x2), 118 x 25 mm antiaéreos',
'Turbinas de vapor, 4 hélices de 3 palas',
136000,17594,1360,3,null,
TO_DATE('18/5/1912','DD/MM/YYYY'),
'Hundido por torpedeamiento el 21 de noviembre de 1944, en el estrecho de Formosa',
'IJN','FBB',20);

INSERT INTO COMANDANTE VALUES(21,'Kamaya Rokuro','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_18','Kirishima','Kongou',222,9.7,31,
'8 x 356 mm (4x2), 16 x 152 mm (8x2), 8 x 127 mm (4x2), 118 x 25 mm antiaéreos',
'Turbinas de vapor, 4 hélices de 3 palas',
136000,17594,1360,3,null,
TO_DATE('1/12/1913','DD/MM/YYYY'),
'Hundido durante la batalla naval de Guadalcanal el 15 de noviembre de 1942',
'IJN','FBB',21);

INSERT INTO COMANDANTE VALUES(22,'Takagi Shichitaro','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_19','Hiei','Kongou',222,9.7,31,
'8 x 356 mm (4x2), 16 x 152 mm (8x2), 8 x 127 mm (4x2), 118 x 25 mm antiaéreos',
'Turbinas de vapor, 4 hélices de 3 palas',
136000,17594,1360,3,null,
TO_DATE('21/11/1912','DD/MM/YYYY'),
'Hundido el 13 de noviembre de 1942',
'IJN','FBB',22);

INSERT INTO COMANDANTE VALUES(23,'Kaneoka Kunizo','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_20','Houshou','Houshou',168.25,6.17,17.98,
'4 × single 14 cm (5.5 in) guns, 2 × single 8 cm (3 in) AA guns',
'2 shafts; 2 geared steam turbines',
30000,16075,512,15,null,
TO_DATE('13/11/1921','DD/MM/YYYY'),
'Desguazado el 2 de Septiembre de 1946',
'IJN','CVL',23);

INSERT INTO COMANDANTE VALUES(24,'Samejima Tomoshige','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_21','Mogami','Mogami',198,5.89,20.2,
'6 × 20 cm/50 3rd Year Type naval guns[3] (3x2), 8 × 12.7 cm/40 Type 89 naval gun (4×2), 30 × Type 96 25 mm AT/AA Gun guns, 12 × Type 93 torpedoes (4 × 3 tube rotating launchers + 12 reloads)',
'4-shaft geared turbines, 10 Kampon boilers',
152000,14816,850,11,null,
TO_DATE('27/10/1934','DD/MM/YYYY'),
'Hundido el 25 de octubre de 1944 en el transcurso de la Batalla del estrecho de Surigao',
'IJN','CAV',24);

INSERT INTO COMANDANTE VALUES(25,'Suzukida Kozo','Capitán','IJN');
INSERT INTO BARCO VALUES('IJN_22','Mikuma','Mogami',198,5.9,20.2,
'6 × 20 cm/50 3rd Year Type naval guns[3] (3x2), 8 × 12.7 cm/40 Type 89 naval gun (4×2), 30 × Type 96 25 mm AT/AA Gun guns, 12 × Type 93 torpedoes (4 × 3 tube rotating launchers + 12 reloads)',
'4-shaft geared turbines, 10 Kampon boilers',
152000,14816,850,3,null,
TO_DATE('31/5/1934','DD/MM/YYYY'),
'Hundido el 6 de junio de 1942 por ataque aéreo en la batalla de Midway',
'IJN','CAV',25);

INSERT INTO COMANDANTE VALUES(26,'Samuel P. Jenkins','Capitán','USN');
INSERT INTO BARCO VALUES('USN_4','Atlanta','Atlanta',161.5,6.25,16.2,
'16 cañones 127 mm, 16 cañones 28 mm, 16 cañones 40 mm, 8 cañones 20 mm, 8 tubos lanzatorpedos 533 mm',
'2 turbinas y 4 calderas',
75000,23150,673,0,null,
TO_DATE('6/9/1941','DD/MM/YYYY'),
'Torpedeado después de sufrir daño severo en la batalla de Guadalcanal por fuego amigo del USS San Francisco, 13 Noviembre 1942',
'USN','CL',26);

INSERT INTO COMANDANTE VALUES(27,'Gordon W. Haines','Capitán','USN');
INSERT INTO BARCO VALUES('USN_5','Minneapolis','New Orleans',179,5.92,18.82,
'9 × 8 in (200 mm)/55 caliber guns (3x3), 8 × 5 in (130 mm)/25 caliber anti-aircraft guns, 2 × 3-pounder 47 mm (1.9 in) saluting guns, 8 × caliber 0.50 in (13 mm) machine guns',
'4 × Westinghouse geared turbines, 4 × screws',
107000,23150,102+817,4,'2 Catapultas',
TO_DATE('27/6/1931','DD/MM/YYYY'),
'Desguazado en Chester, Pennsylvania, Julio 1960',
'USN','CA',27);

INSERT INTO COMANDANTE VALUES(28,'Allen B. Reed','Capitán','USN');
INSERT INTO BARCO VALUES('USN_6','New Orleans','New Orleans',179,5.92,18.82,
'9 × 8 in (200 mm)/55 caliber guns (3x3), 8 × 5 in (130 mm)/25 caliber anti-aircraft guns, 2 × 3-pounder 47 mm (1.9 in) saluting guns, 8 × caliber 0.50 in (13 mm) machine guns',
'4 × Westinghouse geared turbines, 4 × screws',
107000,23150,102+817,4,'2 Catapultas',
TO_DATE('14/3/1931','DD/MM/YYYY'),
'Vendido para chatarra el 22 Septiembre de 1959',
'USN','CA',28);

INSERT INTO COMANDANTE VALUES(29,'Walter N. Vernou','Capitán','USN');
INSERT INTO BARCO VALUES('USN_7','Northampton','Northampton',182.96,7.06,20.14,
'9 × 8 in (203 mm)/55 caliber guns (3x3), 4 × 5 in (127 mm)/25 caliber anti-aircraft guns, 2 × 3-pounder 47 mm (1.9 in) saluting guns, 6 × 21 in (533 mm) torpedo tubes',
'4 × Parsons reduction steam turbines, 4 × screws',
107000,23150,102+817,4,'2 Catapultas',
TO_DATE('12/4/1928','DD/MM/YYYY'),
'Hundido durante la Batalla de Tassafaronga el 1 de Diciembre de 1942',
'USN','CA',29);

INSERT INTO COMANDANTE VALUES(30,'Arnold E. True','Comandante','USN');
INSERT INTO BARCO VALUES('USN_8','Hammann','Sims',106.15,4.07,11,
'5 × 5 inch/38, in single mounts, 4 × .50 caliber/90, in single mounts, 8 × 21 inch torpedo tubes in two quadruple mounts, 2 × depth charge track, 10 depth charges',
'High-pressure super-heated boilers, geared turbines with twin screws',
50000,6778,192,0,null,
TO_DATE('17/1/1938','DD/MM/YYYY'),
'Hundido, en la batalla de Midway por el submarino japonés I-168 el 6 de Junio de 1942 (84 muertos)',
'USN','DD',30);

INSERT INTO CONTIENDA VALUES(1,'Batalla de Midway',TO_DATE('4/6/1942','DD/MM/YYYY'));
INSERT INTO PARTICIPA (SELECT CODIGO_BARCO,1 FROM BARCO WHERE CODIGO_BARCO NOT IN('IJN_14','IJN_15','IJN_2'));

INSERT INTO CONTIENDA VALUES(2,'Batalla de del Golfo de Leyte -Preludio- Paso de Palawan',TO_DATE('23/10/1944','DD/MM/YYYY'));
INSERT INTO CONTIENDA VALUES(3,'Batalla de del Golfo de Leyte -Parte 01- Batalla del mar de Sibuyan',TO_DATE('24/10/1944','DD/MM/YYYY'));
INSERT INTO CONTIENDA VALUES(4,'Batalla de del Golfo de Leyte -Parte 02- Batalla del estrecho de Surigao',TO_DATE('25/10/1944','DD/MM/YYYY'));
INSERT INTO CONTIENDA VALUES(5,'Batalla de del Golfo de Leyte -Parte 03- Batalla de Samar',TO_DATE('25/10/1944','DD/MM/YYYY'));
INSERT INTO CONTIENDA VALUES(6,'Batalla de del Golfo de Leyte -Parte 04- Batalla del cabo Engaño',TO_DATE('26/10/1944','DD/MM/YYYY'));

INSERT INTO COMANDANTE VALUES(31,'George R. Henderson','Vicealmirante','USN');
INSERT INTO BARCO VALUES('USN_9','Princeton','Independence',189.7,7.9,33.3,
'22 × Bofors 40 mm guns, 16 × Oerlikon 20 mm cannons',
'Tres calderas, dos turbinas, dos hélices tripala',
120000,23150,1569,45,null,
TO_DATE('2/6/1941','DD/MM/YYYY'),
'Hundido, en la batalla de golfo de Leyte 1944',
'USN','CVL',31);
INSERT INTO PARTICIPA VALUES('USN_9',3);

INSERT INTO COMANDANTE VALUES(32,'William S. Stovall, Jr.','Comandante','USN');
INSERT INTO BARCO VALUES('USN_10','Darter','Gato',95.02,5.2,8.31,
'10 × 21-inch (533 mm) torpedo tubes
6 forward, 4 aft
24 torpedoes[5]
1 × 3-inch (76 mm) / 50 caliber deck gun[5]
Bofors 40 mm and Oerlikon 20 mm cannon',
'4 × General Motors Model 16-248 V16 Diesel engines driving electric generators, 2 × 126-cell Sargo batteries, 4 × high-speed General Electric electric motors with reduction gears, two propellers',
2740,20372,60,0,'hasta 48h en inmersión',
TO_DATE('20/10/1942','DD/MM/YYYY'),
'Encallado en el estrecho de Palawan y hundido el 24 de octubre de 1944',
'USN','SS',32);
INSERT INTO PARTICIPA VALUES('USN_10',2);

INSERT INTO COMANDANTE VALUES(33,'Joseph F. Enright','Teniente','USN');
INSERT INTO BARCO VALUES('USN_11','Dace','Gato',95.02,5.2,8.31,
'10 × 21-inch (533 mm) torpedo tubes
6 forward, 4 aft
24 torpedoes[5]
1 × 3-inch (76 mm) / 50 caliber deck gun[5]
Bofors 40 mm and Oerlikon 20 mm cannon',
'4 × General Motors Model 16-248 V16 Diesel engines driving electric generators, 2 × 126-cell Sargo batteries, 4 × high-speed General Electric electric motors with reduction gears, two propellers',
2740,20372,60,0,'hasta 48h en inmersión',
TO_DATE('22/7/1942','DD/MM/YYYY'),
'Convertido a GUPPY IB y trasladado a Italia el 31 de enero de 1955',
'USN','SS',33);
INSERT INTO PARTICIPA VALUES('USN_11',2);



ALTER TRIGGER T_BARCO_AUDITORIA DISABLE;
ALTER TRIGGER T_BARCO_AUDITORIA DISABLE;

SELECT * FROM COMANDANTE ORDER BY id_com;
SELECT * FROM BARCO ORDER BY CODIGO_BARCO;
COMMIT;







