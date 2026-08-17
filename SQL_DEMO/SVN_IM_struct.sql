/*
 Navicat MariaDB Data Transfer

 Source Server         : VPS
 Source Server Type    : MariaDB
 Source Server Version : 100521 (10.5.21-MariaDB-1:10.5.21+maria~ubu2004)
 Source Host           : 89.44.137.153:3306
 Source Schema         : SVN_IM

 Target Server Type    : MariaDB
 Target Server Version : 100521 (10.5.21-MariaDB-1:10.5.21+maria~ubu2004)
 File Encoding         : 65001

 Date: 24/03/2026 12:02:34
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for Agenti
-- ----------------------------
DROP TABLE IF EXISTS `Agenti`;
CREATE TABLE `Agenti`  (
  `IdAgent` int(11) NOT NULL AUTO_INCREMENT,
  `NumeAgent` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `IdSursa` int(11) NOT NULL,
  `aTelefon` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `aMail` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Ascuns` tinyint(1) NOT NULL DEFAULT 0,
  `Implicit` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdAgent`) USING BTREE,
  INDEX `IdSursa`(`IdSursa`) USING BTREE,
  INDEX `idx_ordering`(`Ascuns`, `NumeAgent`, `IdSursa`) USING BTREE,
  INDEX `idx_covering`(`Ascuns`, `NumeAgent`, `IdSursa`, `aTelefon`, `aMail`) USING BTREE,
  INDEX `NumeAgent`(`NumeAgent`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `idx_global2`(`NumeAgent`, `aTelefon`, `aMail`) USING BTREE,
  INDEX `IdSursa_2`(`IdSursa`, `IdAgent`) USING BTREE,
  INDEX `idx_query_optimized`(`NumeAgent`, `IdSursa`, `IdAgent`, `aTelefon`, `aMail`, `Ascuns`, `Implicit`) USING BTREE,
  CONSTRAINT `Agenti__SursaLead` FOREIGN KEY (`IdSursa`) REFERENCES `SursaLead` (`IdSursa`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 2128 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Alte_Config
-- ----------------------------
DROP TABLE IF EXISTS `Alte_Config`;
CREATE TABLE `Alte_Config`  (
  `IdTbl` int(11) NOT NULL AUTO_INCREMENT,
  `Tbl` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `MainField` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Afisare` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `Pozitie` int(11) NULL DEFAULT NULL,
  `ExtraInfo` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `ExtraFields` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`IdTbl`) USING BTREE,
  INDEX `idx_ordering_where`(`Ascuns`, `Afisare`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Banci
-- ----------------------------
DROP TABLE IF EXISTS `Banci`;
CREATE TABLE `Banci`  (
  `IdBanca` int(11) NOT NULL AUTO_INCREMENT,
  `Banca` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Ascuns` tinyint(1) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdBanca`) USING BTREE,
  INDEX `idx_ordering_Banci_Ascuns`(`Ascuns`, `Banca`, `IdBanca`) USING BTREE,
  INDEX `idx_Banci_IdBanca`(`Banca`, `IdBanca`) USING BTREE,
  INDEX `Banca`(`Banca`) USING BTREE,
  INDEX `Ascuns`(`Ascuns`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `idx_query_optimized`(`Banca`, `IdBanca`, `Ascuns`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Banci_Documente
-- ----------------------------
DROP TABLE IF EXISTS `Banci_Documente`;
CREATE TABLE `Banci_Documente`  (
  `IdDocument` int(11) NOT NULL AUTO_INCREMENT,
  `IdBanca` int(11) NOT NULL,
  `DenumireDocument` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Document` mediumblob NULL DEFAULT NULL,
  PRIMARY KEY (`IdDocument`) USING BTREE,
  INDEX `IdDocument`(`IdDocument`) USING BTREE,
  INDEX `DenumireDocument`(`DenumireDocument`) USING BTREE,
  INDEX `Banci_Documente__Banci`(`IdBanca`) USING BTREE,
  CONSTRAINT `Banci_Documente__Banci` FOREIGN KEY (`IdBanca`) REFERENCES `Banci` (`IdBanca`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Baza
-- ----------------------------
DROP TABLE IF EXISTS `Baza`;
CREATE TABLE `Baza`  (
  `IdBaza` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Număr identificare simulare',
  `IdLead` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `IdClient` int(11) NOT NULL,
  `IdSursa` int(11) NOT NULL,
  `IdAgent` int(11) NOT NULL,
  `IdConsultant` int(11) NOT NULL,
  `DataPrimire` datetime NOT NULL DEFAULT current_timestamp(),
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `tmp` int(11) NULL DEFAULT NULL,
  `Nou` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdBaza`) USING BTREE,
  INDEX `IdLead`(`IdLead`) USING BTREE,
  INDEX `IdAgent`(`IdAgent`) USING BTREE,
  INDEX `IdClient`(`IdClient`) USING BTREE,
  INDEX `IdConsultant`(`IdConsultant`) USING BTREE,
  INDEX `IdSursa`(`IdSursa`) USING BTREE,
  INDEX `Ascuns`(`Ascuns`, `IdAgent`) USING BTREE,
  INDEX `IdBaza`(`IdBaza`, `Ascuns`) USING BTREE,
  INDEX `idx_view_Filtru`(`Ascuns`) USING BTREE,
  INDEX `DataModificare`(`Ascuns`, `DataModificare`) USING BTREE,
  INDEX `idx_baza_client_consultant`(`IdClient`, `IdConsultant`, `IdBaza`) USING BTREE,
  INDEX `idx_baza_entry`(`Ascuns`, `IdAgent`, `IdSursa`, `IdConsultant`, `IdBaza`) USING BTREE,
  INDEX `idx_covering_2`(`IdSursa`, `Ascuns`, `IdClient`) USING BTREE,
  INDEX `idx_sursa_ascuns_baza`(`Ascuns`, `IdSursa`, `IdBaza`) USING BTREE,
  CONSTRAINT `Baza_Consultanti` FOREIGN KEY (`IdConsultant`) REFERENCES `SVN_00`.`Consultanti` (`IdConsultant`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Baza__Agenti` FOREIGN KEY (`IdAgent`) REFERENCES `Agenti` (`IdAgent`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Baza__Clienti` FOREIGN KEY (`IdClient`) REFERENCES `Clienti` (`IdClient`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Baza__SursaLead` FOREIGN KEY (`IdSursa`) REFERENCES `SursaLead` (`IdSursa`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 93578 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Baza_Alarme
-- ----------------------------
DROP TABLE IF EXISTS `Baza_Alarme`;
CREATE TABLE `Baza_Alarme`  (
  `IdAlarma` int(11) NOT NULL AUTO_INCREMENT,
  `IdBaza` int(11) NOT NULL,
  `IdConsultant` int(11) NOT NULL,
  `IdConsultantAdd` int(11) NOT NULL,
  `Nume` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Detalii` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `ToataZiua` tinyint(4) NULL DEFAULT NULL,
  `DataOra` datetime NOT NULL,
  `Repeta` tinyint(4) NOT NULL DEFAULT 0,
  `TipInterval` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Interval` int(11) NULL DEFAULT NULL,
  `Activa` tinyint(4) NOT NULL DEFAULT 1,
  `SeAnuleaza` tinyint(4) NOT NULL DEFAULT 1,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdAlarma`) USING BTREE,
  INDEX `Baza_Alarme__Consultanti`(`IdConsultant`) USING BTREE,
  INDEX `Baza_Alarma__Baza`(`IdBaza`) USING BTREE,
  CONSTRAINT `Baza_Alarma__Baza` FOREIGN KEY (`IdBaza`) REFERENCES `Baza` (`IdBaza`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Baza_Alarme__Consultanti` FOREIGN KEY (`IdConsultant`) REFERENCES `SVN_00`.`Consultanti` (`IdConsultant`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Baza_FC
-- ----------------------------
DROP TABLE IF EXISTS `Baza_FC`;
CREATE TABLE `Baza_FC`  (
  `IdBR` int(11) NOT NULL,
  `FormatCondition` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `BackColor` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `ForeColor` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `B1` int(11) NULL DEFAULT NULL,
  `B2` int(11) NULL DEFAULT NULL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdBR`) USING BTREE,
  INDEX `BackColor`(`BackColor`) USING BTREE,
  INDEX `FormatCondition`(`FormatCondition`) USING BTREE,
  INDEX `ForeColor`(`ForeColor`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Baza_FeedBack
-- ----------------------------
DROP TABLE IF EXISTS `Baza_FeedBack`;
CREATE TABLE `Baza_FeedBack`  (
  `IdFeedBack` int(11) NOT NULL AUTO_INCREMENT,
  `IdBaza` int(11) NOT NULL,
  `IdStatus` int(11) NOT NULL,
  `IDSG` int(11) NOT NULL DEFAULT 4,
  `IdConsultant` int(11) NULL DEFAULT NULL,
  `DataConectare` date NOT NULL DEFAULT current_timestamp(),
  `Feedback` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `DataReconectare` date NULL DEFAULT NULL,
  `MailTrimis` tinyint(1) NULL DEFAULT 0,
  `Intalnire` tinyint(1) NOT NULL DEFAULT 0,
  `Ora` int(11) NULL DEFAULT NULL,
  `Minut` int(11) NULL DEFAULT NULL,
  `Primar` tinyint(4) NOT NULL DEFAULT 0,
  `IdLead` int(11) NULL DEFAULT NULL,
  `DIF` int(11) GENERATED ALWAYS AS (if(`IDSG` = 2,to_days(current_timestamp()) - to_days(`DataReconectare`),NULL)) VIRTUAL,
  `DIFF` int(11) GENERATED ALWAYS AS (case when `DataReconectare` is null then NULL when cast(`DataReconectare` as date) = curdate() then 1 when unix_timestamp(`DataReconectare`) between unix_timestamp(curdate()) and unix_timestamp(curdate() + interval 4 day) then 2 when unix_timestamp(`DataReconectare`) < unix_timestamp(curdate() + interval 4 day) then 3 end) VIRTUAL,
  `Ipotecare_ro` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `DataAdaugare` datetime NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdFeedBack`, `IdBaza`, `IdStatus`) USING BTREE,
  INDEX `IdConsultant`(`IdConsultant`) USING BTREE,
  INDEX `DataConectare`(`DataConectare`) USING BTREE,
  INDEX `DataReconectare`(`DataReconectare`) USING BTREE,
  INDEX `IdLead`(`IdLead`) USING BTREE,
  INDEX `IDSG`(`IDSG`) USING BTREE,
  INDEX `IdStatus`(`IdStatus`) USING BTREE,
  INDEX `IdFeedBack`(`IdFeedBack`, `IdBaza`, `IdStatus`, `IDSG`, `DataConectare`, `DataReconectare`) USING BTREE,
  INDEX `Baza_FeedBack_ibfk_1`(`IdBaza`, `IdFeedBack`, `IdStatus`, `IDSG`, `DataConectare`, `DataReconectare`) USING BTREE,
  INDEX `IdBaza`(`IdBaza`) USING BTREE,
  INDEX `Primar`(`Primar`) USING BTREE,
  INDEX `idx_bf_baza_primar`(`IdBaza`, `Primar`) USING BTREE,
  INDEX `idx_grouping`(`IdStatus`, `IdBaza`) USING BTREE,
  CONSTRAINT `Baza_FeedBack__Baza` FOREIGN KEY (`IdBaza`) REFERENCES `Baza` (`IdBaza`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Baza_FeedBack__Baza_Status` FOREIGN KEY (`IdStatus`) REFERENCES `Baza_Status` (`IdStatus`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Baza_FeedBack__Baza_Status_Grup` FOREIGN KEY (`IDSG`) REFERENCES `Baza_Status_Grup` (`IDSG`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Baza_FeedBack__Consultanti` FOREIGN KEY (`IdConsultant`) REFERENCES `SVN_00`.`Consultanti` (`IdConsultant`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 366774 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Nu genera legatura la Consultanti pentru ca e posibil ca feedback-ul sa fie adaugat de alt consultant decat cel care a creeat randul initial!' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Baza_Status
-- ----------------------------
DROP TABLE IF EXISTS `Baza_Status`;
CREATE TABLE `Baza_Status`  (
  `IdStatus` int(11) NOT NULL AUTO_INCREMENT,
  `FelStatus` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `TipStatus` int(11) NULL DEFAULT NULL,
  `BackColor` int(11) NULL DEFAULT NULL,
  `ForeColor` int(11) NULL DEFAULT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `IDSG` int(11) NULL DEFAULT NULL,
  `FontName` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `FontSize` int(11) NULL DEFAULT NULL,
  `FontColor` int(11) NULL DEFAULT NULL,
  `FontBold` tinyint(4) NULL DEFAULT NULL,
  `FontItalic` tinyint(4) NULL DEFAULT NULL,
  `FontUnderline` tinyint(4) NULL DEFAULT NULL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdStatus`) USING BTREE,
  INDEX `IDSG`(`IDSG`) USING BTREE,
  INDEX `FelStatus`(`FelStatus`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `idx_query_optimized`(`FelStatus`, `IdStatus`, `TipStatus`, `BackColor`, `Ascuns`, `IDSG`) USING BTREE,
  INDEX `idx_filter`(`FelStatus`, `IdStatus`) USING BTREE,
  CONSTRAINT `Baza_Status__Baza_Status_Grup` FOREIGN KEY (`IDSG`) REFERENCES `Baza_Status_Grup` (`IDSG`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE = InnoDB AUTO_INCREMENT = 112 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Status_baza_de_date' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Baza_Status_Grup
-- ----------------------------
DROP TABLE IF EXISTS `Baza_Status_Grup`;
CREATE TABLE `Baza_Status_Grup`  (
  `IDSG` int(11) NOT NULL,
  `GRUP` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Ascuns` tinyint(4) NULL DEFAULT NULL,
  PRIMARY KEY (`IDSG`) USING BTREE,
  INDEX `idx_global`(`GRUP`, `Ascuns`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for C
-- ----------------------------
DROP TABLE IF EXISTS `C`;
CREATE TABLE `C`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `IDC` int(11) NULL DEFAULT NULL,
  `IDU` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `IDC`(`IDC`) USING BTREE,
  INDEX `IDU`(`IDU`) USING BTREE,
  INDEX `IDC_2`(`IDC`, `IDU`) USING BTREE,
  INDEX `IDU_2`(`IDU`, `IDC`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for CCB
-- ----------------------------
DROP TABLE IF EXISTS `CCB`;
CREATE TABLE `CCB`  (
  `IdColoana` int(11) NULL DEFAULT NULL,
  `NumeTabel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `NumeColoana` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `PozitieInitiala` int(11) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for CCD
-- ----------------------------
DROP TABLE IF EXISTS `CCD`;
CREATE TABLE `CCD`  (
  `IdColoana` int(11) NULL DEFAULT NULL,
  `NumeTabel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `NumeColoana` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `PozitieInitiala` int(11) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Clienti
-- ----------------------------
DROP TABLE IF EXISTS `Clienti`;
CREATE TABLE `Clienti`  (
  `IdClient` int(11) NOT NULL AUTO_INCREMENT,
  `RO` tinyint(4) NOT NULL DEFAULT 1,
  `NumeClient` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `CNPClient` varchar(15) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `TelefonP` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `EmailP` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `DataNastere` date NULL DEFAULT NULL,
  `SMS` tinyint(4) NULL DEFAULT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `IdJudet` int(11) NULL DEFAULT NULL,
  `IdLead` int(11) NULL DEFAULT NULL,
  `DIFN` tinyint(4) GENERATED ALWAYS AS (date_format(`DataNastere`,'%m-%d') = date_format(curdate(),'%m-%d')) VIRTUAL,
  `Judet` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Tara` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'RO',
  `IPO` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `DataAdaugare` datetime NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  `PJ` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`IdClient`) USING BTREE,
  INDEX `idx_where_Ascuns`(`Ascuns`, `NumeClient`) USING BTREE,
  INDEX `IdJudet`(`IdJudet`) USING BTREE,
  INDEX `flt_NumeClient`(`NumeClient`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `TelefonP`(`TelefonP`, `NumeClient`) USING BTREE,
  INDEX `DataNastere`(`DataNastere`) USING BTREE,
  INDEX `idx_IdJudex`(`IdJudet`) USING BTREE,
  INDEX `idx_global`(`NumeClient`, `CNPClient`, `TelefonP`, `EmailP`, `DataNastere`, `Ascuns`, `IdJudet`) USING BTREE,
  INDEX `IdClient`(`IdClient`) USING BTREE,
  INDEX `idx_TelefonP_EmailP`(`EmailP`, `TelefonP`, `IdClient`) USING BTREE,
  INDEX `idx_Ascuns`(`Ascuns`) USING BTREE,
  CONSTRAINT `Clienti__Judete` FOREIGN KEY (`IdJudet`) REFERENCES `SVN_00`.`Judete` (`IdJudet`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 93735 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Clienti_Mail
-- ----------------------------
DROP TABLE IF EXISTS `Clienti_Mail`;
CREATE TABLE `Clienti_Mail`  (
  `IdEmail` int(11) NOT NULL AUTO_INCREMENT,
  `IdClient` int(11) NOT NULL,
  `Email` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Primar` tinyint(4) NOT NULL,
  `OK` tinyint(4) NULL DEFAULT 0,
  `NoTrig` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdEmail`) USING BTREE,
  INDEX `Email`(`Email`) USING BTREE,
  INDEX `Primar`(`Primar`) USING BTREE,
  INDEX `IdClient`(`IdClient`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `idx_global`(`Email`, `Primar`, `DataModificare`) USING BTREE,
  INDEX `idx_ct_client_email`(`IdClient`, `Email`) USING BTREE,
  CONSTRAINT `Clienti_Mail__Clienti` FOREIGN KEY (`IdClient`) REFERENCES `Clienti` (`IdClient`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 105695 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Clienti_Note
-- ----------------------------
DROP TABLE IF EXISTS `Clienti_Note`;
CREATE TABLE `Clienti_Note`  (
  `IdClientNota` int(11) NOT NULL AUTO_INCREMENT,
  `IdConsultant` int(11) NULL DEFAULT NULL,
  `IdClient` int(11) NULL DEFAULT NULL,
  `Note` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdClientNota`) USING BTREE,
  INDEX `IDC`(`IdConsultant`) USING BTREE,
  INDEX `IdClient`(`IdClient`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  CONSTRAINT `Clienti_Note_ibfk_1` FOREIGN KEY (`IdClient`) REFERENCES `Clienti` (`IdClient`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `Clienti_Note_ibfk_2` FOREIGN KEY (`IdConsultant`) REFERENCES `SVN_00`.`Consultanti` (`IdConsultant`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Clienti_Telefon
-- ----------------------------
DROP TABLE IF EXISTS `Clienti_Telefon`;
CREATE TABLE `Clienti_Telefon`  (
  `IdTelefon` int(11) NOT NULL AUTO_INCREMENT,
  `IdClient` int(11) NOT NULL,
  `Telefon` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Primar` tinyint(4) NOT NULL,
  `OK` tinyint(4) NOT NULL DEFAULT 0,
  `NoTrig` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdTelefon`) USING BTREE,
  INDEX `Telefon`(`Telefon`) USING BTREE,
  INDEX `Primar`(`Primar`) USING BTREE,
  INDEX `IdClient`(`IdClient`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `idx_global`(`Telefon`, `Primar`, `DataModificare`) USING BTREE,
  INDEX `idx_ct_client_telefon`(`IdClient`, `Telefon`) USING BTREE,
  CONSTRAINT `Clienti_Telefon__Clienti` FOREIGN KEY (`IdClient`) REFERENCES `Clienti` (`IdClient`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 221129 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Codebitori
-- ----------------------------
DROP TABLE IF EXISTS `Codebitori`;
CREATE TABLE `Codebitori`  (
  `IdCod` int(11) NOT NULL AUTO_INCREMENT,
  `IdDosar` int(11) NOT NULL,
  `IdClient` int(11) NOT NULL,
  `NumeCod` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `CNPCod` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TelefonCod` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `EmailCod` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Tara` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `RO` tinyint(4) NULL DEFAULT NULL,
  PRIMARY KEY (`IdCod`) USING BTREE,
  INDEX `IdClient`(`IdClient`) USING BTREE,
  INDEX `idx_covering`(`NumeCod`, `CNPCod`, `TelefonCod`) USING BTREE,
  INDEX `idx_Codebitori_IdDosar_IdCod`(`IdDosar`, `IdCod`) USING BTREE,
  CONSTRAINT `Codebitori_ibfk_1` FOREIGN KEY (`IdDosar`) REFERENCES `Dosar` (`IdDosar`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Codebitori_ibfk_2` FOREIGN KEY (`IdClient`) REFERENCES `Dosar` (`IdClient`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 6670 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Coloane_DESC
-- ----------------------------
DROP TABLE IF EXISTS `Coloane_DESC`;
CREATE TABLE `Coloane_DESC`  (
  `IdColoanaD` int(11) NOT NULL AUTO_INCREMENT,
  `COLUMN_NAME` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `COLUMN_DESC` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`IdColoanaD`) USING BTREE,
  INDEX `IdColoanaD`(`IdColoanaD`) USING BTREE,
  INDEX `COLUMN_NAME`(`COLUMN_NAME`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 38 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Coloane_FC
-- ----------------------------
DROP TABLE IF EXISTS `Coloane_FC`;
CREATE TABLE `Coloane_FC`  (
  `IdFC` int(11) NOT NULL AUTO_INCREMENT,
  `SelTab` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Departamentul coloanei',
  `IdColoana` int(11) NOT NULL COMMENT 'Id din Coloane_Implicite pentru coloana pe care se aplica formatarea',
  `IdColoanaFC` int(11) NULL DEFAULT NULL COMMENT 'Id din Coloane_Implicite pentru coloana in care se cauta valoarea',
  `NumeTabel` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `NumeColoana` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `AfisareColoana` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `IdSemn` int(11) NOT NULL COMMENT 'Id din Semne - folosit doar in VBA',
  `Semn` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Semnul folosit pentru comparatie atunci cand se calculeaza formatarea',
  `Valoare` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Valoarea campului pe care se aplica formatarea - folosit doar in VBA',
  `ValoareJS` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Valoarea campului definit in IdColoanaFC dupa care se calculeaza formatarea (cu Semn) - doar in JS',
  `Enabled` tinyint(4) NULL DEFAULT NULL COMMENT 'Campul este activat sau nu - doar in VBA',
  `BackColor` int(11) NULL DEFAULT NULL,
  `ForeColor` int(11) NULL DEFAULT NULL,
  `FontBold` tinyint(4) NOT NULL DEFAULT 0,
  `FontUnderline` tinyint(4) NOT NULL DEFAULT 0,
  `FontItalic` tinyint(4) NOT NULL DEFAULT 0,
  `Activ` tinyint(4) NOT NULL DEFAULT 1,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'Daca = 1 atunci nu folosesc aceasta formatare',
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  `AltTabel` tinyint(4) NULL DEFAULT 0,
  PRIMARY KEY (`IdFC`) USING BTREE,
  INDEX `Ascuns`(`Ascuns`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `Coloane_FC__Consultanti_Coloane`(`IdColoana`) USING BTREE,
  INDEX `idx_ordering`(`SelTab`, `IdColoana`, `AfisareColoana`) USING BTREE,
  INDEX `Coloane_FC__Semne`(`IdSemn`) USING BTREE,
  CONSTRAINT `Coloane_FC__Consultanti_Coloane__IdColoanaC` FOREIGN KEY (`IdColoana`) REFERENCES `Coloane_Implicite` (`IdColoana`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Coloane_FC__Semne` FOREIGN KEY (`IdSemn`) REFERENCES `Semne` (`IdSemn`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Coloane_Implicite
-- ----------------------------
DROP TABLE IF EXISTS `Coloane_Implicite`;
CREATE TABLE `Coloane_Implicite`  (
  `IdColoana` int(11) NOT NULL AUTO_INCREMENT,
  `TipCamp` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `NumeTabel` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `NumeColoana` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `ColoanaPK` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `AfisareColoana` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `FormatareInitiala` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `PozitieInitiala` int(11) NULL DEFAULT NULL,
  `MarimeInitiala` int(11) NULL DEFAULT NULL,
  `SelTab` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `AscunsImplicit` tinyint(4) NULL DEFAULT NULL,
  `AliniereInitiala` int(11) NULL DEFAULT NULL,
  `Special` tinyint(4) NULL DEFAULT NULL COMMENT 'Il folosesc pentru a delimita coloanele care au format conditions in tabelul Coloane_FC si cele care le au in tabelul lor separat (ex:TipStatus)',
  `JS_ReadOnlyCbx` tinyint(4) NULL DEFAULT 0,
  `AscunsInFiltru` tinyint(4) NULL DEFAULT 0,
  PRIMARY KEY (`IdColoana`) USING BTREE,
  INDEX `SelectedTab`(`SelTab`) USING BTREE,
  INDEX `Special`(`Special`) USING BTREE,
  INDEX `PozitieInitiala`(`PozitieInitiala`) USING BTREE,
  INDEX `idx_covering`(`NumeColoana`, `TipCamp`, `Special`, `SelTab`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 661 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Coloane_Implicite_Excel
-- ----------------------------
DROP TABLE IF EXISTS `Coloane_Implicite_Excel`;
CREATE TABLE `Coloane_Implicite_Excel`  (
  `IDCE` int(11) NOT NULL AUTO_INCREMENT,
  `IdColoana` int(11) NULL DEFAULT NULL,
  `AfisareColoana` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `PozitieInitiala` int(11) NULL DEFAULT NULL,
  `MarimeInitiala` int(11) NULL DEFAULT NULL,
  `FormatareInitiala` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `AscunsImplicit` tinyint(4) NULL DEFAULT 0,
  `SelTab` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `FontInitial` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `AliniereInitiala` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`IDCE`) USING BTREE,
  INDEX `Coloane_Implicite_Excel__Coloane_Implicite`(`IdColoana`) USING BTREE,
  CONSTRAINT `Coloane_Implicite_Excel__Coloane_Implicite` FOREIGN KEY (`IdColoana`) REFERENCES `Coloane_Implicite` (`IdColoana`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 603 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Coloane_Implicite_Export_Feedback
-- ----------------------------
DROP TABLE IF EXISTS `Coloane_Implicite_Export_Feedback`;
CREATE TABLE `Coloane_Implicite_Export_Feedback`  (
  `IdColoanaHTML` int(11) NOT NULL AUTO_INCREMENT,
  `Coloana` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Afisare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Pozitie` int(11) NOT NULL,
  `HTMLStyle` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`IdColoanaHTML`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Conditii
-- ----------------------------
DROP TABLE IF EXISTS `Conditii`;
CREATE TABLE `Conditii`  (
  `IdConditie` int(11) NOT NULL AUTO_INCREMENT,
  `Camp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Afisare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `SelTab` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TIP` int(11) NOT NULL COMMENT '0=TextBox,1=ComboBox,2=CheckBox',
  `Primar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TipCamp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `SelTabAF` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`IdConditie`) USING BTREE,
  INDEX `Camp`(`Camp`) USING BTREE,
  INDEX `TipCamp`(`TipCamp`) USING BTREE,
  INDEX `SelTab`(`SelTab`, `SelTabAF`) USING BTREE,
  INDEX `Afisare`(`Afisare`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 94 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ConditiiS
-- ----------------------------
DROP TABLE IF EXISTS `ConditiiS`;
CREATE TABLE `ConditiiS`  (
  `IdConditieS` int(11) NOT NULL AUTO_INCREMENT,
  `IdConditie` int(11) NOT NULL,
  `SelTab` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Grup` int(11) NOT NULL,
  `Denumire` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Pozitie` int(11) NOT NULL,
  `CampPrincipal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `AfisareCampPrincipal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TipCampPrincipal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `CampAsociat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AfisareCampAsociat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TipCampAsociat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Valoare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AfisareValoare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TipCampValoare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Semn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AfisareSemn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `AltCamp` tinyint(4) NOT NULL DEFAULT 0,
  `Mesaj` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `CandDaca` tinyint(4) NULL DEFAULT 0 COMMENT '0=Cand;1=Daca',
  `Functie` tinyint(4) NULL DEFAULT 0,
  `Activa` tinyint(4) NOT NULL DEFAULT 1,
  `Versiune` int(11) NULL DEFAULT NULL,
  `DataAdaugare` datetime NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdConditieS`) USING BTREE,
  INDEX `IdConditieS`(`IdConditieS`) USING BTREE,
  INDEX `CampS`(`CampAsociat`) USING BTREE,
  INDEX `Pozitie`(`Pozitie`) USING BTREE,
  INDEX `Grup`(`Grup`) USING BTREE,
  INDEX `Valoare`(`Valoare`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `IdConditie`(`IdConditie`, `Grup`) USING BTREE,
  INDEX `nebunie`(`IdConditie`, `Grup`, `CandDaca`, `Pozitie`) USING BTREE,
  CONSTRAINT `ConditiiS__Conditii` FOREIGN KEY (`IdConditie`) REFERENCES `Conditii` (`IdConditie`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 328 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ConditiiS_192
-- ----------------------------
DROP TABLE IF EXISTS `ConditiiS_192`;
CREATE TABLE `ConditiiS_192`  (
  `IdConditieS` int(11) NOT NULL AUTO_INCREMENT,
  `IdConditie` int(11) NOT NULL,
  `SelTab` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Grup` int(11) NOT NULL,
  `Denumire` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Pozitie` int(11) NOT NULL,
  `CampPrincipal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `AfisareCampPrincipal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TipCampPrincipal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `CampAsociat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AfisareCampAsociat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TipCampAsociat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Valoare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AfisareValoare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TipCampValoare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Semn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AfisareSemn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `AltCamp` tinyint(4) NOT NULL DEFAULT 0,
  `Mesaj` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `CandDaca` tinyint(4) NULL DEFAULT 0 COMMENT '0=Cand;1=Daca',
  `Functie` tinyint(4) NULL DEFAULT 0,
  `Activa` tinyint(4) NOT NULL DEFAULT 1,
  `Versiune` int(11) NULL DEFAULT NULL,
  `DataAdaugare` datetime NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdConditieS`) USING BTREE,
  INDEX `IdConditieS`(`IdConditieS`) USING BTREE,
  INDEX `CampS`(`CampAsociat`) USING BTREE,
  INDEX `Pozitie`(`Pozitie`) USING BTREE,
  INDEX `Grup`(`Grup`) USING BTREE,
  INDEX `Valoare`(`Valoare`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `IdConditie`(`IdConditie`, `Grup`) USING BTREE,
  INDEX `nebunie`(`IdConditie`, `Grup`, `CandDaca`, `Pozitie`) USING BTREE,
  CONSTRAINT `ConditiiS_192_ibfk_1` FOREIGN KEY (`IdConditie`) REFERENCES `Conditii` (`IdConditie`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 287 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ConditiiS_Implicite
-- ----------------------------
DROP TABLE IF EXISTS `ConditiiS_Implicite`;
CREATE TABLE `ConditiiS_Implicite`  (
  `IdConditieS` int(11) NOT NULL AUTO_INCREMENT,
  `IdConditie` int(11) NOT NULL,
  `SelTab` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Grup` int(11) NOT NULL,
  `Denumire` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Pozitie` int(11) NOT NULL,
  `CampPrincipal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `AfisareCampPrincipal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TipCampPrincipal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `CampAsociat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AfisareCampAsociat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TipCampAsociat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Valoare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AfisareValoare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `TipCampValoare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Semn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AfisareSemn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `AltCamp` tinyint(4) NOT NULL DEFAULT 0,
  `Mesaj` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `CandDaca` tinyint(4) NULL DEFAULT 0 COMMENT '0=Cand;1=Daca',
  `DataAdaugare` datetime NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdConditieS`) USING BTREE,
  INDEX `IdConditieS`(`IdConditieS`) USING BTREE,
  INDEX `CampS`(`CampAsociat`) USING BTREE,
  INDEX `Pozitie`(`Pozitie`) USING BTREE,
  INDEX `Grup`(`Grup`) USING BTREE,
  INDEX `Valoare`(`Valoare`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `IdConditie`(`IdConditie`, `Grup`) USING BTREE,
  INDEX `nebunie`(`IdConditie`, `Grup`, `CandDaca`, `Pozitie`) USING BTREE,
  CONSTRAINT `ConditiiS_Implicite_ibfk_1` FOREIGN KEY (`IdConditie`) REFERENCES `Conditii` (`IdConditie`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 223 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ConditiiT
-- ----------------------------
DROP TABLE IF EXISTS `ConditiiT`;
CREATE TABLE `ConditiiT`  (
  `IdConditieT` int(11) NOT NULL AUTO_INCREMENT,
  `TipCamp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Semn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Afisare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `SemnReal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`IdConditieT`) USING BTREE,
  INDEX `IdConditieT`(`IdConditieT`) USING BTREE,
  INDEX `TipCamp`(`TipCamp`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Consultanti_Coloane
-- ----------------------------
DROP TABLE IF EXISTS `Consultanti_Coloane`;
CREATE TABLE `Consultanti_Coloane`  (
  `IDCOL` int(11) NOT NULL AUTO_INCREMENT,
  `IdColoana` int(11) NULL DEFAULT NULL,
  `IdConsultant` int(11) NULL DEFAULT NULL,
  `Afisare` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Pozitie` int(11) NULL DEFAULT NULL,
  `Marime` int(11) NULL DEFAULT NULL,
  `Ascuns` tinyint(4) NULL DEFAULT 0,
  `Aliniere` int(11) NULL DEFAULT NULL,
  `Formatare` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `SelTab` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Special` tinyint(4) NULL DEFAULT NULL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IDCOL`) USING BTREE,
  INDEX `Consultanti_Coloane__Coloane_Implicite`(`IdColoana`) USING BTREE,
  INDEX `Consultanti_Coloane__Coloane_Consultanti`(`IdConsultant`) USING BTREE,
  INDEX `idx_covering`(`IdColoana`, `IdConsultant`, `Ascuns`, `Pozitie`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  CONSTRAINT `Consultanti_Coloane__Coloane_Implicite` FOREIGN KEY (`IdColoana`) REFERENCES `Coloane_Implicite` (`IdColoana`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Consultanti_Coloane__Consultanti` FOREIGN KEY (`IdConsultant`) REFERENCES `SVN_00`.`Consultanti` (`IdConsultant`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 202220 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Consultanti_Coloane_Excel
-- ----------------------------
DROP TABLE IF EXISTS `Consultanti_Coloane_Excel`;
CREATE TABLE `Consultanti_Coloane_Excel`  (
  `IDCOL` int(11) NOT NULL AUTO_INCREMENT,
  `IdConfig` int(11) NULL DEFAULT NULL,
  `IdColoana` int(11) NULL DEFAULT NULL,
  `IdConsultant` int(11) NULL DEFAULT NULL,
  `SelTab` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Pozitie` int(11) NULL DEFAULT NULL,
  `Marime` int(11) NULL DEFAULT NULL,
  `Afisare` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Aliniere` int(11) NULL DEFAULT NULL,
  `Formatare` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Font` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Vizibil` tinyint(4) NOT NULL DEFAULT 0,
  `Ascuns` tinyint(4) NULL DEFAULT NULL,
  `DataAdaugare` datetime NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IDCOL`) USING BTREE,
  INDEX `Consultanti_Coloane__Consultanti`(`IdConsultant`) USING BTREE,
  INDEX `Consultanti_Coloane__Coloane_Implicite`(`IdColoana`) USING BTREE,
  INDEX `Consultanti_Coloane_Excel__Consultanti_Coloane_Excel_Config`(`IdConfig`) USING BTREE,
  CONSTRAINT `Consultanti_Coloane_Excel__Coloane_Implicite_Excel` FOREIGN KEY (`IdColoana`) REFERENCES `Coloane_Implicite_Excel` (`IdColoana`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Consultanti_Coloane_Excel__Consultanti` FOREIGN KEY (`IdConsultant`) REFERENCES `SVN_00`.`Consultanti` (`IdConsultant`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Consultanti_Coloane_Excel__Consultanti_Coloane_Excel_Config` FOREIGN KEY (`IdConfig`) REFERENCES `Consultanti_Coloane_Excel_Config` (`IdConfig`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 135182 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Consultanti_Coloane_Excel_Config
-- ----------------------------
DROP TABLE IF EXISTS `Consultanti_Coloane_Excel_Config`;
CREATE TABLE `Consultanti_Coloane_Excel_Config`  (
  `IdConfig` int(11) NOT NULL AUTO_INCREMENT,
  `IdConsultant` int(11) NULL DEFAULT NULL,
  `NumeConfig` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `SelTab` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`IdConfig`) USING BTREE,
  INDEX `Consultanti_Coloane_Excel_Config__Consultanti`(`IdConsultant`) USING BTREE,
  CONSTRAINT `Consultanti_Coloane_Excel_Config__Consultanti` FOREIGN KEY (`IdConsultant`) REFERENCES `SVN_00`.`Consultanti` (`IdConsultant`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1711 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar
-- ----------------------------
DROP TABLE IF EXISTS `Dosar`;
CREATE TABLE `Dosar`  (
  `IdDosar` int(11) NOT NULL AUTO_INCREMENT,
  `IdBaza` int(11) NOT NULL,
  `IdClient` int(11) NULL DEFAULT NULL,
  `IdConsultant` int(11) NULL DEFAULT NULL,
  `IdAgent` int(11) NULL DEFAULT NULL,
  `IdSursa` int(11) NULL DEFAULT NULL,
  `IdBanca` int(11) NULL DEFAULT NULL,
  `IdEvaluator` int(11) NULL DEFAULT NULL,
  `IdFunctie` int(11) NOT NULL,
  `IdFunctieFunctie` int(11) NULL DEFAULT NULL,
  `IdCompanie` int(11) NULL DEFAULT NULL,
  `IdDomeniu` int(11) NULL DEFAULT NULL,
  `IdTipCompanie` int(11) NULL DEFAULT NULL,
  `IdMotiv` int(11) NULL DEFAULT NULL,
  `IdNotar` int(11) NULL DEFAULT NULL,
  `IdStare` int(11) NOT NULL,
  `IdStatus` int(11) NOT NULL,
  `IdSucursala` int(11) NOT NULL,
  `IdTipCredit` int(11) NOT NULL,
  `IdTipDobanda` int(11) NULL DEFAULT NULL,
  `IdTipImobil` int(11) NULL DEFAULT NULL,
  `IdTipMoneda` int(11) NOT NULL,
  `IdVenit` int(11) NOT NULL,
  `Venit` int(11) NULL DEFAULT 0,
  `ValoareCredit` int(11) NULL DEFAULT NULL,
  `ValoareCreditRON` int(11) NULL DEFAULT NULL,
  `ValoareCreditTras` int(11) NULL DEFAULT NULL,
  `CursMoneda` double NULL DEFAULT NULL,
  `PerioadaCredit` int(11) NULL DEFAULT 0,
  `PerioadaDobanda` int(11) NULL DEFAULT 0,
  `Dobanda` double NULL DEFAULT NULL,
  `MarjaDobandaDF` double NULL DEFAULT NULL,
  `MarjaDobanda` double NULL DEFAULT NULL,
  `NumeCodebitor` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `ValoareImobil` int(11) NULL DEFAULT NULL,
  `ConsilierBanca` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `CodBanca` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `DataIntroducere` datetime NOT NULL,
  `DataPreaprobare` date NULL DEFAULT NULL,
  `DataOpinieJ` date NULL DEFAULT NULL,
  `DataTrimitere` date NULL DEFAULT NULL,
  `DataDebursare` date NULL DEFAULT NULL,
  `DataRespingere` date NULL DEFAULT NULL,
  `DataSemnare` datetime NULL DEFAULT NULL,
  `ObservatiiFinale` varchar(2500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Codebitor` tinyint(4) NOT NULL DEFAULT 0,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `AreImobil` tinyint(4) NULL DEFAULT NULL,
  `DIFD` tinyint(4) GENERATED ALWAYS AS (date_format(`DataDebursare`,'%m-%d') = date_format(curdate(),'%m-%d')) VIRTUAL,
  `ModificatDupaTragere` tinyint(4) NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdDosar`) USING BTREE,
  INDEX `IdBaza`(`IdBaza`) USING BTREE,
  INDEX `IdMotiv`(`IdMotiv`) USING BTREE,
  INDEX `IdStatus`(`IdStatus`) USING BTREE,
  INDEX `IdSucursala`(`IdSucursala`) USING BTREE,
  INDEX `IdVenit`(`IdVenit`) USING BTREE,
  INDEX `IdTipDobanda`(`IdTipDobanda`) USING BTREE,
  INDEX `IdFunctie`(`IdFunctie`) USING BTREE,
  INDEX `IdTipMoneda`(`IdTipMoneda`) USING BTREE,
  INDEX `IdEvaluator`(`IdEvaluator`) USING BTREE,
  INDEX `IdNotar`(`IdNotar`) USING BTREE,
  INDEX `IdStare`(`IdStare`) USING BTREE,
  INDEX `IdTipImobil`(`IdTipImobil`) USING BTREE,
  INDEX `IdTipCredit`(`IdTipCredit`) USING BTREE,
  INDEX `IdBanca`(`IdBanca`) USING BTREE,
  INDEX `idx_view_baza_dosare`(`IdBanca`, `IdBaza`, `IdStatus`, `DataIntroducere`, `ValoareCredit`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `IdClient`(`IdClient`, `IdStatus`) USING BTREE,
  INDEX `Dosar__Agenti`(`IdAgent`) USING BTREE,
  INDEX `Dosar__Consultanti`(`IdConsultant`) USING BTREE,
  INDEX `Dosar__Functii_Companie`(`IdCompanie`) USING BTREE,
  INDEX `Dosar__Functii_Domeniu`(`IdDomeniu`) USING BTREE,
  INDEX `Dosar__Functii_Functie`(`IdFunctieFunctie`) USING BTREE,
  INDEX `Dosar__Functii_TipCompanie`(`IdTipCompanie`) USING BTREE,
  INDEX `Dosar__SursaLead`(`IdSursa`) USING BTREE,
  INDEX `IdClient_2`(`IdClient`) USING BTREE,
  INDEX `idx_dosar_ascuns_idbaza`(`Ascuns`, `IdBaza`) USING BTREE,
  CONSTRAINT `Dosar__Agenti` FOREIGN KEY (`IdAgent`) REFERENCES `Agenti` (`IdAgent`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Banca` FOREIGN KEY (`IdBanca`) REFERENCES `Banci` (`IdBanca`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Baza` FOREIGN KEY (`IdBaza`) REFERENCES `Baza` (`IdBaza`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Clienti` FOREIGN KEY (`IdClient`) REFERENCES `Clienti` (`IdClient`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Consultanti` FOREIGN KEY (`IdConsultant`) REFERENCES `SVN_00`.`Consultanti` (`IdConsultant`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Dosar_Functii` FOREIGN KEY (`IdFunctie`) REFERENCES `Dosar_Functii` (`IdFunctie`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Dosar_Status` FOREIGN KEY (`IdStatus`) REFERENCES `Dosar_Status` (`IdStatus`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Dosar_TipCredit` FOREIGN KEY (`IdTipCredit`) REFERENCES `Dosar_TipCredit` (`IdTipCredit`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Dosar_TipDobanda` FOREIGN KEY (`IdTipDobanda`) REFERENCES `Dosar_TipDobanda` (`IdTipDobanda`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Dosar_TipMoneda` FOREIGN KEY (`IdTipMoneda`) REFERENCES `Dosar_TipMoneda` (`IdTipMoneda`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Dosar_Venit` FOREIGN KEY (`IdVenit`) REFERENCES `Dosar_TipVenit` (`IdVenit`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Functii_Companie` FOREIGN KEY (`IdCompanie`) REFERENCES `Dosar_Functii_Companie` (`IdCompanie`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Functii_Domeniu` FOREIGN KEY (`IdDomeniu`) REFERENCES `Dosar_Functii_Domeniu` (`IdDomeniu`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Functii_Functie` FOREIGN KEY (`IdFunctieFunctie`) REFERENCES `Dosar_Functii_Functie` (`IdFunctieFunctie`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Functii_TipCompanie` FOREIGN KEY (`IdTipCompanie`) REFERENCES `Dosar_Functii_TipCompanie` (`IdTipCompanie`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__Sucursala` FOREIGN KEY (`IdSucursala`) REFERENCES `Sucursale` (`IdSucursala`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar__SursaLead` FOREIGN KEY (`IdSursa`) REFERENCES `SursaLead` (`IdSursa`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 43298 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Alarme
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Alarme`;
CREATE TABLE `Dosar_Alarme`  (
  `IdAlarma` int(11) NOT NULL AUTO_INCREMENT,
  `IdDosar` int(11) NOT NULL,
  `IdConsultant` int(11) NOT NULL,
  `IdConsultantAdd` int(11) NOT NULL,
  `Nume` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Detalii` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `ToataZiua` tinyint(4) NULL DEFAULT NULL,
  `DataOra` datetime NOT NULL,
  `Repeta` tinyint(4) NOT NULL DEFAULT 0,
  `TipInterval` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Interval` int(11) NULL DEFAULT NULL,
  `Activa` tinyint(4) NOT NULL DEFAULT 1,
  `SeAnuleaza` tinyint(4) NOT NULL DEFAULT 1,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdAlarma`) USING BTREE,
  INDEX `Baza_Alarme__Consultanti`(`IdConsultant`) USING BTREE,
  INDEX `Baza_Alarma__Baza`(`IdDosar`) USING BTREE,
  CONSTRAINT `Dosar_Alarme_ibfk_1` FOREIGN KEY (`IdDosar`) REFERENCES `Baza` (`IdBaza`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Dosar_Alarme_ibfk_2` FOREIGN KEY (`IdConsultant`) REFERENCES `SVN_00`.`Consultanti` (`IdConsultant`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Evaluatori
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Evaluatori`;
CREATE TABLE `Dosar_Evaluatori`  (
  `IdEvaluator` int(11) NOT NULL AUTO_INCREMENT,
  `Evaluator` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `IdJudet` int(11) NOT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdEvaluator`) USING BTREE,
  INDEX `idx_covering`(`IdEvaluator`, `Evaluator`, `IdJudet`, `Ascuns`) USING BTREE,
  INDEX `idx_filtering_idjudet`(`IdJudet`, `Ascuns`, `Evaluator`) USING BTREE,
  INDEX `idx_ordering`(`Ascuns`, `Evaluator`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  CONSTRAINT `Evaluatori__Judete` FOREIGN KEY (`IdJudet`) REFERENCES `SVN_00`.`Judete` (`IdJudet`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_FC
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_FC`;
CREATE TABLE `Dosar_FC`  (
  `IdBR` int(11) NOT NULL,
  `FormatCondition` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `BackColor` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `ForeColor` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `B1` int(11) NULL DEFAULT NULL,
  `B2` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`IdBR`) USING BTREE,
  INDEX `BackColor`(`BackColor`) USING BTREE,
  INDEX `FormatCondition`(`FormatCondition`) USING BTREE,
  INDEX `ForeColor`(`ForeColor`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_FeedBack
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_FeedBack`;
CREATE TABLE `Dosar_FeedBack`  (
  `IdFeedBack` int(11) NOT NULL AUTO_INCREMENT,
  `IdDosar` int(11) NOT NULL,
  `IdStatusFeedback` int(11) NULL DEFAULT NULL,
  `IDSG` int(11) NOT NULL,
  `IdConsultant` int(11) NOT NULL,
  `DataConectare` date NULL DEFAULT NULL,
  `FeedBack` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `DataReconectare` date NULL DEFAULT NULL,
  `Primar` tinyint(4) NOT NULL DEFAULT 0,
  `DIF` int(11) GENERATED ALWAYS AS (if(`IDSG` = 2,to_days(current_timestamp()) - to_days(`DataReconectare`),NULL)) VIRTUAL,
  `DIFF` int(11) GENERATED ALWAYS AS (if(`IDSG` = 2,case when `DataReconectare` is null then NULL when cast(`DataReconectare` as date) = curdate() then 1 when unix_timestamp(`DataReconectare`) between unix_timestamp(curdate()) and unix_timestamp(curdate() + interval 4 day) then 2 when unix_timestamp(`DataReconectare`) < unix_timestamp(curdate() + interval 4 day) then 3 end,NULL)) VIRTUAL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdFeedBack`) USING BTREE,
  INDEX `IdConsultant`(`IdConsultant`) USING BTREE,
  INDEX `IdDosar`(`IdDosar`) USING BTREE,
  INDEX `IdStatusFeedback`(`IdStatusFeedback`) USING BTREE,
  INDEX `idx_global`(`IdFeedBack`, `IdStatusFeedback`, `IdDosar`, `DataConectare`, `DataReconectare`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `Primar`(`Primar`) USING BTREE,
  CONSTRAINT `Dosar_FeedBack__Consultanti` FOREIGN KEY (`IdConsultant`) REFERENCES `SVN_00`.`Consultanti` (`IdConsultant`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Dosar_FeedBack__Dosar` FOREIGN KEY (`IdDosar`) REFERENCES `Dosar` (`IdDosar`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Dosar_FeedBack__Dosar_Status` FOREIGN KEY (`IdStatusFeedback`) REFERENCES `Dosar_FeedBack_Status` (`IdStatusFeedBack`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 936 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_FeedBack_Status
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_FeedBack_Status`;
CREATE TABLE `Dosar_FeedBack_Status`  (
  `IdStatusFeedBack` int(11) NOT NULL AUTO_INCREMENT,
  `FelStatusFeedback` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `BackColorFeedback` int(11) NOT NULL,
  PRIMARY KEY (`IdStatusFeedBack`) USING BTREE,
  INDEX `FelStatusFeedback`(`FelStatusFeedback`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Functii
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Functii`;
CREATE TABLE `Dosar_Functii`  (
  `IdFunctie` int(11) NOT NULL AUTO_INCREMENT,
  `IdClient` int(11) NOT NULL,
  `IdFunctieFunctie` int(11) NOT NULL,
  `IdCompanie` int(11) NOT NULL,
  `IdDomeniu` int(11) NOT NULL,
  `IdTipCompanie` int(11) NOT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdFunctie`) USING BTREE,
  INDEX `IdDomeniu`(`IdDomeniu`) USING BTREE,
  INDEX `IdTipCompanie`(`IdTipCompanie`) USING BTREE,
  INDEX `IdFunctieFunctie`(`IdFunctieFunctie`) USING BTREE,
  INDEX `IdCompanie`(`IdCompanie`) USING BTREE,
  INDEX `IdClient`(`IdClient`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `idx_covering`(`IdFunctie`, `IdClient`, `IdDomeniu`, `IdTipCompanie`, `IdFunctieFunctie`, `IdCompanie`, `DataModificare`) USING BTREE,
  CONSTRAINT `Dosar_Functii__Clienti` FOREIGN KEY (`IdClient`) REFERENCES `Clienti` (`IdClient`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar_Functii__Dosar_Functii_Companie` FOREIGN KEY (`IdCompanie`) REFERENCES `Dosar_Functii_Companie` (`IdCompanie`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar_Functii__Dosar_Functii_Domeniu` FOREIGN KEY (`IdDomeniu`) REFERENCES `Dosar_Functii_Domeniu` (`IdDomeniu`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar_Functii__Dosar_Functii_Functie` FOREIGN KEY (`IdFunctieFunctie`) REFERENCES `Dosar_Functii_Functie` (`IdFunctieFunctie`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Dosar_Functii__Dosar_Functii_TipCompanie` FOREIGN KEY (`IdTipCompanie`) REFERENCES `Dosar_Functii_TipCompanie` (`IdTipCompanie`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 17878 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Functii_Companie
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Functii_Companie`;
CREATE TABLE `Dosar_Functii_Companie`  (
  `IdCompanie` int(11) NOT NULL AUTO_INCREMENT,
  `Companie` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `CodFiscal` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `LN` int(11) NULL DEFAULT octet_length(`Companie`),
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdCompanie`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `Companie`(`Companie`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 90439 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Functii_Domeniu
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Functii_Domeniu`;
CREATE TABLE `Dosar_Functii_Domeniu`  (
  `IdDomeniu` int(11) NOT NULL AUTO_INCREMENT,
  `Domeniu` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `LN` int(11) NULL DEFAULT octet_length(`Domeniu`),
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdDomeniu`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `Domeniu`(`Domeniu`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 64 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Functii_Functie
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Functii_Functie`;
CREATE TABLE `Dosar_Functii_Functie`  (
  `IdFunctieFunctie` int(11) NOT NULL AUTO_INCREMENT,
  `Functie` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Ascuns` tinyint(4) NULL DEFAULT 0,
  `LN` int(11) NULL DEFAULT octet_length(`Functie`),
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdFunctieFunctie`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `Functie`(`Functie`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 82732 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Functii_TipCompanie
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Functii_TipCompanie`;
CREATE TABLE `Dosar_Functii_TipCompanie`  (
  `IdTipCompanie` int(11) NOT NULL AUTO_INCREMENT,
  `TipCompanie` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `LN` int(11) NULL DEFAULT octet_length(`TipCompanie`),
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdTipCompanie`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `TipCompanie`(`TipCompanie`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Motiv
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Motiv`;
CREATE TABLE `Dosar_Motiv`  (
  `IdMotiv` int(11) NOT NULL AUTO_INCREMENT,
  `Motiv` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Automat` tinyint(4) NOT NULL DEFAULT 0,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdMotiv`) USING BTREE,
  INDEX `idx_global_Dosar_Motiv`(`IdMotiv`, `Motiv`, `Ascuns`) USING BTREE,
  INDEX `idx_ordering_ascuns`(`Ascuns`, `Motiv`) USING BTREE,
  INDEX `Motiv`(`Motiv`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Notari
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Notari`;
CREATE TABLE `Dosar_Notari`  (
  `IdNotar` int(11) NOT NULL AUTO_INCREMENT,
  `Notar` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `IdJudet` int(11) NOT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdNotar`) USING BTREE,
  INDEX `idx_covering`(`IdNotar`, `IdJudet`, `Notar`, `Ascuns`) USING BTREE,
  INDEX `idx_filtering_idjudet`(`IdJudet`, `Ascuns`, `Notar`) USING BTREE,
  INDEX `idx_ordering_ascuns`(`Ascuns`, `Notar`) USING BTREE,
  INDEX `idx_ordering_notar`(`IdJudet`, `Notar`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  CONSTRAINT `Notar__Judete` FOREIGN KEY (`IdJudet`) REFERENCES `SVN_00`.`Judete` (`IdJudet`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Stare
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Stare`;
CREATE TABLE `Dosar_Stare`  (
  `IdStare` int(11) NOT NULL AUTO_INCREMENT,
  `Stare` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `Implicit` tinyint(4) NOT NULL DEFAULT 0,
  `IdStatusAsociat` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdStare`) USING BTREE,
  INDEX `idx_ordering`(`Ascuns`, `Stare`) USING BTREE,
  INDEX `Implicit`(`Implicit`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `idx_covering`(`Stare`, `Ascuns`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Stare_Status
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Stare_Status`;
CREATE TABLE `Dosar_Stare_Status`  (
  `IdStareStatus` int(11) NOT NULL AUTO_INCREMENT,
  `IdStare` int(11) NOT NULL DEFAULT 0,
  `IdStatus` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`IdStareStatus`) USING BTREE,
  INDEX `IdStatus`(`IdStatus`) USING BTREE,
  INDEX `Covering`(`IdStare`, `IdStatus`) USING BTREE,
  CONSTRAINT `Dosar_Stare_Status_ibfk_1` FOREIGN KEY (`IdStare`) REFERENCES `Dosar_Stare` (`IdStare`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `Dosar_Stare_Status_ibfk_2` FOREIGN KEY (`IdStatus`) REFERENCES `Dosar_Status` (`IdStatus`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Status
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Status`;
CREATE TABLE `Dosar_Status`  (
  `IdStatus` int(11) NOT NULL AUTO_INCREMENT,
  `FelStatus` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `IDSG` int(11) NULL DEFAULT NULL,
  `AltaBanca` tinyint(4) NULL DEFAULT NULL,
  `AnuleazaDosareActive` tinyint(4) NOT NULL DEFAULT 0,
  `TipStatus` int(11) NOT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `BackColor` int(9) NULL DEFAULT NULL,
  `ForeColor` int(11) NULL DEFAULT NULL,
  `FontName` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `FontSize` int(11) NULL DEFAULT NULL,
  `FontColor` int(11) NULL DEFAULT NULL,
  `FontBold` tinyint(4) NULL DEFAULT NULL,
  `FontItalic` tinyint(4) NULL DEFAULT NULL,
  `FontUnderline` tinyint(4) NULL DEFAULT NULL,
  `Implicit` tinyint(4) NOT NULL DEFAULT 0,
  `Automat` tinyint(4) NOT NULL DEFAULT 0,
  `IdStareAsociat` int(11) NULL DEFAULT NULL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdStatus`) USING BTREE,
  INDEX `IDSG`(`IDSG`) USING BTREE,
  INDEX `idx_ordering`(`Ascuns`, `IdStatus`, `FelStatus`) USING BTREE,
  INDEX `idx_ordering_ascuns`(`Ascuns`, `FelStatus`, `IDSG`) USING BTREE,
  INDEX `FelStatus`(`FelStatus`) USING BTREE,
  INDEX `idx_covering`(`IDSG`, `FelStatus`, `TipStatus`, `BackColor`, `Ascuns`) USING BTREE,
  INDEX `idx_view_baza_dosare`(`FelStatus`, `TipStatus`, `BackColor`) USING BTREE,
  INDEX `Implicit`(`Implicit`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  CONSTRAINT `Dosar_Status__Dosar_Status_Grup` FOREIGN KEY (`IDSG`) REFERENCES `Dosar_Status_Grup` (`IDSG`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_Status_Grup
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_Status_Grup`;
CREATE TABLE `Dosar_Status_Grup`  (
  `IDSG` int(11) NOT NULL,
  `GRUP` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Ascuns` tinyint(4) NOT NULL,
  PRIMARY KEY (`IDSG`) USING BTREE,
  INDEX `idx_where_Ascuns`(`Ascuns`, `IDSG`, `GRUP`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_TipCredit
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_TipCredit`;
CREATE TABLE `Dosar_TipCredit`  (
  `IdTipCredit` int(11) NOT NULL AUTO_INCREMENT,
  `TipCredit` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Ascuns` tinyint(4) NULL DEFAULT NULL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdTipCredit`) USING BTREE,
  INDEX `idx_global_Dosar_TipCredit`(`IdTipCredit`, `TipCredit`, `Ascuns`) USING BTREE,
  INDEX `idx_ordering_ascuns`(`Ascuns`, `TipCredit`) USING BTREE,
  INDEX `idx_ordering_idtc`(`Ascuns`, `TipCredit`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 150 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_TipDobanda
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_TipDobanda`;
CREATE TABLE `Dosar_TipDobanda`  (
  `IdTipDobanda` int(11) NOT NULL AUTO_INCREMENT,
  `TipDobanda` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `IDTC` int(11) NOT NULL,
  `Fields` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdTipDobanda`) USING BTREE,
  INDEX `Ascuns`(`Ascuns`) USING BTREE,
  INDEX `idx_covering`(`IdTipDobanda`, `TipDobanda`, `Ascuns`, `IDTC`) USING BTREE,
  INDEX `idx_ordering_ascuns`(`Ascuns`, `IDTC`, `TipDobanda`) USING BTREE,
  INDEX `TipDobanda`(`TipDobanda`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_TipImobil
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_TipImobil`;
CREATE TABLE `Dosar_TipImobil`  (
  `IdTipImobil` int(11) NOT NULL AUTO_INCREMENT,
  `TipImobil` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdTipImobil`) USING BTREE,
  INDEX `idx_ordering`(`Ascuns`, `TipImobil`) USING BTREE,
  INDEX `idx_covering`(`IdTipImobil`, `TipImobil`, `Ascuns`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_TipMoneda
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_TipMoneda`;
CREATE TABLE `Dosar_TipMoneda`  (
  `IdTipMoneda` int(11) NOT NULL AUTO_INCREMENT,
  `Moneda` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `RON` tinyint(4) NOT NULL DEFAULT 0,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdTipMoneda`) USING BTREE,
  INDEX `idx_global_Dosar_TipMoneda`(`IdTipMoneda`, `Moneda`, `Ascuns`) USING BTREE,
  INDEX `idx_sort_Dosar_TipProdus_Moneda`(`Moneda`, `IdTipMoneda`) USING BTREE,
  INDEX `idx_ordering`(`Ascuns`, `Moneda`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Dosar_TipVenit
-- ----------------------------
DROP TABLE IF EXISTS `Dosar_TipVenit`;
CREATE TABLE `Dosar_TipVenit`  (
  `IdVenit` int(11) NOT NULL AUTO_INCREMENT,
  `TipVenit` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdVenit`) USING BTREE,
  INDEX `Ascuns`(`Ascuns`) USING BTREE,
  INDEX `idx_ordering_Dosar_TipVenit`(`Ascuns`, `TipVenit`) USING BTREE,
  INDEX `idx_covering`(`IdVenit`, `TipVenit`, `Ascuns`) USING BTREE,
  INDEX `TipVenit`(`TipVenit`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Filtru
-- ----------------------------
DROP TABLE IF EXISTS `Filtru`;
CREATE TABLE `Filtru`  (
  `IDF` int(11) NOT NULL AUTO_INCREMENT,
  `IdColoana` int(11) NULL DEFAULT NULL,
  `SelTab` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `AlteColoane` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'Folosita in CRM la creearea ListBox-ului! Nu sterge ca genereaza un cacat de eroare la ADO.',
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  `S` tinyint(4) NULL DEFAULT NULL,
  PRIMARY KEY (`IDF`) USING BTREE,
  INDEX `idx_ordering`(`SelTab`, `Ascuns`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `idx_filtru_seltab_ascuns_idf`(`SelTab`, `Ascuns`, `IDF`) USING BTREE,
  INDEX `idx_filtru_idcoloana`(`IdColoana`) USING BTREE,
  INDEX `Filtru__Coloane_Implicite`(`IdColoana`, `SelTab`, `Ascuns`, `IDF`) USING BTREE,
  CONSTRAINT `Filtru__Coloane_Implicite` FOREIGN KEY (`IdColoana`) REFERENCES `Coloane_Implicite` (`IdColoana`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 833 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for HTML_EXPL
-- ----------------------------
DROP TABLE IF EXISTS `HTML_EXPL`;
CREATE TABLE `HTML_EXPL`  (
  `S` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Mesaje
-- ----------------------------
DROP TABLE IF EXISTS `Mesaje`;
CREATE TABLE `Mesaje`  (
  `IdMesaj` int(11) NOT NULL AUTO_INCREMENT,
  `IdConsultant` int(11) NULL DEFAULT NULL,
  `Catre` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Citit` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Primar` tinyint(4) NOT NULL DEFAULT 0,
  `Mesaj` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `DataExpirare` datetime NULL DEFAULT NULL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdMesaj`) USING BTREE,
  INDEX `IdMesaj`(`IdMesaj`) USING BTREE,
  INDEX `IdConsultant`(`IdConsultant`) USING BTREE,
  INDEX `Primar`(`Primar`) USING BTREE,
  INDEX `DataAdaugare`(`DataAdaugare`) USING BTREE,
  INDEX `DataExpirare`(`DataExpirare`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  CONSTRAINT `Mesaje__Consultanti` FOREIGN KEY (`IdConsultant`) REFERENCES `SVN_00`.`Consultanti` (`IdConsultant`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Online
-- ----------------------------
DROP TABLE IF EXISTS `Online`;
CREATE TABLE `Online`  (
  `IdLead` int(11) NOT NULL AUTO_INCREMENT,
  `IdOnline` int(11) NOT NULL,
  `IdJudet` int(11) NULL DEFAULT NULL,
  `Judet` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Nume` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Prenume` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Email` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Telefon` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `NewsLetter` tinyint(4) NOT NULL DEFAULT 0,
  `Nou` tinyint(4) NOT NULL DEFAULT 1,
  `DataPrimire` datetime NOT NULL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdLead`) USING BTREE,
  INDEX `IdLead`(`IdLead`) USING BTREE,
  INDEX `IdOnline`(`IdOnline`) USING BTREE,
  INDEX `Telefon`(`Telefon`) USING BTREE,
  INDEX `Judet`(`Judet`) USING BTREE,
  INDEX `IdJudet`(`IdJudet`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6324 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Semne
-- ----------------------------
DROP TABLE IF EXISTS `Semne`;
CREATE TABLE `Semne`  (
  `IdSemn` int(11) NOT NULL AUTO_INCREMENT,
  `Semn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Afisare` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `SemnReal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `TipCamp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`IdSemn`) USING BTREE,
  INDEX `IdConditieT`(`IdSemn`) USING BTREE,
  INDEX `TipCamp`(`TipCamp`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Setari
-- ----------------------------
DROP TABLE IF EXISTS `Setari`;
CREATE TABLE `Setari`  (
  `IdSetare` int(11) NOT NULL AUTO_INCREMENT,
  `SetareImplicita` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `ValoareImplicita` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Explicatie` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `RGX` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '[{\"REGEX\":\"(^\\\\d+)x(\\\\d+$)\",\"COND\":[{\"COND1\":\"1920x1080\",\"COND2\":\"1024x768\"}]}]',
  PRIMARY KEY (`IdSetare`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for SetariADC
-- ----------------------------
DROP TABLE IF EXISTS `SetariADC`;
CREATE TABLE `SetariADC`  (
  `IDS` int(11) NOT NULL AUTO_INCREMENT,
  `Setare` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Valoare` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`IDS`) USING BTREE,
  INDEX `Setare`(`Setare`) USING BTREE,
  INDEX `IDS`(`IDS`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Sucursale
-- ----------------------------
DROP TABLE IF EXISTS `Sucursale`;
CREATE TABLE `Sucursale`  (
  `IdSucursala` int(11) NOT NULL AUTO_INCREMENT,
  `Sucursala` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `IdBanca` int(11) NULL DEFAULT NULL,
  `Ascuns` tinyint(4) NOT NULL DEFAULT 0,
  `IdJudet` int(11) NULL DEFAULT NULL,
  `Orasul` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  `Implicit` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`IdSucursala`) USING BTREE,
  INDEX `IdJudet`(`IdJudet`) USING BTREE,
  INDEX `idx_where_ascuns`(`Ascuns`, `IdBanca`) USING BTREE,
  INDEX `idx_ordering`(`Ascuns`, `Orasul`, `Sucursala`, `IdBanca`, `IdJudet`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE,
  INDEX `Orasul`(`Orasul`) USING BTREE,
  CONSTRAINT `Sucursale__Judete` FOREIGN KEY (`IdJudet`) REFERENCES `SVN_00`.`Judete` (`IdJudet`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 582 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for SursaLead
-- ----------------------------
DROP TABLE IF EXISTS `SursaLead`;
CREATE TABLE `SursaLead`  (
  `IdSursa` int(11) NOT NULL AUTO_INCREMENT,
  `Sursa` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Explicatie` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Ascuns` tinyint(4) NULL DEFAULT 0,
  `DataAdaugare` datetime NOT NULL DEFAULT current_timestamp(),
  `DataModificare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdSursa`) USING BTREE,
  INDEX `idx_ordering`(`Ascuns`, `Sursa`) USING BTREE,
  INDEX `Sursa`(`Sursa`) USING BTREE,
  INDEX `DataModificare`(`DataModificare`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 154 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for TABLES_INFO
-- ----------------------------
DROP TABLE IF EXISTS `TABLES_INFO`;
CREATE TABLE `TABLES_INFO`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `TABLE_NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `COLUMN_NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `DATA_TYPE` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `CHARACTER_MAXIMUM_LENGTH` bigint(20) NULL DEFAULT NULL,
  `PRIMARY_COLUMN` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `idx_table_name`(`TABLE_NAME`) USING BTREE,
  INDEX `idx_column_name`(`COLUMN_NAME`) USING BTREE,
  INDEX `idx_covering`(`TABLE_NAME`, `COLUMN_NAME`, `PRIMARY_COLUMN`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1250 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for TIP
-- ----------------------------
DROP TABLE IF EXISTS `TIP`;
CREATE TABLE `TIP`  (
  `IDTC` int(11) NOT NULL AUTO_INCREMENT,
  `TIPC` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `SchemaName` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Prefix` varchar(4) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`IDTC`) USING BTREE,
  INDEX `IDTC`(`IDTC`) USING BTREE,
  INDEX `SchemaName`(`SchemaName`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for TRIGS
-- ----------------------------
DROP TABLE IF EXISTS `TRIGS`;
CREATE TABLE `TRIGS`  (
  `IDTRG` int(11) NOT NULL AUTO_INCREMENT,
  `TBL` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `TIP` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `VAL` tinyint(4) NULL DEFAULT 0,
  PRIMARY KEY (`IDTRG`) USING BTREE,
  INDEX `IDTRG`(`IDTRG`) USING BTREE,
  INDEX `TBL`(`TBL`) USING BTREE,
  INDEX `TIP`(`TIP`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- View structure for BlackList
-- ----------------------------
DROP VIEW IF EXISTS `BlackList`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `BlackList` AS select `SVN_00`.`BlackList`.`ID` AS `ID`,`SVN_00`.`BlackList`.`Telefon` AS `Telefon`,`SVN_00`.`BlackList`.`Email` AS `Email` from `SVN_00`.`BlackList`;

-- ----------------------------
-- View structure for Consultanti
-- ----------------------------
DROP VIEW IF EXISTS `Consultanti`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Consultanti` AS select `SVN_00`.`Consultanti`.`IdConsultant` AS `IdConsultant`,`SVN_00`.`Consultanti`.`IdNivel` AS `IdNivel`,`SVN_00`.`Consultanti`.`IdRegiune` AS `IdRegiune`,`SVN_00`.`Consultanti`.`IdParinte` AS `IdParinte`,`SVN_00`.`Consultanti`.`NumeConsultant` AS `NumeConsultant`,`SVN_00`.`Consultanti`.`CNP` AS `CNP`,`SVN_00`.`Consultanti`.`Adresa` AS `Adresa`,`SVN_00`.`Consultanti`.`Ascuns` AS `Ascuns`,`SVN_00`.`Consultanti`.`Functie` AS `Functie`,`SVN_00`.`Consultanti`.`cMail` AS `cMail`,`SVN_00`.`Consultanti`.`cTelefon` AS `cTelefon`,`SVN_00`.`Consultanti`.`CodJudet` AS `CodJudet`,`SVN_00`.`Consultanti`.`CodFiscal` AS `CodFiscal`,`SVN_00`.`Consultanti`.`CodOras` AS `CodOras`,`SVN_00`.`Consultanti`.`DataAdaugare` AS `DataAdaugare`,`SVN_00`.`Consultanti`.`DataModificare` AS `DataModificare`,`SVN_00`.`Consultanti`.`SchimbaParola` AS `SchimbaParola`,`SVN_00`.`Consultanti`.`Nou` AS `Nou`,`SVN_00`.`Consultanti`.`Plecat` AS `Plecat`,`SVN_00`.`Consultanti`.`Sistem` AS `Sistem`,`SVN_00`.`Consultanti`.`Suffix` AS `Suffix`,`SVN_00`.`Consultanti`.`Beta` AS `Beta`,`SVN_00`.`Consultanti`.`K1` AS `K1`,`SVN_00`.`Consultanti`.`K2` AS `K2` from `SVN_00`.`Consultanti`;

-- ----------------------------
-- View structure for Consultanti_Drepturi
-- ----------------------------
DROP VIEW IF EXISTS `Consultanti_Drepturi`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Consultanti_Drepturi` AS select `SVN_00`.`Consultanti_Drepturi`.`IDCD` AS `IDCD`,`SVN_00`.`Consultanti_Drepturi`.`IdConsultant` AS `IdConsultant`,`SVN_00`.`Consultanti_Drepturi`.`IdDrept` AS `IdDrept`,`SVN_00`.`Consultanti_Drepturi`.`IdNivel` AS `IdNivel`,`SVN_00`.`Consultanti_Drepturi`.`Valoare` AS `Valoare`,`SVN_00`.`Consultanti_Drepturi`.`DataModificare` AS `DataModificare` from `SVN_00`.`Consultanti_Drepturi`;

-- ----------------------------
-- View structure for Consultanti_Judete
-- ----------------------------
DROP VIEW IF EXISTS `Consultanti_Judete`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Consultanti_Judete` AS select `SVN_00`.`Consultanti_Judete`.`IDCJ` AS `IDCJ`,`SVN_00`.`Consultanti_Judete`.`IdJudet` AS `IdJudet`,`SVN_00`.`Consultanti_Judete`.`IdRegiune` AS `IdRegiune`,`SVN_00`.`Consultanti_Judete`.`IdConsultant` AS `IdConsultant`,`SVN_00`.`Consultanti_Judete`.`DataModificare` AS `DataModificare` from `SVN_00`.`Consultanti_Judete`;

-- ----------------------------
-- View structure for Consultanti_Relatii
-- ----------------------------
DROP VIEW IF EXISTS `Consultanti_Relatii`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Consultanti_Relatii` AS select `SVN_00`.`Consultanti_Relatii`.`IDCR` AS `IDCR`,`SVN_00`.`Consultanti_Relatii`.`IdParinte` AS `IdParinte`,`SVN_00`.`Consultanti_Relatii`.`IdCopil` AS `IdCopil`,`SVN_00`.`Consultanti_Relatii`.`Ascuns` AS `Ascuns`,`SVN_00`.`Consultanti_Relatii`.`DataModificare` AS `DataModificare` from `SVN_00`.`Consultanti_Relatii`;

-- ----------------------------
-- View structure for Consultanti_Setari
-- ----------------------------
DROP VIEW IF EXISTS `Consultanti_Setari`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Consultanti_Setari` AS select `SVN_00`.`Consultanti_Setari`.`IdConsultantSetare` AS `IdConsultantSetare`,`SVN_00`.`Consultanti_Setari`.`IdConsultant` AS `IdConsultant`,`SVN_00`.`Consultanti_Setari`.`IdSetare` AS `IdSetare`,`SVN_00`.`Consultanti_Setari`.`Setare` AS `Setare`,`SVN_00`.`Consultanti_Setari`.`Valoare` AS `Valoare`,`SVN_00`.`Consultanti_Setari`.`User` AS `User`,`SVN_00`.`Consultanti_Setari`.`DataModificare` AS `DataModificare` from `SVN_00`.`Consultanti_Setari`;

-- ----------------------------
-- View structure for Drepturi
-- ----------------------------
DROP VIEW IF EXISTS `Drepturi`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Drepturi` AS select `SVN_00`.`Drepturi`.`IdDrept` AS `IdDrept`,`SVN_00`.`Drepturi`.`IdNivel` AS `IdNivel`,`SVN_00`.`Drepturi`.`Drept` AS `Drept`,`SVN_00`.`Drepturi`.`ValoareImplicita` AS `ValoareImplicita`,`SVN_00`.`Drepturi`.`Ascuns` AS `Ascuns`,`SVN_00`.`Drepturi`.`DataAdaugare` AS `DataAdaugare`,`SVN_00`.`Drepturi`.`DataModificare` AS `DataModificare` from `SVN_00`.`Drepturi`;

-- ----------------------------
-- View structure for Filtru_Dosar
-- ----------------------------
DROP VIEW IF EXISTS `Filtru_Dosar`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Filtru_Dosar` AS select `D`.`IdDosar` AS `IdDosar`,`D`.`IdBaza` AS `IdBaza`,`D`.`IdClient` AS `IdClient`,`D`.`IdConsultant` AS `IdConsultant`,`D`.`IdAgent` AS `IdAgent`,`D`.`IdSursa` AS `IdSursa`,`D`.`IdFunctie` AS `IdFunctie`,`D`.`IdBanca` AS `IdBanca`,`D`.`IdSucursala` AS `IdSucursala`,`D`.`IdStare` AS `IdStare`,`D`.`IdStatus` AS `IdStatus`,`D`.`IdDomeniu` AS `IdDomeniu`,`D`.`IdFunctieFunctie` AS `IdFunctieFunctie`,`D`.`IdTipCompanie` AS `IdTipCompanie`,`D`.`IdCompanie` AS `IdCompanie`,`D`.`IdEvaluator` AS `IdEvaluator`,`D`.`IdMotiv` AS `IdMotiv`,`D`.`IdNotar` AS `IdNotar`,`D`.`IdTipImobil` AS `IdTipImobil`,`D`.`IdVenit` AS `IdVenit`,`D`.`IdTipDobanda` AS `IdTipDobanda`,`D`.`IdTipMoneda` AS `IdTipMoneda`,`D`.`IdTipCredit` AS `IdTipCredit`,`D`.`Venit` AS `Venit`,`D`.`ValoareCredit` AS `ValoareCredit`,`D`.`PerioadaCredit` AS `PerioadaCredit`,`D`.`PerioadaDobanda` AS `PerioadaDobanda`,`D`.`Dobanda` AS `Dobanda`,`D`.`NumeCodebitor` AS `NumeCodebitor`,`D`.`MarjaDobanda` AS `MarjaDobanda`,`D`.`MarjaDobandaDF` AS `MarjaDobandaDF`,`D`.`ValoareImobil` AS `ValoareImobil`,`D`.`ConsilierBanca` AS `ConsilierBanca`,`D`.`CodBanca` AS `CodBanca`,`D`.`DataIntroducere` AS `DataIntroducere`,`D`.`DataPreaprobare` AS `DataPreaprobare`,`D`.`DataOpinieJ` AS `DataOpinieJ`,`D`.`DataTrimitere` AS `DataTrimitere`,`D`.`DataDebursare` AS `DataDebursare`,`D`.`DataRespingere` AS `DataRespingere`,`D`.`CursMoneda` AS `CursMoneda`,`D`.`Codebitor` AS `Codebitor`,`D`.`AreImobil` AS `AreImobil`,`D`.`ObservatiiFinale` AS `ObservatiiFinale`,`DS`.`Stare` AS `Stare`,`DSt`.`FelStatus` AS `FelStatus`,`DSt`.`TipStatus` AS `TipStatus`,`DSt`.`IDSG` AS `IDSG`,`B`.`DataPrimire` AS `DataPrimire`,`Cl`.`NumeClient` AS `NumeClient`,`Cl`.`CNPClient` AS `CNPClient`,`Cl`.`TelefonP` AS `TelefonClient`,`Cl`.`EmailP` AS `EmailClient`,`Cl`.`DataNastere` AS `DataNastere`,`Cl`.`IdJudet` AS `IdJudet`,`C`.`NumeConsultant` AS `NumeConsultant`,`C`.`cTelefon` AS `cTelefon`,`C`.`cMail` AS `cMail`,`A`.`NumeAgent` AS `NumeAgent`,`SL`.`Sursa` AS `Sursa`,`DFD`.`Domeniu` AS `Domeniu`,`DFTC`.`TipCompanie` AS `TipCompanie`,`DFF`.`Functie` AS `Functie`,`DFC`.`Companie` AS `Companie`,`Bc`.`Banca` AS `Banca`,`S`.`Sucursala` AS `Sucursala`,`DTV`.`TipVenit` AS `TipVenit`,`DTD`.`TipDobanda` AS `TipDobanda`,`DTM`.`Moneda` AS `Moneda`,`DTC`.`TipCredit` AS `TipCredit`,`DFB`.`IdFeedBack` AS `IdFeedBack`,`DFB`.`IdStatusFeedBack` AS `IdStatusFeedback`,`DFB`.`DataConectare` AS `DataConectare`,`DFB`.`DataReconectare` AS `DataReconectare`,`DN`.`Notar` AS `Notar`,`DE`.`Evaluator` AS `Evaluator`,`DTI`.`TipImobil` AS `TipImobil`,`DM`.`Motiv` AS `Motiv`,if(`DFB`.`IdStatusFeedBack` = 1,to_days(current_timestamp()) - to_days(`DFB`.`DataReconectare`),NULL) AS `DIF`,ifnull(month(`D`.`DataDebursare`) = month(current_timestamp()) and dayofmonth(`D`.`DataDebursare`) = dayofmonth(current_timestamp()) and year(`D`.`DataDebursare`) < year(current_timestamp()),0) AS `aDIF`,ifnull(month(`Cl`.`DataNastere`) = month(current_timestamp()) and dayofmonth(`Cl`.`DataNastere`) = dayofmonth(current_timestamp()),0) AS `cDIF`,if(`DFB`.`IdStatusFeedBack` = 1,to_days(current_timestamp()) - to_days(`D`.`DataIntroducere`),0) AS `OLD` from ((((((((((((((((((((((`SVN_IM`.`Dosar` `D` join `SVN_IM`.`Dosar_Stare` `DS` on(`D`.`IdStare` = `DS`.`IdStare`)) join `SVN_IM`.`Dosar_Status` `DSt` on(`D`.`IdStatus` = `DSt`.`IdStatus`)) join `SVN_IM`.`Baza` `B` on(`D`.`IdBaza` = `B`.`IdBaza`)) join `SVN_IM`.`Agenti` `A` on(`D`.`IdAgent` = `A`.`IdAgent`)) join `SVN_IM`.`Consultanti` `C` on(`D`.`IdConsultant` = `C`.`IdConsultant`)) join `SVN_IM`.`Clienti` `Cl` on(`D`.`IdClient` = `Cl`.`IdClient`)) join `SVN_IM`.`SursaLead` `SL` on(`D`.`IdSursa` = `SL`.`IdSursa`)) join `SVN_IM`.`Dosar_Functii_Companie` `DFC` on(`D`.`IdCompanie` = `DFC`.`IdCompanie`)) join `SVN_IM`.`Dosar_Functii_Domeniu` `DFD` on(`D`.`IdDomeniu` = `DFD`.`IdDomeniu`)) join `SVN_IM`.`Dosar_Functii_Functie` `DFF` on(`D`.`IdFunctieFunctie` = `DFF`.`IdFunctieFunctie`)) join `SVN_IM`.`Dosar_Functii_TipCompanie` `DFTC` on(`D`.`IdTipCompanie` = `DFTC`.`IdTipCompanie`)) join `SVN_IM`.`Banci` `Bc` on(`D`.`IdBanca` = `Bc`.`IdBanca`)) join `SVN_IM`.`Sucursale` `S` on(`D`.`IdSucursala` = `S`.`IdSucursala`)) join `SVN_IM`.`Dosar_TipVenit` `DTV` on(`D`.`IdVenit` = `DTV`.`IdVenit`)) left join `SVN_IM`.`Dosar_TipDobanda` `DTD` on(`D`.`IdTipDobanda` = `DTD`.`IdTipDobanda`)) join `SVN_IM`.`Dosar_TipMoneda` `DTM` on(`D`.`IdTipMoneda` = `DTM`.`IdTipMoneda`)) join `SVN_IM`.`Dosar_TipCredit` `DTC` on(`D`.`IdTipCredit` = `DTC`.`IdTipCredit`)) left join (select `DFF`.`IdFeedBack` AS `IdFeedBack`,`DFF`.`IdDosar` AS `IdDosar`,`DFF`.`IdStatusFeedback` AS `IdStatusFeedBack`,`DFF`.`DataConectare` AS `DataConectare`,`DFF`.`DataReconectare` AS `DataReconectare` from (`SVN_IM`.`Dosar_FeedBack` `DFF` join (select max(`SVN_IM`.`Dosar_FeedBack`.`IdFeedBack`) AS `IdFeedBack` from `SVN_IM`.`Dosar_FeedBack` group by `SVN_IM`.`Dosar_FeedBack`.`IdDosar`) `df` on(`DFF`.`IdFeedBack` = `df`.`IdFeedBack`))) `DFB` on(`D`.`IdDosar` = `DFB`.`IdDosar`)) left join `SVN_IM`.`Dosar_Notari` `DN` on(`D`.`IdNotar` = `DN`.`IdNotar`)) left join `SVN_IM`.`Dosar_Evaluatori` `DE` on(`D`.`IdEvaluator` = `DE`.`IdEvaluator`)) left join `SVN_IM`.`Dosar_TipImobil` `DTI` on(`D`.`IdTipImobil` = `DTI`.`IdTipImobil`)) left join `SVN_IM`.`Dosar_Motiv` `DM` on(`D`.`IdMotiv` = `DM`.`IdMotiv`)) order by `D`.`IdDosar` desc;

-- ----------------------------
-- View structure for Judete
-- ----------------------------
DROP VIEW IF EXISTS `Judete`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Judete` AS select `SVN_00`.`Judete`.`IdJudet` AS `IdJudet`,`SVN_00`.`Judete`.`Judet` AS `Judet`,`SVN_00`.`Judete`.`Ascuns` AS `Ascuns`,`SVN_00`.`Judete`.`IdRegiune` AS `IdRegiune`,`SVN_00`.`Judete`.`CodJudet` AS `CodJudet` from `SVN_00`.`Judete`;

-- ----------------------------
-- View structure for Niveluri
-- ----------------------------
DROP VIEW IF EXISTS `Niveluri`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Niveluri` AS select `SVN_00`.`Niveluri`.`IdNivel` AS `IdNivel`,`SVN_00`.`Niveluri`.`Explicatie` AS `Explicatie`,`SVN_00`.`Niveluri`.`Prefix` AS `Prefix`,`SVN_00`.`Niveluri`.`PicText` AS `PicText`,`SVN_00`.`Niveluri`.`Ascuns` AS `Ascuns`,`SVN_00`.`Niveluri`.`DataAdaugare` AS `DataAdaugare`,`SVN_00`.`Niveluri`.`DataModificare` AS `DataModificare` from `SVN_00`.`Niveluri`;

-- ----------------------------
-- View structure for Orase
-- ----------------------------
DROP VIEW IF EXISTS `Orase`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Orase` AS select `SVN_00`.`Orase`.`IdOras` AS `IdOras`,`SVN_00`.`Orase`.`IdJudet` AS `IdJudet`,`SVN_00`.`Orase`.`nume` AS `nume`,`SVN_00`.`Orase`.`diacritice` AS `diacritice`,`SVN_00`.`Orase`.`judet` AS `judet`,`SVN_00`.`Orase`.`auto` AS `auto`,`SVN_00`.`Orase`.`zip` AS `zip`,`SVN_00`.`Orase`.`populatie` AS `populatie`,`SVN_00`.`Orase`.`lat` AS `lat`,`SVN_00`.`Orase`.`lng` AS `lng` from `SVN_00`.`Orase`;

-- ----------------------------
-- View structure for Regiuni
-- ----------------------------
DROP VIEW IF EXISTS `Regiuni`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Regiuni` AS select `SVN_00`.`Regiuni`.`IdRegiune` AS `IdRegiune`,`SVN_00`.`Regiuni`.`Regiune` AS `Regiune`,`SVN_00`.`Regiuni`.`Ascuns` AS `Ascuns` from `SVN_00`.`Regiuni`;

-- ----------------------------
-- View structure for viewBanciSucursale
-- ----------------------------
DROP VIEW IF EXISTS `viewBanciSucursale`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewBanciSucursale` AS select `SVN_IM`.`Banci`.`IdBanca` AS `IdBanca`,`SVN_IM`.`Banci`.`Banca` AS `Banca`,`SVN_IM`.`Sucursale`.`IdSucursala` AS `IdSucursala`,`SVN_IM`.`Sucursale`.`Sucursala` AS `Sucursala`,`SVN_00`.`Judete`.`IdJudet` AS `IdJudet`,`SVN_00`.`Judete`.`Judet` AS `Judet`,`SVN_IM`.`Sucursale`.`Orasul` AS `Orasul`,concat_ws('_',`SVN_IM`.`Banci`.`Banca`,`SVN_00`.`Judete`.`Judet`,`SVN_IM`.`Sucursale`.`Sucursala`) AS `Caut` from ((`SVN_IM`.`Banci` join `SVN_IM`.`Sucursale` on(`SVN_IM`.`Banci`.`IdBanca` = `SVN_IM`.`Sucursale`.`IdBanca`)) join `SVN_00`.`Judete` on(`SVN_IM`.`Sucursale`.`IdJudet` = `SVN_00`.`Judete`.`IdJudet`)) where `SVN_IM`.`Banci`.`Ascuns` = 0 and `SVN_IM`.`Sucursale`.`Ascuns` = 0 order by `SVN_IM`.`Banci`.`Banca`,`SVN_00`.`Judete`.`Judet`,`SVN_IM`.`Sucursale`.`Sucursala`;

-- ----------------------------
-- View structure for viewBaza
-- ----------------------------
DROP VIEW IF EXISTS `viewBaza`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewBaza` AS select `B`.`IdBaza` AS `IdBaza`,`B`.`IdAgent` AS `IDAgent`,`B`.`IdSursa` AS `IdSursa`,`B`.`IdConsultant` AS `IdConsultant`,`B`.`IdClient` AS `IdClient`,`B`.`DataPrimire` AS `DataPrimire`,`C`.`NumeClient` AS `NumeClient`,replace(`C`.`TelefonP`,' ','') AS `TelefonClient`,`C`.`EmailP` AS `EmailClient`,`C`.`CNPClient` AS `CNPClient`,`C`.`SMS` AS `SMS`,`C`.`DataNastere` AS `DataNastere`,`C`.`IdJudet` AS `IdJudet`,`C`.`Tara` AS `Tara`,`C`.`RO` AS `RO`,`C`.`IdLead` AS `IdLead`,`C`.`IPO` AS `IPO`,`J`.`Judet` AS `JudetClient`,`C`.`DIFN` AS `DIFN`,`CO`.`NumeConsultant` AS `NumeConsultant`,`CO`.`cTelefon` AS `cTelefon`,`CO`.`cMail` AS `cMail`,`CO`.`IdNivel` AS `IdNivel`,`CO`.`IdParinte` AS `IdParinte`,`SL`.`Sursa` AS `Sursa`,`A`.`NumeAgent` AS `NumeAgent`,`A`.`aTelefon` AS `aTelefon`,`A`.`aMail` AS `aMail`,`FB`.`IdFeedBack` AS `IdFeedBack`,`FB`.`IdStatus` AS `IdStatus`,`BS`.`FelStatus` AS `FelStatus`,`FB`.`IDSG` AS `IDSG`,`FB`.`DataConectare` AS `DataConectare`,`FB`.`DataReconectare` AS `DataReconectare`,`FB`.`Ora` AS `Ora`,`FB`.`Minut` AS `Minut`,`FB`.`DIF` AS `DIF`,`FB`.`DIFF` AS `DIFF`,`B`.`DataModificare` AS `DataModificare` from (((((((`SVN_IM`.`Baza` `B` FORCE INDEX (`idx_sursa_ascuns_baza`) join `SVN_IM`.`Clienti` `C` on(`B`.`IdClient` = `C`.`IdClient`)) join `SVN_IM`.`Consultanti` `CO` on(`B`.`IdConsultant` = `CO`.`IdConsultant`)) join `SVN_IM`.`Baza_FeedBack` `FB` on(`B`.`IdBaza` = `FB`.`IdBaza` and `FB`.`Primar` = 1)) left join `SVN_IM`.`Judete` `J` on(`C`.`IdJudet` = `J`.`IdJudet`)) left join `SVN_IM`.`SursaLead` `SL` on(`B`.`IdSursa` = `SL`.`IdSursa`)) left join `SVN_IM`.`Agenti` `A` on(`B`.`IdAgent` = `A`.`IdAgent`)) left join `SVN_IM`.`Baza_Status` `BS` on(`FB`.`IdStatus` = `BS`.`IdStatus`)) where `B`.`Ascuns` = 0;

-- ----------------------------
-- View structure for viewBaza_2025
-- ----------------------------
DROP VIEW IF EXISTS `viewBaza_2025`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewBaza_2025` AS select `B`.`IdBaza` AS `IdBaza`,`B`.`IdAgent` AS `IDAgent`,`B`.`IdSursa` AS `IdSursa`,`B`.`IdConsultant` AS `IdConsultant`,`B`.`IdClient` AS `IdClient`,`B`.`DataPrimire` AS `DataPrimire`,`C`.`NumeClient` AS `NumeClient`,replace(`C`.`TelefonP`,' ','') AS `TelefonClient`,`C`.`EmailP` AS `EmailClient`,`C`.`CNPClient` AS `CNPClient`,`C`.`SMS` AS `SMS`,`C`.`DataNastere` AS `DataNastere`,`C`.`IdJudet` AS `IdJudet`,`C`.`Tara` AS `Tara`,`C`.`RO` AS `RO`,`C`.`IdLead` AS `IdLead`,`C`.`IPO` AS `IPO`,`J`.`Judet` AS `JudetClient`,`C`.`DIFN` AS `DIFN`,`CO`.`NumeConsultant` AS `NumeConsultant`,`CO`.`cTelefon` AS `cTelefon`,`CO`.`cMail` AS `cMail`,`CO`.`IdNivel` AS `IdNivel`,`CO`.`IdParinte` AS `IdParinte`,`SL`.`Sursa` AS `Sursa`,`A`.`NumeAgent` AS `NumeAgent`,`A`.`aTelefon` AS `aTelefon`,`A`.`aMail` AS `aMail`,`FB`.`IdFeedBack` AS `IdFeedBack`,`FB`.`IdStatus` AS `IdStatus`,`BS`.`FelStatus` AS `FelStatus`,`FB`.`IDSG` AS `IDSG`,`FB`.`DataConectare` AS `DataConectare`,`FB`.`Feedback` AS `Feedback`,'' AS `FeedBack_Cumulat_Export`,'' AS `FeedBack_Cumulat`,`FB`.`DataReconectare` AS `DataReconectare`,`FB`.`Ora` AS `Ora`,`FB`.`Minut` AS `Minut`,`FB`.`DIF` AS `DIF`,`FB`.`DIFF` AS `DIFF`,case when exists(select 1 from `SVN_IM`.`Dosar` `d` where `d`.`IdBaza` = `B`.`IdBaza` and `d`.`Ascuns` = 0 limit 1) then 1 else 0 end AS `AreDosar`,`B`.`DataModificare` AS `DataModificare`,0 AS `S`,0 AS `imgAlarma` from (((((((`SVN_IM`.`Baza` `B` FORCE INDEX (`idx_sursa_ascuns_baza`) join `SVN_IM`.`Clienti` `C` on(`B`.`IdClient` = `C`.`IdClient`)) join `SVN_IM`.`Consultanti` `CO` on(`B`.`IdConsultant` = `CO`.`IdConsultant`)) join `SVN_IM`.`Baza_FeedBack` `FB` on(`B`.`IdBaza` = `FB`.`IdBaza` and `FB`.`Primar` = 1)) join `SVN_IM`.`Judete` `J` on(`C`.`IdJudet` = `J`.`IdJudet`)) join `SVN_IM`.`SursaLead` `SL` on(`B`.`IdSursa` = `SL`.`IdSursa`)) join `SVN_IM`.`Agenti` `A` on(`B`.`IdAgent` = `A`.`IdAgent`)) join `SVN_IM`.`Baza_Status` `BS` on(`FB`.`IdStatus` = `BS`.`IdStatus`)) where `B`.`Ascuns` = 0;

-- ----------------------------
-- View structure for viewBaza_Count
-- ----------------------------
DROP VIEW IF EXISTS `viewBaza_Count`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewBaza_Count` AS select `B`.`IdBaza` AS `IdBaza`,`B`.`IdConsultant` AS `IdConsultant`,`FB`.`DIF` AS `DIF`,`FB`.`DIFF` AS `DIFF` from (`Baza` `B` join `Baza_FeedBack` `FB` on(`B`.`IdBaza` = `FB`.`IdBaza`)) where `FB`.`Primar` = 1;

-- ----------------------------
-- View structure for viewBaza_desters
-- ----------------------------
DROP VIEW IF EXISTS `viewBaza_desters`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewBaza_desters` AS select `B`.`IdBaza` AS `IdBaza`,`B`.`IdAgent` AS `IDAgent`,`B`.`IdSursa` AS `IdSursa`,`B`.`IdConsultant` AS `IdConsultant`,`B`.`IdClient` AS `IdClient`,`B`.`DataPrimire` AS `DataPrimire`,`C`.`NumeClient` AS `NumeClient`,replace(`C`.`TelefonP`,' ','') AS `TelefonClient`,`C`.`EmailP` AS `EmailClient`,`C`.`CNPClient` AS `CNPClient`,`C`.`SMS` AS `SMS`,`C`.`DataNastere` AS `DataNastere`,`C`.`IdJudet` AS `IdJudet`,`C`.`Tara` AS `Tara`,`C`.`RO` AS `RO`,`C`.`IdLead` AS `IdLead`,`C`.`IPO` AS `IPO`,(select `Judete`.`Judet` from `SVN_IM`.`Judete` where `Judete`.`IdJudet` = `C`.`IdJudet`) AS `JudetClient`,`C`.`DIFN` AS `DIFN`,`CO`.`NumeConsultant` AS `NumeConsultant`,`CO`.`cTelefon` AS `cTelefon`,`CO`.`cMail` AS `cMail`,`CO`.`IdNivel` AS `IdNivel`,`CO`.`IdParinte` AS `IdParinte`,(select `SVN_IM`.`SursaLead`.`Sursa` from `SVN_IM`.`SursaLead` where `SVN_IM`.`SursaLead`.`IdSursa` = `B`.`IdSursa`) AS `Sursa`,`A`.`NumeAgent` AS `NumeAgent`,`A`.`aTelefon` AS `aTelefon`,`A`.`aMail` AS `aMail`,`FB`.`IdFeedBack` AS `IdFeedBack`,`FB`.`IdStatus` AS `IdStatus`,(select `SVN_IM`.`Baza_Status`.`FelStatus` from `SVN_IM`.`Baza_Status` where `SVN_IM`.`Baza_Status`.`IdStatus` = `FB`.`IdStatus`) AS `FelStatus`,`FB`.`IDSG` AS `IDSG`,`FB`.`DataConectare` AS `DataConectare`,`FB`.`Feedback` AS `FeedBack`,'' AS `FeedBack_Cumulat_Export`,'' AS `FeedBack_Cumulat`,`FB`.`DataReconectare` AS `DataReconectare`,`FB`.`Ora` AS `Ora`,`FB`.`Minut` AS `Minut`,`FB`.`DIF` AS `DIF`,`FB`.`DIFF` AS `DIFF`,(select exists(select 1 from `SVN_IM`.`Dosar` `D` where `D`.`IdBaza` = `B`.`IdBaza` limit 1)) AS `AreDosar`,`B`.`DataModificare` AS `DataModificare`,(select 0) AS `S`,(select count(`BA`.`IdAlarma`) from `SVN_IM`.`Baza_Alarme` `BA` where `BA`.`IdBaza` = `B`.`IdBaza`) AS `imgAlarma` from ((((`SVN_IM`.`Baza` `B` join `SVN_IM`.`Clienti` `C` on(`B`.`IdClient` = `C`.`IdClient`)) join `SVN_IM`.`Consultanti` `CO` on(`B`.`IdConsultant` = `CO`.`IdConsultant`)) join `SVN_IM`.`Agenti` `A` on(`B`.`IdSursa` = `A`.`IdSursa` and `B`.`IdAgent` = `A`.`IdAgent`)) join `SVN_IM`.`Baza_FeedBack` `FB` on(`B`.`IdBaza` = `FB`.`IdBaza`)) where `FB`.`Primar` = 1 and `B`.`Ascuns` = 0;

-- ----------------------------
-- View structure for viewBaza_export
-- ----------------------------
DROP VIEW IF EXISTS `viewBaza_export`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewBaza_export` AS select `B`.`IdBaza` AS `IdBaza`,`B`.`IdAgent` AS `IDAgent`,`B`.`IdSursa` AS `IdSursa`,`B`.`IdConsultant` AS `IdConsultant`,`B`.`IdClient` AS `IdClient`,`B`.`DataPrimire` AS `DataPrimire`,`C`.`NumeClient` AS `NumeClient`,replace(`C`.`TelefonP`,' ','') AS `TelefonClient`,`C`.`EmailP` AS `EmailClient`,`C`.`CNPClient` AS `CNPClient`,`C`.`SMS` AS `SMS`,`C`.`DataNastere` AS `DataNastere`,`C`.`IdJudet` AS `IdJudet`,`C`.`Tara` AS `Tara`,`C`.`RO` AS `RO`,`C`.`IdLead` AS `IdLead`,`C`.`IPO` AS `IPO`,`J`.`Judet` AS `JudetClient`,`C`.`DIFN` AS `DIFN`,`CO`.`NumeConsultant` AS `NumeConsultant`,`CO`.`cTelefon` AS `cTelefon`,`CO`.`cMail` AS `cMail`,`CO`.`IdNivel` AS `IdNivel`,`CO`.`IdParinte` AS `IdParinte`,`SL`.`Sursa` AS `Sursa`,`A`.`NumeAgent` AS `NumeAgent`,`A`.`aTelefon` AS `aTelefon`,`A`.`aMail` AS `aMail`,`FB`.`IdFeedBack` AS `IdFeedBack`,`FB`.`IdStatus` AS `IdStatus`,`BS`.`FelStatus` AS `FelStatus`,`FB`.`IDSG` AS `IDSG`,`FB`.`DataConectare` AS `DataConectare`,`FB`.`Feedback` AS `Feedback`,'' AS `FeedBack_Cumulat`,`FB`.`DataReconectare` AS `DataReconectare`,`FB`.`Ora` AS `Ora`,`FB`.`Minut` AS `Minut`,`FB`.`DIF` AS `DIF`,`FB`.`DIFF` AS `DIFF`,replace((select group_concat(regexp_replace(`bfc`.`Feedback`,'<.+?>','') separator ',') from `SVN_IM`.`Baza_FeedBack` `bfc` where `bfc`.`IdBaza` = `B`.`IdBaza`),'\r\n&nbsp;\r\n','') AS `FeedBack_Cumulat_Export`,case when exists(select 1 from `SVN_IM`.`Dosar` `d` where `d`.`IdBaza` = `B`.`IdBaza` and `d`.`Ascuns` = 0 limit 1) then 1 else 0 end AS `AreDosar`,`B`.`DataModificare` AS `DataModificare`,0 AS `S`,0 AS `imgAlarma` from (((((((`SVN_IM`.`Baza` `B` FORCE INDEX (`idx_sursa_ascuns_baza`) join `SVN_IM`.`Clienti` `C` on(`B`.`IdClient` = `C`.`IdClient`)) join `SVN_IM`.`Consultanti` `CO` on(`B`.`IdConsultant` = `CO`.`IdConsultant`)) join `SVN_IM`.`Baza_FeedBack` `FB` on(`B`.`IdBaza` = `FB`.`IdBaza` and `FB`.`Primar` = 1)) join `SVN_IM`.`Judete` `J` on(`C`.`IdJudet` = `J`.`IdJudet`)) join `SVN_IM`.`SursaLead` `SL` on(`B`.`IdSursa` = `SL`.`IdSursa`)) join `SVN_IM`.`Agenti` `A` on(`B`.`IdAgent` = `A`.`IdAgent`)) join `SVN_IM`.`Baza_Status` `BS` on(`FB`.`IdStatus` = `BS`.`IdStatus`)) where `B`.`Ascuns` = 0;

-- ----------------------------
-- View structure for viewBaza_Filtru_2025
-- ----------------------------
DROP VIEW IF EXISTS `viewBaza_Filtru_2025`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewBaza_Filtru_2025` AS select `B`.`IdBaza` AS `IdBaza`,`B`.`IdAgent` AS `IDAgent`,`B`.`IdSursa` AS `IdSursa`,`B`.`IdConsultant` AS `IdConsultant`,`B`.`IdClient` AS `IdClient`,`B`.`DataPrimire` AS `DataPrimire`,`C`.`NumeClient` AS `NumeClient`,replace(`C`.`TelefonP`,' ','') AS `TelefonClient`,`C`.`EmailP` AS `EmailClient`,`C`.`CNPClient` AS `CNPClient`,`C`.`SMS` AS `SMS`,`C`.`DataNastere` AS `DataNastere`,`C`.`IdJudet` AS `IdJudet`,`C`.`Tara` AS `Tara`,`C`.`RO` AS `RO`,`C`.`IdLead` AS `IdLead`,`C`.`IPO` AS `IPO`,`J`.`Judet` AS `JudetClient`,`C`.`DIFN` AS `DIFN`,`CO`.`NumeConsultant` AS `NumeConsultant`,`CO`.`cTelefon` AS `cTelefon`,`CO`.`cMail` AS `cMail`,`CO`.`IdNivel` AS `IdNivel`,`CO`.`IdParinte` AS `IdParinte`,`SL`.`Sursa` AS `Sursa`,`A`.`NumeAgent` AS `NumeAgent`,`A`.`aTelefon` AS `aTelefon`,`A`.`aMail` AS `aMail`,`FB`.`IdFeedBack` AS `IdFeedBack`,`FB`.`IdStatus` AS `IdStatus`,`BS`.`FelStatus` AS `FelStatus`,`FB`.`IDSG` AS `IDSG`,`FB`.`DataConectare` AS `DataConectare`,`FB`.`DataReconectare` AS `DataReconectare`,`FB`.`Ora` AS `Ora`,`FB`.`Minut` AS `Minut`,`FB`.`DIF` AS `DIF`,`FB`.`DIFF` AS `DIFF`,`B`.`DataModificare` AS `DataModificare` from (((((((`SVN_IM`.`Baza` `B` FORCE INDEX (`idx_sursa_ascuns_baza`) join `SVN_IM`.`Clienti` `C` on(`B`.`IdClient` = `C`.`IdClient`)) join `SVN_IM`.`Consultanti` `CO` on(`B`.`IdConsultant` = `CO`.`IdConsultant`)) join `SVN_IM`.`Baza_FeedBack` `FB` on(`B`.`IdBaza` = `FB`.`IdBaza` and `FB`.`Primar` = 1)) join `SVN_IM`.`Judete` `J` on(`C`.`IdJudet` = `J`.`IdJudet`)) join `SVN_IM`.`SursaLead` `SL` on(`B`.`IdSursa` = `SL`.`IdSursa`)) join `SVN_IM`.`Agenti` `A` on(`B`.`IdAgent` = `A`.`IdAgent`)) join `SVN_IM`.`Baza_Status` `BS` on(`FB`.`IdStatus` = `BS`.`IdStatus`)) where `B`.`Ascuns` = 0;

-- ----------------------------
-- View structure for viewBaza_PYTHON
-- ----------------------------
DROP VIEW IF EXISTS `viewBaza_PYTHON`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewBaza_PYTHON` AS select `B`.`IdBaza` AS `IdBaza`,`B`.`IdAgent` AS `IDAgent`,`B`.`IdSursa` AS `IdSursa`,`B`.`IdConsultant` AS `IdConsultant`,`B`.`IdClient` AS `IdClient`,date_format(`B`.`DataPrimire`,'%Y-%m-%dT%H:%i:%s') AS `DataPrimire`,`C`.`NumeClient` AS `NumeClient`,replace(`C`.`TelefonP`,' ','') AS `TelefonClient`,`C`.`EmailP` AS `EmailClient`,`C`.`CNPClient` AS `CNPClient`,`C`.`SMS` AS `SMS`,date_format(`C`.`DataNastere`,'%Y-%m-%dT%H:%i:%s') AS `DataNastere`,`C`.`IdJudet` AS `IdJudet`,`C`.`Tara` AS `Tara`,`C`.`RO` AS `RO`,`C`.`IdLead` AS `IdLead`,`C`.`IPO` AS `IPO`,`J`.`Judet` AS `JudetClient`,`C`.`DIFN` AS `DIFN`,`CO`.`NumeConsultant` AS `NumeConsultant`,`CO`.`cTelefon` AS `cTelefon`,`CO`.`cMail` AS `cMail`,`CO`.`IdNivel` AS `IdNivel`,`CO`.`IdParinte` AS `IdParinte`,`SL`.`Sursa` AS `Sursa`,`A`.`NumeAgent` AS `NumeAgent`,`A`.`aTelefon` AS `aTelefon`,`A`.`aMail` AS `aMail`,`FB`.`IdFeedBack` AS `IdFeedBack`,`FB`.`IdStatus` AS `IdStatus`,`BS`.`FelStatus` AS `FelStatus`,`FB`.`IDSG` AS `IDSG`,date_format(`FB`.`DataConectare`,'%Y-%m-%dT%H:%i:%s') AS `DataConectare`,`FB`.`Feedback` AS `Feedback`,'' AS `FeedBack_Cumulat_Export`,'' AS `FeedBack_Cumulat`,date_format(`FB`.`DataReconectare`,'%Y-%m-%dT%H:%i:%s') AS `DataReconectare`,`FB`.`Ora` AS `Ora`,`FB`.`Minut` AS `Minut`,`FB`.`DIF` AS `DIF`,`FB`.`DIFF` AS `DIFF`,case when exists(select 1 from `SVN_IM`.`Dosar` `d` where `d`.`IdBaza` = `B`.`IdBaza` and `d`.`Ascuns` = 0 limit 1) then 1 else 0 end AS `AreDosar`,date_format(`B`.`DataModificare`,'%Y-%m-%dT%H:%i:%s') AS `DataModificare`,0 AS `S`,0 AS `imgAlarma` from (((((((`SVN_IM`.`Baza` `B` FORCE INDEX (`idx_sursa_ascuns_baza`) join `SVN_IM`.`Clienti` `C` on(`B`.`IdClient` = `C`.`IdClient`)) join `SVN_IM`.`Consultanti` `CO` on(`B`.`IdConsultant` = `CO`.`IdConsultant`)) join `SVN_IM`.`Baza_FeedBack` `FB` on(`B`.`IdBaza` = `FB`.`IdBaza` and `FB`.`Primar` = 1)) join `SVN_IM`.`Judete` `J` on(`C`.`IdJudet` = `J`.`IdJudet`)) join `SVN_IM`.`SursaLead` `SL` on(`B`.`IdSursa` = `SL`.`IdSursa`)) join `SVN_IM`.`Agenti` `A` on(`B`.`IdAgent` = `A`.`IdAgent`)) join `SVN_IM`.`Baza_Status` `BS` on(`FB`.`IdStatus` = `BS`.`IdStatus`)) where `B`.`Ascuns` = 0;

-- ----------------------------
-- View structure for viewConditii_Salvare
-- ----------------------------
DROP VIEW IF EXISTS `viewConditii_Salvare`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewConditii_Salvare` AS select `T`.`IdConditie` AS `IdConditie`,`T`.`Camp` AS `Camp`,`T`.`SelTab` AS `SelTab`,json_arrayagg(json_object('GRUP',`T`.`Grup`,'JSN',json_extract(`T`.`jsnConditie`,'$')) order by `T`.`Grup` ASC) AS `jsnConditii` from (select `c`.`IdConditie` AS `IdConditie`,`c`.`Grup` AS `Grup`,`c`.`CampPrincipal` AS `Camp`,`c`.`SelTab` AS `SelTab`,json_arrayagg(json_object('IdConditie',`c`.`IdConditie`,'IdConditieS',`c`.`IdConditieS`,'Grup',`c`.`Grup`,'CandDaca',`c`.`CandDaca`,'Pozitie',`c`.`Pozitie`,'CampS',`c`.`CampAsociat`,'Semn',case when `c`.`Semn` = -1 then NULL when `c`.`Semn` = 1 then '=' when `c`.`Semn` = 2 then '=' else `c`.`Semn` end,'AfisareS',`c`.`AfisareSemn`,'Valoare',`c`.`Valoare`,'AfisareV',`c`.`AfisareValoare`,'AltCamp',`c`.`AltCamp`,'Mesaj',`c`.`Mesaj`,'TipCampS',`c`.`TipCampAsociat`,'TipCampV',`c`.`TipCampValoare`,'Functie',`c`.`Functie`) order by `c`.`Pozitie` ASC) AS `jsnConditie` from `ConditiiS` `c` group by `c`.`IdConditie`,`c`.`Grup`) `T` group by `T`.`IdConditie`;

-- ----------------------------
-- View structure for viewConsultanti
-- ----------------------------
DROP VIEW IF EXISTS `viewConsultanti`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewConsultanti` AS select `c`.`IdConsultant` AS `IdConsultant`,`c`.`NumeConsultant` AS `NumeConsultant`,`cp`.`NumeConsultant` AS `NumeParinte`,ifnull(`c`.`IdParinte`,0) AS `IdParinte`,`c`.`IdNivel` AS `IdNivel`,`c`.`IdRegiune` AS `IdRegiune`,`c`.`CNP` AS `CNP`,`c`.`Adresa` AS `Adresa`,`c`.`Ascuns` AS `Ascuns`,`c`.`Functie` AS `Functie`,`c`.`cMail` AS `cMail`,`c`.`cTelefon` AS `cTelefon`,`c`.`CodFiscal` AS `CodFiscal`,`c`.`CodJudet` AS `CodJudet`,`c`.`CodOras` AS `CodOras`,`c`.`DataAdaugare` AS `DataAdaugare`,`c`.`DataModificare` AS `DataModificare`,`c`.`SchimbaParola` AS `SchimbaParola`,`c`.`Nou` AS `Nou`,`c`.`Plecat` AS `Plecat`,`c`.`Sistem` AS `Sistem`,`c`.`Suffix` AS `Suffix`,`c`.`Beta` AS `Beta`,`c`.`K1` AS `K1`,`n`.`Prefix` AS `Prefix`,`n`.`PicText` AS `PicText`,if(`cc`.`cCaut` is null,concat_ws(',',ucase(trim(`c`.`NumeConsultant`)),regexp_replace(`c`.`cTelefon`,'\\D+','')),`cc`.`cCaut`) AS `Caut`,if(`cc`.`cCaut2` is null,`c`.`IdConsultant`,`cc`.`cCaut2`) AS `Caut2` from (((`SVN_00`.`Consultanti` `c` join `SVN_00`.`Niveluri` `n` on(`c`.`IdNivel` = `n`.`IdNivel`)) left join `SVN_00`.`Consultanti` `cp` on(`c`.`IdParinte` = `cp`.`IdConsultant`)) left join (select `SVN_00`.`Consultanti_Copii`.`IdCopil` AS `IdCopil`,group_concat(concat_ws(',',ucase(trim(`SVN_00`.`Consultanti`.`NumeConsultant`)),regexp_replace(`SVN_00`.`Consultanti`.`cTelefon`,'\\D+','')) separator ',') AS `cCaut`,group_concat(`SVN_00`.`Consultanti_Copii`.`IdCopilCopil` separator ',') AS `cCaut2` from (`SVN_00`.`Consultanti_Copii` join `SVN_00`.`Consultanti` on(`SVN_00`.`Consultanti_Copii`.`IdCopilCopil` = `SVN_00`.`Consultanti`.`IdConsultant`)) group by `SVN_00`.`Consultanti_Copii`.`IdCopil`) `cc` on(`c`.`IdConsultant` = `cc`.`IdCopil`)) where `c`.`Ascuns` = 0 group by `c`.`IdConsultant` order by `c`.`IdNivel` desc,`c`.`NumeConsultant`;

-- ----------------------------
-- View structure for viewConsultantiRaport
-- ----------------------------
DROP VIEW IF EXISTS `viewConsultantiRaport`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewConsultantiRaport` AS with recursive Hierarchy(`IdConsultant`,`IdParinte`,`IdNivel`,`IdRegiune`,`NumeConsultant`,`CNP`,`Adresa`,`Ascuns`,`Functie`,`cMail`,`cTelefon`,`CodFiscal`,`CodJudet`,`CodOras`,`DataAdaugare`,`HierarchyLevel`,`HierarchyPath`) as (select `Consultanti`.`IdConsultant` AS `IdConsultant`,`Consultanti`.`IdParinte` AS `IdParinte`,`Consultanti`.`IdNivel` AS `IdNivel`,`Consultanti`.`IdRegiune` AS `IdRegiune`,`Consultanti`.`NumeConsultant` AS `NumeConsultant`,`Consultanti`.`CNP` AS `CNP`,`Consultanti`.`Adresa` AS `Adresa`,`Consultanti`.`Ascuns` AS `Ascuns`,`Consultanti`.`Functie` AS `Functie`,`Consultanti`.`cMail` AS `cMail`,`Consultanti`.`cTelefon` AS `cTelefon`,`Consultanti`.`CodFiscal` AS `CodFiscal`,`Consultanti`.`CodJudet` AS `CodJudet`,`Consultanti`.`CodOras` AS `CodOras`,`Consultanti`.`DataAdaugare` AS `DataAdaugare`,0 AS `HierarchyLevel`,cast(`Consultanti`.`NumeConsultant` as char(255) charset utf8mb4) AS `HierarchyPath` from `SVN_IM`.`Consultanti` where `Consultanti`.`IdParinte` is null and `Consultanti`.`Plecat` = 0 and `Consultanti`.`Sistem` = 0 union all select `c`.`IdConsultant` AS `IdConsultant`,`c`.`IdParinte` AS `IdParinte`,`c`.`IdNivel` AS `IdNivel`,`c`.`IdRegiune` AS `IdRegiune`,`c`.`NumeConsultant` AS `NumeConsultant`,`c`.`CNP` AS `CNP`,`c`.`Adresa` AS `Adresa`,`c`.`Ascuns` AS `Ascuns`,`c`.`Functie` AS `Functie`,`c`.`cMail` AS `cMail`,`c`.`cTelefon` AS `cTelefon`,`c`.`CodFiscal` AS `CodFiscal`,`c`.`CodJudet` AS `CodJudet`,`c`.`CodOras` AS `CodOras`,`c`.`DataAdaugare` AS `DataAdaugare`,`h`.`HierarchyLevel` + 1 AS `h.HierarchyLevel + 1`,concat(`h`.`HierarchyPath`,',',`c`.`NumeConsultant`) AS `CONCAT(h.HierarchyPath, ',', c.NumeConsultant)` from (`SVN_IM`.`Consultanti` `c` join `Hierarchy` `h` on(`c`.`IdParinte` = `h`.`IdConsultant`)) where `h`.`HierarchyLevel` <= 8)select `Hierarchy`.`HierarchyLevel` AS `HierarchyLevel`,`Hierarchy`.`HierarchyPath` AS `HierarchyPath`,`Hierarchy`.`IdConsultant` AS `IdConsultant`,`Hierarchy`.`IdNivel` AS `IdNivel`,`Hierarchy`.`NumeConsultant` AS `NumeConsultant`,`Hierarchy`.`cMail` AS `cMail`,`Hierarchy`.`cTelefon` AS `cTelefon`,`Hierarchy`.`DataAdaugare` AS `DataAdaugare` from `Hierarchy` where `Hierarchy`.`Ascuns` = 0 order by `Hierarchy`.`HierarchyPath`;

-- ----------------------------
-- View structure for viewConsultanti_Bun
-- ----------------------------
DROP VIEW IF EXISTS `viewConsultanti_Bun`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewConsultanti_Bun` AS select `c`.`IdConsultant` AS `IdConsultant`,`c`.`NumeConsultant` AS `NumeConsultant`,`ph`.`Parinte` AS `Parinte`,ifnull(`ph`.`TopParent`,0) AS `IdParinteTop`,ifnull(`c`.`IdParinte`,0) AS `IdParinte`,`c`.`IdNivel` AS `IdNivel`,`c`.`IdRegiune` AS `IdRegiune`,`c`.`CNP` AS `CNP`,`c`.`Adresa` AS `Adresa`,`c`.`Ascuns` AS `Ascuns`,`c`.`Functie` AS `Functie`,`c`.`cMail` AS `cMail`,`c`.`cTelefon` AS `cTelefon`,`c`.`CodFiscal` AS `CodFiscal`,`c`.`CodJudet` AS `CodJudet`,`c`.`CodOras` AS `CodOras`,`c`.`DataAdaugare` AS `DataAdaugare`,`c`.`DataModificare` AS `DataModificare`,`c`.`SchimbaParola` AS `SchimbaParola`,`c`.`Nou` AS `Nou`,`c`.`Plecat` AS `Plecat`,`c`.`Sistem` AS `Sistem`,`c`.`Suffix` AS `Suffix`,`c`.`Beta` AS `Beta`,`c`.`K1` AS `K1`,`n`.`Prefix` AS `Prefix`,`n`.`PicText` AS `PicText`,`ph`.`Path` AS `Path` from ((`SVN_00`.`Consultanti` `c` join `SVN_00`.`CTree` `ph` on(`c`.`IdConsultant` = `ph`.`IdConsultant`)) join `SVN_00`.`Niveluri` `n` on(`c`.`IdNivel` = `n`.`IdNivel`)) where `c`.`Ascuns` = 0 group by `c`.`IdConsultant` order by `ph`.`TopParent`,`c`.`IdNivel` desc,`c`.`NumeConsultant`;

-- ----------------------------
-- View structure for viewConsultanti_R
-- ----------------------------
DROP VIEW IF EXISTS `viewConsultanti_R`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewConsultanti_R` AS with recursive ConsultantHierarchy as (select `Consultanti`.`IdConsultant` AS `IdConsultant`,`Consultanti`.`NumeConsultant` AS `NumeConsultant`,`Consultanti`.`IdParinte` AS `IdParinte`,1 AS `Lvl`,`Consultanti`.`IdConsultant` AS `Id1`,NULL AS `Id2`,NULL AS `Id3`,NULL AS `Id4`,NULL AS `Id5` from `SVN_IM`.`Consultanti` where `Consultanti`.`IdNivel` = 40 union all select `c`.`IdConsultant` AS `IdConsultant`,`c`.`NumeConsultant` AS `NumeConsultant`,`c`.`IdParinte` AS `IdParinte`,`ch`.`Lvl` + 1 AS `Lvl`,case when `ch`.`Lvl` = 1 then `c`.`IdConsultant` else `ch`.`Id1` end AS `Id1`,case when `ch`.`Lvl` = 1 then NULL when `ch`.`Lvl` = 2 then `c`.`IdConsultant` else `ch`.`Id2` end AS `Id2`,case when `ch`.`Lvl` = 1 then NULL when `ch`.`Lvl` = 2 then NULL when `ch`.`Lvl` = 3 then `c`.`IdConsultant` else `ch`.`Id3` end AS `Id3`,case when `ch`.`Lvl` = 1 then NULL when `ch`.`Lvl` = 2 then NULL when `ch`.`Lvl` = 3 then NULL when `ch`.`Lvl` = 4 then `c`.`IdConsultant` else `ch`.`Id4` end AS `Id4`,case when `ch`.`Lvl` = 1 then NULL when `ch`.`Lvl` = 2 then NULL when `ch`.`Lvl` = 3 then NULL when `ch`.`Lvl` = 4 then NULL when `ch`.`Lvl` = 5 then `c`.`IdConsultant` else `ch`.`Id5` end AS `Id5` from (`SVN_IM`.`Consultanti` `c` join `ConsultantHierarchy` `ch` on(`c`.`IdParinte` = `ch`.`IdConsultant`)))select `ConsultantHierarchy`.`IdConsultant` AS `IdConsultant`,`ConsultantHierarchy`.`NumeConsultant` AS `NumeConsultant`,`ConsultantHierarchy`.`IdParinte` AS `IdParinte`,`ConsultantHierarchy`.`Lvl` AS `Lvl`,`ConsultantHierarchy`.`Id1` AS `Id1`,`ConsultantHierarchy`.`Id2` AS `Id2`,`ConsultantHierarchy`.`Id3` AS `Id3`,`ConsultantHierarchy`.`Id4` AS `Id4`,`ConsultantHierarchy`.`Id5` AS `Id5` from `ConsultantHierarchy` order by `ConsultantHierarchy`.`Lvl`,`ConsultantHierarchy`.`NumeConsultant`;

-- ----------------------------
-- View structure for viewDosar
-- ----------------------------
DROP VIEW IF EXISTS `viewDosar`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewDosar` AS select `D`.`IdDosar` AS `IdDosar`,`D`.`IdBaza` AS `IdBaza`,`D`.`IdClient` AS `IdClient`,`D`.`IdConsultant` AS `IdConsultant`,`D`.`IdAgent` AS `IdAgent`,`D`.`IdSursa` AS `IdSursa`,`D`.`IdFunctie` AS `IdFunctie`,`D`.`IdBanca` AS `IdBanca`,`D`.`IdSucursala` AS `IdSucursala`,`D`.`IdStare` AS `IdStare`,`D`.`IdStatus` AS `IdStatus`,`D`.`IdDomeniu` AS `IdDomeniu`,`D`.`IdFunctieFunctie` AS `IdFunctieFunctie`,`D`.`IdTipCompanie` AS `IdTipCompanie`,`D`.`IdCompanie` AS `IdCompanie`,`D`.`IdEvaluator` AS `IdEvaluator`,`D`.`IdMotiv` AS `IdMotiv`,`D`.`IdNotar` AS `IdNotar`,`D`.`IdTipImobil` AS `IdTipImobil`,`D`.`IdVenit` AS `IdVenit`,`D`.`IdTipDobanda` AS `IdTipDobanda`,`D`.`IdTipMoneda` AS `IdTipMoneda`,`D`.`IdTipCredit` AS `IdTipCredit`,`D`.`Venit` AS `Venit`,`D`.`ValoareCredit` AS `ValoareCredit`,`D`.`ValoareCreditRON` AS `ValoareCreditRON`,`D`.`PerioadaCredit` AS `PerioadaCredit`,`D`.`PerioadaDobanda` AS `PerioadaDobanda`,`D`.`Dobanda` AS `Dobanda`,`D`.`MarjaDobanda` AS `MarjaDobanda`,`D`.`MarjaDobandaDF` AS `MarjaDobandaDF`,`D`.`ValoareImobil` AS `ValoareImobil`,`D`.`ConsilierBanca` AS `ConsilierBanca`,`D`.`CodBanca` AS `CodBanca`,`D`.`DataIntroducere` AS `DataIntroducere`,`D`.`DataPreaprobare` AS `DataPreaprobare`,`D`.`DataOpinieJ` AS `DataOpinieJ`,`D`.`DataTrimitere` AS `DataTrimitere`,`D`.`DataDebursare` AS `DataDebursare`,`D`.`DataRespingere` AS `DataRespingere`,`D`.`DataSemnare` AS `DataSemnare`,`D`.`CursMoneda` AS `CursMoneda`,`D`.`Codebitor` AS `Codebitor`,`D`.`AreImobil` AS `AreImobil`,`D`.`ObservatiiFinale` AS `ObservatiiFinale`,`D`.`ValoareCreditTras` AS `ValoareCreditTras`,`D`.`DIFD` AS `DIFD`,`DS`.`Stare` AS `Stare`,`DSt`.`FelStatus` AS `FelStatus`,`DSt`.`TipStatus` AS `TipStatus`,`DSt`.`IDSG` AS `IDSG`,`DSt`.`AltaBanca` AS `AltaBanca`,`B`.`DataPrimire` AS `DataPrimire`,`Cl`.`NumeClient` AS `NumeClient`,`Cl`.`CNPClient` AS `CNPClient`,`Cl`.`TelefonP` AS `TelefonClient`,`Cl`.`EmailP` AS `EmailClient`,`Cl`.`DataNastere` AS `DataNastere`,`Cl`.`IdJudet` AS `IdJudet`,`Cl`.`DIFN` AS `DIFN`,`Cl`.`Tara` AS `Tara`,`Cl`.`RO` AS `RO`,(select `Judete`.`Judet` from `SVN_IM`.`Judete` where `Judete`.`IdJudet` = `Cl`.`IdJudet`) AS `JudetClient`,`C`.`NumeConsultant` AS `NumeConsultant`,`C`.`cTelefon` AS `cTelefon`,`C`.`cMail` AS `cMail`,`A`.`NumeAgent` AS `NumeAgent`,`A`.`aTelefon` AS `aTelefon`,`A`.`aMail` AS `aMail`,`SL`.`Sursa` AS `Sursa`,(select `SVN_IM`.`Dosar_Functii_Companie`.`Companie` from `SVN_IM`.`Dosar_Functii_Companie` where `SVN_IM`.`Dosar_Functii_Companie`.`IdCompanie` = `D`.`IdCompanie`) AS `Companie`,(select `SVN_IM`.`Dosar_Functii_Domeniu`.`Domeniu` from `SVN_IM`.`Dosar_Functii_Domeniu` where `SVN_IM`.`Dosar_Functii_Domeniu`.`IdDomeniu` = `D`.`IdDomeniu`) AS `Domeniu`,(select `SVN_IM`.`Dosar_Functii_Functie`.`Functie` from `SVN_IM`.`Dosar_Functii_Functie` where `SVN_IM`.`Dosar_Functii_Functie`.`IdFunctieFunctie` = `D`.`IdFunctieFunctie`) AS `Functie`,(select `SVN_IM`.`Dosar_Functii_TipCompanie`.`TipCompanie` from `SVN_IM`.`Dosar_Functii_TipCompanie` where `SVN_IM`.`Dosar_Functii_TipCompanie`.`IdTipCompanie` = `D`.`IdTipCompanie`) AS `TipCompanie`,(select `SVN_IM`.`Banci`.`Banca` from `SVN_IM`.`Banci` where `SVN_IM`.`Banci`.`IdBanca` = `D`.`IdBanca`) AS `Banca`,`S`.`Sucursala` AS `Sucursala`,(select `Judete`.`Judet` from `SVN_IM`.`Judete` where `Judete`.`IdJudet` = `S`.`IdJudet`) AS `JudetBanca`,`S`.`Orasul` AS `Oras_Banca`,`DTV`.`TipVenit` AS `TipVenit`,`DTD`.`TipDobanda` AS `TipDobanda`,`DTM`.`Moneda` AS `Moneda`,(select `SVN_IM`.`Dosar_TipCredit`.`TipCredit` from `SVN_IM`.`Dosar_TipCredit` where `SVN_IM`.`Dosar_TipCredit`.`IdTipCredit` = `D`.`IdTipCredit`) AS `TipCredit`,`DN`.`Notar` AS `Notar`,`DE`.`Evaluator` AS `Evaluator`,`DTI`.`TipImobil` AS `TipImobil`,`DM`.`Motiv` AS `Motiv`,`CD`.`IdCod` AS `IdCodebitor`,`CD`.`NumeCod` AS `NumeCodebitor`,`CD`.`CNPCod` AS `CNPCodebitor`,`CD`.`EmailCod` AS `EmailCodebitor`,`CD`.`TelefonCod` AS `TelefonCodebitor`,`CD`.`Tara` AS `TaraCodebitor`,`CD`.`RO` AS `ROCodebitor`,0 AS `S`,0 AS `DIF`,0 AS `DIFF`,`D`.`DataModificare` AS `DataModificare`,'Dosar' AS `TblName`,'IdDosar' AS `IdName` from ((((((((((((((((`SVN_IM`.`Dosar` `D` join `SVN_IM`.`Dosar_Stare` `DS` on(`D`.`IdStare` = `DS`.`IdStare`)) join `SVN_IM`.`Dosar_Status` `DSt` FORCE INDEX (PRIMARY) on(`D`.`IdStatus` = `DSt`.`IdStatus`)) join `SVN_IM`.`Baza` `B` on(`D`.`IdBaza` = `B`.`IdBaza`)) join `SVN_IM`.`Agenti` `A` on(`D`.`IdAgent` = `A`.`IdAgent`)) join `SVN_IM`.`Consultanti` `C` on(`D`.`IdConsultant` = `C`.`IdConsultant`)) join `SVN_IM`.`Clienti` `Cl` on(`D`.`IdClient` = `Cl`.`IdClient`)) join `SVN_IM`.`SursaLead` `SL` on(`D`.`IdSursa` = `SL`.`IdSursa`)) join `SVN_IM`.`Sucursale` `S` on(`D`.`IdSucursala` = `S`.`IdSucursala`)) join `SVN_IM`.`Dosar_TipVenit` `DTV` on(`D`.`IdVenit` = `DTV`.`IdVenit`)) left join `SVN_IM`.`Dosar_TipDobanda` `DTD` on(`D`.`IdTipDobanda` = `DTD`.`IdTipDobanda`)) join `SVN_IM`.`Dosar_TipMoneda` `DTM` on(`D`.`IdTipMoneda` = `DTM`.`IdTipMoneda`)) left join `SVN_IM`.`Dosar_Notari` `DN` on(`D`.`IdNotar` = `DN`.`IdNotar`)) left join `SVN_IM`.`Dosar_Evaluatori` `DE` on(`D`.`IdEvaluator` = `DE`.`IdEvaluator`)) left join `SVN_IM`.`Dosar_TipImobil` `DTI` on(`D`.`IdTipImobil` = `DTI`.`IdTipImobil`)) left join `SVN_IM`.`Dosar_Motiv` `DM` on(`D`.`IdMotiv` = `DM`.`IdMotiv`)) left join `SVN_IM`.`Codebitori` `CD` on(`D`.`IdDosar` = `CD`.`IdDosar`)) where `D`.`Ascuns` = 0;

-- ----------------------------
-- View structure for viewDosar_2025
-- ----------------------------
DROP VIEW IF EXISTS `viewDosar_2025`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewDosar_2025` AS select `D`.`IdDosar` AS `IdDosar`,`D`.`IdBaza` AS `IdBaza`,`D`.`IdClient` AS `IdClient`,`D`.`IdConsultant` AS `IdConsultant`,`D`.`IdAgent` AS `IdAgent`,`D`.`IdSursa` AS `IdSursa`,`D`.`IdFunctie` AS `IdFunctie`,`D`.`IdBanca` AS `IdBanca`,`D`.`IdSucursala` AS `IdSucursala`,`D`.`IdStare` AS `IdStare`,`D`.`IdStatus` AS `IdStatus`,`D`.`IdDomeniu` AS `IdDomeniu`,`D`.`IdFunctieFunctie` AS `IdFunctieFunctie`,`D`.`IdTipCompanie` AS `IdTipCompanie`,`D`.`IdCompanie` AS `IdCompanie`,`D`.`IdEvaluator` AS `IdEvaluator`,`D`.`IdMotiv` AS `IdMotiv`,`D`.`IdNotar` AS `IdNotar`,`D`.`IdTipImobil` AS `IdTipImobil`,`D`.`IdVenit` AS `IdVenit`,`D`.`IdTipDobanda` AS `IdTipDobanda`,`D`.`IdTipMoneda` AS `IdTipMoneda`,`D`.`IdTipCredit` AS `IdTipCredit`,`D`.`Venit` AS `Venit`,`D`.`ValoareCredit` AS `ValoareCredit`,`D`.`ValoareCreditRON` AS `ValoareCreditRON`,`D`.`PerioadaCredit` AS `PerioadaCredit`,`D`.`PerioadaDobanda` AS `PerioadaDobanda`,`D`.`Dobanda` AS `Dobanda`,`D`.`MarjaDobanda` AS `MarjaDobanda`,`D`.`MarjaDobandaDF` AS `MarjaDobandaDF`,`D`.`ValoareImobil` AS `ValoareImobil`,`D`.`ConsilierBanca` AS `ConsilierBanca`,`D`.`CodBanca` AS `CodBanca`,`D`.`DataIntroducere` AS `DataIntroducere`,`D`.`DataPreaprobare` AS `DataPreaprobare`,`D`.`DataOpinieJ` AS `DataOpinieJ`,`D`.`DataTrimitere` AS `DataTrimitere`,`D`.`DataDebursare` AS `DataDebursare`,`D`.`DataRespingere` AS `DataRespingere`,`D`.`DataSemnare` AS `DataSemnare`,`D`.`CursMoneda` AS `CursMoneda`,`D`.`Codebitor` AS `Codebitor`,`D`.`AreImobil` AS `AreImobil`,`D`.`ObservatiiFinale` AS `ObservatiiFinale`,`D`.`ValoareCreditTras` AS `ValoareCreditTras`,`D`.`DIFD` AS `DIFD`,`DS`.`Stare` AS `Stare`,`DSt`.`FelStatus` AS `FelStatus`,`DSt`.`TipStatus` AS `TipStatus`,`DSt`.`IDSG` AS `IDSG`,`DSt`.`AltaBanca` AS `AltaBanca`,`B`.`DataPrimire` AS `DataPrimire`,`Cl`.`NumeClient` AS `NumeClient`,`Cl`.`CNPClient` AS `CNPClient`,`Cl`.`TelefonP` AS `TelefonClient`,`Cl`.`EmailP` AS `EmailClient`,`Cl`.`DataNastere` AS `DataNastere`,`Cl`.`IdJudet` AS `IdJudet`,`Cl`.`DIFN` AS `DIFN`,`Cl`.`Tara` AS `Tara`,`Cl`.`RO` AS `RO`,`Jc`.`Judet` AS `JudetClient`,`C`.`NumeConsultant` AS `NumeConsultant`,`C`.`cTelefon` AS `cTelefon`,`C`.`cMail` AS `cMail`,`A`.`NumeAgent` AS `NumeAgent`,`A`.`aTelefon` AS `aTelefon`,`A`.`aMail` AS `aMail`,`SL`.`Sursa` AS `Sursa`,`Cmp`.`Companie` AS `Companie`,`Dom`.`Domeniu` AS `Domeniu`,`Fnc`.`Functie` AS `Functie`,`TcTip`.`TipCompanie` AS `TipCompanie`,`Bn`.`Banca` AS `Banca`,`S`.`Sucursala` AS `Sucursala`,`Jb`.`Judet` AS `JudetBanca`,`S`.`Orasul` AS `Oras_Banca`,`DTV`.`TipVenit` AS `TipVenit`,`DTD`.`TipDobanda` AS `TipDobanda`,`DTM`.`Moneda` AS `Moneda`,`TcCred`.`TipCredit` AS `TipCredit`,`DN`.`Notar` AS `Notar`,`DE`.`Evaluator` AS `Evaluator`,`DTI`.`TipImobil` AS `TipImobil`,`DM`.`Motiv` AS `Motiv`,`cb2`.`IdCod` AS `IdCodebitor`,`cb2`.`NumeCod` AS `NumeCodebitor`,`cb2`.`CNPCod` AS `CNPCodebitor`,`cb2`.`EmailCod` AS `EmailCodebitor`,`cb2`.`TelefonCod` AS `TelefonCodebitor`,`cb2`.`Tara` AS `TaraCodebitor`,`cb2`.`RO` AS `ROCodebitor`,0 AS `S`,0 AS `DIF`,0 AS `DIFF`,`D`.`DataModificare` AS `DataModificare`,'Dosar' AS `TblName`,'IdDosar' AS `IdName` from (((((((((((((((((((((((((`SVN_IM`.`Dosar` `D` join `SVN_IM`.`Dosar_Stare` `DS` on(`D`.`IdStare` = `DS`.`IdStare`)) join `SVN_IM`.`Dosar_Status` `DSt` on(`D`.`IdStatus` = `DSt`.`IdStatus`)) join `SVN_IM`.`Baza` `B` on(`D`.`IdBaza` = `B`.`IdBaza`)) join `SVN_IM`.`Agenti` `A` on(`D`.`IdAgent` = `A`.`IdAgent`)) join `SVN_IM`.`Consultanti` `C` on(`D`.`IdConsultant` = `C`.`IdConsultant`)) join `SVN_IM`.`Clienti` `Cl` on(`D`.`IdClient` = `Cl`.`IdClient`)) join `SVN_IM`.`SursaLead` `SL` on(`D`.`IdSursa` = `SL`.`IdSursa`)) join `SVN_IM`.`Sucursale` `S` on(`D`.`IdSucursala` = `S`.`IdSucursala`)) join `SVN_IM`.`Dosar_TipVenit` `DTV` on(`D`.`IdVenit` = `DTV`.`IdVenit`)) left join `SVN_IM`.`Dosar_TipDobanda` `DTD` on(`D`.`IdTipDobanda` = `DTD`.`IdTipDobanda`)) join `SVN_IM`.`Dosar_TipMoneda` `DTM` on(`D`.`IdTipMoneda` = `DTM`.`IdTipMoneda`)) left join `SVN_IM`.`Dosar_Notari` `DN` on(`D`.`IdNotar` = `DN`.`IdNotar`)) left join `SVN_IM`.`Dosar_Evaluatori` `DE` on(`D`.`IdEvaluator` = `DE`.`IdEvaluator`)) left join `SVN_IM`.`Dosar_TipImobil` `DTI` on(`D`.`IdTipImobil` = `DTI`.`IdTipImobil`)) left join `SVN_IM`.`Dosar_Motiv` `DM` on(`D`.`IdMotiv` = `DM`.`IdMotiv`)) left join `SVN_IM`.`Judete` `Jc` on(`Cl`.`IdJudet` = `Jc`.`IdJudet`)) left join `SVN_IM`.`Dosar_Functii_Companie` `Cmp` on(`D`.`IdCompanie` = `Cmp`.`IdCompanie`)) left join `SVN_IM`.`Dosar_Functii_Domeniu` `Dom` on(`D`.`IdDomeniu` = `Dom`.`IdDomeniu`)) left join `SVN_IM`.`Dosar_Functii_Functie` `Fnc` on(`D`.`IdFunctieFunctie` = `Fnc`.`IdFunctieFunctie`)) left join `SVN_IM`.`Dosar_Functii_TipCompanie` `TcTip` on(`D`.`IdTipCompanie` = `TcTip`.`IdTipCompanie`)) left join `SVN_IM`.`Banci` `Bn` on(`D`.`IdBanca` = `Bn`.`IdBanca`)) left join `SVN_IM`.`Judete` `Jb` on(`S`.`IdJudet` = `Jb`.`IdJudet`)) left join `SVN_IM`.`Dosar_TipCredit` `TcCred` on(`D`.`IdTipCredit` = `TcCred`.`IdTipCredit`)) left join (select `SVN_IM`.`Codebitori`.`IdDosar` AS `IdDosar`,min(`SVN_IM`.`Codebitori`.`IdCod`) AS `MinCod` from `SVN_IM`.`Codebitori` FORCE INDEX (`idx_Codebitori_IdDosar_IdCod`) group by `SVN_IM`.`Codebitori`.`IdDosar` order by `SVN_IM`.`Codebitori`.`IdDosar`) `cbmin` on(`cbmin`.`IdDosar` = `D`.`IdDosar`)) left join `SVN_IM`.`Codebitori` `cb2` on(`cb2`.`IdDosar` = `cbmin`.`IdDosar` and `cb2`.`IdCod` = `cbmin`.`MinCod`)) where `D`.`Ascuns` = 0;

-- ----------------------------
-- View structure for viewDosar_export
-- ----------------------------
DROP VIEW IF EXISTS `viewDosar_export`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewDosar_export` AS select `D`.`IdDosar` AS `IdDosar`,`D`.`IdBaza` AS `IdBaza`,`D`.`IdClient` AS `IdClient`,`D`.`IdConsultant` AS `IdConsultant`,`D`.`IdAgent` AS `IdAgent`,`D`.`IdSursa` AS `IdSursa`,`D`.`IdFunctie` AS `IdFunctie`,`D`.`IdBanca` AS `IdBanca`,`D`.`IdSucursala` AS `IdSucursala`,`D`.`IdStare` AS `IdStare`,`D`.`IdStatus` AS `IdStatus`,`D`.`IdDomeniu` AS `IdDomeniu`,`D`.`IdFunctieFunctie` AS `IdFunctieFunctie`,`D`.`IdTipCompanie` AS `IdTipCompanie`,`D`.`IdCompanie` AS `IdCompanie`,`D`.`IdEvaluator` AS `IdEvaluator`,`D`.`IdMotiv` AS `IdMotiv`,`D`.`IdNotar` AS `IdNotar`,`D`.`IdTipImobil` AS `IdTipImobil`,`D`.`IdVenit` AS `IdVenit`,`D`.`IdTipDobanda` AS `IdTipDobanda`,`D`.`IdTipMoneda` AS `IdTipMoneda`,`D`.`IdTipCredit` AS `IdTipCredit`,`D`.`Venit` AS `Venit`,`D`.`ValoareCredit` AS `ValoareCredit`,`D`.`ValoareCreditRON` AS `ValoareCreditRON`,`D`.`PerioadaCredit` AS `PerioadaCredit`,`D`.`PerioadaDobanda` AS `PerioadaDobanda`,`D`.`Dobanda` AS `Dobanda`,`D`.`MarjaDobanda` AS `MarjaDobanda`,`D`.`MarjaDobandaDF` AS `MarjaDobandaDF`,`D`.`ValoareImobil` AS `ValoareImobil`,`D`.`ConsilierBanca` AS `ConsilierBanca`,`D`.`CodBanca` AS `CodBanca`,`D`.`DataIntroducere` AS `DataIntroducere`,`D`.`DataPreaprobare` AS `DataPreaprobare`,`D`.`DataOpinieJ` AS `DataOpinieJ`,`D`.`DataTrimitere` AS `DataTrimitere`,`D`.`DataDebursare` AS `DataDebursare`,`D`.`DataRespingere` AS `DataRespingere`,`D`.`DataSemnare` AS `DataSemnare`,`D`.`CursMoneda` AS `CursMoneda`,`D`.`Codebitor` AS `Codebitor`,`D`.`AreImobil` AS `AreImobil`,`D`.`ObservatiiFinale` AS `ObservatiiFinale`,`D`.`ValoareCreditTras` AS `ValoareCreditTras`,`D`.`DIFD` AS `DIFD`,`DS`.`Stare` AS `Stare`,`DSt`.`FelStatus` AS `FelStatus`,`DSt`.`TipStatus` AS `TipStatus`,`DSt`.`IDSG` AS `IDSG`,`DSt`.`AltaBanca` AS `AltaBanca`,`B`.`DataPrimire` AS `DataPrimire`,`Cl`.`NumeClient` AS `NumeClient`,`Cl`.`CNPClient` AS `CNPClient`,`Cl`.`TelefonP` AS `TelefonClient`,`Cl`.`EmailP` AS `EmailClient`,`Cl`.`DataNastere` AS `DataNastere`,`Cl`.`IdJudet` AS `IdJudet`,`Cl`.`DIFN` AS `DIFN`,`Cl`.`Tara` AS `Tara`,`Cl`.`RO` AS `RO`,`Jc`.`Judet` AS `JudetClient`,`C`.`NumeConsultant` AS `NumeConsultant`,`C`.`cTelefon` AS `cTelefon`,`C`.`cMail` AS `cMail`,`A`.`NumeAgent` AS `NumeAgent`,`A`.`aTelefon` AS `aTelefon`,`A`.`aMail` AS `aMail`,`SL`.`Sursa` AS `Sursa`,`Cmp`.`Companie` AS `Companie`,`Dom`.`Domeniu` AS `Domeniu`,`Fnc`.`Functie` AS `Functie`,`TcTip`.`TipCompanie` AS `TipCompanie`,`Bn`.`Banca` AS `Banca`,`S`.`Sucursala` AS `Sucursala`,`Jb`.`Judet` AS `JudetBanca`,`S`.`Orasul` AS `Oras_Banca`,`DTV`.`TipVenit` AS `TipVenit`,`DTD`.`TipDobanda` AS `TipDobanda`,`DTM`.`Moneda` AS `Moneda`,`TcCred`.`TipCredit` AS `TipCredit`,`DN`.`Notar` AS `Notar`,`DE`.`Evaluator` AS `Evaluator`,`DTI`.`TipImobil` AS `TipImobil`,`DM`.`Motiv` AS `Motiv`,`cb2`.`IdCod` AS `IdCodebitor`,`cb2`.`NumeCod` AS `NumeCodebitor`,`cb2`.`CNPCod` AS `CNPCodebitor`,`cb2`.`EmailCod` AS `EmailCodebitor`,`cb2`.`TelefonCod` AS `TelefonCodebitor`,`cb2`.`Tara` AS `TaraCodebitor`,`cb2`.`RO` AS `ROCodebitor`,0 AS `S`,0 AS `DIF`,0 AS `DIFF`,`D`.`DataModificare` AS `DataModificare`,'Dosar' AS `TblName`,'IdDosar' AS `IdName` from (((((((((((((((((((((((((`SVN_IM`.`Dosar` `D` join `SVN_IM`.`Dosar_Stare` `DS` on(`D`.`IdStare` = `DS`.`IdStare`)) join `SVN_IM`.`Dosar_Status` `DSt` on(`D`.`IdStatus` = `DSt`.`IdStatus`)) join `SVN_IM`.`Baza` `B` on(`D`.`IdBaza` = `B`.`IdBaza`)) join `SVN_IM`.`Agenti` `A` on(`D`.`IdAgent` = `A`.`IdAgent`)) join `SVN_IM`.`Consultanti` `C` on(`D`.`IdConsultant` = `C`.`IdConsultant`)) join `SVN_IM`.`Clienti` `Cl` on(`D`.`IdClient` = `Cl`.`IdClient`)) join `SVN_IM`.`SursaLead` `SL` on(`D`.`IdSursa` = `SL`.`IdSursa`)) join `SVN_IM`.`Sucursale` `S` on(`D`.`IdSucursala` = `S`.`IdSucursala`)) join `SVN_IM`.`Dosar_TipVenit` `DTV` on(`D`.`IdVenit` = `DTV`.`IdVenit`)) left join `SVN_IM`.`Dosar_TipDobanda` `DTD` on(`D`.`IdTipDobanda` = `DTD`.`IdTipDobanda`)) join `SVN_IM`.`Dosar_TipMoneda` `DTM` on(`D`.`IdTipMoneda` = `DTM`.`IdTipMoneda`)) left join `SVN_IM`.`Dosar_Notari` `DN` on(`D`.`IdNotar` = `DN`.`IdNotar`)) left join `SVN_IM`.`Dosar_Evaluatori` `DE` on(`D`.`IdEvaluator` = `DE`.`IdEvaluator`)) left join `SVN_IM`.`Dosar_TipImobil` `DTI` on(`D`.`IdTipImobil` = `DTI`.`IdTipImobil`)) left join `SVN_IM`.`Dosar_Motiv` `DM` on(`D`.`IdMotiv` = `DM`.`IdMotiv`)) left join `SVN_IM`.`Judete` `Jc` on(`Cl`.`IdJudet` = `Jc`.`IdJudet`)) left join `SVN_IM`.`Dosar_Functii_Companie` `Cmp` on(`D`.`IdCompanie` = `Cmp`.`IdCompanie`)) left join `SVN_IM`.`Dosar_Functii_Domeniu` `Dom` on(`D`.`IdDomeniu` = `Dom`.`IdDomeniu`)) left join `SVN_IM`.`Dosar_Functii_Functie` `Fnc` on(`D`.`IdFunctieFunctie` = `Fnc`.`IdFunctieFunctie`)) left join `SVN_IM`.`Dosar_Functii_TipCompanie` `TcTip` on(`D`.`IdTipCompanie` = `TcTip`.`IdTipCompanie`)) left join `SVN_IM`.`Banci` `Bn` on(`D`.`IdBanca` = `Bn`.`IdBanca`)) left join `SVN_IM`.`Judete` `Jb` on(`S`.`IdJudet` = `Jb`.`IdJudet`)) left join `SVN_IM`.`Dosar_TipCredit` `TcCred` on(`D`.`IdTipCredit` = `TcCred`.`IdTipCredit`)) left join (select `SVN_IM`.`Codebitori`.`IdDosar` AS `IdDosar`,min(`SVN_IM`.`Codebitori`.`IdCod`) AS `MinCod` from `SVN_IM`.`Codebitori` FORCE INDEX (`idx_Codebitori_IdDosar_IdCod`) group by `SVN_IM`.`Codebitori`.`IdDosar` order by `SVN_IM`.`Codebitori`.`IdDosar`) `cbmin` on(`cbmin`.`IdDosar` = `D`.`IdDosar`)) left join `SVN_IM`.`Codebitori` `cb2` on(`cb2`.`IdDosar` = `cbmin`.`IdDosar` and `cb2`.`IdCod` = `cbmin`.`MinCod`)) where `D`.`Ascuns` = 0;

-- ----------------------------
-- View structure for viewDosar_Feedback
-- ----------------------------
DROP VIEW IF EXISTS `viewDosar_Feedback`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewDosar_Feedback` AS select `Dosar_FeedBack`.`IdFeedBack` AS `IdFeedBack`,`Dosar_FeedBack`.`IdStatusFeedback` AS `IdStatusFeedback`,`Dosar_FeedBack`.`IdDosar` AS `IdDosar`,`Dosar_FeedBack`.`DataConectare` AS `DataConectare`,`Dosar_FeedBack`.`FeedBack` AS `FeedBack`,`Dosar_FeedBack`.`DataReconectare` AS `DataReconectare`,`Dosar_FeedBack_Status`.`FelStatusFeedback` AS `FelStatusFeedback` from (`Dosar_FeedBack` join `Dosar_FeedBack_Status` on(`Dosar_FeedBack`.`IdStatusFeedback` = `Dosar_FeedBack_Status`.`IdStatusFeedBack`)) where `Dosar_FeedBack`.`IdFeedBack` in (select max(`Dosar_FeedBack`.`IdFeedBack`) AS `IdFeedBack` from `Dosar_FeedBack` group by `Dosar_FeedBack`.`IdDosar`);

-- ----------------------------
-- View structure for viewDosar_Filtru_2025
-- ----------------------------
DROP VIEW IF EXISTS `viewDosar_Filtru_2025`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewDosar_Filtru_2025` AS select `D`.`IdDosar` AS `IdDosar`,`D`.`IdBaza` AS `IdBaza`,`D`.`IdClient` AS `IdClient`,`D`.`IdConsultant` AS `IdConsultant`,`D`.`IdAgent` AS `IdAgent`,`D`.`IdSursa` AS `IdSursa`,`D`.`IdFunctie` AS `IdFunctie`,`D`.`IdBanca` AS `IdBanca`,`D`.`IdSucursala` AS `IdSucursala`,`D`.`IdStare` AS `IdStare`,`D`.`IdStatus` AS `IdStatus`,`D`.`IdDomeniu` AS `IdDomeniu`,`D`.`IdFunctieFunctie` AS `IdFunctieFunctie`,`D`.`IdTipCompanie` AS `IdTipCompanie`,`D`.`IdCompanie` AS `IdCompanie`,`D`.`IdEvaluator` AS `IdEvaluator`,`D`.`IdMotiv` AS `IdMotiv`,`D`.`IdNotar` AS `IdNotar`,`D`.`IdTipImobil` AS `IdTipImobil`,`D`.`IdVenit` AS `IdVenit`,`D`.`IdTipDobanda` AS `IdTipDobanda`,`D`.`IdTipMoneda` AS `IdTipMoneda`,`D`.`IdTipCredit` AS `IdTipCredit`,`D`.`Venit` AS `Venit`,`D`.`ValoareCredit` AS `ValoareCredit`,`D`.`ValoareCreditRON` AS `ValoareCreditRON`,`D`.`PerioadaCredit` AS `PerioadaCredit`,`D`.`PerioadaDobanda` AS `PerioadaDobanda`,`D`.`Dobanda` AS `Dobanda`,`D`.`MarjaDobanda` AS `MarjaDobanda`,`D`.`MarjaDobandaDF` AS `MarjaDobandaDF`,`D`.`ValoareImobil` AS `ValoareImobil`,`D`.`ConsilierBanca` AS `ConsilierBanca`,`D`.`CodBanca` AS `CodBanca`,`D`.`DataIntroducere` AS `DataIntroducere`,`D`.`DataPreaprobare` AS `DataPreaprobare`,`D`.`DataOpinieJ` AS `DataOpinieJ`,`D`.`DataTrimitere` AS `DataTrimitere`,`D`.`DataDebursare` AS `DataDebursare`,`D`.`DataRespingere` AS `DataRespingere`,`D`.`DataSemnare` AS `DataSemnare`,`D`.`CursMoneda` AS `CursMoneda`,`D`.`Codebitor` AS `Codebitor`,`D`.`AreImobil` AS `AreImobil`,`D`.`ObservatiiFinale` AS `ObservatiiFinale`,`D`.`ValoareCreditTras` AS `ValoareCreditTras`,`D`.`DIFD` AS `DIFD`,`DS`.`Stare` AS `Stare`,`DSt`.`FelStatus` AS `FelStatus`,`DSt`.`TipStatus` AS `TipStatus`,`DSt`.`IDSG` AS `IDSG`,`DSt`.`AltaBanca` AS `AltaBanca`,`B`.`DataPrimire` AS `DataPrimire`,`Cl`.`NumeClient` AS `NumeClient`,`Cl`.`CNPClient` AS `CNPClient`,`Cl`.`TelefonP` AS `TelefonClient`,`Cl`.`EmailP` AS `EmailClient`,`Cl`.`DataNastere` AS `DataNastere`,`Cl`.`IdJudet` AS `IdJudet`,`Cl`.`DIFN` AS `DIFN`,`Cl`.`Tara` AS `Tara`,`Cl`.`RO` AS `RO`,`Jc`.`Judet` AS `JudetClient`,`C`.`NumeConsultant` AS `NumeConsultant`,`C`.`cTelefon` AS `cTelefon`,`C`.`cMail` AS `cMail`,`A`.`NumeAgent` AS `NumeAgent`,`A`.`aTelefon` AS `aTelefon`,`A`.`aMail` AS `aMail`,`SL`.`Sursa` AS `Sursa`,`Cmp`.`Companie` AS `Companie`,`Dom`.`Domeniu` AS `Domeniu`,`Fnc`.`Functie` AS `Functie`,`TcTip`.`TipCompanie` AS `TipCompanie`,`Bn`.`Banca` AS `Banca`,`S`.`Sucursala` AS `Sucursala`,`Jb`.`Judet` AS `JudetBanca`,`S`.`Orasul` AS `Oras_Banca`,`DTV`.`TipVenit` AS `TipVenit`,`DTD`.`TipDobanda` AS `TipDobanda`,`DTM`.`Moneda` AS `Moneda`,`TcCred`.`TipCredit` AS `TipCredit`,`DN`.`Notar` AS `Notar`,`DE`.`Evaluator` AS `Evaluator`,`DTI`.`TipImobil` AS `TipImobil`,`DM`.`Motiv` AS `Motiv`,0 AS `S`,0 AS `DIF`,0 AS `DIFF`,`D`.`DataModificare` AS `DataModificare`,'Dosar' AS `TblName`,'IdDosar' AS `IdName` from (((((((((((((((((((((((`SVN_IM`.`Dosar` `D` join `SVN_IM`.`Dosar_Stare` `DS` on(`D`.`IdStare` = `DS`.`IdStare`)) join `SVN_IM`.`Dosar_Status` `DSt` on(`D`.`IdStatus` = `DSt`.`IdStatus`)) join `SVN_IM`.`Baza` `B` on(`D`.`IdBaza` = `B`.`IdBaza`)) join `SVN_IM`.`Agenti` `A` on(`D`.`IdAgent` = `A`.`IdAgent`)) join `SVN_IM`.`Consultanti` `C` on(`D`.`IdConsultant` = `C`.`IdConsultant`)) join `SVN_IM`.`Clienti` `Cl` on(`D`.`IdClient` = `Cl`.`IdClient`)) join `SVN_IM`.`SursaLead` `SL` on(`D`.`IdSursa` = `SL`.`IdSursa`)) join `SVN_IM`.`Sucursale` `S` on(`D`.`IdSucursala` = `S`.`IdSucursala`)) join `SVN_IM`.`Dosar_TipVenit` `DTV` on(`D`.`IdVenit` = `DTV`.`IdVenit`)) left join `SVN_IM`.`Dosar_TipDobanda` `DTD` on(`D`.`IdTipDobanda` = `DTD`.`IdTipDobanda`)) join `SVN_IM`.`Dosar_TipMoneda` `DTM` on(`D`.`IdTipMoneda` = `DTM`.`IdTipMoneda`)) left join `SVN_IM`.`Dosar_Notari` `DN` on(`D`.`IdNotar` = `DN`.`IdNotar`)) left join `SVN_IM`.`Dosar_Evaluatori` `DE` on(`D`.`IdEvaluator` = `DE`.`IdEvaluator`)) left join `SVN_IM`.`Dosar_TipImobil` `DTI` on(`D`.`IdTipImobil` = `DTI`.`IdTipImobil`)) left join `SVN_IM`.`Dosar_Motiv` `DM` on(`D`.`IdMotiv` = `DM`.`IdMotiv`)) left join `SVN_IM`.`Judete` `Jc` on(`Cl`.`IdJudet` = `Jc`.`IdJudet`)) left join `SVN_IM`.`Dosar_Functii_Companie` `Cmp` on(`D`.`IdCompanie` = `Cmp`.`IdCompanie`)) left join `SVN_IM`.`Dosar_Functii_Domeniu` `Dom` on(`D`.`IdDomeniu` = `Dom`.`IdDomeniu`)) left join `SVN_IM`.`Dosar_Functii_Functie` `Fnc` on(`D`.`IdFunctieFunctie` = `Fnc`.`IdFunctieFunctie`)) left join `SVN_IM`.`Dosar_Functii_TipCompanie` `TcTip` on(`D`.`IdTipCompanie` = `TcTip`.`IdTipCompanie`)) left join `SVN_IM`.`Banci` `Bn` on(`D`.`IdBanca` = `Bn`.`IdBanca`)) left join `SVN_IM`.`Judete` `Jb` on(`S`.`IdJudet` = `Jb`.`IdJudet`)) left join `SVN_IM`.`Dosar_TipCredit` `TcCred` on(`D`.`IdTipCredit` = `TcCred`.`IdTipCredit`)) where `D`.`Ascuns` = 0;

-- ----------------------------
-- View structure for viewDosar_Status
-- ----------------------------
DROP VIEW IF EXISTS `viewDosar_Status`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewDosar_Status` AS select `Dosar_Status`.`IdStatus` AS `IdStatus`,`Dosar_Status`.`FelStatus` AS `FelStatus`,`Dosar_Status`.`TipStatus` AS `TipStatus`,`Dosar_Status`.`BackColor` AS `BackColor`,`Dosar_Status`.`Ascuns` AS `Ascuns`,`Dosar_Status`.`Implicit` AS `Implicit` from `Dosar_Status` order by `Dosar_Status`.`FelStatus`;

-- ----------------------------
-- View structure for viewEvaluatori
-- ----------------------------
DROP VIEW IF EXISTS `viewEvaluatori`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewEvaluatori` AS select `Dosar_Evaluatori`.`IdEvaluator` AS `IdEvaluator`,`Dosar_Evaluatori`.`Evaluator` AS `Evaluator`,`Dosar_Evaluatori`.`Ascuns` AS `Ascuns` from `Dosar_Evaluatori`;

-- ----------------------------
-- View structure for viewIpotecare
-- ----------------------------
DROP VIEW IF EXISTS `viewIpotecare`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewIpotecare` AS select `SVN_00`.`ipotecare`.`ID` AS `ID`,`SVN_00`.`ipotecare`.`id_ipotecare` AS `id_ipotecare`,`SVN_00`.`ipotecare`.`IdBaza` AS `IdBaza`,`SVN_00`.`ipotecare`.`IdConsultant` AS `IdConsultant`,`SVN_00`.`ipotecare`.`IdAgent` AS `IdAgent`,`SVN_00`.`ipotecare`.`IdSursa` AS `IdSursa`,`SVN_00`.`ipotecare`.`IdJudet` AS `IdJudet`,`SVN_00`.`ipotecare`.`Agent` AS `Agent`,`SVN_00`.`ipotecare`.`NumeLead` AS `NumeLead`,`SVN_00`.`ipotecare`.`Email` AS `Email`,`SVN_00`.`ipotecare`.`Telefon` AS `Telefon`,`SVN_00`.`ipotecare`.`Feedback_Initial` AS `Feedback_Initial`,`SVN_00`.`ipotecare`.`mail_consultant` AS `mail_consultant`,`SVN_00`.`ipotecare`.`Judetul` AS `Judetul`,`SVN_00`.`ipotecare`.`Tara` AS `Tara`,`SVN_00`.`ipotecare`.`L` AS `L`,`SVN_00`.`ipotecare`.`D` AS `D`,`SVN_00`.`ipotecare`.`Rezolvat` AS `Rezolvat`,cast(`SVN_00`.`ipotecare`.`DataAdaugare` as date) AS `DataAdaugare`,`SVN_00`.`ipotecare`.`DataModificare` AS `DataModificare`,`SVN_00`.`Consultanti`.`NumeConsultant` AS `NumeConsultant`,`SVN_IM`.`Agenti`.`NumeAgent` AS `NumeAgent`,to_days(current_timestamp()) - to_days(`SVN_00`.`ipotecare`.`DataAdaugare`) AS `DIF`,case when `SVN_00`.`ipotecare`.`DataAdaugare` is null then NULL when cast(`SVN_00`.`ipotecare`.`DataAdaugare` as date) = curdate() then 1 when unix_timestamp(`SVN_00`.`ipotecare`.`DataAdaugare`) between unix_timestamp(curdate()) and unix_timestamp(curdate() + interval 4 day) then 2 when unix_timestamp(`SVN_00`.`ipotecare`.`DataAdaugare`) < unix_timestamp(curdate() + interval 4 day) then 3 end AS `DIFF`,(select 0) AS `S` from ((`SVN_00`.`ipotecare` join `SVN_00`.`Consultanti` on(`SVN_00`.`ipotecare`.`IdConsultant` = `SVN_00`.`Consultanti`.`IdConsultant`)) join `SVN_IM`.`Agenti` on(`SVN_00`.`ipotecare`.`IdAgent` = `SVN_IM`.`Agenti`.`IdAgent`)) where `SVN_00`.`ipotecare`.`IdBaza` is null;

-- ----------------------------
-- View structure for viewJudete
-- ----------------------------
DROP VIEW IF EXISTS `viewJudete`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewJudete` AS select `SVN_00`.`Judete`.`IdJudet` AS `IdJudet`,`SVN_00`.`Judete`.`CodJudet` AS `CodJudet`,`SVN_00`.`Judete`.`Judet` AS `Judet`,`SVN_00`.`Regiuni`.`IdRegiune` AS `IdRegiune`,`SVN_00`.`Regiuni`.`Regiune` AS `Regiune` from (`SVN_00`.`Judete` join `SVN_00`.`Regiuni` on(`SVN_00`.`Judete`.`IdRegiune` = `SVN_00`.`Regiuni`.`IdRegiune`));

-- ----------------------------
-- View structure for viewNotari
-- ----------------------------
DROP VIEW IF EXISTS `viewNotari`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewNotari` AS select `Dosar_Notari`.`IdNotar` AS `IdNotar`,`Dosar_Notari`.`Notar` AS `Notar`,`Dosar_Notari`.`Ascuns` AS `Ascuns` from `Dosar_Notari`;

-- ----------------------------
-- View structure for viewParams
-- ----------------------------
DROP VIEW IF EXISTS `viewParams`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewParams` AS select `T`.`SPECIFIC_NAME` AS `procName`,`T`.`PARAMETER_NAME` AS `pName`,concat('[',json_object('ORDINAL_POSITION',`T`.`ORDINAL_POSITION`,'PARAMETER_NAME',`T`.`PARAMETER_NAME`,'DATA_TYPE',`T`.`DATA_TYPE`),']') AS `objJson` from (select `information_schema`.`PARAMETERS`.`SPECIFIC_NAME` AS `SPECIFIC_NAME`,`information_schema`.`PARAMETERS`.`ORDINAL_POSITION` AS `ORDINAL_POSITION`,`information_schema`.`PARAMETERS`.`PARAMETER_NAME` AS `PARAMETER_NAME`,`information_schema`.`PARAMETERS`.`DATA_TYPE` AS `DATA_TYPE` from `information_schema`.`PARAMETERS` where `information_schema`.`PARAMETERS`.`SPECIFIC_SCHEMA` = database() order by `information_schema`.`PARAMETERS`.`SPECIFIC_NAME`,`information_schema`.`PARAMETERS`.`ORDINAL_POSITION`) `T`;

-- ----------------------------
-- View structure for viewParinti
-- ----------------------------
DROP VIEW IF EXISTS `viewParinti`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewParinti` AS select `Consultanti`.`IdConsultant` AS `IdParinte`,`Consultanti`.`NumeConsultant` AS `NumeConsultant`,`Consultanti`.`cTelefon` AS `cTelefon`,`Consultanti`.`IdRegiune` AS `IdRegiune`,`Consultanti`.`IdNivel` AS `IdNivel`,ifnull(`r`.`IdParinte`,0) AS `IdParinteParinte` from (`SVN_IM`.`Consultanti` left join `SVN_IM`.`Consultanti_Relatii` `r` on(`Consultanti`.`IdConsultant` = `r`.`IdCopil`)) where `Consultanti`.`Ascuns` = 0 and `Consultanti`.`IdNivel` > 10 order by `Consultanti`.`IdNivel` desc,`Consultanti`.`NumeConsultant`;

-- ----------------------------
-- View structure for viewSchema
-- ----------------------------
DROP VIEW IF EXISTS `viewSchema`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewSchema` AS select `T`.`T` AS `T`,`T`.`K` AS `K`,group_concat(`T`.`ColumnName` separator ',') AS `F`,json_arrayagg(json_object('NAME',`T`.`ColumnName`,'TYPE',`T`.`ColumnType`,'LENGTH',`T`.`ColumnLength`)) AS `JSN`,`T`.`TableType` AS `TableType` from (select `C`.`TABLE_NAME` AS `T`,`KCU`.`COLUMN_NAME` AS `K`,case when `T`.`TABLE_TYPE` = 'BASE TABLE' then 'Table' else 'View' end AS `TableType`,`C`.`COLUMN_NAME` AS `ColumnName`,substring_index(`C`.`COLUMN_TYPE`,'(',1) AS `ColumnType`,least(`C`.`CHARACTER_MAXIMUM_LENGTH`,9999) AS `ColumnLength` from ((`information_schema`.`COLUMNS` `C` left join `information_schema`.`TABLES` `T` on(`C`.`TABLE_NAME` = `T`.`TABLE_NAME` and `C`.`TABLE_SCHEMA` = `T`.`TABLE_SCHEMA`)) left join `information_schema`.`KEY_COLUMN_USAGE` `KCU` on(`KCU`.`TABLE_NAME` = `C`.`TABLE_NAME` and `KCU`.`COLUMN_NAME` = `C`.`COLUMN_NAME` and `KCU`.`TABLE_SCHEMA` = `C`.`TABLE_SCHEMA`)) where `C`.`TABLE_SCHEMA` = database() and ifnull(`T`.`ENGINE`,'') <> 'FEDERATED' group by `T`.`TABLE_TYPE`,`T`.`TABLE_NAME`,`C`.`COLUMN_NAME` order by `T`.`TABLE_TYPE`,`T`.`TABLE_NAME`,`KCU`.`COLUMN_NAME` desc) `T` group by `T`.`T`;

-- ----------------------------
-- View structure for viewSchema_Baza_Dosar
-- ----------------------------
DROP VIEW IF EXISTS `viewSchema_Baza_Dosar`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewSchema_Baza_Dosar` AS select `B`.`COLUMN_NAME` AS `COLUMN_NAME`,`B`.`COLUMN_TYPE` AS `COLUMN_TYPE`,`B`.`CHARACTER_MAXIMUM_LENGTH` AS `CHARACTER_MAXIMUM_LENGTH` from ((select `C`.`COLUMN_NAME` AS `COLUMN_NAME`,`C`.`COLUMN_TYPE` AS `COLUMN_TYPE`,`C`.`CHARACTER_MAXIMUM_LENGTH` AS `CHARACTER_MAXIMUM_LENGTH` from `information_schema`.`COLUMNS` `C` where `C`.`TABLE_SCHEMA` = database() and `C`.`TABLE_NAME` = 'viewDosar') `B` join (select `C`.`COLUMN_NAME` AS `COLUMN_NAME`,`C`.`COLUMN_TYPE` AS `COLUMN_TYPE`,`C`.`CHARACTER_MAXIMUM_LENGTH` AS `CHARACTER_MAXIMUM_LENGTH` from `information_schema`.`COLUMNS` `C` where `C`.`TABLE_SCHEMA` = database() and `C`.`TABLE_NAME` = 'viewDosar') `D` on(`B`.`COLUMN_NAME` = `D`.`COLUMN_NAME`));

-- ----------------------------
-- View structure for viewStareStatus
-- ----------------------------
DROP VIEW IF EXISTS `viewStareStatus`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewStareStatus` AS select `Dosar_Stare`.`IdStare` AS `IdStare`,`Dosar_Stare`.`Stare` AS `Stare`,`Dosar_Status`.`IdStatus` AS `IdStatus`,`Dosar_Status`.`FelStatus` AS `FelStatus`,`Dosar_Status`.`IDSG` AS `IDSG`,`Dosar_Status`.`AltaBanca` AS `AltaBanca`,`Dosar_Stare`.`Ascuns` <> 0 and `Dosar_Status`.`Ascuns` <> 0 AS `Ascuns`,`Dosar_Status`.`AnuleazaDosareActive` AS `AnuleazaDosareActive` from ((`Dosar_Stare_Status` join `Dosar_Stare` on(`Dosar_Stare_Status`.`IdStare` = `Dosar_Stare`.`IdStare`)) join `Dosar_Status` on(`Dosar_Stare_Status`.`IdStatus` = `Dosar_Status`.`IdStatus`)) order by `Dosar_Stare`.`Stare`,`Dosar_Status`.`FelStatus`;

-- ----------------------------
-- View structure for viewSurseAgenti
-- ----------------------------
DROP VIEW IF EXISTS `viewSurseAgenti`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `viewSurseAgenti` AS select `SursaLead`.`IdSursa` AS `IdSursa`,`SursaLead`.`Sursa` AS `Sursa`,`Agenti`.`IdAgent` AS `IDAgent`,`Agenti`.`NumeAgent` AS `NumeAgent`,`Agenti`.`aTelefon` AS `aTelefon`,`Agenti`.`aMail` AS `aMail`,concat_ws('_',`SursaLead`.`Sursa`,`Agenti`.`NumeAgent`,`Agenti`.`aTelefon`) AS `Caut` from (`SursaLead` join `Agenti` on(`SursaLead`.`IdSursa` = `Agenti`.`IdSursa`)) where `SursaLead`.`Ascuns` = 0 and `Agenti`.`Ascuns` = 0 order by `SursaLead`.`Sursa`,`Agenti`.`NumeAgent`;

-- ----------------------------
-- View structure for view_Baza_Alarme
-- ----------------------------
DROP VIEW IF EXISTS `view_Baza_Alarme`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Baza_Alarme` AS select `SVN_IM`.`Baza_Alarme`.`IdAlarma` AS `IdAlarma`,`SVN_IM`.`Baza_Alarme`.`IdBaza` AS `IdBaza`,`SVN_IM`.`Baza_Alarme`.`IdConsultant` AS `IdConsultant`,`SVN_IM`.`Baza_Alarme`.`IdConsultantAdd` AS `IdConsultantAdd`,`Consultanti`.`NumeConsultant` AS `NumeConsultant`,`SVN_IM`.`Baza_Alarme`.`Nume` AS `Nume`,`SVN_IM`.`Baza_Alarme`.`DataOra` AS `DataOra`,`SVN_IM`.`Baza_Alarme`.`ToataZiua` AS `ToataZiua`,`SVN_IM`.`Baza_Alarme`.`Activa` AS `Activa`,`SVN_IM`.`Baza_Alarme`.`SeAnuleaza` AS `SeAnuleaza` from (`SVN_IM`.`Baza_Alarme` join `SVN_IM`.`Consultanti` on(`SVN_IM`.`Baza_Alarme`.`IdConsultant` = `Consultanti`.`IdConsultant`));

-- ----------------------------
-- View structure for view_Baza_Clienti
-- ----------------------------
DROP VIEW IF EXISTS `view_Baza_Clienti`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Baza_Clienti` AS select `SVN_IM`.`Baza`.`IdBaza` AS `IdBaza`,`SVN_IM`.`Baza`.`IdClient` AS `IdClient`,`SVN_IM`.`Baza`.`IdConsultant` AS `IdConsultant`,`SVN_IM`.`Clienti`.`NumeClient` AS `NumeClient`,`SVN_IM`.`Clienti`.`TelefonP` AS `TelefonP`,`SVN_IM`.`Clienti`.`EmailP` AS `EmailP`,`SVN_IM`.`Clienti`.`CNPClient` AS `CNPClient`,`SVN_IM`.`Clienti`.`SMS` AS `SMS`,`SVN_IM`.`Clienti`.`DataNastere` AS `DataNastere`,`Judete`.`IdJudet` AS `IdJudet`,`Judete`.`Judet` AS `Judet` from ((`SVN_IM`.`Baza` join `SVN_IM`.`Clienti` on(`SVN_IM`.`Baza`.`IdClient` = `SVN_IM`.`Clienti`.`IdClient`)) join `SVN_IM`.`Judete` on(`SVN_IM`.`Clienti`.`IdJudet` = `Judete`.`IdJudet`));

-- ----------------------------
-- View structure for view_Baza_Dosare
-- ----------------------------
DROP VIEW IF EXISTS `view_Baza_Dosare`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Baza_Dosare` AS select `t`.`IdBaza` AS `IdBaza`,json_arrayagg(json_extract(`t`.`JSN`,'$')) AS `jsn_Dosare` from (select `Dosar`.`IdBaza` AS `IdBaza`,json_object('IdDosar',`Dosar`.`IdDosar`,'IdBanca',`Banci`.`IdBanca`,'DataIntroducere',date_format(`Dosar`.`DataIntroducere`,'%d/%m/%Y'),'ValoareCredit',format(`Dosar`.`ValoareCredit`,'ro-RO'),'IdStatus',`Dosar`.`IdStatus`,'FelStatus',`Dosar_Status`.`FelStatus`,'TipStatus',`Dosar_Status`.`TipStatus`,'BackColor',`Dosar_Status`.`BackColor`,'Banca',`Banci`.`Banca`) AS `JSN` from ((`Dosar` join `Banci` on(`Dosar`.`IdBanca` = `Banci`.`IdBanca`)) join `Dosar_Status` on(`Dosar`.`IdStatus` = `Dosar_Status`.`IdStatus`)) group by `Dosar`.`IdDosar`) `t` group by `t`.`IdBaza`;

-- ----------------------------
-- View structure for view_Baza_FeedBack
-- ----------------------------
DROP VIEW IF EXISTS `view_Baza_FeedBack`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Baza_FeedBack` AS select `bf`.`IdBaza` AS `IdBaza`,`bf`.`IdFeedBack` AS `IdFeedBack`,`bf`.`IdStatus` AS `IdStatus`,`bf`.`DataConectare` AS `DataConectare`,`bf`.`DIF` AS `DIF`,`bf`.`DIFF` AS `DIFF`,`bs`.`FelStatus` AS `FelStatus`,`bs`.`IDSG` AS `IDSG`,`bf`.`Feedback` AS `FeedBack`,`bf`.`MailTrimis` AS `MailTrimis`,(select json_arrayagg(json_object('IdFeedBack',`bfc`.`IdFeedBack`,'IdConsultant',`bfc`.`IdConsultant`,'IdStatus',`bfc`.`IdStatus`,'IDSG',`bfc`.`IDSG`,'DataConectare',`bfc`.`DataConectare`,'FeedBack',`bfc`.`Feedback`,'DataReconectare',`bfc`.`DataReconectare`,'MailTrimis',`bfc`.`MailTrimis`,'DIF',`bfc`.`DIF`,'DIFF',`bfc`.`DIFF`)) from `Baza_FeedBack` `bfc` where `bfc`.`IdBaza` = `bf`.`IdBaza`) AS `FeedBack_Cumulat`,`bf`.`DataReconectare` AS `DataReconectare` from (`Baza_FeedBack` `bf` join `Baza_Status` `bs` on(`bf`.`IdStatus` = `bs`.`IdStatus`)) where `bf`.`IdFeedBack` = (select max(`Baza_FeedBack`.`IdFeedBack`) AS `IdFeedBack` from `Baza_FeedBack` where `Baza_FeedBack`.`IdBaza` = `bf`.`IdBaza`);

-- ----------------------------
-- View structure for view_Baza_FeedBack_PYTHON
-- ----------------------------
DROP VIEW IF EXISTS `view_Baza_FeedBack_PYTHON`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Baza_FeedBack_PYTHON` AS select `bf`.`IdFeedBack` AS `IdFeedBack`,`bf`.`IdBaza` AS `IdBaza`,`bf`.`IdStatus` AS `IdStatus`,date_format(`bf`.`DataConectare`,'%Y-%m-%dT%H:%i:%s') AS `DataConectare`,`bf`.`Feedback` AS `FeedBack`,date_format(`bf`.`DataReconectare`,'%Y-%m-%dT%H:%i:%s') AS `DataReconectare`,`bf`.`MailTrimis` AS `MailTrimis`,`bf`.`DIF` AS `DIF`,`bf`.`DIFF` AS `DIFF`,`bs`.`FelStatus` AS `FelStatus`,`bs`.`IDSG` AS `IDSG`,concat('#',lpad(hex(coalesce(`bs`.`BackColor`,0xffffff) >> 16 & 0xff | coalesce(`bs`.`BackColor`,0xffffff) & 0x00ff00 | (coalesce(`bs`.`BackColor`,0xffffff) & 0xff) << 16),6,'0')) AS `BackColor`,`bs`.`BackColor` AS `ACC` from (`Baza_FeedBack` `bf` join `Baza_Status` `bs` on(`bf`.`IdStatus` = `bs`.`IdStatus`)) order by `bf`.`IdFeedBack` desc;

-- ----------------------------
-- View structure for view_Baza_Status
-- ----------------------------
DROP VIEW IF EXISTS `view_Baza_Status`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Baza_Status` AS select `Baza_Status`.`IdStatus` AS `IdStatus`,`Baza_Status_Grup`.`GRUP` AS `GRUP`,`Baza_Status`.`FelStatus` AS `FelStatus`,`Baza_Status`.`TipStatus` AS `TipStatus`,`Baza_Status`.`BackColor` AS `BackColor` from (`Baza_Status` join `Baza_Status_Grup` on(`Baza_Status`.`IDSG` = `Baza_Status_Grup`.`IDSG`));

-- ----------------------------
-- View structure for view_Dosar_Alarme
-- ----------------------------
DROP VIEW IF EXISTS `view_Dosar_Alarme`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Dosar_Alarme` AS select `SVN_IM`.`Dosar_Alarme`.`IdAlarma` AS `IdAlarma`,`SVN_IM`.`Dosar_Alarme`.`IdDosar` AS `IdDosar`,`SVN_IM`.`Dosar_Alarme`.`IdConsultant` AS `IdConsultant`,`SVN_IM`.`Dosar_Alarme`.`IdConsultantAdd` AS `IdConsultantAdd`,`Consultanti`.`NumeConsultant` AS `NumeConsultant`,`SVN_IM`.`Dosar_Alarme`.`Nume` AS `Nume`,`SVN_IM`.`Dosar_Alarme`.`DataOra` AS `DataOra`,`SVN_IM`.`Dosar_Alarme`.`ToataZiua` AS `ToataZiua`,`SVN_IM`.`Dosar_Alarme`.`Activa` AS `Activa`,`SVN_IM`.`Dosar_Alarme`.`SeAnuleaza` AS `SeAnuleaza` from (`SVN_IM`.`Dosar_Alarme` join `SVN_IM`.`Consultanti` on(`SVN_IM`.`Dosar_Alarme`.`IdConsultant` = `Consultanti`.`IdConsultant`));

-- ----------------------------
-- View structure for view_Dosar_Baza
-- ----------------------------
DROP VIEW IF EXISTS `view_Dosar_Baza`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Dosar_Baza` AS select `SVN_IM`.`Baza`.`IdBaza` AS `IdBaza`,`SVN_IM`.`Baza`.`IdAgent` AS `IDAgent`,`SVN_IM`.`Baza`.`IdSursa` AS `IdSursa`,`SVN_IM`.`Baza`.`IdConsultant` AS `IdConsultant`,`SVN_IM`.`Baza`.`IdClient` AS `IdClient`,`SVN_IM`.`Baza`.`DataPrimire` AS `DataPrimire`,`Clienti`.`NumeClient` AS `NumeClient`,`Clienti`.`TelefonP` AS `TelefonClient`,`Clienti`.`EmailP` AS `EmailClient`,`Clienti`.`CNPClient` AS `CNPClient`,`Clienti`.`SMS` AS `SMS`,`Clienti`.`DataNastere` AS `DataNastere`,`Clienti`.`IdJudet` AS `IdJudet`,`Clienti`.`Judet` AS `Judet`,`Consultanti`.`NumeConsultant` AS `NumeConsultant`,`Consultanti`.`cTelefon` AS `cTelefon`,`Consultanti`.`cMail` AS `cMail`,`SursaLead`.`Sursa` AS `Sursa`,`Agenti`.`NumeAgent` AS `NumeAgent`,`Agenti`.`aTelefon` AS `aTelefon`,`Agenti`.`aMail` AS `aMail` from ((((`SVN_IM`.`Baza` join `SVN_IM`.`view_Baza_Clienti` `Clienti` on(`SVN_IM`.`Baza`.`IdClient` = `Clienti`.`IdClient`)) join (select `SVN_IM`.`SursaLead`.`IdSursa` AS `IdSursa`,`SVN_IM`.`SursaLead`.`Sursa` AS `Sursa` from `SVN_IM`.`SursaLead`) `SursaLead` on(`SVN_IM`.`Baza`.`IdSursa` = `SursaLead`.`IdSursa`)) join (select `SVN_IM`.`Agenti`.`IdAgent` AS `IdAgent`,`SVN_IM`.`Agenti`.`NumeAgent` AS `NumeAgent`,`SVN_IM`.`Agenti`.`aTelefon` AS `aTelefon`,`SVN_IM`.`Agenti`.`aMail` AS `aMail` from `SVN_IM`.`Agenti`) `Agenti` on(`SVN_IM`.`Baza`.`IdAgent` = `Agenti`.`IdAgent`)) join (select `Consultanti`.`IdConsultant` AS `IdConsultant`,`Consultanti`.`NumeConsultant` AS `NumeConsultant`,`Consultanti`.`cTelefon` AS `cTelefon`,`Consultanti`.`cMail` AS `cMail` from `SVN_IM`.`Consultanti`) `Consultanti` on(`SVN_IM`.`Baza`.`IdConsultant` = `Consultanti`.`IdConsultant`)) where `SVN_IM`.`Baza`.`Ascuns` = 0;

-- ----------------------------
-- View structure for view_Dosar_FeedBack
-- ----------------------------
DROP VIEW IF EXISTS `view_Dosar_FeedBack`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Dosar_FeedBack` AS select `Dosar`.`IdDosar` AS `IdDosar`,`Dosar_FeedBack`.`IdFeedBack` AS `IdFeedBack`,`Dosar_FeedBack`.`IdStatusFeedback` AS `IdStatusFeedback`,`Dosar_FeedBack`.`DataConectare` AS `DataConectare`,`Dosar_FeedBack`.`DataReconectare` AS `DataReconectare`,`Dosar_FeedBack_Status`.`FelStatusFeedback` AS `FelStatusFeedback`,`Dosar_FeedBack`.`FeedBack` AS `FeedBack` from ((`Dosar` join `Dosar_FeedBack` on(`Dosar`.`IdDosar` = `Dosar_FeedBack`.`IdDosar`)) join `Dosar_FeedBack_Status` on(`Dosar_FeedBack`.`IdStatusFeedback` = `Dosar_FeedBack_Status`.`IdStatusFeedBack`));

-- ----------------------------
-- View structure for view_Dosar_Functii
-- ----------------------------
DROP VIEW IF EXISTS `view_Dosar_Functii`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Dosar_Functii` AS select `Dosar`.`IdDosar` AS `IdDosar`,`Dosar`.`IdFunctie` AS `IdFunctie`,`Dosar`.`IdClient` AS `IdClient`,`Dosar`.`IdCompanie` AS `IdCompanie`,`Dosar`.`IdDomeniu` AS `IdDomeniu`,`Dosar`.`IdFunctieFunctie` AS `IdFunctieFunctie`,`Dosar`.`IdTipCompanie` AS `IdTipCompanie`,`Dosar_Functii_Companie`.`Companie` AS `Companie`,`Dosar_Functii_Companie`.`CodFiscal` AS `CodFiscal`,`Dosar_Functii_Domeniu`.`Domeniu` AS `Domeniu`,`Dosar_Functii_Functie`.`Functie` AS `Functie`,`Dosar_Functii_TipCompanie`.`TipCompanie` AS `TipCompanie`,`Dosar_Functii`.`DataModificare` AS `DataModificare` from (((((`Dosar` join `Dosar_Functii` on(`Dosar`.`IdFunctie` = `Dosar_Functii`.`IdFunctie`)) join `Dosar_Functii_Companie` on(`Dosar`.`IdCompanie` = `Dosar_Functii_Companie`.`IdCompanie`)) join `Dosar_Functii_Domeniu` on(`Dosar`.`IdDomeniu` = `Dosar_Functii_Domeniu`.`IdDomeniu`)) join `Dosar_Functii_Functie` on(`Dosar`.`IdFunctieFunctie` = `Dosar_Functii_Functie`.`IdFunctieFunctie`)) join `Dosar_Functii_TipCompanie` on(`Dosar`.`IdTipCompanie` = `Dosar_Functii_TipCompanie`.`IdTipCompanie`));

-- ----------------------------
-- View structure for view_Dosar_LEFT_JOINS
-- ----------------------------
DROP VIEW IF EXISTS `view_Dosar_LEFT_JOINS`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Dosar_LEFT_JOINS` AS select `Dosar`.`IdDosar` AS `IdDosar`,`Dosar_Notari`.`Notar` AS `Notar`,`Dosar_Notari`.`IdJudet` AS `Judet_Notar`,`Dosar_Evaluatori`.`Evaluator` AS `Evaluator`,`Dosar_Evaluatori`.`IdJudet` AS `Judet_Evaluator`,`Dosar_TipImobil`.`TipImobil` AS `TipImobil`,`Dosar_Motiv`.`Motiv` AS `Motiv` from ((((`Dosar` left join `Dosar_Notari` on(`Dosar`.`IdNotar` = `Dosar_Notari`.`IdNotar`)) left join `Dosar_Evaluatori` on(`Dosar`.`IdEvaluator` = `Dosar_Evaluatori`.`IdEvaluator`)) left join `Dosar_TipImobil` on(`Dosar`.`IdTipImobil` = `Dosar_TipImobil`.`IdTipImobil`)) left join `Dosar_Motiv` on(`Dosar`.`IdMotiv` = `Dosar_Motiv`.`IdMotiv`)) where `Dosar`.`IdNotar` is not null or `Dosar`.`IdEvaluator` is not null or `Dosar`.`IdTipImobil` is not null or `Dosar`.`IdMotiv` is not null;

-- ----------------------------
-- View structure for view_Dosar_Status
-- ----------------------------
DROP VIEW IF EXISTS `view_Dosar_Status`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Dosar_Status` AS select `Dosar`.`IdDosar` AS `IdDosar`,`Dosar_Status`.`IdStatus` AS `IdStatus`,`Dosar_Status`.`IDSG` AS `IDSG`,`Dosar_Status`.`FelStatus` AS `FelStatus`,`Dosar_Status`.`TipStatus` AS `TipStatus` from (`Dosar` join `Dosar_Status` on(`Dosar`.`IdStatus` = `Dosar_Status`.`IdStatus`));

-- ----------------------------
-- View structure for view_Dosar_Status_Grup
-- ----------------------------
DROP VIEW IF EXISTS `view_Dosar_Status_Grup`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Dosar_Status_Grup` AS select `Dosar_Status`.`IdStatus` AS `IdStatus`,`Dosar_Status`.`FelStatus` AS `FelStatus`,`Dosar_Status`.`TipStatus` AS `TipStatus`,`Dosar_Status_Grup`.`IDSG` AS `IDSG`,`Dosar_Status_Grup`.`GRUP` AS `GRUP` from (`Dosar_Status_Grup` join `Dosar_Status` on(`Dosar_Status_Grup`.`IDSG` = `Dosar_Status`.`IDSG`));

-- ----------------------------
-- View structure for view_Drepturi
-- ----------------------------
DROP VIEW IF EXISTS `view_Drepturi`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_Drepturi` AS select `c`.`IdConsultant` AS `IdConsultant`,json_arrayagg(json_extract(`t`.`jsn_Drepturi`,'$')) AS `jsn_Drepturi` from (`SVN_IM`.`Consultanti` `c` join (select `cd`.`IdConsultant` AS `IdConsultant`,json_object('IdDrept',`cd`.`IdDrept`,'IdCD',`cd`.`IDCD`,'IdNivel',`cd`.`IdNivel`,'Valoare',`cd`.`Valoare`,'Drept',`d`.`Drept`) AS `jsn_Drepturi` from (`SVN_IM`.`Drepturi` `d` join `SVN_IM`.`Consultanti_Drepturi` `cd` on(`d`.`IdDrept` = `cd`.`IdDrept`)) group by `cd`.`IdConsultant`,`d`.`IdDrept`) `t` on(`c`.`IdConsultant` = `t`.`IdConsultant`)) group by `c`.`IdConsultant`;

-- ----------------------------
-- View structure for view_MaxIDC
-- ----------------------------
DROP VIEW IF EXISTS `view_MaxIDC`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_MaxIDC` AS select max(`T`.`IDC`) AS `IDC` from (select max(`Consultanti`.`IdConsultant`) AS `IDC` from `SVN_IM`.`Consultanti` union all select max(`Consultanti`.`IdConsultant`) AS `IDC` from `SVN_NP`.`Consultanti` union all select max(`SVN_Credit_2`.`Consultanti`.`IdConsultant`) AS `IDC` from `SVN_Credit_2`.`Consultanti` union all select max(`SVN_Credit`.`Consultanti`.`IdConsultant`) AS `IDC` from `SVN_Credit`.`Consultanti`) `T`;

-- ----------------------------
-- View structure for _Cautare Client
-- ----------------------------
DROP VIEW IF EXISTS `_Cautare Client`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `_Cautare Client` AS select `Clienti`.`IdClient` AS `IdClient`,`Baza`.`IdBaza` AS `IdBaza`,`Baza_FeedBack`.`IdFeedBack` AS `IdFeedBack`,`Clienti`.`NumeClient` AS `NumeClient`,`Clienti`.`CNPClient` AS `CNPClient`,`Clienti`.`TelefonP` AS `TelefonP`,`Clienti`.`EmailP` AS `EmailP`,`Baza`.`IdSursa` AS `IdSursa`,`Baza`.`IdAgent` AS `IdAgent`,`Baza`.`IdConsultant` AS `IdConsultant`,`Baza`.`DataPrimire` AS `DataPrimire`,`Baza`.`DataAdaugare` AS `DataAdaugare`,`Baza`.`DataModificare` AS `DataModificare`,`Baza_FeedBack`.`IdStatus` AS `IdStatus`,`Baza_FeedBack`.`IDSG` AS `IDSG`,`Baza_FeedBack`.`DataConectare` AS `DataConectare`,`Baza_FeedBack`.`Feedback` AS `Feedback`,`Baza_FeedBack`.`DataReconectare` AS `DataReconectare`,`Baza_FeedBack`.`MailTrimis` AS `MailTrimis`,`Baza_FeedBack`.`Intalnire` AS `Intalnire`,`Baza_FeedBack`.`Ora` AS `Ora`,`Baza_FeedBack`.`Minut` AS `Minut`,`Baza_FeedBack`.`Primar` AS `Primar`,`Baza_FeedBack`.`DataAdaugare` AS `FDataAdaugare`,`Baza_FeedBack`.`DataModificare` AS `FDataModificare` from ((`Clienti` join `Baza` on(`Clienti`.`IdClient` = `Baza`.`IdClient`)) join `Baza_FeedBack` on(`Baza`.`IdBaza` = `Baza_FeedBack`.`IdBaza`));

-- ----------------------------
-- View structure for _Coloane Filtru
-- ----------------------------
DROP VIEW IF EXISTS `_Coloane Filtru`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `_Coloane Filtru` AS select `Coloane_Implicite`.`IdColoana` AS `IdColoana`,`Filtru`.`IDF` AS `IDF`,`Coloane_Implicite`.`TipCamp` AS `TipCamp`,`Coloane_Implicite`.`NumeTabel` AS `NumeTabel`,`Coloane_Implicite`.`NumeColoana` AS `NumeColoana`,`Coloane_Implicite`.`ColoanaPK` AS `ColoanaPK`,`Coloane_Implicite`.`AfisareColoana` AS `AfisareColoana`,`Coloane_Implicite`.`FormatareInitiala` AS `FormatareInitiala`,`Coloane_Implicite`.`PozitieInitiala` AS `PozitieInitiala`,`Coloane_Implicite`.`MarimeInitiala` AS `MarimeInitiala`,`Coloane_Implicite`.`SelTab` AS `SelTab`,`Coloane_Implicite`.`AscunsImplicit` AS `AscunsImplicit` from (`Coloane_Implicite` join `Filtru` on(`Coloane_Implicite`.`IdColoana` = `Filtru`.`IdColoana`));

-- ----------------------------
-- Procedure structure for AdaugaDrept
-- ----------------------------
DROP PROCEDURE IF EXISTS `AdaugaDrept`;
delimiter ;;
CREATE PROCEDURE `AdaugaDrept`(IN `pIdDrept` INT)
  NO SQL 
BEGIN

	SELECT IdDrept INTO @D FROM CD WHERE IdDrept = pIdDrept;
	
	IF IFNULL(@D,'') = '' THEN
		INSERT INTO CD ( IdConsultant, Drept, IdDrept, Valoare, VB, Ascuns )
		SELECT Consultanti.IdConsultant, Drepturi.Drept, Drepturi.IdDrept, Drepturi.Valoare, Drepturi.VB, Drepturi.Ascuns
		FROM Consultanti, Drepturi
		WHERE Drepturi.IdDrept = pIdDrept;
	END IF;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for explain_statement
-- ----------------------------
DROP PROCEDURE IF EXISTS `explain_statement`;
delimiter ;;
CREATE PROCEDURE `explain_statement`(IN `query` TEXT)
BEGIN
    SET @explain := CONCAT('EXPLAIN FORMAT=json ', query);
    PREPARE stmt FROM @explain;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for ExtractAttributes
-- ----------------------------
DROP PROCEDURE IF EXISTS `ExtractAttributes`;
delimiter ;;
CREATE PROCEDURE `ExtractAttributes`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE IdColoanaHTML INT;
    DECLARE elements JSON;  -- Declare the elements variable
    DECLARE element VARCHAR(255);
    DECLARE attribute_name VARCHAR(255);
    DECLARE attribute_value VARCHAR(255);

    -- Cursor to iterate over rows
    DECLARE cur CURSOR FOR 
        SELECT Coloane_Implicite_Export_Feedback.IdColoanaHTML,
               JSON_UNQUOTE(JSON_EXTRACT(Coloane_Implicite_Export_Feedback.HTMLStyle, '$.*')) AS elements
        FROM Coloane_Implicite_Export_Feedback;

    -- Handlers
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    -- Initialize the dynamic SQL
    SET @sql = 'SELECT IdColoanaHTML, Element, Attribute, Value FROM (';

    read_loop: LOOP
        FETCH cur INTO IdColoanaHTML, elements;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Loop through the JSON elements
        SET element = JSON_UNQUOTE(JSON_KEYS(elements));
        json_loop: LOOP
            -- Extract attribute name and value dynamically
            SET attribute_name = JSON_UNQUOTE(JSON_KEYS(JSON_EXTRACT(elements, CONCAT('$.', element))));
            SET attribute_value = JSON_UNQUOTE(COALESCE(JSON_EXTRACT(elements, CONCAT('$.', element, '.', attribute_name)), 'NULL'));

            -- Build the dynamic SQL query
            SET @sql = CONCAT(@sql, 'SELECT ', IdColoanaHTML, ' AS IdColoanaHTML, ''', element, ''' AS Element, ''', attribute_name, ''' AS Attribute, ''', attribute_value, ''' AS Value UNION ');

            -- Break the loop if there are no more attributes
            IF JSON_SEARCH(elements, 'one', CONCAT('$.', element)) IS NULL THEN
                LEAVE json_loop;
            END IF;
        END LOOP;
    END LOOP;

    CLOSE cur;

    -- Remove the trailing 'UNION'
    SET @sql = SUBSTRING(@sql, 1, LENGTH(@sql) - LENGTH('UNION'));
	SELECT @sql;
    -- Execute the dynamic SQL
    PREPARE final_query FROM @sql;
    EXECUTE final_query;
    DEALLOCATE PREPARE final_query;
END
;;
delimiter ;

-- ----------------------------
-- Function structure for isNumeric
-- ----------------------------
DROP FUNCTION IF EXISTS `isNumeric`;
delimiter ;;
CREATE FUNCTION `isNumeric`(`input` VARCHAR(255))
 RETURNS int(11)
RETURN input REGEXP '^[0-9]+\\.?[0-9]*$'
;;
delimiter ;

-- ----------------------------
-- Procedure structure for Json_Row
-- ----------------------------
DROP PROCEDURE IF EXISTS `Json_Row`;
delimiter ;;
CREATE PROCEDURE `Json_Row`(IN `pTBL` VARCHAR(255), IN `pCOL` VARCHAR(255), IN `pVAL` VARCHAR(255), OUT `Res` TEXT)
BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE create_list TEXT(10000);
	DECLARE col TEXT(10000);
	DECLARE V TEXT(10000);
	
	DECLARE c_columns CURSOR FOR 
		SELECT column_name
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_SCHEMA = "SVN_Credit_2"
				AND table_name = pTBL
		ORDER BY ordinal_position;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN c_columns;	
	
	SET @sql = "SELECT CONCAT_WS(',',";
	
	read_loop: LOOP
		FETCH c_columns INTO col;
		IF done THEN 
			LEAVE read_loop;
		END IF;
		
		SET @sql = CONCAT(@sql," CONCAT('{\'",col,"\':\'',`",col,"`,'\'}'),");
	END LOOP read_loop;
	
	set @SQL = substring(@SQL, 1, CHAR_LENGTH(@SQL) - 1);
	
	SET @sql = CONCAT(@sql, ") as Fld INTO @V "," FROM `", "SVN_Credit_2", "`.`", pTBL, "` WHERE `", pCOL, "`='", pVAL, "'");

 	PREPARE stmt FROM @sql;
 	EXECUTE stmt;

	SET Res= CONCAT("[",@V,"]");
	
	DEALLOCATE PREPARE stmt;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for nefolosit_procConsultanti
-- ----------------------------
DROP PROCEDURE IF EXISTS `nefolosit_procConsultanti`;
delimiter ;;
CREATE PROCEDURE `nefolosit_procConsultanti`(IN `pIDC` varchar(4))
BEGIN
	
	SET @sql = CONCAT ("
		WITH RECURSIVE ParentHierarchy AS (
		SELECT IdConsultant, IdConsultant AS TopParent, NumeConsultant as Parinte
		FROM Consultanti
		WHERE IdConsultant NOT IN (SELECT DISTINCT IdCopil FROM Consultanti_Relatii)
		
		UNION ALL
		
		SELECT c.IdCopil, ph.TopParent, ph.Parinte
		FROM (SELECT IdParinte,IdCopil,NumeConsultant as Parinte FROM Consultanti_Relatii JOIN Consultanti ON Consultanti_Relatii.IdCopil=Consultanti.IdConsultant) c
		JOIN ParentHierarchy ph ON c.IdParinte = ph.IdConsultant
		)
		SELECT 
		c.IdConsultant,
		c.NumeConsultant,
		ph.Parinte, 
		c.IdNivel,
		c.IdRegiune,
		c.CNP,
		c.Adresa,
		c.Ascuns,
		c.Functie,
		c.cMail,
		c.cTelefon,
		c.CodFiscal,
		c.CodJudet,
		c.CodOras,
		c.DataAdaugare,
		c.DataModificare,
		c.SchimbaParola,
		c.Nou,
		c.Plecat,
		c.Sistem,
		c.Suffix,
		ph.TopParent AS IdParinte, 
		IF (IFNULL(cj.IdJudet,'')='',NULL,JSON_ARRAYAGG(JSON_OBJECT('IdJudet',j.IdJudet,'CodJudet',j.CodJudet,'Judet',j.Judet))) AS JJSON
		FROM Consultanti c LEFT JOIN (Consultanti_Judete cj JOIN Judete j USING (IdJudet)) ON c.IdConsultant=cj.IdConsultant
		JOIN ParentHierarchy ph ON c.IdConsultant = ph.IdConsultant
		GROUP BY IdConsultant
		ORDER BY ph.TopParent,IdNivel DESC, NumeConsultant;
							");
	-- SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
 	DEALLOCATE PREPARE stmt;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procAlarme
-- ----------------------------
DROP PROCEDURE IF EXISTS `procAlarme`;
delimiter ;;
CREATE PROCEDURE `procAlarme`(IN `IdConsultant` int,IN `Tabel` varchar(255))
BEGIN
	SET @target_value = `IdConsultant`;

	PREPARE stmt FROM CONCAT('SELECT * FROM ', Tabel, ' WHERE IdConsultant IN (SELECT IdConsultant FROM SVN_00.CTree WHERE Path LIKE CONCAT("%[", ?, "]%"))');
	EXECUTE stmt USING @target_value;
	DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procAlte_Config
-- ----------------------------
DROP PROCEDURE IF EXISTS `procAlte_Config`;
delimiter ;;
CREATE PROCEDURE `procAlte_Config`(IN `pIDTC` INT, IN `pAscuns` TINYINT (4))
BEGIN	
	SELECT
		*,
		0 as OnOff,
		JSON_OBJECT('FontName','Consolas','FontSize',10,'FontBold',0,'FontItalic',0,'FontUnderline',0,'FontColor',0) as Font,
		JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverBackColor',14151142,'HoverForeColor',0,'PressedColor',13434828) as Color
	FROM
		Alte_Config FORCE INDEX (idx_ordering_where)
	WHERE
		Ascuns=0 
	ORDER BY
		Afisare;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procBanciSucursale_Add
-- ----------------------------
DROP PROCEDURE IF EXISTS `procBanciSucursale_Add`;
delimiter ;;
CREATE PROCEDURE `procBanciSucursale_Add`(IN `pIdBanca` VARCHAR (255),
IN `pBanca` VARCHAR (255),
IN `pIdSucursala` VARCHAR (255),
IN `pSucursala` VARCHAR (255),
IN `pIdJudet` VARCHAR (255),
IN `pOrasul` VARCHAR (255),
OUT `OUT` VARCHAR(2000))
proc_label: BEGIN
		DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		BEGIN
			GET DIAGNOSTICS CONDITION 1
			@sqlstate = RETURNED_SQLSTATE,
			@errno = MYSQL_ERRNO,
			@text = MESSAGE_TEXT;
			
			 SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
			ROLLBACK;
		END; 
END;
	
	SET @ERRMSG=NULL;
	SET @IdBanca=`pIdBanca`;
	SET @IdSucursala=`pIdSucursala`;
	SET @Banca=`pBanca`;
	SET @Sucursala=`pSucursala`;
	SET @IdJudet=`pIdJudet`;
	SET @Orasul=`pOrasul`;
	
	IF IFNULL(@IdBanca,'')='' AND IFNULL(@Banca,'')<>'' THEN
		SET @ERRMSG='ADD_BANCA';
	
		SET @sql = CONCAT("INSERT INTO Banci (Banca) VALUES (?)");
		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @Banca;
		DEALLOCATE PREPARE stmt;

		SET @IdBanca=LAST_INSERT_ID();
	END IF;
	
	IF IFNULL(@IdBanca,'')<>'' THEN
		SET @ERRMSG='MOD_BANCA';

		SET @sql = CONCAT("UPDATE Banci SET Banca=? WHERE IdBanca=?");
		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @Banca, @IdBanca;
		DEALLOCATE PREPARE stmt;
	END IF;
	
	IF IFNULL(@IdSucursala,'')='' AND IFNULL(@Sucursala,'') <> '' THEN
		SET @ERRMSG='ADD_SUCURSALA';
				
		SET @sql = CONCAT("INSERT INTO Sucursale (IdBanca, Sucursala, IdJudet, Orasul) SELECT ?, ?, ?, ?");

		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @IdBanca, @Sucursala, @IdJudet, @Orasul;
		DEALLOCATE PREPARE stmt;

		SET @IdSucursala=LAST_INSERT_ID();
	END IF;
	
	IF IFNULL(@IdSucursala,'')<>'' THEN
		SET @ERRMSG='MOD_SUCURSALA';

		SET @sql = CONCAT("UPDATE Sucursale SET Sucursala=?,IdJudet=?,Orasul=? WHERE IdSucursala=?");
		
		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @Sucursala, @IdJudet, @Orasul, @IdSucursala;
		DEALLOCATE PREPARE stmt;
	END IF;
	
	SET @OUT=JSON_OBJECT("IdBanca",@IdBanca,"IdSucursala",@IdSucursala);
	
	SET `OUT`=@OUT;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procBaza
-- ----------------------------
DROP PROCEDURE IF EXISTS `procBaza`;
delimiter ;;
CREATE PROCEDURE `procBaza`(IN `IDC` INT, -- IdConsultant
		IN `IDN` INT, -- IdNivel
		IN `ViewName` VARCHAR(50), 
		IN `SyncTime` VARCHAR(50),
		IN `MaxRecords` INT)
BEGIN
	DECLARE Tbl VARCHAR(50);
	
	SET Tbl = "viewBaza";
	
	IF IFNULL(SyncTime,'')='' THEN
		SET @DataM=UNIX_TIMESTAMP('1989-04-22 01:01:01');
	ELSE
		SET @DataM=CAST(SyncTime AS INT);
	END IF;

	IF IDN > 30 THEN
		SET @sql = CONCAT(
		"SELECT ", Tbl, ".*, 
		UNIX_TIMESTAMP(NOW()) as SyncTime 
		FROM ", Tbl, " 
		WHERE UNIX_TIMESTAMP( DataModificare) > ", @DataM, " 
		ORDER BY IdBaza DESC ",
		IF(MaxRecords<=0,"", CONCAT("LIMIT ", MaxRecords)), ";"
		);
	ELSE
		SET @sql = CONCAT("
		SELECT ", Tbl, ".*, 
		UNIX_TIMESTAMP(NOW()) as SyncTime
		FROM ", Tbl, " 
		JOIN (
			SELECT IdConsultant FROM Consultanti WHERE IdConsultant=",IDC," 
			UNION SELECT IdCopil FROM Consultanti_Relatii WHERE IdParinte=",IDC,"
		) C USING (IdConsultant) 
		WHERE UNIX_TIMESTAMP( DataModificare) > ", @DataM, "
		ORDER BY IdBaza DESC ",
		IF(MaxRecords<=0,"", CONCAT("LIMIT ", MaxRecords)), ";"
		);
	END IF;
	
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;	


    -- Record the end time for profiling
    -- SET end_time_numeric = UNIX_TIMESTAMP(NOW(6)) * 1000000;
		
    -- Calculate and store the execution time in microseconds
    -- SET `OUT` =  end_time_numeric - start_time_numeric;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procBaza_Add
-- ----------------------------
DROP PROCEDURE IF EXISTS `procBaza_Add`;
delimiter ;;
CREATE PROCEDURE `procBaza_Add`(IN JSON_BAZA VARCHAR(2000),
	OUT `OUT` VARCHAR (2000))
BEGIN
		DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
			GET DIAGNOSTICS CONDITION 1
			@sqlstate = RETURNED_SQLSTATE,
			@errno = MYSQL_ERRNO,
			@text = MESSAGE_TEXT;
			SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND", REPLACE(JSON_BAZA,"""",""));
			ROLLBACK;
END;
	
	SET @ERRMSG=NULL;
	-- Extract values from JSON
	SET @TIP = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.TIP')),'');
	SET @IdBaza = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdBaza')), "null");
	SET @IdClient = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdClient')), "null");
	SET @IdConsultant = CAST(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdConsultant')), NULL) AS INT);
	SET @IdFeedBack = CAST(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdFeedBack')), 0) AS INT);
	SET @IdSursa = CAST(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdSursa')), NULL) AS INT);
	SET @IdAgent = CAST(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdAgent')), NULL) AS INT);
	SET @IdStatus = CAST(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdStatus')), NULL) AS INT);
	SET @IdJudet = CAST(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdJudet')), NULL) AS INT);
	SET @NumeClient = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.NumeClient')), 'null');
	SET @CNPClient = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.CNPClient')), 'null');
	SET @TelefonP = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.TelefonP')), 'null');
	SET @EmailP = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.EmailP')), 'null');
	SET @DataNastere = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.DataNastere')), 'null');
	SET @DataReconectare = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.DataReconectare')), 'null');
	SET @FeedBack = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.FeedBack')), 'null');

	IF @IdClient = 0 THEN
		SET @IdClient=NULL;
	END IF;
	
	/*SET `OUT` = JSON_OBJECT(
			"TIP", COALESCE(@TIP, ''),
			"IdBaza", COALESCE(@IdBaza, ''),
			"IdClient", COALESCE(@IdClient, ''),
			"IdConsultant", COALESCE(@IdConsultant, ''),
			"IdSursa", COALESCE(@IdSursa, ''),
			"IdAgent", COALESCE(@IdAgent, ''),
			"NumeClient", COALESCE(@NumeClient, ''),
			"CNPClient", COALESCE(@CNPClient, ''),
			"TelefonP", COALESCE(@TelefonP, ''),
			"EmailP", COALESCE(@EmailP, ''),
			"DataNastere", COALESCE(@DataNastere, ''),
			"DataPrimire", COALESCE(@DataPrimire, ''),
			"DataConectare", COALESCE(@DataConectare, ''),
			"DataReconectare", COALESCE(@DataReconectare, ''),
			"FeedBack", COALESCE(@FeedBack, ''),
			"IdJudet", COALESCE(@IdJudet,''));*/

	/*SET @jsonString = JSON_OBJECT(
			'IdBaza', @IdBaza,
			'IdClient', @IdClient,
			'IdConsultant', @IdConsultant,
			'IdFeedBack', @IdFeedBack,
			'IdSursa', @IdSursa,
			'IdAgent', @IdAgent,
			'IdStatus', @IdStatus,
			'IdJudet', @IdJudet,
			'NumeClient', @NumeClient,
			'CNPClient', @CNPClient,
			'TelefonP', @TelefonP,
			'EmailP', @EmailP,
			'DataNastere', @DataNastere,
			'DataReconectare', @DataReconectare,
			'FeedBack', @FeedBack
	);

	-- Display the resulting JSON object
	SELECT @jsonString AS jsonString;*/

	SET @DataPrimire = NOW(); -- COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.pDataPrimire')), ''), NULL);
	SET @DataConectare = NOW(); -- COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.pDataConectare')), ''), NULL);
	
	-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	
	START TRANSACTION;

	CASE @TIP	
		WHEN 'ADD' THEN
			-- adaugare Client
			IF ISNULL(@IdClient) THEN -- daca s-a transmis un IdClient pe adaugare insemna ca NU se adauga si client!
				SET @ERRMSG='ADD_CLIENT';
				
				SET @sql = CONCAT("INSERT INTO Clienti (NumeClient, CNPClient, TelefonP, EmailP, DataNastere, IdJudet) SELECT ?, ?, ?, ?, ?, ?");
				
				PREPARE stmt FROM @sql;
				EXECUTE stmt USING @NumeClient, @CNPClient, @TelefonP, @EmailP, @DataNastere,@IdJudet;
				DEALLOCATE PREPARE stmt;

				SET @IdClient=LAST_INSERT_ID();
			END IF;
			
			-- adaugare Baza
			SET @sql = "INSERT INTO Baza (IdClient, IdSursa, IDAgent, IdConsultant, DataPrimire) SELECT ?, ?, ?, ?, ?";
			SET @ERRMSG='ADD_BAZA';
				
			PREPARE stmt FROM @sql;
			EXECUTE stmt USING @IdClient, @IdSursa, @IdAgent, @IdConsultant, @DataPrimire;
			DEALLOCATE PREPARE stmt;

			SET @IdBaza=LAST_INSERT_ID();
			
		-- adaugare FeedBack
			SET @ERRMSG='ADD_FEEDBACK';
			
			SET @sql = "INSERT INTO Baza_FeedBack (IdBaza, IdStatus, IDSG, IdConsultant, FeedBack, DataReconectare, Primar) SELECT ?, ?, (SELECT IDSG FROM Baza_Status WHERE IdStatus=?), ?, ?, ?, 1";
			PREPARE stmt FROM @sql;
			EXECUTE stmt USING @IdBaza, @IdStatus, @IdStatus, @IdConsultant, @FeedBack, @DataReconectare;
			DEALLOCATE PREPARE stmt;
			
			SET @IdFeedBack=LAST_INSERT_ID();
									
		WHEN 'MOD' THEN
			-- Client
			SET @sql = CONCAT("UPDATE Clienti SET NumeClient=?, CNPClient=?, TelefonP=?, EmailP=?, DataNastere=?, IdJudet=? WHERE IdClient=?");
			SET @ERRMSG='MOD_CLIENT';

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING @NumeClient, @CNPClient, @TelefonP, @EmailP, @DataNastere,@IdJudet,@IdClient;
			DEALLOCATE PREPARE stmt;

			-- Baza
			SET @sql = "UPDATE Baza SET IdSursa=?, IdConsultant=?, IDAgent=? WHERE IdBaza=?";
			SET @ERRMSG='MOD_BAZA';

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING @IdSursa, @IdConsultant, @IdAgent, @IdBaza;
			DEALLOCATE PREPARE stmt;
		
	END CASE;
	
	COMMIT;
	
	SET `OUT`=JSON_OBJECT('IdBaza',@IdBaza,'IdClient',@IdClient,'IdFeedBack',@IdFeedBack);	
	/*
	DO SLEEP(0.9);
	
	SET @ERRMSG='RETRIEVING RECORDSETS'; 
	CASE 
    WHEN @TIP IN ('ADD', 'MOD') THEN
			SELECT *, "Baza" as TblName, "IdBaza" as IdName FROM viewBaza WHERE IdBaza=@IdBaza;
			-- TREBUIE SA FIE EXACT TEXTUL DIN `viewBaza`!!!
			SELECT B.IdBaza AS IdBaza,B.IdAgent AS IDAgent,B.IdSursa AS IdSursa,B.IdConsultant AS IdConsultant,B.IdClient AS IdClient,B.DataPrimire AS DataPrimire,C.NumeClient AS NumeClient, REPLACE (C.TelefonP,' ','') AS TelefonClient,C.EmailP AS EmailClient,C.CNPClient AS CNPClient,C.SMS AS SMS,C.DataNastere AS DataNastere,C.IdJudet AS IdJudet,C.Judet AS JudetClient,C.DIFN AS DIFN,CO.NumeConsultant AS NumeConsultant,CO.cTelefon AS cTelefon,CO.cMail AS cMail,SL.Sursa AS Sursa,A.NumeAgent AS NumeAgent,A.aTelefon AS aTelefon,A.aMail AS aMail,FB.IdFeedBack AS IdFeedBack,FB.IdStatus AS IdStatus,FB.FelStatus AS FelStatus,FB.IDSG AS IDSG,FB.DataConectare AS DataConectare,FB.FeedBack AS FeedBack,FB.FeedBack_Cumulat AS FeedBack_Cumulat,FB.DataReconectare AS DataReconectare,FB.DIF AS DIF,FB.DIFF AS DIFF,0 AS AreDosar,B.DataModificare AS DataModificare,B.S AS S FROM ((((((SELECT Baza.IdBaza AS IdBaza,Baza.IdLead AS IdLead,Baza.IdClient AS IdClient,Baza.IdSursa AS IdSursa,Baza.IdAgent AS IdAgent,Baza.IdConsultant AS IdConsultant,Baza.DataPrimire AS DataPrimire,Baza.Ascuns AS Ascuns,Baza.Nou AS Nou,Baza.DataAdaugare AS DataAdaugare,Baza.DataModificare AS DataModificare,0 AS S FROM Baza WHERE Baza.Ascuns=0 AND Baza.IdBaza=@IdBaza AND Baza.DataModificare< CURRENT_TIMESTAMP ()) B JOIN Clienti C ON (B.IdClient=C.IdClient)) JOIN SursaLead SL ON (B.IdSursa=SL.IdSursa)) JOIN Consultanti CO ON (B.IdConsultant=CO.IdConsultant)) JOIN Agenti A ON (B.IdAgent=A.IdAgent)) LEFT JOIN (SELECT bf.IdBaza AS IdBaza,bf.IdFeedBack AS IdFeedBack,bf.IdStatus AS IdStatus,bf.DataConectare AS DataConectare,bf.DIF AS DIF,bf.DIFF AS DIFF,bs.FelStatus AS FelStatus,bs.IDSG AS IDSG,bf.Feedback AS FeedBack,(SELECT json_arrayagg(json_object('IdFeedBack',bfc.IdFeedBack,'IdConsultant',bfc.IdConsultant,'IdStatus',bfc.IdStatus,'IDSG',bfc.IDSG,'DataConectare',bfc.DataConectare,'FeedBack',bfc.Feedback,'DataReconectare',bfc.DataReconectare,'MailTrimis',bfc.MailTrimis,'DIF',bfc.DIF,'DIFF',bfc.DIFF)) FROM Baza_FeedBack bfc WHERE bfc.IdBaza=bf.IdBaza) AS FeedBack_Cumulat,bf.DataReconectare AS DataReconectare FROM (Baza_FeedBack bf JOIN Baza_Status bs ON (bf.IdStatus=bs.IdStatus)) WHERE bf.IdFeedBack=(SELECT max(Baza_FeedBack.IdFeedBack) AS IdFeedBack FROM Baza_FeedBack WHERE Baza_FeedBack.IdBaza=bf.IdBaza)) FB ON (B.IdBaza=FB.IdBaza));
				
				IF @TIP='ADD' THEN
					SELECT `bfc`.`IdFeedBack`,`bfc`.`IdConsultant`,`bfc`.`IdStatus`,`bfc`.`IDSG`,`bfc`.`DataConectare`,`bfc`.`Feedback`,`bfc`.`DataReconectare`,`bfc`.`MailTrimis`,'Baza_Feedback' AS TblName,'IdFeedBack' AS IdName FROM Baza_FeedBack bfc WHERE bfc.IdFeedBack=@IdFeedBack;
				END IF;
				
		WHEN @TIP = 'ADDF' THEN
					SELECT `bfc`.`IdFeedBack`,`bfc`.`IdConsultant`,`bfc`.`IdStatus`,`bfc`.`IDSG`,`bfc`.`DataConectare`,`bfc`.`Feedback`,`bfc`.`DataReconectare`,`bfc`.`MailTrimis`,'Baza_Feedback' AS TblName,'IdFeedBack' AS IdName FROM Baza_FeedBack bfc WHERE bfc.IdFeedBack=@IdFeedBack;
	END CASE;
	-- ROLLBACK;*/
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procBaza_Add_Feedback
-- ----------------------------
DROP PROCEDURE IF EXISTS `procBaza_Add_Feedback`;
delimiter ;;
CREATE PROCEDURE `procBaza_Add_Feedback`(IN JSON_BAZA VARCHAR(2000),
	OUT `OUT` VARCHAR (2000))
BEGIN
		DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
			GET DIAGNOSTICS CONDITION 1
			@sqlstate = RETURNED_SQLSTATE,
			@errno = MYSQL_ERRNO,
			@text = MESSAGE_TEXT;
			
			SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND", REPLACE(JSON_BAZA,"""",""));
			ROLLBACK;
END;
	
	SET @ERRMSG=NULL;

	SET @IdBaza = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdBaza')), "null");
	SET @IdConsultant = CAST(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdConsultant')), NULL) AS INT);
	SET @IdFeedBack = CAST(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdFeedBack')), 0) AS INT);
	SET @IdStatus = CAST(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.IdStatus')), NULL) AS INT);
	SET @DataReconectare = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.DataReconectare')), 'null');
	SET @FeedBack = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.FeedBack')), 'null');
	SET @DataConectare = NOW(); -- COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_BAZA, '$.pDataConectare')), ''), NULL);
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	START TRANSACTION;

	SET @ERRMSG='UPD_FEEDBACK_OLD';
	SET @sql = "UPDATE Baza_FeedBack SET Primar=0 WHERE IdBaza=?;";
	PREPARE stmt FROM @sql;
	EXECUTE stmt USING @IdBaza;
	DEALLOCATE PREPARE stmt;
	
	SET @ERRMSG='ADDF_FEEDBACK';
	SET @sql = "INSERT INTO Baza_FeedBack (IdBaza, IdStatus, IDSG, IdConsultant, FeedBack, DataReconectare,Primar) 
							SELECT ?, ?, (SELECT IDSG FROM Baza_Status WHERE IdStatus=?), ?, ?, ?, 1";
	PREPARE stmt FROM @sql;
	EXECUTE stmt USING @IdBaza, @IdStatus, @IdStatus, @IdConsultant, @FeedBack, @DataReconectare;
	DEALLOCATE PREPARE stmt;
	
	SET @IdFeedBack=LAST_INSERT_ID();
				
	COMMIT;
	
	SET `OUT`=JSON_OBJECT('IdBaza',@IdBaza,'IdFeedBack',@IdFeedBack);	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procBaza_Count_DIF
-- ----------------------------
DROP PROCEDURE IF EXISTS `procBaza_Count_DIF`;
delimiter ;;
CREATE PROCEDURE `procBaza_Count_DIF`(IN `pIDC` varchar (255), IN `pFilter` VARCHAR(2000), IN `pTipStatus` VARCHAR(255))
BEGIN
	SET @Filtru = IF(IFNULL(pFilter,'')='','1',pFilter);
	SET @IDC="";
	SET @NIV=0;
	
	IF `pTipStatus` = "%" THEN 
		SELECT GROUP_CONCAT(IdStatus) INTO @IDSG FROM Baza_Status WHERE IDSG=2;
		SET @TipStatus = CONCAT("IN (", @IDSG, ")");
	ELSE
		SET @TipStatus = CONCAT("=", `pTipStatus`);
	END IF;
	
	SELECT IdNivel INTO @NIV FROM Consultanti WHERE IdConsultant=`pIDC`;
	
	CASE
		WHEN @NIV <= 10 THEN
			SET @IDC = CONCAT("=",`pIDC`);
			
		WHEN @NIV > 10 and @NIV <= 30 THEN
			SELECT CONCAT_WS(",",`pIDC`,GROUP_CONCAT(IdCopil)) INTO @IDC FROM Consultanti_Relatii WHERE IdParinte=`pIDC` GROUP BY IdParinte;

			IF IFNULL(@IDC,'')='' THEN 
				SET @IDC= CONCAT("=",`pIDC`);
			ELSE	
				IF RIGHT(@IDC,1)="," THEN
						SET @IDC = CONCAT("IN (", MID(@IDC,1,LENGTH(@IDC)-1), ")");
				ELSE
						SET @IDC = CONCAT("IN (", @IDC, ")");			
				END IF;
			END IF;
			
		WHEN @NIV > 30 THEN
			SET @IDC = "LIKE '%'";
	
		ELSE
			SET @IDC = "LIKE '%'";
	
	END CASE ;
	
	SET @sql = CONCAT (
						"SELECT 
						  Sum(IF(IFNULL(IdDosare,'')='',0,1)) as DAB,
							Sum(IF(DATEDIFF(NOW(),DataReconectare) > 0,1,0)) as DR0,
							Sum(IF(DATEDIFF(NOW(),DataReconectare) = 0,1,0)) as DR1,
							Sum(IF(DATEDIFF(NOW(),DataReconectare) IN (-1,-2,-3),1,0)) as DR2
						FROM 
							Filtru_Baza
						WHERE 
							IdConsultant ", @IDC, " AND ", 
							@Filtru, " AND 
							IdStatus ", @TipStatus);
	-- SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
 	DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procBaza_Dosare
-- ----------------------------
DROP PROCEDURE IF EXISTS `procBaza_Dosare`;
delimiter ;;
CREATE PROCEDURE `procBaza_Dosare`(IN `pIDC` VARCHAR(255), IN `pIDB` VARCHAR(255))
BEGIN
	SET @sql = CONCAT (
	"
		SELECT 
			Dosar.IdDosar,
			sBaza.IdClient,
			Banci.Banca,
			Dosar_Status.FelStatus,
			Dosar_Status.TipStatus,
			Dosar.DataIntroducere,
			Dosar.ValoareCredit,
			Dosar_Status.BackColor 
		FROM
			Dosar
			INNER JOIN (SELECT IdBaza, IdClient, IdConsultant FROM Baza WHERE IdBaza=",`pIDB`, ") as sBaza USING ( IdBaza )
			INNER JOIN Banci USING ( IdBanca )
			INNER JOIN Sucursale USING ( IdSucursala )
			INNER JOIN Dosar_Status USING ( IdStatus )");
		
	-- SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
 	DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procBaza_Excel
-- ----------------------------
DROP PROCEDURE IF EXISTS `procBaza_Excel`;
delimiter ;;
CREATE PROCEDURE `procBaza_Excel`(IN `pIDC` varchar (255), IN pFields TEXT, IN `pSort` varchar (255), IN pLimit VARCHAR(255), IN pFilter VARCHAR(2000))
BEGIN
	SET @Sort = IF(IFNULL(pSort,'')='',1,pSort);
	SET @MaxRec = IF(IFNULL(pLimit,'')='','',CONCAT(" LIMIT ",pLimit));
	SET @Filtru = IF(IFNULL(pFilter,'')='','1',pFilter);
	SET @NIV=0;
	SET @IDC="";
	
	SELECT IdNivel INTO @NIV FROM Consultanti WHERE IdConsultant=@pIDC;
	
	CASE @NIV
		WHEN 10 THEN
			SET @IDC = CONCAT("=",`pIDC`);
			
		WHEN 20 THEN
			SELECT CONCAT_WS(",",`pIDC`,GROUP_CONCAT(IdCopil)) INTO @IDC FROM Consultanti_Relatii WHERE IdParinte=`pIDC` GROUP BY IdParinte;

			IF IFNULL(@IDC,'')='' THEN 
				SET @IDC= CONCAT("=",`pIDC`);
			ELSE	
				IF RIGHT(@IDC,1)="," THEN
						SET @IDC = CONCAT("IN (", MID(@IDC,1,LENGTH(@IDC)-1), ")");
				ELSE
						SET @IDC = CONCAT("IN (", @IDC, ")");			
				END IF;
			END IF;
			
		WHEN 30 THEN
			SET @IDC = "LIKE '%'";
	
		ELSE
			SET @IDC = "LIKE '%'";
	
	END CASE ;
	
	SET @sql = CONCAT (
						"SELECT ", pFields, "
						FROM
						`Filtru_Baza`
						WHERE IdConsultant ",@IDC, " AND ", @Filtru, "
						ORDER BY ", @Sort, " ", @MaxRec);

	PREPARE stmt FROM @sql;
	EXECUTE stmt;
 	DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procBaza_FeedBack
-- ----------------------------
DROP PROCEDURE IF EXISTS `procBaza_FeedBack`;
delimiter ;;
CREATE PROCEDURE `procBaza_FeedBack`(IN `pIdBaza` INT)
  READS SQL DATA 
BEGIN
	SELECT
		*,
		UNIX_TIMESTAMP(NOW()) as SyncTime,'Baza_Feedback' as TblName, 'IdFeedBack' as IdName 
	FROM
		view_Baza_FeedBack bf
	WHERE
		 bf.IdBaza = pIdBaza 
	ORDER BY
		bf.IdFeedBack DESC;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procBaza_Istoric
-- ----------------------------
DROP PROCEDURE IF EXISTS `procBaza_Istoric`;
delimiter ;;
CREATE PROCEDURE `procBaza_Istoric`(IN `IDB` int)
BEGIN
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE json_key VARCHAR(255);
    DECLARE json_keyss TEXT DEFAULT '';
    DECLARE json_value TEXT;
    
    -- Use the query to retrieve JSON keys
		SELECT REPLACE(REPLACE(JSON_KEYS(json_data), '[', ''), ']', '') AS json_keys INTO json_keyss
		FROM (
				SELECT JSON_UNQUOTE(JSON_EXTRACT(EXPL, CONCAT('$[', numbers.n, ']'))) AS json_data
				FROM LOG.LOG
				CROSS JOIN (
						SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
				) AS numbers
				WHERE ID = 1459543
				AND numbers.n < JSON_LENGTH(EXPL)
		) AS numbered;
	SELECT json_keyss;
	
    IF json_keyss IS NOT NULL THEN
        -- Remove square brackets and quotes from JSON keys
        SET json_keyss = REPLACE(REPLACE(json_keyss, '[', ''), ']', '');
        SET json_keyss = REPLACE(json_keyss, '"', '');

        -- Start building the SQL query
        SET @sql = 'SELECT ';

        -- Iterate through each JSON key
        WHILE (LOCATE(',', json_keyss) > 0) DO
            SET json_key = SUBSTRING(json_keyss, 1, LOCATE(',', json_keyss) - 1);
            SET json_keyss = SUBSTRING(json_keyss FROM LOCATE(',', json_keyss) + 1);
            SET @sql = CONCAT(@sql, 'JSON_UNQUOTE(JSON_EXTRACT(EXPL, \'$."', json_key, '\')) AS ', json_key, ', ');
        END WHILE;

        -- Add the last or only key
        SET @sql = CONCAT(@sql, 'JSON_UNQUOTE(JSON_EXTRACT(EXPL, \'$."', json_keyss, '\')) AS ', json_keyss);

        -- Finish the SQL statement
        SET @sql = CONCAT(@sql, ' FROM LOG.LOG WHERE IdBaza = ?;');
				SELECT @sql;
        -- Prepare and execute the statement
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING IDB;
        DEALLOCATE PREPARE stmt;
    END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procBaza_Row
-- ----------------------------
DROP PROCEDURE IF EXISTS `procBaza_Row`;
delimiter ;;
CREATE PROCEDURE `procBaza_Row`(IN `pIdBaza` INT,
	OUT `OUT` VARCHAR(200))
BEGIN
	DECLARE start_time_numeric BIGINT;
	DECLARE end_time_numeric BIGINT;

	-- Record the start time for profiling
	SET start_time_numeric = UNIX_TIMESTAMP(NOW(6)) * 1000000;

	SET @sql = CONCAT ("SELECT * FROM viewBaza WHERE IdBaza=?");

	PREPARE stmt FROM @sql;
	EXECUTE stmt USING pIdBaza;
 	DEALLOCATE PREPARE stmt;

	-- Record the end time for profiling
	SET end_time_numeric = UNIX_TIMESTAMP(NOW(6)) * 1000000;
	
	-- Calculate and store the execution time in microseconds
	SET `OUT` =  end_time_numeric - start_time_numeric;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procChangePassword
-- ----------------------------
DROP PROCEDURE IF EXISTS `procChangePassword`;
delimiter ;;
CREATE PROCEDURE `procChangePassword`(IN `IdCons` INT, IN `p` VARCHAR(255), OUT `OUT` VARCHAR(255))
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
 			ROLLBACK; 
		BEGIN
			GET DIAGNOSTICS CONDITION 1
			@sqlstate = RETURNED_SQLSTATE,
			@errno = MYSQL_ERRNO,
			@text = MESSAGE_TEXT;

			SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
			ROLLBACK;
		END; 
	END;

	SET @ERRMSG='MOD_PASS';

	SET @sql = CONCAT("SET PASSWORD FOR `C", LPAD(IdCons,3,'0'), "`@`%` = PASSWORD('", p, "');");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	UPDATE Consultanti SET SchimbaParola=0 WHERE IdConsultant=IdCons;
	
	SET `OUT`=JSON_OBJECT("REZULTAT","OK");
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procClient_ADD
-- ----------------------------
DROP PROCEDURE IF EXISTS `procClient_ADD`;
delimiter ;;
CREATE PROCEDURE `procClient_ADD`(IN `pTelefon` varchar(50))
BEGIN
	DECLARE X INT;
	DECLARE Y INT;
	
	SET @Tel = IFNULL(pTelefon,'');
	
	SELECT SUM(CB) as B, SUM(CD) as D INTO X,Y FROM (
	SELECT Count(IdFeedBack) CB, 0 as CD FROM Baza_FeedBack JOIN (SELECT IdBaza FROM Baza JOIN (SELECT IdClient FROM Clienti_Telefon WHERE Telefon=@Tel) ct USING (IdClient)) b USING (IdBaza) WHERE IDSG=2 AND Primar=1
	UNION 
	SELECT 0 AS CB, Count(IdStatus) as CD FROM Dosar_Status JOIN (SELECT IdStatus FROM Dosar JOIN (SELECT IdClient FROM Clienti_Telefon WHERE Telefon=@Tel) ct USING (IdClient)) d USING (IdStatus) WHERE IDSG=2
	) T;

	SET @sql = CONCAT("
						SELECT
							cl.IdClient,
							b.Idbaza,
							b.IdConsultant,
							b.IdSursa,
							b.IDAgent,
							cl.NumeClient,
							b.DataPrimire,
							c.NumeConsultant AS `Consultant`,
							c.cTelefon as `TelefonConsultant`,
							s.Sursa,
							a.NumeAgent AS Agent,
							cl.EmailP,
							cl.DataNastere,
							cl.IdJudet,
							cl.Judet,
							cl.Tara,
							cl.RO,
							st.FelStatus as StatusFinal,
							st.BackColor as BkColor,
							? as CBaza,
							? as CDosar,
							IF((?=0 AND ?=0)=0,'NU','DA') as Util
						FROM
							Clienti_Telefon ct
							JOIN Clienti cl USING ( IdClient )
							JOIN Baza b USING ( IdClient )
							JOIN Consultanti c USING ( IdConsultant )
							JOIN SursaLead s USING ( IdSursa )
							JOIN Agenti a USING ( IdAgent )
							JOIN (SELECT IdBaza,FelStatus,BackColor FROM Baza_Status bs 
										JOIN Baza_FeedBack bf USING (IdStatus) WHERE IdFeedBack IN 
										(SELECT Max(IdFeedBack) FROM Baza_FeedBack bf 	
										  JOIN Baza b USING (IdBaza) 
											JOIN Clienti c USING (IdClient) 
											JOIN Clienti_Telefon ct USING (IdClient) 
											WHERE Telefon=? 
											GROUP BY IdBaza  
										) AND bs.IDSG<>1

										UNION ALL SELECT IdBaza,FelStatus,BackColor FROM Dosar_Status ds 
										JOIN Dosar USING (IdStatus) WHERE IdDosar IN 
										(SELECT Max(IdDosar) FROM Dosar 
										  JOIN Clienti c USING (IdClient) 
											JOIN Clienti_Telefon ct USING (IdClient) 
											WHERE Telefon=? 
											GROUP BY IdBaza
										) GROUP  BY IdDosar
									) st USING ( IdBaza )
						WHERE
							ct.Telefon=?
						GROUP BY IdBaza;
");
	-- SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt USING X,Y,X,Y,@Tel,@Tel,@Tel;
	DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procClient_ADD_2025
-- ----------------------------
DROP PROCEDURE IF EXISTS `procClient_ADD_2025`;
delimiter ;;
CREATE PROCEDURE `procClient_ADD_2025`(IN `pTelefon` varchar(50), IN `IDC` int)
BEGIN
	DECLARE X INT;
	DECLARE Y INT;
	
	SET @Tel = IFNULL(pTelefon,'');
	
	SELECT SUM(CB) as B, SUM(CD) as D INTO X,Y FROM (
			SELECT Count(IdFeedBack) CB, 0 as CD FROM Baza_FeedBack JOIN (SELECT IdBaza FROM Baza JOIN (SELECT IdClient FROM Clienti_Telefon WHERE Telefon=@Tel) ct USING (IdClient)) b USING (IdBaza) WHERE IDSG=2 AND Primar=1
		UNION 
			SELECT 0 AS CB, Count(IdStatus) as CD FROM Dosar_Status JOIN (SELECT IdStatus FROM Dosar JOIN (SELECT IdClient FROM Clienti_Telefon WHERE Telefon=@Tel) ct USING (IdClient)) d USING (IdStatus) WHERE IDSG=2
	) T;

	SET @sql = CONCAT("
			SELECT IdClient,Idbaza,IdDosar,IdConsultant,IdSursa,IDAgent,DataPrimire,Consultant,TelefonConsultant,Sursa,Agent,NumeClient,CNPClient,EmailP,IdJudet,Judet,Tara,RO,DataNastere,IDSG,BackColor as BkColor,FelStatus as StatusFinal, ? as CBaza, ? as CDosar, IF((?+?)=0,'DA','NU') as Util
			FROM (
				SELECT cl.IdClient,b.Idbaza,0 AS IdDosar,b.IdConsultant,b.IdSursa,b.IDAgent,b.DataPrimire,c.NumeConsultant AS `Consultant`,c.cTelefon AS `TelefonConsultant`,s.Sursa,a.NumeAgent AS Agent,cl.NumeClient,cl.CNPClient,cl.EmailP,cl.IdJudet,cl.Judet,cl.Tara,cl.RO,cl.DataNastere,bf.IDSG,bs.BackColor,bs.FelStatus FROM Clienti_Telefon ct JOIN Clienti cl USING (IdClient) JOIN Baza b USING (IdClient) JOIN Consultanti c USING (IdConsultant) JOIN SursaLead s USING (IdSursa) JOIN Agenti a USING (IdAgent) JOIN Baza_FeedBack bf USING (IdBaza) JOIN Baza_Status bs USING (IdStatus) WHERE ct.Telefon=? AND bf.Primar=1 GROUP BY IdBaza 
				UNION ALL
				SELECT cl.IdClient,d.Idbaza,d.IdDosar,d.IdConsultant,d.IdSursa,d.IDAgent,d.DataIntroducere AS DataPrimire,c.NumeConsultant AS `Consultant`,c.cTelefon AS `TelefonConsultant`,s.Sursa,a.NumeAgent AS Agent,cl.NumeClient,cl.CNPClient,cl.EmailP,cl.IdJudet,cl.Judet,cl.Tara,cl.RO,cl.DataNastere,ds.IDSG,ds.BackColor,ds.FelStatus FROM Clienti_Telefon ct JOIN Clienti cl USING (IdClient) JOIN Dosar d USING (IdClient) JOIN Consultanti c USING (IdConsultant) JOIN SursaLead s USING (IdSursa) JOIN Agenti a USING (IdAgent) JOIN Dosar_Status ds USING (IdStatus) WHERE ct.Telefon=? GROUP BY IdDosar) t
			-- WHERE IdConsultant<>?
");
	-- SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt USING X,Y,X,Y,@Tel,@Tel; -- ,IDC;
	DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procClient_ADD_2025_Personal
-- ----------------------------
DROP PROCEDURE IF EXISTS `procClient_ADD_2025_Personal`;
delimiter ;;
CREATE PROCEDURE `procClient_ADD_2025_Personal`(IN `pTelefon` varchar(50), IN `IDC` int)
BEGIN

	SET @Tel = IFNULL(pTelefon,'');
	SET @IDC = IFNULL(IDC,'');

	SET @sql = CONCAT("
			SELECT IdClient,NumeClient,IdBaza,0 AS IdDosar,FelStatus,(bf.IDSG<>2) AS Util FROM Clienti_Telefon ct INNER JOIN Clienti c USING (IdClient) INNER JOIN Baza b USING (IdClient) INNER JOIN Baza_FeedBack bf USING (IdBaza) INNER JOIN Baza_Status bs USING (IdStatus) WHERE b.IdConsultant=? AND bf.Primar=1 AND ct.Telefon=? GROUP BY b.IdBaza 
			UNION
			SELECT IdClient,NumeClient,IdBaza,IdDosar,FelStatus,(IDSG<>2) AS Util FROM Clienti_Telefon ct INNER JOIN Clienti c USING (IdClient) INNER JOIN Dosar d USING (IdClient) INNER JOIN Dosar_Status ds USING (IdStatus) WHERE d.IdConsultant=? AND ct.Telefon=?
");
	-- SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt USING @IDC,@Tel,@IDC,@Tel;
	DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procClient_ADD_2025_PYTHON
-- ----------------------------
DROP PROCEDURE IF EXISTS `procClient_ADD_2025_PYTHON`;
delimiter ;;
CREATE PROCEDURE `procClient_ADD_2025_PYTHON`(IN `pTelefon` varchar(50), IN `IDC` int)
BEGIN
	DECLARE X INT;
	DECLARE Y INT;
	
	SET @Tel = IFNULL(pTelefon,'');
	
	SELECT SUM(CB) as B, SUM(CD) as D INTO X,Y FROM (
			SELECT Count(IdFeedBack) CB, 0 as CD FROM Baza_FeedBack JOIN (SELECT IdBaza FROM Baza JOIN (SELECT IdClient FROM Clienti_Telefon WHERE Telefon=@Tel) ct USING (IdClient)) b USING (IdBaza) WHERE IDSG=2 AND Primar=1
		UNION 
			SELECT 0 AS CB, Count(IdStatus) as CD FROM Dosar_Status JOIN (SELECT IdStatus FROM Dosar JOIN (SELECT IdClient FROM Clienti_Telefon WHERE Telefon=@Tel) ct USING (IdClient)) d USING (IdStatus) WHERE IDSG=2
	) T;

	SET @sql = CONCAT("
			SELECT IdClient,Idbaza,IdDosar,IdConsultant,IdSursa,IDAgent,DataPrimire,Consultant,TelefonConsultant,Sursa,Agent,NumeClient,CNPClient,EmailP,IdJudet,Judet,Tara,RO,DataNastere,IDSG,CONCAT('#',LPAD(HEX(((COALESCE (BackColor,0xFFFFFF) & 0xFF)<< 16) | (COALESCE (BackColor,0xFFFFFF) & 0xFF00) | ((COALESCE (BackColor,0xFFFFFF) & 0xFF0000)>> 16)),6,'0')) as BkColor,FelStatus as StatusFinal, ? as CBaza, ? as CDosar, IF((?+?)=0,'DA','NU') as Util
			FROM (
				SELECT cl.IdClient,b.Idbaza,0 AS IdDosar,b.IdConsultant,b.IdSursa,b.IDAgent,b.DataPrimire,c.NumeConsultant AS `Consultant`,c.cTelefon AS `TelefonConsultant`,s.Sursa,a.NumeAgent AS Agent,cl.NumeClient,cl.CNPClient,cl.EmailP,cl.IdJudet,cl.Judet,cl.Tara,cl.RO,cl.DataNastere,bf.IDSG,bs.BackColor,bs.FelStatus FROM Clienti_Telefon ct JOIN Clienti cl USING (IdClient) JOIN Baza b USING (IdClient) JOIN Consultanti c USING (IdConsultant) JOIN SursaLead s USING (IdSursa) JOIN Agenti a USING (IdAgent) JOIN Baza_FeedBack bf USING (IdBaza) JOIN Baza_Status bs USING (IdStatus) WHERE ct.Telefon=? AND bf.Primar=1 GROUP BY IdBaza 
				UNION ALL
				SELECT cl.IdClient,d.Idbaza,d.IdDosar,d.IdConsultant,d.IdSursa,d.IDAgent,d.DataIntroducere AS DataPrimire,c.NumeConsultant AS `Consultant`,c.cTelefon AS `TelefonConsultant`,s.Sursa,a.NumeAgent AS Agent,cl.NumeClient,cl.CNPClient,cl.EmailP,cl.IdJudet,cl.Judet,cl.Tara,cl.RO,cl.DataNastere,ds.IDSG,ds.BackColor,ds.FelStatus FROM Clienti_Telefon ct JOIN Clienti cl USING (IdClient) JOIN Dosar d USING (IdClient) JOIN Consultanti c USING (IdConsultant) JOIN SursaLead s USING (IdSursa) JOIN Agenti a USING (IdAgent) JOIN Dosar_Status ds USING (IdStatus) WHERE ct.Telefon=? GROUP BY IdDosar) t
			WHERE IdConsultant<>?
");
	-- SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt USING X,Y,X,Y,@Tel,@Tel,IDC;
	DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procClient_ADD_2025_TEST
-- ----------------------------
DROP PROCEDURE IF EXISTS `procClient_ADD_2025_TEST`;
delimiter ;;
CREATE PROCEDURE `procClient_ADD_2025_TEST`(IN `pTelefon` varchar(50), IN `IDC` int)
BEGIN
	DECLARE X INT;
	DECLARE Y INT;
	
	SET @Tel = IFNULL(pTelefon,'');
	
	SELECT SUM(CB) as B, SUM(CD) as D INTO X,Y FROM (
			SELECT Count(IdFeedBack) CB, 0 as CD FROM Baza_FeedBack JOIN (SELECT IdBaza FROM Baza JOIN (SELECT IdClient FROM Clienti_Telefon WHERE Telefon=@Tel) ct USING (IdClient)) b USING (IdBaza) WHERE IDSG=2 AND Primar=1
		UNION 
			SELECT 0 AS CB, Count(IdStatus) as CD FROM Dosar_Status JOIN (SELECT IdStatus FROM Dosar JOIN (SELECT IdClient FROM Clienti_Telefon WHERE Telefon=@Tel) ct USING (IdClient)) d USING (IdStatus) WHERE IDSG=2
	) T;

	SET @sql = CONCAT("
			SELECT IdClient,Idbaza,IdDosar,IdConsultant,IdSursa,IDAgent,DataPrimire,Consultant,TelefonConsultant,Sursa,Agent,NumeClient,CNPClient,EmailP,IdJudet,Judet,Tara,RO,DataNastere,IDSG,BackColor as BkColor,FelStatus as StatusFinal, ? as CBaza, ? as CDosar, IF((?+?)=0,'DA','NU') as Util
			FROM (
				SELECT cl.IdClient,b.Idbaza,0 AS IdDosar,b.IdConsultant,b.IdSursa,b.IDAgent,b.DataPrimire,c.NumeConsultant AS `Consultant`,c.cTelefon AS `TelefonConsultant`,s.Sursa,a.NumeAgent AS Agent,cl.NumeClient,cl.CNPClient,cl.EmailP,cl.IdJudet,cl.Judet,cl.Tara,cl.RO,cl.DataNastere,bf.IDSG,bs.BackColor,bs.FelStatus FROM Clienti_Telefon ct JOIN Clienti cl USING (IdClient) JOIN Baza b USING (IdClient) JOIN Consultanti c USING (IdConsultant) JOIN SursaLead s USING (IdSursa) JOIN Agenti a USING (IdAgent) JOIN Baza_FeedBack bf USING (IdBaza) JOIN Baza_Status bs USING (IdStatus) WHERE ct.Telefon=? AND bf.Primar=1 GROUP BY IdBaza 
				UNION ALL
				SELECT cl.IdClient,d.Idbaza,d.IdDosar,d.IdConsultant,d.IdSursa,d.IDAgent,d.DataIntroducere AS DataPrimire,c.NumeConsultant AS `Consultant`,c.cTelefon AS `TelefonConsultant`,s.Sursa,a.NumeAgent AS Agent,cl.NumeClient,cl.CNPClient,cl.EmailP,cl.IdJudet,cl.Judet,cl.Tara,cl.RO,cl.DataNastere,ds.IDSG,ds.BackColor,ds.FelStatus FROM Clienti_Telefon ct JOIN Clienti cl USING (IdClient) JOIN Dosar d USING (IdClient) JOIN Consultanti c USING (IdConsultant) JOIN SursaLead s USING (IdSursa) JOIN Agenti a USING (IdAgent) JOIN Dosar_Status ds USING (IdStatus) WHERE ct.Telefon=? GROUP BY IdDosar) t
			-- WHERE IdConsultant<>?
");
	-- SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt USING X,Y,X,Y,@Tel,@Tel; -- ,IDC;
	DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procClient_Mod
-- ----------------------------
DROP PROCEDURE IF EXISTS `procClient_Mod`;
delimiter ;;
CREATE PROCEDURE `procClient_Mod`(IN `TIP` varchar (10),
	IN `ValoareNoua` varchar(200),
	IN `ValoareVeche` varchar(200), 
	IN `IDCL` INT, 
	OUT `OUT` VARCHAR(1000))
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", "procClient_Mod");
		ROLLBACK;
	END; 
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	
	START TRANSACTION;

	IF `TIP`='MOD_TEL' THEN
		UPDATE Clienti SET TelefonP=`ValoareNoua` WHERE IdClient=`IDCL`;
		UPDATE Clienti_Telefon SET Telefon=`ValoareNoua` WHERE Telefon=`ValoareVeche` AND IdClient=`IDCL`;

	ELSEIF `TIP`='ADD_TEL' THEN
		UPDATE Clienti SET TelefonP=`ValoareNoua` WHERE IdClient=`IDCL`;
		INSERT INTO Clienti_Telefon (IdClient, Telefon, Primar)	SELECT `IDCL`, `ValoareNoua`, 1;
		UPDATE Clienti_Telefon SET Primar=0 WHERE IdClient=`IDCL` AND Telefon<>`ValoareNoua`;
	
	ELSEIF `TIP`='MOD_EML' THEN
		UPDATE Clienti SET EmailP=`ValoareNoua` WHERE IdClient=`IDCL`;
		UPDATE Clienti_Mail SET Email=`ValoareNoua` WHERE Email=`ValoareVeche` AND IdClient=`IDCL`;

	ELSEIF `TIP`='ADD_EML' THEN
		UPDATE Clienti SET EmailP=`ValoareNoua` WHERE IdClient=`IDCL`;
		INSERT INTO Clienti_Mail (IdClient, Email, Primar)	SELECT `IDCL`, `ValoareNoua`, 1;
		UPDATE Clienti_Mail SET Primar=0 WHERE IdClient=`IDCL` AND Email<>`ValoareNoua`;

	END IF;
	
	COMMIT;
	
	SET `OUT`=JSON_OBJECT("SUCCES","1");
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procCoditieS_ADD
-- ----------------------------
DROP PROCEDURE IF EXISTS `procCoditieS_ADD`;
delimiter ;;
CREATE PROCEDURE `procCoditieS_ADD`(IN `JSON_CONDITII` JSON,
	OUT `OUT` VARCHAR (2000))
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SET `OUT` = JSON_OBJECT('EROARE', @errno, 'DESCRIERE', @text, 'MODUL', @ERRMSG, 'PARAMETERS', CAST(@jsonString AS VARCHAR(1000)));
		ROLLBACK;
	END;

	SET @TIP = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.TIP')), 'null') AS INT);
	SET @SELTAB = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.SelTab')) AS VARCHAR(255)), 'null');
	SET @POZITIE = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.Pozitie')), 'null') AS INT);

	SET @IDCONDITIE = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.IdConditie')), 'null') AS INT);
	SET @IDCONDITIES = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.IdConditieS')), 'null') AS INT);

	SET @GRUP = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.Grup')), 'null') AS INT);
	SET @GRUPNUME = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.GrupNume')) AS VARCHAR(255)), 'null');
	SET @ALTCAMP = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.AltCamp')), 'null') AS INT);
	SET @MESAJ = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.Mesaj')) AS VARCHAR(2000)), 'null');
	SET @CANDDACA = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.CandDaca')), 'null') AS INT);

	SET @CAMPPRINCIPAL = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.CampPrincipal')) AS VARCHAR(255)), 'null');
	SET @AFISARECAMPPRINCIPAL = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.AfisareCampPrincipal')) AS VARCHAR(255)), 'null');
	SET @TIPCAMPPRINCIPAL = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.TipCampPrincipal')) AS VARCHAR(255)), 'null');

	SET @CAMPASOCIAT = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.CampAsociat')) AS VARCHAR(255)), 'null');
	SET @TIPCAMPASOCIAT = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.TipCampAsociat')) AS VARCHAR(255)), 'null');
	SET @AFISARECAMPASOCIAT = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.AfisareCampAsociat')) AS VARCHAR(255)), 'null');

	SET @SEMN = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.Semn')) AS VARCHAR(255)), 'null');
	SET @AFISARESEMN = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.AfisareSemn')) AS VARCHAR(255)), 'null');

	SET @VALOARE = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.Valoare')) AS VARCHAR(255)), 'null');
	SET @AFISAREVALOARE = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.AfisareValoare')) AS VARCHAR(255)), 'null');
	SET @TIPCAMPVALOARE = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_CONDITII, '$.TipCampValoare')) AS VARCHAR(255)), 'null');

	/*SET @jsonString = CAST(JSON_OBJECT(
		"@TIP", @TIP ,
		"@SELTAB",@SELTAB,
		"@POZITIE", @POZITIE ,
		"@IDCONDITIE", @IDCONDITIE ,
		"@IDCONDITIES", @IDCONDITIES ,
		"@GRUP", @GRUP ,
		"@GRUPNUME", @GRUPNUME ,
		"@ALTCAMP", @ALTCAMP ,
		"@MESAJ", @MESAJ ,
		"@CANDDACA", @CANDDACA ,
		"@CAMPPRINCIPAL", @CAMPPRINCIPAL ,
		"@AFISARECAMPPRINCIPAL", @AFISARECAMPPRINCIPAL ,
		"@TIPCAMPPRINCIPAL",@TIPCAMPPRINCIPAL,
		"@CAMPASOCIAT", @CAMPASOCIAT ,
		"@TIPCAMPASOCIAT", @TIPCAMPASOCIAT ,
		"@AFISARECAMPASOCIAT", @AFISARECAMPASOCIAT ,
		"@SEMN", @SEMN ,
		"@AFISARESEMN", @AFISARESEMN ,
		"@VALOARE", @VALOARE ,
		"@AFISAREVALOARE", @AFISAREVALOARE ,
		"@TIPCAMPVALOARE", @TIPCAMPVALOARE) as VARCHAR(1000));

	SELECT @jsonString;*/

	SET @ERRMSG='VERIFICĂRI INIȚIALE';
	
	IF @IDCONDITIE = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lipseste IdConditie!';
	ELSEIF @IDCONDITIES = 0 AND @TIP = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lipseste IdConditieS!';
	ELSEIF @GRUP = 0 AND @TIP < 2 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lipseste Grupul Conditiei!';
	-- ELSEIF @AltCamp = 1 AND (LEFT(@Valoare, 1) <> '[' OR RIGHT(@Valoare, 1) <> ']') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Campul de verificat nu este formatat corect ([])!';
	END IF;
			
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	START TRANSACTION;

	IF @TIP=0 THEN -- se modifica o conditie
		SET @ERRMSG='MOD_CONDITIE_SALVARE';
		SET @sql = CONCAT(
			"UPDATE ConditiiS SET 
				AltCamp=?,
				Mesaj=?,
				CandDaca=?,
				CampAsociat=?,
				TipCampAsociat=?,
				AfisareCampAsociat=?,
				Semn=?,
				AfisareSemn=?,
				Valoare=?,
				AfisareValoare=?,
				TipCampValoare=?
			WHERE IdConditieS=?");
		PREPARE stmt FROM @sql;
		EXECUTE stmt USING
				@ALTCAMP,
				@MESAJ,
				@CANDDACA,
				@CAMPASOCIAT,
				@TIPCAMPASOCIAT,
				@AFISARECAMPASOCIAT,
				@SEMN,
				@AFISARESEMN,
				@VALOARE,
				@AFISAREVALOARE,
				@TIPCAMPVALOARE,
				@IDCONDITIES;
		DEALLOCATE PREPARE stmt;
		
		SET `OUT`=JSON_OBJECT("IdConditie",CAST(@IDCONDITIE AS INT),"Grup",CAST(@GRUP as INT),"IdConditieS",CAST(@IDCONDITIES AS INT));
		
	ELSE -- se adauga conditie
		SET @ERRMSG='ADD_CONDITIE_SALVARE';
		SET @sql = CONCAT(
			 "INSERT INTO ConditiiS 
			 (
					SelTab,
					Pozitie,
					IdConditie,
					Grup,
					Denumire,
					AltCamp,
					Mesaj,
					CandDaca,
					CampPrincipal,
					AfisareCampPrincipal,
					TipCampPrincipal,
					CampAsociat,
					TipCampAsociat,
					AfisareCampAsociat,
					Semn,
					AfisareSemn,
					Valoare,
					AfisareValoare,
					TipCampValoare
			 ) SELECT ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?");

		PREPARE stmt FROM @sql;
		EXECUTE stmt USING 
			 @SELTAB,
			 @POZITIE,
			 @IDCONDITIE,
			 @GRUP,
			 @GRUPNUME,
			 @ALTCAMP,
			 @MESAJ,
			 @CANDDACA,
			 @CAMPPRINCIPAL,
			 @AFISARECAMPPRINCIPAL,
			 @TIPCAMPPRINCIPAL,
			 @CAMPASOCIAT,
			 @TIPCAMPASOCIAT,
			 @AFISARECAMPASOCIAT,
			 @SEMN,
			 @AFISARESEMN,
			 @VALOARE,
			 @AFISAREVALOARE,
			 @TIPCAMPVALOARE; 

		DEALLOCATE PREPARE stmt;

		SET @IDCONDITIES=LAST_INSERT_ID();
		SET `OUT`=JSON_OBJECT("IdConditie",CAST(@IDCONDITIE AS INT),"Grup",CAST(@GRUP as INT),"IdConditieS",CAST(@IDCONDITIES AS INT));

	END IF;	
	
	COMMIT;
	
	SELECT *,'ConditiiS' as TblName, 'IdConditieS' as IdName FROM ConditiiS WHERE IdConditieS=@IDCONDITIES;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procColoane_Excel
-- ----------------------------
DROP PROCEDURE IF EXISTS `procColoane_Excel`;
delimiter ;;
CREATE PROCEDURE `procColoane_Excel`(IN `pIDC` INT, IN `pSelTab` VARCHAR(255), IN `pNumeConfig` VARCHAR(255), IN `pShowIDs` TINYINT(4))
  READS SQL DATA 
BEGIN
	SELECT Count(IDCOL) INTO @CNT FROM Consultanti_Coloane_Excel WHERE IdConsultant=`pIDC`;
		 
	IF @CNT=0 THEN
		SELECT
			IdColoana,
			"(implicit)" as NumeConfig,
			NumeColoana,
			AfisareColoana,
			PozitieInitiala AS Pozitie,
			LatimeImplicita as Latime,
			AscunsImplicit AS Ascuns,
			NOT AscunsImplicit as Vizibil,
			FontImplicit AS Font,
			JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828) as Color,
			LEFT ( NumeColoana, 2 )= "ID" AS ID ,
			0 as IDCOL
		FROM
			Coloane_Implicite_Excel 
		WHERE
			SelectedTab = `pSelTab` 
			AND (LEFT ( NumeColoana, 2 )= "ID")=`pShowIDs`
		ORDER BY
			PozitieInitiala;
				
	ELSE
		SELECT
			IdColoana,
			NumeConfig,
			NumeColoana,
			Afisare as AfisareColoana,
			Pozitie,
			Latime,
			Ascuns,
			NOT Ascuns as Vizibil,
			Font,
			JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828) as Color,
			LEFT ( NumeColoana, 2 )= "ID" AS ID,
			IDCOL 
		FROM
			Consultanti_Coloane_Excel
			INNER JOIN Coloane_Implicite_Excel USING ( IdColoana ) 
		WHERE
			SelectedTab = `pSelTab` 
			AND IdConsultant = `pIDC` 
			AND (LEFT ( NumeColoana, 2 )= "ID")=`pShowIDs`
		ORDER BY
			Pozitie;		
	END IF;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procColoane_Excel_Add
-- ----------------------------
DROP PROCEDURE IF EXISTS `procColoane_Excel_Add`;
delimiter ;;
CREATE PROCEDURE `procColoane_Excel_Add`(IN `pTIP` VARCHAR (3),
	IN `pIdConsultant` INT,
	IN `pNumeConfig` VARCHAR (255),
	IN `pColoaneJson` JSON,
	OUT `OUT` VARCHAR(2000))
BEGIN
	BEGIN
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;

		SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
		ROLLBACK;
	END;
	
	SET @ColoaneCount = JSON_LENGTH(pColoaneJson);
	SET @i = 0;
	
	-- SELECT @ColoaneCount,@i;
	
	IF pTIP='ADD' THEN
		SET @ERRMSG="ADD_CONFIG_EXCEL";
		
		WHILE @i < @ColoaneCount DO
			SET @IdColoana = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].IdColoana'));
			SET @Pozitie = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Pozitie'));
			SET @Latime = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Latime'));
			SET @Afisare = REPLACE(JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Afisare')),'"','');
			SET @Font = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Font'));
			SET @Ascuns = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Ascuns'));

			-- SELECT @IdColoana,@Pozitie,@Latime,@Afisare,@Font,@Ascuns;
			
			SET @sql = CONCAT("INSERT INTO Consultanti_Coloane_Excel (NumeConfig, IdColoana, IdConsultant, Pozitie, Latime, Afisare, Font, Ascuns) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING pNumeConfig, @IdColoana, pIdConsultant, @Pozitie, @Latime, @Afisare, @Font, @Ascuns;
			DEALLOCATE PREPARE stmt;

			SET @i = @i + 1;
		END WHILE;
	
	ELSE
		SET @ERRMSG="MOD_CONFIG_EXCEL";
		
		WHILE @i < @ColoaneCount DO
			SET @IDCOL = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].IDCOL'));
			SET @IdColoana = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].IdColoana'));
			SET @Pozitie = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Pozitie'));
			SET @Latime = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Latime'));
			SET @Afisare = REPLACE(JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Afisare')),'"','');
			SET @Font = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Font'));
			SET @Ascuns = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Ascuns'));
			
			SET @sql = CONCAT("UPDATE Consultanti_Coloane_Excel SET Pozitie=?, Latime=?, Afisare=?, Font=?, Ascuns=? WHERE IDCOL=?");

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING @Pozitie, @Latime, @Afisare, @Font, @Ascuns, @IDCOL;
			DEALLOCATE PREPARE stmt;

			SET @i = @i + 1;
		END WHILE;
		
	END IF;
	
	SET `OUT` = JSON_OBJECT("REZULTAT", "SUCCES");
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procColoane_Excel_Config
-- ----------------------------
DROP PROCEDURE IF EXISTS `procColoane_Excel_Config`;
delimiter ;;
CREATE PROCEDURE `procColoane_Excel_Config`(IN `pIdConsultant` int)
BEGIN
	SELECT
		Consultanti_Coloane_Excel.IDCOL,
		Consultanti_Coloane_Excel.NumeConfig,
	IF
		( Coloane_Implicite_Excel.SelectedTab = 'nvB1', 'Simulari', 'Dosare' ) AS Tbl 
	FROM
		Consultanti_Coloane_Excel
		INNER JOIN Coloane_Implicite_Excel ON Consultanti_Coloane_Excel.IdColoana = Coloane_Implicite_Excel.IdColoana 
	WHERE
		Consultanti_Coloane_Excel.IdConsultant = pIdConsultant 
	GROUP BY
		Consultanti_Coloane_Excel.NumeConfig 
	ORDER BY
		Consultanti_Coloane_Excel.NumeConfig ASC;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procColoane_Filtru
-- ----------------------------
DROP PROCEDURE IF EXISTS `procColoane_Filtru`;
delimiter ;;
CREATE PROCEDURE `procColoane_Filtru`(IN `pSelTab` VARCHAR ( 255 ), IN `pShowIDs` TINYINT(4))
BEGIN
	SELECT
		IDF,
		ColV as NumeColoana,
		Col as Afisare,
		Pozitie,
		Tbl,
		SelectedTab,
		IsID AS ID,
		Ascuns,			
		FldType,
		PrCol,
		Dt,
		Nm,
		Pr,
		'{"FontName":"Consolas","FontSize":10,"FontBold":0,"FontItalic":0,"FontUnderline":0,"FontColor":"0000000"}' as Font,
		JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828) as Color,
		-1 as Latime,
		0 AS S
	FROM
		`Filtru` FORCE INDEX (idx_ordering)
	WHERE
		IsID = `pShowIDs` AND
		SelectedTab LIKE `pSelTab`  
	GROUP BY
		IDF
	ORDER BY
		SelectedTab,
		Pozitie;		
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procConditii_Salvare
-- ----------------------------
DROP PROCEDURE IF EXISTS `procConditii_Salvare`;
delimiter ;;
CREATE PROCEDURE `procConditii_Salvare`(IN `pSelTab` VARCHAR ( 255 ))
BEGIN
SELECT
    IdConditie,
		Camp,
		TipCamp,
		Grup,
    JSON_arrayAGG(JSON_OBJECT( 'CampS', REPLACE(REPLACE(CampS,']',''),'[',''), 'Pozitie', Pozitie, 'CandDaca', CandDaca, 'Semn', Semn, 'Valoare', REPLACE(REPLACE(Valoare,']',''),'[',''), 'AltCamp', AltCamp, 'TipCampS',TipCampS, 'TipCampV',TipCampV, 'Mesaj', Mesaj )) AS jsnConditie
FROM
    viewConditii_Salvare
WHERE 
	Pozitie>0 AND
	SelTab=pSelTab
GROUP BY
    IdConditie
ORDER BY
	IdConditie,Grup,Pozitie;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procConsultanti_Coloane
-- ----------------------------
DROP PROCEDURE IF EXISTS `procConsultanti_Coloane`;
delimiter ;;
CREATE PROCEDURE `procConsultanti_Coloane`(IN `pIDC` INT, IN `pSelTab` VARCHAR(255), IN `pImplicit` TINYINT (4), IN `pDoarVizibile` TINYINT (4))
  READS SQL DATA 
BEGIN
	IF `pImplicit`=0 THEN
		SELECT
			Consultanti_Coloane.IDCOL, 
			Consultanti_Coloane.IdColoana, 
			Coloane_Implicite.NumeColoana, 
			Coloane_Implicite.AfisareColoana, 
			Consultanti_Coloane.Pozitie, 
			Consultanti_Coloane.Marime, 
			Consultanti_Coloane.Ascuns,
			Consultanti_Coloane.Aliniere,
			Consultanti_Coloane.Formatare,
			JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828) as Color,
			'{"FontName":"Consolas","FontSize":10,"FontBold":0,"FontItalic":0,"FontUnderline":0,"FontColor":"0000000"}' as Font,
			FC_JSON AS FC,
			NumeColoana_FC,
			NOT Ascuns as Vizibil,
			`pImplicit` as Implicit	,
			Special	
		FROM
			Coloane_Implicite
			INNER JOIN
			Consultanti_Coloane
			ON 
				Coloane_Implicite.IdColoana = Consultanti_Coloane.IdColoana
			LEFT JOIN
			view_FC
			ON
				Coloane_Implicite.IdColoana = view_FC.IdColoana
		WHERE
			Consultanti_Coloane.IdConsultant = `pIDC` AND
			Coloane_Implicite.SelectedTab = `pSelTab` AND
			Consultanti_Coloane.Ascuns <> IF(`pDoarVizibile`=0,-1,1)
		ORDER BY
			Consultanti_Coloane.Pozitie;
			
	ELSE
		SELECT
			Consultanti_Coloane.IDCOL, 
			Consultanti_Coloane.IdColoana, 
			Coloane_Implicite.NumeColoana, 
			Coloane_Implicite.AfisareColoana, 
			Coloane_Implicite.PozitieInitiala as Pozitie, 
			Coloane_Implicite.MarimeInitiala as Marime, 
			Coloane_Implicite.AscunsImplicit as Ascuns,
			Coloane_Implicite.AliniereInitiala as Aliniere,
			Coloane_Implicite.FormatareInitiala as Formatare,
			JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828) as Color,
			'{"FontName":"Consolas","FontSize":10,"FontBold":0,"FontItalic":0,"FontUnderline":0,"FontColor":"0000000"}' as Font,
			FC_JSON AS FC,
			NumeColoana_FC,
			NOT Coloane_Implicite.AscunsImplicit as Vizibil,
			`pImplicit` as Implicit,
			Special
		FROM
			Coloane_Implicite
			INNER JOIN
			Consultanti_Coloane
			ON 
				Coloane_Implicite.IdColoana = Consultanti_Coloane.IdColoana
			LEFT JOIN
			view_FC
			ON
				Coloane_Implicite.IdColoana = view_FC.IdColoana
		WHERE
			Consultanti_Coloane.IdConsultant = `pIDC` AND
			Coloane_Implicite.SelectedTab = `pSelTab` 
		ORDER BY
			Coloane_Implicite.PozitieInitiala;
			
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procConsultanti_Coloane_Add
-- ----------------------------
DROP PROCEDURE IF EXISTS `procConsultanti_Coloane_Add`;
delimiter ;;
CREATE PROCEDURE `procConsultanti_Coloane_Add`(IN `pIdConsultant` INT,
	IN `pColoaneJson` JSON,
	-- IN `pActualizeazaPozitii` VARCHAR(1),
	OUT `OUT` VARCHAR(2000))
BEGIN
	BEGIN
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;

		SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
		ROLLBACK;
	END;
	
	SET @ColoaneCount = JSON_LENGTH(pColoaneJson);
	SET @i = 0;	
	SET @ERRMSG="MOD_CONFIG_COLOANE";
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	
	START TRANSACTION;
	
-- 	IF CAST(IFNULL(pActualizeazaPozitii,'0') AS INT) = 0 THEN
		WHILE @i < @ColoaneCount DO
			SET @IDCOL = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].IDCOL'));
			SET @Pozitie = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Pozitie'));
			SET @Formatare = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Formatare'))),"null");
			SET @Marime = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Marime'));
			SET @Ascuns = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Ascuns'));
			SET @Aliniere = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Aliniere'));
			
			-- SELECT @IDCOL,@Pozitie,@Formatare,@Marime,@Ascuns,@Aliniere;
			
			SET @sql = CONCAT("UPDATE Consultanti_Coloane SET Pozitie=?, Marime=?, Ascuns=?, Aliniere=?,Formatare=? WHERE IDCOL=? AND IdConsultant=?");

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING @Pozitie, @Marime, @Ascuns, @Aliniere, @Formatare, @IDCOL, pIdConsultant;
			DEALLOCATE PREPARE stmt;

			SET @i = @i + 1;
		END WHILE;
	
/*	ELSE
		WHILE @i < @ColoaneCount DO
			SET @IDCOL = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].IDCOL'));
			SET @Pozitie = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Pozitie'));
			SET @Ascuns = JSON_EXTRACT(pColoaneJson, CONCAT('$[', @i, '].Ascuns'));

			SET @sql = CONCAT("UPDATE Consultanti_Coloane SET Pozitie=?, Ascuns=? WHERE IDCOL=? AND IdConsultant=?");

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING @Pozitie, @Ascuns, @IDCOL, pIdConsultant;
			DEALLOCATE PREPARE stmt;

			SET @i = @i + 1;
		END WHILE;
		
	END IF;*/
	
	COMMIT;
	
	SET `OUT` = JSON_OBJECT("REZULTAT", "SUCCES");
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procConsultanti_Judete
-- ----------------------------
DROP PROCEDURE IF EXISTS `procConsultanti_Judete`;
delimiter ;;
CREATE PROCEDURE `procConsultanti_Judete`(IN `pIdConsultant` VARCHAR (255),
	IN `pIdRegiune` INT)
BEGIN
	SET @IdConsultant = IFNULL(pIdConsultant,"");
	SET @IdRegiune = MOD(pIdRegiune,2);
	
	IF @IdRegiune = 0 THEN 
		SET @IdRegiune = 2; 
	ELSE 
		SET @IdRegiune = 1; 
	END IF;
		
SELECT * 
FROM
	(
	SELECT True as S, IdJudet, Judete.IdRegiune, CodJudet, Judet FROM Consultanti_Judete INNER JOIN Judete USING (IdJudet) WHERE IdConsultant = @IdConsultant 
	UNION ALL 
	
	SELECT False as S, IdJudet, IdRegiune, CodJudet, Judet FROM Judete WHERE IdRegiune=@IdRegiune AND IdJudet NOT IN (SELECT IdJudet FROM Consultanti_Judete WHERE IdConsultant = @IdConsultant)
	) as J
ORDER BY S DESC, Judet;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procConsultanti_Judete_Add
-- ----------------------------
DROP PROCEDURE IF EXISTS `procConsultanti_Judete_Add`;
delimiter ;;
CREATE PROCEDURE `procConsultanti_Judete_Add`(IN `TIP` VARCHAR (255),
IN `pIdConsultant` VARCHAR (255),
IN `pIdRegiune` VARCHAR (255),
OUT `OUT` VARCHAR(2000))
  READS SQL DATA 
BEGIN
SELECT * 
FROM
	(
	SELECT True as S, IdJudet, CodJudet, Judet FROM Consultanti_Judete WHERE IdConsultant = pIdConsultant 
	UNION ALL 
	SELECT False as S, IdJudet, CodJudet, Judet FROM Judete WHERE IdRegiune=pIdRegiune
	) as J
ORDER BY S DESC, Judet;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procConsultanti_Tree
-- ----------------------------
DROP PROCEDURE IF EXISTS `procConsultanti_Tree`;
delimiter ;;
CREATE PROCEDURE `procConsultanti_Tree`(IN `pIdConsultant` INT)
  READS SQL DATA 
BEGIN
	WITH RECURSIVE Descendants AS (
			SELECT
					vc.IdConsultant,vc.NumeConsultant,vc.IdParinteTop,vc.Parinte,CAST(NULL AS CHAR(255)) AS ParentConsultantName,vc.IdParinte,vc.IdNivel,vc.IdRegiune,vc.Adresa,vc.CNP,vc.Ascuns,vc.Functie,vc.cMail,vc.cTelefon,vc.CodFiscal,vc.CodJudet,vc.CodOras,vc.DataAdaugare,vc.DataModificare,vc.SchimbaParola,vc.Nou,vc.Plecat,vc.Sistem,vc.Suffix,vc.Beta,vc.Prefix, vc.PicText 
			FROM viewConsultanti vc
			WHERE vc.IdConsultant = pIdConsultant

			UNION ALL

			SELECT
					child.IdConsultant,child.NumeConsultant,child.IdParinteTop,child.Parinte,parent.NumeConsultant AS ParentConsultantName,child.IdParinte,child.IdNivel,child.IdRegiune,child.Adresa,child.CNP,child.Ascuns,child.Functie,child.cMail,child.cTelefon,child.CodFiscal,child.CodJudet,child.CodOras,child.DataAdaugare,child.DataModificare,child.SchimbaParola,child.Nou,child.Plecat,child.Sistem,child.Suffix,child.Beta,child.Prefix, child.PicText
			FROM viewConsultanti child
			INNER JOIN Descendants AS parent ON child.IdParinte = parent.IdConsultant
	)
	SELECT * FROM Descendants;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procCount_Baza
-- ----------------------------
DROP PROCEDURE IF EXISTS `procCount_Baza`;
delimiter ;;
CREATE PROCEDURE `procCount_Baza`(IN `IDC` INT, IN IDN INT, IN Filtru VARCHAR(2000))
BEGIN
	DECLARE `OUT` VARCHAR(2000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');
	
	IF IDN >= 40 THEN
			SET @sql = CONCAT("
				SELECT IdConsultant, TotalRows, bDR0, bDR1, bDR2, 'CountBaza' as tblName 
				FROM 
				(SELECT 
					IdConsultant,
					SUM(1) as TotalRows,
					SUM(CASE WHEN DIFF = 1 THEN 1 ELSE 0 END) AS bDR2, 
					SUM(CASE WHEN DIFF = 2 THEN 1 ELSE 0 END) AS bDR1, 
					SUM(CASE WHEN DIFF = 3 THEN 1 ELSE 0 END) AS bDR0
				FROM viewBaza 
				WHERE ", Filtru, " 
				GROUP BY IdConsultant) t"
			);
			
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt; 
	ELSE
			SET @sql = CONCAT("
				SELECT IdConsultant, TotalRows, bDR0, bDR1, bDR2, 'CountBaza' as tblName  
				FROM 
				(SELECT 
					IdConsultant,
					SUM(1) as TotalRows,
					SUM(CASE WHEN DIFF = 1 THEN 1 ELSE 0 END) AS bDR2, 
					SUM(CASE WHEN DIFF = 2 THEN 1 ELSE 0 END) AS bDR1, 
					SUM(CASE WHEN DIFF = 3 THEN 1 ELSE 0 END) AS bDR0
				FROM viewBaza 
				WHERE ", Filtru, "
				GROUP BY IdConsultant
				) as v JOIN (
					SELECT IdCopilCopil 
					FROM SVN_00.Consultanti_Copii 
					WHERE IdCopil=?
				) cc ON v.IdConsultant=cc.IdCopilCopil
			");
			
			PREPARE stmt FROM @sql;
			EXECUTE stmt USING IDC;
			DEALLOCATE PREPARE stmt; 
	END IF;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procCount_Baza_2025
-- ----------------------------
DROP PROCEDURE IF EXISTS `procCount_Baza_2025`;
delimiter ;;
CREATE PROCEDURE `procCount_Baza_2025`(IN `IDC` INT, IN IDN INT, IN Filtru VARCHAR(5000))
BEGIN
	DECLARE `OUT` VARCHAR(5000);
		-- Filter testing against injection
	DECLARE flt_bad     BOOLEAN DEFAULT FALSE;
	DECLARE flt_errmsg  TEXT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	IF Filtru <> '' THEN
		BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '42S22'  -- unknown column
				SET flt_bad = TRUE;

			SET @test_flt = CONCAT(
				'SELECT 1 INTO @flt_dummy FROM viewBaza_2025',
				' WHERE ', Filtru,
				' LIMIT 0'
			);
			PREPARE _flt FROM @test_flt;
			EXECUTE _flt;
			DEALLOCATE PREPARE _flt;
		END;
	END IF;
	
	IF IDN >= 40 THEN
			SET @sql = CONCAT("
				SELECT TotalRows, bDR0, bDR1, bDR2, 'CountBaza' as tblName 
				FROM 
				(SELECT 
					IdConsultant,
					SUM(1) as TotalRows,
					SUM(CASE WHEN DIFF = 1 THEN 1 ELSE 0 END) AS bDR1, 
					SUM(CASE WHEN DIFF = 2 THEN 1 ELSE 0 END) AS bDR2, 
					SUM(CASE WHEN DIFF = 3 THEN 1 ELSE 0 END) AS bDR0
				FROM viewBaza_2025 ", 
				IF(Filtru="","", CONCAT("WHERE ", Filtru)), " 
				) t"
			);
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt; 
	ELSE
			SET @sql = CONCAT("
				SELECT Sum(TotalRows) as TotalRows, Sum(bDR0) as bDR0, Sum(bDR1) as bDR1, Sum(bDR2) as bDR2, 'CountBaza' as tblName  
				FROM 
				(SELECT 
					IdConsultant,
					SUM(1) as TotalRows,
					SUM(CASE WHEN DIFF = 1 THEN 1 ELSE 0 END) AS bDR1, 
					SUM(CASE WHEN DIFF = 2 THEN 1 ELSE 0 END) AS bDR2, 
					SUM(CASE WHEN DIFF = 3 THEN 1 ELSE 0 END) AS bDR0
				FROM viewBaza_2025 ",
				IF(Filtru="","",CONCAT("WHERE ", Filtru)), "
				GROUP BY IdConsultant
				) as v JOIN (
					SELECT IdCopilCopil 
					FROM SVN_00.Consultanti_Copii 
					WHERE IdCopil=?
				) cc ON v.IdConsultant=cc.IdCopilCopil
			");

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING IDC;
			DEALLOCATE PREPARE stmt; 
	END IF;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procCount_Dosar
-- ----------------------------
DROP PROCEDURE IF EXISTS `procCount_Dosar`;
delimiter ;;
CREATE PROCEDURE `procCount_Dosar`(IN `IDC` INT, IN IDN INT, IN Filtru VARCHAR(2000))
BEGIN
	DECLARE `OUT` VARCHAR(2000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');
	
	IF IDN >= 40 THEN
			SET @sql = CONCAT("
				SELECT IdConsultant, TotalRows, bDR0, bDR1, bDR2, 'CountDosar' as tblName 
				FROM 
				(SELECT 
					IdConsultant,
					SUM(1) as TotalRows,
					SUM(CASE WHEN IDSG = 2 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR2, 
					SUM(CASE WHEN IDSG = 1 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR1, 
					SUM(CASE WHEN IDSG = 3 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR0
				FROM viewDosar 
				WHERE ", Filtru, " 
				GROUP BY IdConsultant) t"
			);
			
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt; 
	ELSE
			SET @sql = CONCAT("
				SELECT IdConsultant, TotalRows, bDR0, bDR1, bDR2, 'CountBaza' as tblName  
				FROM 
				(SELECT 
					IdConsultant,
					SUM(1) as TotalRows,
					SUM(CASE WHEN IDSG = 2 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR2, 
					SUM(CASE WHEN IDSG = 1 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR1, 
					SUM(CASE WHEN IDSG = 3 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR0
				FROM viewDosar 
				WHERE ", Filtru, "
				GROUP BY IdConsultant
				) as v JOIN (
					SELECT IdCopilCopil 
					FROM SVN_00.Consultanti_Copii 
					WHERE IdCopil=?
				) cc ON v.IdConsultant=cc.IdCopilCopil
			");
			
			PREPARE stmt FROM @sql;
			EXECUTE stmt USING IDC;
			DEALLOCATE PREPARE stmt; 
	END IF;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procCount_Dosar_2025
-- ----------------------------
DROP PROCEDURE IF EXISTS `procCount_Dosar_2025`;
delimiter ;;
CREATE PROCEDURE `procCount_Dosar_2025`(IN `IDC` INT, IN IDN INT, IN Filtru VARCHAR(2000))
BEGIN
	DECLARE `OUT` VARCHAR(2000);
		-- Filter testing against injection
	DECLARE flt_bad     BOOLEAN DEFAULT FALSE;
	DECLARE flt_errmsg  TEXT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;

	IF Filtru <> '' THEN
		BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '42S22'  -- unknown column
				SET flt_bad = TRUE;

			SET @test_flt = CONCAT(
				'SELECT 1 INTO @flt_dummy FROM viewDosar_2025',
				' WHERE ', Filtru,
				' LIMIT 0'
			);
			PREPARE _flt FROM @test_flt;
			EXECUTE _flt;
			DEALLOCATE PREPARE _flt;
		END;
	END IF;
	
	IF IDN >= 40 THEN
			SET @sql = CONCAT("
				SELECT TotalRows, bDR0, bDR1, bDR2, 'CountDosar' as tblName 
				FROM 
				(SELECT 
					IdConsultant,
					SUM(1) as TotalRows,
					SUM(CASE WHEN IDSG = 2 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR2, 
					SUM(CASE WHEN IDSG = 1 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR1, 
					SUM(CASE WHEN IDSG = 3 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR0
				FROM viewDosar_2025 ", 
				IF(Filtru="","", CONCAT("WHERE ", Filtru)), " 
				) t"
			);
			
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt; 
	ELSE
			SET @sql = CONCAT("
				SELECT Sum(TotalRows) as TotalRows, Sum(bDR0) as bDR0, Sum(bDR1) as bDR1, Sum(bDR2) as bDR2, 'CountBaza' as tblName  
				FROM 
				(SELECT 
					IdConsultant,
					SUM(1) as TotalRows,
					SUM(CASE WHEN IDSG = 2 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR2, 
					SUM(CASE WHEN IDSG = 1 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR1, 
					SUM(CASE WHEN IDSG = 3 AND AltaBanca = 0 THEN 1 ELSE 0 END) AS bDR0
				FROM viewDosar_2025 ",
				IF(Filtru="","",CONCAT("WHERE ", Filtru)), "
				GROUP BY IdConsultant
				) as v JOIN (
					SELECT IdCopilCopil 
					FROM SVN_00.Consultanti_Copii 
					WHERE IdCopil=?
				) cc ON v.IdConsultant=cc.IdCopilCopil
			");
			
			PREPARE stmt FROM @sql;
			EXECUTE stmt USING IDC;
			DEALLOCATE PREPARE stmt; 
	END IF;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procCount_Ipotecare_2025
-- ----------------------------
DROP PROCEDURE IF EXISTS `procCount_Ipotecare_2025`;
delimiter ;;
CREATE PROCEDURE `procCount_Ipotecare_2025`(IN `IDC` INT, IN IDN INT, IN Filtru VARCHAR(2000))
BEGIN
	DECLARE `OUT` VARCHAR(2000);
		-- Filter testing against injection
	DECLARE flt_bad     BOOLEAN DEFAULT FALSE;
	DECLARE flt_errmsg  TEXT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	IF Filtru <> '' THEN
		BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '42S22'  -- unknown column
				SET flt_bad = TRUE;

			SET @test_flt = CONCAT(
				'SELECT 1 INTO @flt_dummy FROM viewIpotecare',
				' WHERE ', Filtru,
				' LIMIT 0'
			);
			PREPARE _flt FROM @test_flt;
			EXECUTE _flt;
			DEALLOCATE PREPARE _flt;
		END;
	END IF;
		
	IF IDN >= 40 THEN
			SET @sql = CONCAT("
				SELECT TotalRows, bDR0, bDR1, bDR2, 'CountIpotecare' as tblName 
				FROM 
				(SELECT 
					IdConsultant,
					SUM(1) as TotalRows,
					SUM(CASE WHEN DIFF = 2 THEN 1 ELSE 0 END) AS bDR2, 
					SUM(CASE WHEN DIFF = 1 THEN 1 ELSE 0 END) AS bDR1, 
					SUM(CASE WHEN DIFF = 3 THEN 1 ELSE 0 END) AS bDR0
				FROM viewIpotecare ", 
				IF(Filtru="","", CONCAT("WHERE ", Filtru)), " 
				) t"
			);
			
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt; 
	ELSE
			SET @sql = CONCAT("
				SELECT Sum(TotalRows) as TotalRows, Sum(bDR0) as bDR0, Sum(bDR1) as bDR1, Sum(bDR2) as bDR2, 'CountIpotecare' as tblName  
				FROM 
				(SELECT 
					IdConsultant,
					SUM(1) as TotalRows,
					SUM(CASE WHEN DIFF = 2 THEN 1 ELSE 0 END) AS bDR2, 
					SUM(CASE WHEN DIFF = 1 THEN 1 ELSE 0 END) AS bDR1, 
					SUM(CASE WHEN DIFF = 3 THEN 1 ELSE 0 END) AS bDR0
				FROM viewIpotecare ",
				IF(Filtru="","",CONCAT("WHERE ", Filtru)), "
				GROUP BY IdConsultant
				) as v JOIN (
					SELECT IdCopilCopil 
					FROM SVN_00.Consultanti_Copii 
					WHERE IdCopil=?
				) cc ON v.IdConsultant=cc.IdCopilCopil
			");
			
			PREPARE stmt FROM @sql;
			EXECUTE stmt USING IDC;
			DEALLOCATE PREPARE stmt; 
	END IF;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procDosar
-- ----------------------------
DROP PROCEDURE IF EXISTS `procDosar`;
delimiter ;;
CREATE PROCEDURE `procDosar`(IN `pIDC` VARCHAR(255), 
    IN `pSort` VARCHAR(255), 
    IN `pLimit` VARCHAR(255), 
    IN `pFilter` VARCHAR(2000))
BEGIN
    DECLARE start_time_numeric BIGINT;
    DECLARE end_time_numeric BIGINT;
    
    -- Validation
    IF NOT (pIDC REGEXP '^[0-9]+$' OR pIDC = '%') THEN
        -- Handle invalid input (e.g., raise an error, set default value, etc.)
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valoare invalidă pentru parametrul pIDC!';
    END IF;

    -- Sanitization
    SET pSort = QUOTE(pSort);
    SET pLimit = QUOTE(pLimit);
    SET pFilter = QUOTE(pFilter);

    -- Variable declarations
    SET @Sort = IF(IFNULL(pSort,"")="''"," IdBaza DESC ",pSort);
    SET @Filtru = IF(IFNULL(pFilter,"")="''","1",pFilter);
    SET @NIV=0;
    SET @IDC="";
    
    IF IFNULL(pLimit,"")="''" THEN    
        SET @MaxRec="";
    ELSE
        IF CAST(SUBSTRING_INDEX(`pLimit`,",",1) AS INT)=0 THEN
            SET @MaxRec = CONCAT(" LIMIT ", CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(`pLimit`,",",2),",",-1) AS INT));
        ELSE
            SET @MaxRec = CONCAT(" LIMIT ", CAST(SUBSTRING_INDEX(`pLimit`,",",1) AS INT), ",", CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(`pLimit`,",",2),",",-1) AS INT));
        END IF;
    END IF;

    -- Fetch consultant level
    SELECT IdNivel INTO @NIV FROM Consultanti WHERE IdConsultant=`pIDC`;

    -- Determine filtering condition based on consultant level
    CASE 
        WHEN @NIV <= 10 THEN SET @IDC = CONCAT("=",`pIDC`);
            
        WHEN @NIV > 10 AND @NIV <= 30 THEN
            -- For level 11 to 30, fetch related IDs
            SELECT CONCAT_WS(",",`pIDC`,GROUP_CONCAT(IdCopil)) INTO @IDC FROM Consultanti_Relatii WHERE IdParinte=`pIDC` GROUP BY IdParinte;

            IF IFNULL(@IDC,'')='' THEN 
                SET @IDC= CONCAT("=",`pIDC`);
            ELSE    
                IF RIGHT(@IDC,1)="," THEN
                    SET @IDC = CONCAT("IN (", MID(@IDC,1,LENGTH(@IDC)-1), ")");
                ELSE
                    SET @IDC = CONCAT("IN (", @IDC, ")");            
                END IF;
            END IF;
            
        WHEN @NIV > 30 AND @NIV <= 40 THEN
            -- For level 31 to 40, fetch related IDs by IdRegiune
            SELECT CONCAT_WS(",",`pIDC`,GROUP_CONCAT(IdConsultant)) INTO @IDC FROM Consultanti WHERE IdRegiune IN (SELECT IdRegiune FROM Consultanti WHERE IdConsultant=`pIDC`);

            IF IFNULL(@IDC,'')='' THEN 
                SET @IDC= CONCAT("=",`pIDC`);
            ELSE    
                IF RIGHT(@IDC,1)="," THEN
                    SET @IDC = CONCAT("IN (", MID(@IDC,1,LENGTH(@IDC)-1), ")");
                ELSE
                    SET @IDC = CONCAT("IN (", @IDC, ")");            
                END IF;
            END IF;
    
        WHEN @NIV >40 AND @NIV <= 50 THEN SET @IDC = "LIKE '%'";
    END CASE;


    -- Record the start time for profiling
    -- SET start_time_numeric = UNIX_TIMESTAMP(NOW(6)) * 1000000;

    -- Construct dynamic SQL query
    SET @sql = CONCAT ("SELECT * FROM Filtru_Dosar WHERE IdConsultant ", @IDC, " AND ", @Filtru, " ORDER BY ", @Sort, " ", @MaxRec);
	
	-- DEBUG: (remove -- from next line for debugging)
	-- SELECT @sql;
	
    -- Execute the dynamic SQL query
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

		-- SET `OUT` = @sql;
    -- Record the end time for profiling
    -- SET end_time_numeric = UNIX_TIMESTAMP(NOW(6)) * 1000000;
	
    -- Calculate and store the execution time in microseconds
    -- SET `MS` =  end_time_numeric - start_time_numeric;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procDosar_Add
-- ----------------------------
DROP PROCEDURE IF EXISTS `procDosar_Add`;
delimiter ;;
CREATE PROCEDURE `procDosar_Add`(IN `TIP` VARCHAR (255),
	IN `IdDosar` VARCHAR (255),
	IN `IdBaza` VARCHAR (255),
	IN `IdClient` VARCHAR (255),
	IN `IdConsultant` VARCHAR (255),
	IN `IdSursa` VARCHAR (255),
	IN `IdAgent` VARCHAR (255),
	IN `IdStatus` VARCHAR (255),
	IN `IdStare` VARCHAR (255),
	IN `Codebitor` VARCHAR (255),
	IN `NumeCodebitor` VARCHAR (255),
	IN `IdMotiv` VARCHAR (255),
	IN `ObservatiiFinale` VARCHAR (255),
	IN `JSONVenit` JSON, -- 	IN `IdVenit` VARCHAR (255),	IN `Venit` VARCHAR (255), 	IN `TipCredit` VARCHAR (255),	IN `IdTipMoneda` VARCHAR (255),	IN `PerioadaCredit` VARCHAR (255),	IN `ValoareCredit` VARCHAR (255),	IN `IdTipDobanda` VARCHAR (255),	IN `Dobanda` VARCHAR (255),	IN `CursMoneda` DOUBLE,
	IN `JSONBanca` JSON, -- 	IN `IdBanca` VARCHAR (255),	IN `IdSucursala` VARCHAR (255),	IN `ConsilierBanca` VARCHAR (255),	IN `CodBanca` VARCHAR (255),
	IN `JSONFunctie` JSON, -- IN `IdFunctie` VARCHAR (255),IN `IdFunctieFunctie` VARCHAR (255),IN `IdCompanie` VARCHAR (255),IN `IdDomeniu` VARCHAR (255),IN `Domeniu` VARCHAR (255),IN `Functie` VARCHAR (255),IN `Companie` VARCHAR (255),IN `TipCompanie` VARCHAR (255),
	-- IN `JSONFeedback` JSON, -- IN `IdFeedBack` VARCHAR (255),	IN `IdStatusFeedback` VARCHAR (255),	IN `FeedBack` VARCHAR (1000),	IN `DataConectare` VARCHAR (255),	IN `DataReconectare` VARCHAR (255),
	IN `JSONDate` JSON, -- IN `DataDebursare` VARCHAR (255),	IN `DataRespingere` VARCHAR (255), IN `DataOpinieJ` VARCHAR (255), IN `DataPreaprobare` VARCHAR (255), IN `DataTrimitere` VARCHAR (255)
	OUT `OUT` VARCHAR (2000))
BEGIN

	DECLARE num_items INT;
	DECLARE i INT DEFAULT 0;
	DECLARE pfn VARCHAR(10);
	DECLARE psf VARCHAR(10);
	DECLARE curs DOUBLE DEFAULT 0;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","");
		ROLLBACK;
	END;

	SET @ERRMSG="START";

	SET @TIP = IFNULL(`TIP`,'');
	-- extract json
	-- Functie
	SET @IdFunctie = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdFunctie')), 'null');
	SET pfn=CAST(IFNULL(@IdFunctie,0) AS INT);
	SET @IdCompanie = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdCompanie')), 'null');
	SET @IdDomeniu = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdDomeniu')), 'null');
	SET @IdFunctieFunctie = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdFunctieFunctie')), 'null');
	SET @IdTipCompanie = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdTipCompanie')), 'null');

	-- Banca
	SET @IdBanca = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdBanca')), 'null');
	SET @IdSucursala = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdSucursala')), 'null');
	SET @ConsilierBanca = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.ConsilierBanca')), 'null');
	SET @CodBanca = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.CodBanca')), 'null');
	SET curs = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.CursMoneda')), 'null') AS DOUBLE);
	SET @IdNotar = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdNotar')),'null');
	SET @IdEvaluator = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdEvaluator')),'null');

	-- Venit
	SET @IdVenit = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdVenit')), 'null');
	SET @Venit = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.Venit')), 'null');

	SET @IdTipImobil = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipImobil')), 'null');
	SET @AreImobil = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.AreImobil')), 'null');
	SET @ValoareImobil = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.ValoareImobil')), 'null');
	
	SET @IdTipCredit = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipCredit')), 'null');
	SET @PerioadaCredit = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.PerioadaCredit')), 'null');
	SET @IdTipMoneda = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipMoneda')), 'null');
	SET @ValoareCredit = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.ValoareCredit')), 'null');
	SET @ValoareCreditRON = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.ValoareCreditRON')), 'null');
	
	SET @IdTipDobanda = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipDobanda')), 'null');
	SET @Dobanda = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.Dobanda')), 'null');
	SET @MarjaDobanda = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.MarjaDobanda')), 'null');
	SET @MarjaDobandaDF = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.MarjaDobandaDF')), 'null');
	SET @PerioadaDobanda = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.PerioadaDobanda')), 'null');
	
	-- Feedback
	/*SET @IdFeedBack = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFeedback, '$.IdFeedBack')), '0');
	SET @IdStatusFeedback = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFeedback, '$.IdStatusFeedback')), '0');
	SET psf=CAST(IFNULL(@IdFeedBack,0) AS INT);
	SET @DataConectare = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFeedback, '$.DataConectare')), 'null') AS DATE);
	SET @DataReconectare = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFeedback, '$.DataReconectare')), 'null') AS DATE);
	SET @FeedBack = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFeedback, '$.FeedBack')), 'null');*/

	-- Date
	SET @DataIntroducere = CAST(NOW() AS DATE);
	SET @DataDebursare = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataDebursare')), 'null') AS DATE);
	SET @DataRespingere = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataRespingere')), 'null') AS DATE);
	SET @DataOpinieJ = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataOpinieJ')), 'null') AS DATE);
	SET @DataPreaprobare = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataPreaprobare')), 'null') AS DATE);
	SET @DataTrimitere = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataTrimitere')), 'null') AS DATE);


	-- iduri
	SET @IdDosar = NULLIF(IFNULL(IdDosar, ''), 'null');
	SET @IdBaza = NULLIF(IFNULL(IdBaza, ''), 'null');
	SET @IdClient = NULLIF(IFNULL(IdClient, ''), 'null');
	SET @IdConsultant = NULLIF(IFNULL(IdConsultant, ''), 'null');
	SET @IdSursa = NULLIF(IFNULL(IdSursa, ''), 'null');
	SET @IdAgent = NULLIF(IFNULL(IdAgent, ''), 'null');
	SET @IdStatus = NULLIF(IFNULL(IdStatus, ''), 'null');
	SET @IdStare = NULLIF(IFNULL(IdStare, ''), 'null');
	SET @IdMotiv = NULLIF(IdMotiv, '');
	
	-- alti parametri
	SET @Codebitor = CAST(Codebitor AS INT);
	SET @NumeCodebitor = NULLIF(NumeCodebitor, 'null');
	SET @ObservatiiFinale = NULLIF(ObservatiiFinale, 'null');

	/*SELECT  @TIP, CAST(JSON_OBJECT('IdFunctie',@IdFunctie,'IdCompanie',@IdCompanie,'IdDomeniu',@IdDomeniu,'IdFunctieFunctie',@IdFunctieFunctie,'IdTipCompanie',@IdTipCompanie,'IdBanca',@IdBanca,'IdSucursala',@IdSucursala,'ConsilierBanca',@ConsilierBanca,'CodBanca',@CodBanca,'IdNotar',@IdNotar,'IdEvaluator',@IdEvaluator,'CursMoneda',curs,'IdVenit',@IdVenit,'Venit',@Venit,'IdTipImobil',@IdTipImobil,'AreImobil',@AreImobil,'ValoareImobil',@ValoareImobil,'IdTipCredit',@IdTipCredit,'PerioadaCredit',@PerioadaCredit,'IdTipMoneda',@IdTipMoneda,'ValoareCredit',@ValoareCredit,'IdTipDobanda',@IdTipDobanda,'Dobanda',@Dobanda,'MarjaDobanda',@MarjaDobanda,'MarjaDobandaDF',@MarjaDobandaDF,'PerioadaDobanda',@PerioadaDobanda,'IdFeedBack',@IdFeedBack,'IdStatusFeedback',@IdStatusFeedback,'DataConectare',@DataConectare,'DataReconectare',@DataReconectare,'FeedBack',@FeedBack,'DataDebursare',@DataDebursare,'DataRespingere',@DataRespingere,'DataOpinieJ',@DataOpinieJ,'DataPreaprobare',@DataPreaprobare,'DataTrimitere',@DataTrimitere,'IdDosar',@IdDosar,'IdBaza',@IdBaza,'IdClient',@IdClient,'IdConsultant',@IdConsultant,'IdSursa',@IdSursa,'IdAgent',@IdAgent,'IdStatus',@IdStatus,'IdStare',@IdStare,'IdMotiv',@IdMotiv,'Codebitor',@Codebitor,'NumeCodebitor',@NumeCodebitor,'ObservatiiFinale',@ObservatiiFinale) AS VARCHAR(2000)) AS json_result, pfn, psf;*/
	
	SET @ERRMSG="START";

	-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	
	START TRANSACTION;
	
	IF IFNULL(@IdFunctie,'')='' THEN -- se adauga functie noua
		SET @ERRMSG='ADD_FUNCTIE';
		
		SET @sql = "INSERT INTO Dosar_Functii (IdClient,IdFunctieFunctie,IdDomeniu,IdCompanie,IdTipCompanie) SELECT ?,?,?,?,?;";
		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @IdClient,@IdFunctieFunctie,@IdDomeniu,@IdCompanie,@IdTipCompanie;
		DEALLOCATE PREPARE stmt;

		SET @IdFunctie=LAST_INSERT_ID();
	END IF;
	
	CASE 
		WHEN @TIP IN ('ADD','TRA') THEN

			SET @ERRMSG='ADD_DOSAR'; -- adaugare Dosar
			SET @sql = "
				INSERT INTO Dosar (
					IdBaza, IdClient, IdConsultant, IdAgent, IdSursa, 
					IdBanca, IdSucursala, ConsilierBanca, CodBanca, IdEvaluator, IdNotar, 
					IdFunctie, IdFunctieFunctie, IdDomeniu, IdCompanie, IdTipCompanie,
					IdStare, IdStatus, IdMotiv, 
					IdVenit, Venit, 
					IdTipImobil, AreImobil, ValoareImobil, 
					IdTipCredit, IdTipMoneda, PerioadaCredit, ValoareCredit, CursMoneda, ValoareCreditRON,
					IdTipDobanda, Dobanda, MarjaDobanda, MarjaDobandaDF, PerioadaDobanda, 
					Codebitor, NumeCodebitor, 
					DataIntroducere, DataPreaprobare, DataOpinieJ, DataTrimitere, DataDebursare, DataRespingere,
					ObservatiiFinale
					) 
				VALUES 
					(
					?, ?, ?, ?, ?, 
					?, ?, ?, ?, ?, ?,
					?, ?, ?, ?, ?,
					?, ?, ?, 
					?, ?,
					?, ?, ?, 
					?, ?, ?, ?, ?,
					?, ?, ?, ?, ?, ?,
					?, ?,
					?, ?, ?, ?, ?, ?,
					?
					)";

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING 
					@IdBaza, @IdClient, @IdConsultant, @IdAgent, @IdSursa, 
					@IdBanca, @IdSucursala, @ConsilierBanca, @CodBanca, @IdEvaluator, @IdNotar, 
					@IdFunctie, @IdFunctieFunctie, @IdDomeniu, @IdCompanie, @IdTipCompanie,
					@IdStare, @IdStatus, @IdMotiv, 
					@IdVenit, @Venit, 
					@IdTipImobil, @AreImobil, @ValoareImobil, 
					@IdTipCredit, @IdTipMoneda, @PerioadaCredit, @ValoareCredit, curs, @ValoareCreditRON,
					@IdTipDobanda, @Dobanda, @MarjaDobanda, @MarjaDobandaDF, @PerioadaDobanda, 
					@Codebitor, @NumeCodebitor, 
					@DataIntroducere, @DataPreaprobare, @DataOpinieJ, @DataTrimitere, @DataDebursare, @DataRespingere, 
					@ObservatiiFinale;

			DEALLOCATE PREPARE stmt;

			SET @IdDosar=LAST_INSERT_ID(); 

			/*IF IFNULL(@IdStatusFeedback,'')<>'' THEN -- doar daca exista un FeedBack
				SET @ERRMSG='ADD_FEEDBACK'; -- adaugare FeedBack
				-- ceva nu merge la adaugare status. 11/12/23
				SET @sql = "INSERT INTO Dosar_FeedBack (IdDosar, IdStatus, IDSG, IdConsultant, DataConectare, FeedBack, DataReconectare, Primar) 
										SELECT ?, ?, (SELECT IDSG FROM Dosar_Status WHERE IdStatus=?), ?, ?, ?, ?, 1";

				PREPARE stmt FROM @sql;
				EXECUTE stmt USING @IdDosar, @IdStatusFeedback, @IdStatusFeedback, @IdConsultant, @DataConectare, @FeedBack, @DataReconectare;
				DEALLOCATE PREPARE stmt;
				
				SET @IdFeedBack=LAST_INSERT_ID();
			END IF;*/
			
			IF @TIP='TRA' THEN
				SET @ERRMSG='UPD_FEEDBACK_OLD';
				SET @sql =  CONCAT("UPDATE Baza_FeedBack SET Primar=0 WHERE IdBaza=?;");
				PREPARE stmt FROM @sql;
				EXECUTE stmt USING @IdBaza;
				
				SET @ERRMSG='ADD_FEEDBACK_BAZA';
				SET @sql = "INSERT INTO Baza_FeedBack (IdBaza, IdStatus, IDSG, IdConsultant, DataConectare, FeedBack, Primar) SELECT ?, 1, 1, ?, ?, 'Transferat în Analiză Bancară', 1";

				PREPARE stmt FROM @sql;
				EXECUTE stmt USING @IdBaza, @IdConsultant, @DataIntroducere;
				DEALLOCATE PREPARE stmt;
				
				SET @IdFeedBackBaza = LAST_INSERT_ID();
			END IF;
															
/*		WHEN 'ADDF' THEN
			SET @ERRMSG='UPD_FEEDBACK_OLD';
			UPDATE Dosar_FeedBack SET Primar=0 WHERE IdDosar=@IdDosar;
			
			SET @ERRMSG='ADDF_FEEDBACK';
			SET @sql = "INSERT INTO Dosar_FeedBack (IdDosar, IdStatus, IDSG, IdConsultant, DataConectare, FeedBack, DataReconectare, Primar) 
									SELECT ?, ?, (SELECT IDSG FROM Dosar_Status WHERE IdStatus=?), ?, ?, ?, ?, 1";

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING @IdDosar, @IdStatusFeedback, @IdStatusFeedback, @IdConsultant, @DataConectare, @FeedBack, @DataReconectare;
			DEALLOCATE PREPARE stmt;*/
			
	END CASE;
	
	COMMIT;
	
SET `OUT`=JSON_OBJECT('IdDosar',@IdDosar,'IdFunctie',@IdFunctie,'IdFeedBack',@IdFeedBack);	

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procDosar_Client_Functie
-- ----------------------------
DROP PROCEDURE IF EXISTS `procDosar_Client_Functie`;
delimiter ;;
CREATE PROCEDURE `procDosar_Client_Functie`(IN `pIdClient` INT, IN `pIdDosar` INT)
  READS SQL DATA 
BEGIN
		SELECT 
			TRUE as Activ,
			IdDosar,
			IdFunctie,
			IdFunctieFunctie,
			IdCompanie,
			IdDomeniu,
			IdTipCompanie,
			Companie,
			CodFiscal,
			Domeniu,
			Functie,
			TipCompanie 
		FROM
			Dosar INNER JOIN
			Dosar_Functii_Companie USING (IdCompanie) INNER JOIN 
			Dosar_Functii_Domeniu USING (IdDomeniu) INNER JOIN 
			Dosar_Functii_Functie USING (IdFunctieFunctie) INNER JOIN 
			Dosar_Functii_TipCompanie USING (IdTipCompanie)
		WHERE 
			IdClient = pIdClient AND
			IdDosar = pIdDosar
			
		UNION ALL 
		
		SELECT
			False as Activ,
			0 as IdDosar,
			IdFunctie,
			IdFunctieFunctie,
			IdCompanie,
			IdDomeniu,
			IdTipCompanie,
			Companie,
			CodFiscal,
			Domeniu,
			Functie,
			TipCompanie 
		FROM
			Dosar_Functii INNER JOIN 
			Dosar_Functii_Companie	USING (IdCompanie) INNER JOIN 
			Dosar_Functii_Domeniu USING (IdDomeniu) INNER JOIN 
			Dosar_Functii_Functie USING (IdFunctieFunctie) INNER JOIN 
			Dosar_Functii_TipCompanie USING (IdTipCompanie)
		WHERE
			IdClient = pIdClient AND
			IdFunctie NOT IN (SELECT IdFunctie FROM Dosar WHERE IdClient = pIdClient AND IdDosar = pIdDosar)
		GROUP BY
			IdFunctie
; 
		

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procDosar_Count_DIF
-- ----------------------------
DROP PROCEDURE IF EXISTS `procDosar_Count_DIF`;
delimiter ;;
CREATE PROCEDURE `procDosar_Count_DIF`(IN `pIDC` varchar (255), IN `pFilter` VARCHAR(2000), IN `pTipStatus` VARCHAR(255))
BEGIN
	SET @Filtru = IF(IFNULL(pFilter,'')='','1',pFilter);
	SET @IDC="";
	SET @NIV=0;
	
	IF `pTipStatus` = "%" THEN 
		SELECT GROUP_CONCAT(IdStatus) INTO @IDSG FROM Dosar_Status WHERE IDSG=2;
		SET @TipStatus = CONCAT("IN (", @IDSG, ")");
	ELSE
		SET @TipStatus = CONCAT("=", `pTipStatus`);
	END IF;
	
	-- genereaza lista cu consultanti asociati (in cazul nivel 30, toti)
	SELECT IdNivel INTO @NIV FROM Consultanti WHERE IdConsultant=`pIDC`;
	
	CASE @NIV
		WHEN 10 THEN
			SET @IDC = CONCAT("=",`pIDC`);
			
		WHEN 20 THEN
			SELECT CONCAT_WS(",",`pIDC`,GROUP_CONCAT(IdCopil)) INTO @IDC FROM Consultanti_Relatii WHERE IdParinte=`pIDC` GROUP BY IdParinte;

			IF IFNULL(@IDC,'')='' THEN 
				SET @IDC= CONCAT("=",`pIDC`);
			ELSE	
				IF RIGHT(@IDC,1)="," THEN
						SET @IDC = CONCAT("IN (", MID(@IDC,1,LENGTH(@IDC)-1), ")");
				ELSE
						SET @IDC = CONCAT("IN (", @IDC, ")");			
				END IF;
			END IF;
			
		WHEN 30 THEN
			SET @IDC = "LIKE '%'";
	
		ELSE
			SET @IDC = "LIKE '%'";
	
	END CASE ;
	-- ------
	
	SET @sql = CONCAT (
						"SELECT 
						  Sum(IF(IFNULL(IdDosar,'')='',0,1)) as DAB,
							Sum(IF(DATEDIFF(NOW(),DataReconectare) > 0,1,0)) as DR0,
							Sum(IF(DATEDIFF(NOW(),DataReconectare) = 0,1,0)) as DR1,
							Sum(IF(DATEDIFF(NOW(),DataReconectare) IN (-1,-2,-3),1,0)) as DR2
						FROM 
							Filtru_Dosar
						WHERE 
							IdConsultant ", @IDC, " AND ", 
							@Filtru, " AND 
							IdStatus ", @TipStatus);
	-- SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
 	DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procDosar_FeedBack
-- ----------------------------
DROP PROCEDURE IF EXISTS `procDosar_FeedBack`;
delimiter ;;
CREATE PROCEDURE `procDosar_FeedBack`(IN `pIdDosar` INT, IN `pSyncTime` VARCHAR(255))
  READS SQL DATA 
BEGIN
	
	IF IFNULL(pSyncTime,'')='' THEN
		SET @DataM=CAST(DATE_FORMAT('1989-04-22 01:01:01', '%Y-%m-%d %H:%i:%s') AS DATETIME);
	ELSE
		SET @DataM=CAST(DATE_FORMAT(pSyncTime, '%Y-%m-%d %H:%i:%s') AS DATETIME);
	END IF;

	SELECT
		f.IdFeedBack,
		f.IdDosar,
		s.IdStatusFeedBack,
		s.FelStatusFeedback,
		s.BackColorFeedback,
		f.DataConectare,
		f.Feedback,
		f.DataReconectare,
		f.DataModificare,
		UNIX_TIMESTAMP(NOW()) as SyncTime,'Dosar_FeedBack' as TblName, 'IdFeedBack' as IdName  
	FROM
		Dosar_FeedBack f
		JOIN Dosar_FeedBack_Status s ON f.IdStatusFeedback = s.IdStatusFeedback 
	WHERE
		 f.DataModificare > @DataM AND f.IdDosar = pIdDosar 
	ORDER BY
		DataModificare DESC, IdFeedBack DESC;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procDosar_JOINS
-- ----------------------------
DROP PROCEDURE IF EXISTS `procDosar_JOINS`;
delimiter ;;
CREATE PROCEDURE `procDosar_JOINS`(IN `pIDTC` INT)
  READS SQL DATA 
BEGIN
	SELECT C,V,J FROM (
		-- Dosar_TipVenit
		SELECT C, V, J FROM (
				SELECT 'IdBanca' AS C, 
						JSON_ARRAYAGG(
								JSON_OBJECT('IdBanca', IdBanca, 'Banca', CONCAT(IF(ABS(Ascuns) = 1, '*', ''), Banca))
						) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Banci') AS J
				FROM Banci 
				ORDER BY Ascuns, Banca
		) Q

		UNION ALL 

		SELECT C, V, J FROM (
				SELECT 'IdVenit' AS C, 
						JSON_ARRAYAGG(
								JSON_OBJECT('IdVenit', IdVenit, 'TipVenit', CONCAT(IF(ABS(Ascuns) = 1, '*', ''), TipVenit))
						) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_TipVenit') AS J
				FROM Dosar_TipVenit 
				WHERE IDTC = pIDTC 
				ORDER BY Ascuns, TipVenit
		) Q

		UNION ALL

		-- Dosar_TipDobanda
		SELECT C, V, J FROM (
				SELECT 'IdTipDobanda' AS C, 
						JSON_ARRAYAGG(
								JSON_OBJECT('IdTipDobanda', IdTipDobanda, 'TipDobanda', CONCAT(IF(ABS(Ascuns) = 1, '*', ''), TipDobanda), 'Fields', `Fields`)
						) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_TipDobanda') AS J
				FROM Dosar_TipDobanda 
				WHERE IDTC = pIDTC 
				ORDER BY Ascuns, TipDobanda
		) Q

		UNION ALL

		-- Dosar_Status
		SELECT C, V, J FROM (
				SELECT 'IdStatus' AS C, 
						JSON_ARRAYAGG(
								JSON_OBJECT('IdStatus', IdStatus, 'FelStatus', CONCAT(IF(ABS(Ascuns) = 1, '*', ''), FelStatus), 'TipStatus', TipStatus, 'BackColor', BackColor)
						) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'viewDosar_Status') AS J
				FROM viewDosar_Status 
		) Q

		UNION ALL
		-- Dosar_Motiv
		SELECT C, V, J FROM (
				SELECT 'IdMotiv' AS C, 
						JSON_ARRAYAGG(
								JSON_OBJECT('IdMotiv', IdMotiv, 'Motiv', CONCAT(IF(ABS(Ascuns) = 1, '*', ''), Motiv))
						) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_Motiv') AS J
				FROM Dosar_Motiv 
				WHERE IDTC = pIDTC 
				ORDER BY Ascuns, Motiv
		) Q

		UNION ALL

		-- Dosar_TipMoneda
		SELECT C, V, J FROM (
				SELECT 'IdTipMoneda' AS C, 
						JSON_ARRAYAGG(
								JSON_OBJECT('IdTipMoneda', IdTipMoneda, 'Moneda', CONCAT(IF(ABS(Ascuns) = 1, '*', ''), Moneda))
						) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_TipMoneda') AS J
				FROM Dosar_TipMoneda 
				WHERE IDTC = pIDTC 
				ORDER BY Ascuns, Moneda
		) Q

		UNION ALL

		-- Dosar_TipCredit
		SELECT C, V, J FROM (
				SELECT 'IdTipCredit' AS C, 
						JSON_ARRAYAGG(
								JSON_OBJECT('IdTipCredit', IdTipCredit, 'TipCredit', CONCAT(IF(ABS(Ascuns) = 1, '*', ''), TipCredit))
						) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_TipCredit') AS J
				FROM Dosar_TipCredit 
				WHERE IDTC = pIDTC 
				ORDER BY Ascuns, TipCredit
		) Q

		UNION ALL

		-- Dosar_Stare
		SELECT C, V, J FROM (
				SELECT 'IdStare' AS C, 
						JSON_ARRAYAGG(
								JSON_OBJECT('IdStare', IdStare, 'Stare', CONCAT(IF(ABS(Ascuns) = 1, '*', ''), Stare))
						) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_Stare') AS J
				FROM Dosar_Stare 
				ORDER BY Stare
		) Q

		UNION ALL

		-- Dosar_TipImobil
		SELECT C, V, J FROM (
				SELECT 'IdTipImobil' AS C, 
						JSON_ARRAYAGG(
								JSON_OBJECT('IdTipImobil', IdTipImobil, 'TipImobil', CONCAT(IF(ABS(Ascuns) = 1, '*', ''), TipImobil))
						) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_TipImobil') AS J
				FROM Dosar_TipImobil 
				ORDER BY Ascuns, TipImobil
		) Q
		
		UNION ALL

		-- Sucursale (view)
		SELECT C,V,J FROM (SELECT 'IdSucursala' as C, JSON_ARRAYAGG(JSON_OBJECT("IdSucursala",IdSucursala,"Sucursala",CONCAT(IF(ABS(Ascuns)=1,'*',''),Sucursala), 'Judet', Judet, 'Orasul', Orasul, 'IdBanca', IdBanca)) as V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'viewSucursale') AS J FROM viewSucursale ORDER BY Ascuns ) Q 
		UNION ALL 

		SELECT C,V,J FROM (SELECT 'IdNotar' AS C, JSON_ARRAYAGG(JSON_OBJECT('IdNotar',IdNotar,'Notar',CONCAT(IF(ABS(Ascuns)=1,'*',''),Notar))) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'viewNotari') AS J FROM Dosar_Notari ORDER BY Ascuns,Notar) Q

		UNION ALL 

		SELECT C,V,J FROM (SELECT 'IdEvaluator' as C, JSON_ARRAYAGG(JSON_OBJECT('IdEvaluator', IdEvaluator, 'Evaluator', UCASE(CONCAT(IF(ABS(Ascuns)=1,'*',''),Evaluator)))) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'viewEvaluatori') AS J FROM Dosar_Evaluatori ORDER BY Ascuns, Evaluator) Q
		
		UNION ALL 
		
		SELECT C,V,J FROM (SELECT 'IdFunctieFunctie' AS C, JSON_ARRAYAGG(JSON_OBJECT('IdFunctieFunctie',IdFunctieFunctie,'Functie',CONCAT(IF(ABS(Ascuns)=1,'*',''),Functie))) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_Functii_Functie') AS J FROM Dosar_Functii_Functie ORDER BY Ascuns,Functie) Q

		UNION ALL 
		
		SELECT C,V,J FROM (SELECT 'IdCompanie' AS C, JSON_ARRAYAGG(JSON_OBJECT('IdCompanie',IdCompanie,'Companie',CONCAT(IF(ABS(Ascuns)=1,'*',''),Companie))) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_Functii_Companie') AS J FROM Dosar_Functii_Companie ORDER BY Ascuns,Companie) Q

		UNION ALL 
		
		SELECT C,V,J FROM (SELECT 'IdDomeniu' AS C, JSON_ARRAYAGG(JSON_OBJECT('IdDomeniu',IdDomeniu,'Domeniu',CONCAT(IF(ABS(Ascuns)=1,'*',''),Domeniu))) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_Functii_Domeniu') AS J FROM Dosar_Functii_Domeniu ORDER BY Ascuns,Domeniu) Q

		UNION ALL 
		
		SELECT C,V,J FROM (SELECT 'IdTipCompanie' AS C, JSON_ARRAYAGG(JSON_OBJECT('IdTipCompanie',IdTipCompanie,'TipCompanie',CONCAT(IF(ABS(Ascuns)=1,'*',''),TipCompanie))) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_Functii_Functie') AS J FROM Dosar_Functii_TipCompanie ORDER BY Ascuns,TipCompanie) Q

		UNION ALL

		SELECT C, V, J FROM (
				SELECT 'IdStatusFeedback' AS C, 
						JSON_ARRAYAGG(
								JSON_OBJECT('IdStatusFeedback', IdStatusFeedback, 'FelStatusFeedback', FelStatusFeedback, 'BackColorFeedback', `BackColorFeedback`)
						) AS V,
						(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
						 FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_FeedBack_Status') AS J
				FROM Dosar_FeedBack_Status 
				ORDER BY FelStatusFeedback
		) Q
	) M
	ORDER BY C
	;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procDosar_JOINS_COND
-- ----------------------------
DROP PROCEDURE IF EXISTS `procDosar_JOINS_COND`;
delimiter ;;
CREATE PROCEDURE `procDosar_JOINS_COND`(IN `pIDTC` INT, IN `pIdBanca` INT, IN `pIdJudet` INT)
  READS SQL DATA 
BEGIN

SELECT C,V,J FROM (SELECT 'IdSucursala' as C, JSON_ARRAYAGG(JSON_OBJECT("IdSucursala",IdSucursala,"Sucursala",CONCAT(IF(ABS(Sucursale.Ascuns)=1,'*',''),Sucursala, ' - ', Judet))) as V,
        (SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
         FROM TABLES_INFO WHERE TABLE_NAME = 'Sucursale') AS J FROM Sucursale INNER JOIN Judete USING (IdJudet) WHERE IdJudet=pIdJudet AND IdBanca=pIdBanca ORDER BY Sucursale.Ascuns,Sucursala,Orasul) Q

UNION ALL 

SELECT C,V,J FROM (SELECT 'IdNotar' AS C, JSON_ARRAYAGG(JSON_OBJECT('IdNotar',IdNotar,'Notar',CONCAT(IF(ABS(Ascuns)=1,'*',''),Notar))) AS V,
        (SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
         FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_Notari') AS J FROM Dosar_Notari WHERE IdJudet=pIdJudet ORDER BY Ascuns,Notar) Q

UNION ALL 

SELECT C,V,J FROM (SELECT 'IdEvaluator' as C, JSON_ARRAYAGG(JSON_OBJECT('IdEvaluator', IdEvaluator, 'Den_Evaluator', UCASE(CONCAT(IF(ABS(Ascuns)=1,'*',''),Evaluator)))) AS V,
        (SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
         FROM TABLES_INFO WHERE TABLE_NAME = 'Dosar_Evaluatori') AS J FROM Dosar_Evaluatori WHERE IdJudet = pIdJudet ORDER BY Ascuns, Evaluator) Q

;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procDosar_Mod
-- ----------------------------
DROP PROCEDURE IF EXISTS `procDosar_Mod`;
delimiter ;;
CREATE PROCEDURE `procDosar_Mod`(IN `TIP` VARCHAR (255),
	IN `IdDosar` VARCHAR (255),
	IN `IdBaza` VARCHAR (255),
	IN `IdClient` VARCHAR (255),
	IN `IdConsultant` VARCHAR (255),
	IN `IdSursa` VARCHAR (255),
	IN `IdAgent` VARCHAR (255),
	IN `IdStatus` VARCHAR (255),
	IN `IdStare` VARCHAR (255),
	IN `Codebitor` VARCHAR (255),
	IN `NumeCodebitor` VARCHAR (255),
	IN `IdMotiv` VARCHAR (255),
	IN `ObservatiiFinale` VARCHAR (2000),
	IN `JSONVenit` JSON, -- 	IN `IdVenit` VARCHAR (255),	IN `Venit` VARCHAR (255), 	IN `TipCredit` VARCHAR (255),	IN `IdTipMoneda` VARCHAR (255),	IN `PerioadaCredit` VARCHAR (255),	IN `ValoareCredit` VARCHAR (255),	IN `IdTipDobanda` VARCHAR (255),	IN `Dobanda` VARCHAR (255),	IN `CursMoneda` DOUBLE,
	IN `JSONBanca` JSON, -- 	IN `IdBanca` VARCHAR (255),	IN `IdSucursala` VARCHAR (255),	IN `ConsilierBanca` VARCHAR (255),	IN `CodBanca` VARCHAR (255),
	IN `JSONFunctie` VARCHAR(2000), -- IN `IdFunctie` VARCHAR (255),IN `IdFunctieFunctie` VARCHAR (255),IN `IdCompanie` VARCHAR (255),IN `IdDomeniu` VARCHAR (255),IN `Domeniu` VARCHAR (255),IN `Functie` VARCHAR (255),IN `Companie` VARCHAR (255),IN `TipCompanie` VARCHAR (255),
	IN `JSONDate` JSON, -- IN `DataDebursare` VARCHAR (255),	IN `DataRespingere` VARCHAR (255), IN `DataOpinieJ` VARCHAR (255), IN `DataPreaprobare` VARCHAR (255), IN `DataTrimitere` VARCHAR (255)
	OUT `OUT` VARCHAR (2000))
BEGIN
	DECLARE num_items INT;
	DECLARE i INT DEFAULT 0;
	DECLARE pfn VARCHAR(10);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","");
		ROLLBACK;
	END;

	SET @ERRMSG="START";

	SET @TIP = IFNULL(`TIP`,'');
	-- extract json
	-- Functie
	SET @IdFunctie = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdFunctie')) AS INT);
	SET pfn=CAST(IFNULL(@IdFunctie,0) AS INT);
	SET @IdCompanie = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdCompanie')) AS INT);
	SET @IdDomeniu = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdDomeniu')) AS INT);
	SET @IdFunctieFunctie = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdFunctieFunctie')) AS INT);
	SET @IdTipCompanie = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdTipCompanie')) AS INT);

	-- Banca
	SET @IdBanca = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdBanca')) AS INT);
	SET @IdSucursala = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdSucursala')) AS INT);
	SET @ConsilierBanca = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.ConsilierBanca')), 'null');
	SET @CodBanca = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.CodBanca')), 'null');
	SET @CursMoneda = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.CursMoneda')), 'null') AS DOUBLE);
	SET @IdNotar = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdNotar')),'');
	SET @IdEvaluator = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdEvaluator')),'');
	-- Venit
	SET @IdVenit = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdVenit')) AS INT);
	SET @Venit = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.Venit')) AS INT);

	SET @IdTipImobil = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipImobil')) AS INT);
	SET @AreImobil = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.AreImobil')) AS INT);
	SET @ValoareImobil = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.ValoareImobil')) AS INT);
	
	SET @IdTipCredit = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipCredit')) AS INT);
	SET @PerioadaCredit = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.PerioadaCredit')) AS INT);
	SET @IdTipMoneda = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipMoneda')) AS INT);
	SET @ValoareCredit = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.ValoareCredit')) AS INT);
	SET @ValoareCreditRON = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.ValoareCreditRON')) AS INT);
	
	SET @IdTipDobanda = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipDobanda')) AS INT);
	SET @Dobanda = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.Dobanda')),0),'NULL');
	SET @MarjaDobanda = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.MarjaDobanda')),0),'NULL');
	SET @MarjaDobandaDF = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.MarjaDobandaDF')),0),'NULL');
	SET @PerioadaDobanda = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.PerioadaDobanda')),0),'NULL');

	-- Date
	SET @DataDebursare = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataDebursare')), 'null'),'null');
	SET @DataRespingere =IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataRespingere')), 'null'),'null');
	SET @DataOpinieJ = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataOpinieJ')), 'null'),'null');
	SET @DataPreaprobare = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataPreaprobare')), 'null'),'null');
	SET @DataTrimitere = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataTrimitere')), 'null'),'null');

	IF IFNULL(@DataDebursare,'null')<>'null' THEN SET @DataDebursare=CONCAT("'",@DataDebursare,"'"); END IF;
	IF IFNULL(@DataRespingere,'null')<>'null' THEN SET @DataRespingere=CONCAT("'",@DataRespingere,"'"); END IF;
	IF IFNULL(@DataOpinieJ,'null')<>'null' THEN SET @DataOpinieJ=CONCAT("'",@DataOpinieJ,"'"); END IF;
	IF IFNULL(@DataPreaprobare,'null')<>'null' THEN SET @DataPreaprobare=CONCAT("'",@DataPreaprobare,"'"); END IF;
	IF IFNULL(@DataTrimitere,'null')<>'null' THEN SET @DataTrimitere=CONCAT("'",@DataTrimitere,"'"); END IF;
	
	-- iduri
	SET @IdDosar = CAST(IdDosar as INT);
	SET @IdStatus = CAST(IdStatus AS INT);
	SET @IdStare = CAST(IdStare AS INT);
	SET @IdMotiv = IFNULL(NULLIF(CAST(IdMotiv AS INT),''),'null');
	
	-- alti parametri
	SET @Codebitor = CAST(Codebitor AS INT);
	SET @NumeCodebitor = NULLIF(QUOTE(NumeCodebitor),'');
	SET @ObservatiiFinale = NULLIF(QUOTE(ObservatiiFinale),'');
	
	SET @ERRMSG=NULL;

	-- SELECT  @TIP, CAST(JSON_OBJECT('IdFunctie',@IdFunctie,'IdCompanie',@IdCompanie,'IdDomeniu',@IdDomeniu,'IdFunctieFunctie',@IdFunctieFunctie,'IdTipCompanie',@IdTipCompanie,'IdBanca',@IdBanca,'IdSucursala',@IdSucursala,'ConsilierBanca',@ConsilierBanca,'CodBanca',@CodBanca,'CursMoneda',@CursMoneda,'IdVenit',@IdVenit,'Venit',@Venit,'IdTipImobil',@IdTipImobil,'AreImobil',@AreImobil,'ValoareImobil',@ValoareImobil,'IdTipCredit',@IdTipCredit,'PerioadaCredit',@PerioadaCredit,'IdTipMoneda',@IdTipMoneda,'ValoareCredit',@ValoareCredit,'IdTipDobanda',@IdTipDobanda,'Dobanda',@Dobanda,'MarjaDobanda',@MarjaDobanda,'MarjaDobandaDF',@MarjaDobandaDF,'PerioadaDobanda',@PerioadaDobanda,'DataDebursare',@DataDebursare,'DataRespingere',@DataRespingere,'DataOpinieJ',@DataOpinieJ,'DataPreaprobare',@DataPreaprobare,'DataTrimitere',@DataTrimitere,'IdDosar',@IdDosar,'IdStatus',@IdStatus,'IdStare',@IdStare,'IdMotiv',@IdMotiv,'Codebitor',@Codebitor,'NumeCodebitor',@NumeCodebitor,'ObservatiiFinale',@ObservatiiFinale,'IdNotar',@IdNotar,'IdEvaluator',@IdEvaluator) AS VARCHAR(2000)) AS json_result, pfn, 'TEST' as TblName;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	START TRANSACTION;
	
	IF IFNULL(@IdFunctie,'')='' THEN -- se adauga functie noua
		SET @ERRMSG='ADD_FUNCTIE';
		
		SET @sql = "INSERT INTO Dosar_Functii (IdClient,IdFunctieFunctie,IdDomeniu,IdCompanie,IdTipCompanie) SELECT ?,?,?,?,?;";
		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @IdClient,@IdFunctieFunctie,@IdDomeniu,@IdCompanie,@IdTipCompanie;
		DEALLOCATE PREPARE stmt;

		SET @IdFunctie=LAST_INSERT_ID();
	END IF;
					
	SET @ERRMSG='MOD_DOSAR'; -- modificare Dosar

	SET @sql = CONCAT_WS("",
			"UPDATE Dosar SET ",
			"IdBanca = ", @IdBanca, ", ",
			"IdSucursala = ", @IdSucursala, ", ",
			"ConsilierBanca = '", @ConsilierBanca, "', ",
			"CodBanca = '", @CodBanca, "', ",
			"IdEvaluator = ", @IdEvaluator, ", ",
			"IdNotar = ", @IdNotar, ", ",
			"IdFunctie = ", @IdFunctie, ", ",
			"IdFunctieFunctie = ", @IdFunctieFunctie, ", ",
			"IdDomeniu = ", @IdDomeniu, ", ",
			"IdCompanie = ", @IdCompanie, ", ",
			"IdTipCompanie = ", @IdTipCompanie, ", ",
			"IdStare = ", @IdStare, ", ",
			"IdStatus = ", @IdStatus, ", ",
			"IdMotiv = ", @IdMotiv, ", ",
			"IdVenit = ", @IdVenit, ", ",
			"Venit = ", @Venit, ", ",
			"IdTipImobil = ", @IdTipImobil, ", ",
			"AreImobil = ", @AreImobil, ", ",
			"ValoareImobil = ", @ValoareImobil, ", ",
			"IdTipCredit = ", @IdTipCredit, ", ",
			"IdTipMoneda = ", @IdTipMoneda, ", ",
			"PerioadaCredit = ", @PerioadaCredit, ", ",
			"ValoareCredit = ", @ValoareCredit, ", ",
			"ValoareCreditRON = ", @ValoareCreditRON, ", ",
			"CursMoneda = ", @CursMoneda, ", ",
			"IdTipDobanda = ", @IdTipDobanda, ", ",
			"Dobanda = ", @Dobanda, ", ",
			"MarjaDobanda = ", @MarjaDobanda, ", ",
			"MarjaDobandaDF = ", @MarjaDobandaDF, ", ",
			"PerioadaDobanda = ", @PerioadaDobanda, ", ",
			"Codebitor = ", @Codebitor, ", ",
			"NumeCodebitor = ", @NumeCodebitor, ", ",
			"DataPreaprobare = ", @DataPreaprobare, ", ",
			"DataOpinieJ = ", @DataOpinieJ, ", ",
			"DataTrimitere = ", @DataTrimitere, ", ",
			"DataDebursare = ", @DataDebursare, ", ",
			"DataRespingere = ", @DataRespingere, ", ",
			"ObservatiiFinale = ", @ObservatiiFinale, " ",
			"WHERE IdDosar = ", @IdDosar
	);
	-- SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	-- ROLLBACK;
	COMMIT;
	SET `OUT`=JSON_OBJECT('IdDosar',@IdDosar,'IdFunctie',@IdFunctie,'IdFeedBack',@IdFeedBack);	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procDosar_Row
-- ----------------------------
DROP PROCEDURE IF EXISTS `procDosar_Row`;
delimiter ;;
CREATE PROCEDURE `procDosar_Row`(IN `pIdDosar` VARCHAR(255), OUT `OUT` VARCHAR(200))
BEGIN
	DECLARE start_time_numeric BIGINT;
	DECLARE end_time_numeric BIGINT;

	-- Record the start time for profiling
	SET start_time_numeric = UNIX_TIMESTAMP(NOW(6)) * 1000000;

	SET @sql = CONCAT ("SELECT * FROM viewDosar WHERE IdDosar IN (", pIdDosar, ") ORDER BY IdDosar DESC");

	PREPARE stmt FROM @sql;
	EXECUTE stmt;
 	DEALLOCATE PREPARE stmt;

	-- Record the end time for profiling
	SET end_time_numeric = UNIX_TIMESTAMP(NOW(6)) * 1000000;
	
	-- Calculate and store the execution time in microseconds
	SET `OUT` =  end_time_numeric - start_time_numeric;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procExcel_Export
-- ----------------------------
DROP PROCEDURE IF EXISTS `procExcel_Export`;
delimiter ;;
CREATE PROCEDURE `procExcel_Export`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(2000),
    IN `MaxRecords` VARCHAR(10),
		IN `Coloane` VARCHAR(2000))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	DECLARE `Sort` VARCHAR(100);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET MaxRecords = CAST(COALESCE(NULLIF(MaxRecords,''),200) AS INT);
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');
	SET Sort=IF(ViewName='viewBaza','IdBaza DESC','IdDosar DESC');

	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
				SELECT * FROM (
					SELECT ", Coloane, "
					FROM ", ViewName, " 
					WHERE ", Filtru, "
					ORDER BY ", Sort, "
				) T ",
				IF(MaxRecords<0,"", CONCAT("LIMIT ", MaxRecords))
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
				SELECT * FROM (
					SELECT ", Coloane, "
					FROM ", ViewName, " v JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
					WHERE cc.IdCopil=", IDC," AND ", Filtru, "
					ORDER BY ", Sort, " 
				) T ",
				IF(MaxRecords<0,"", CONCAT("LIMIT ", MaxRecords))
				);
  -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procExcel_Export_2025
-- ----------------------------
DROP PROCEDURE IF EXISTS `procExcel_Export_2025`;
delimiter ;;
CREATE PROCEDURE `procExcel_Export_2025`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(5000),
    IN `MaxRecords` VARCHAR(10),
		IN `Coloane` VARCHAR(5000))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(5000);
	DECLARE `OUT` VARCHAR(5000);
	DECLARE `Sort` VARCHAR(100);
	DECLARE LimitClause VARCHAR(255);
	DECLARE ViewID      VARCHAR(100);

	-- Filter testing against injection
	DECLARE flt_bad     BOOLEAN DEFAULT FALSE;
	DECLARE flt_errmsg  TEXT;
	-- Coloane testing against injection
	DECLARE col_bad     BOOLEAN DEFAULT FALSE;
	DECLARE col_errmsg  TEXT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
	END;
	
	SET SESSION group_concat_max_len = 5000;
	
	-- Build LIMIT / OFFSET
	IF LimitClause IS NULL OR LimitClause='' THEN
			SET LimitClause='';

	ELSEIF LOCATE(',', MaxRecords) > 0 THEN
			SET LimitClause = CONCAT(
					'LIMIT ',
					SUBSTRING_INDEX(MaxRecords, ',', 1),
					' OFFSET ',
					SUBSTRING_INDEX(MaxRecords, ',', -1)
			);
	ELSEIF CAST(MaxRecords AS int) <> -1 THEN
			SET LimitClause = CONCAT('LIMIT ', MaxRecords);

	END IF;

	-- Defaults
	SET Sort   = IFNULL(
			NULLIF(Sort, ''),
			CASE 
					WHEN LEFT(ViewName,8) = 'viewBaza'      THEN ' IdBaza DESC'
					WHEN LEFT(ViewName,9) = 'viewDosar'     THEN ' IdDosar DESC'
					WHEN LEFT(ViewName,13) = 'viewIpotecare' THEN ' ID DESC'
			END
	);

	IF ISNULL(Filtru) THEN
		SET Filtru="";
	END IF;
	
	IF Filtru <> "" THEN
		BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '42S22'  -- unknown column
				SET flt_bad = TRUE;

			SET @test_flt = CONCAT(
				'SELECT 1 INTO @flt_dummy FROM ', CONCAT(ViewName,"_export"),
				' WHERE ', Filtru, 
				' LIMIT 0'
			);
			PREPARE _flt FROM @test_flt;
			EXECUTE _flt;
			DEALLOCATE PREPARE _flt;
		END;

		IF flt_bad THEN
			SET flt_errmsg = CONCAT('Invalid filter, unknown column in: ', Filtru);
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = flt_errmsg;
		END IF;
	END IF;

	BEGIN
		DECLARE CONTINUE HANDLER FOR SQLSTATE '42S22'  -- unknown column
			SET col_bad = TRUE;

		SET @test_col = CONCAT(
			'SELECT CONCAT(', Coloane, ') INTO @col_dummy FROM ', CONCAT(ViewName,"_export"),
			' LIMIT 0'
		);
		PREPARE _col FROM @test_col;
		EXECUTE _col;
		DEALLOCATE PREPARE _col;
	END;

	IF col_bad THEN
		SET col_errmsg = CONCAT('Coloane invalide: ', Coloane);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = col_errmsg;
	END IF;
	
	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
				SELECT ", Coloane, " FROM ", CONCAT(ViewName, "_export"), " ",	IF(Filtru="","",CONCAT("WHERE ", Filtru)) , " ORDER BY ", Sort, " ", LimitClause
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
				SELECT ", Coloane, " FROM ", CONCAT(ViewName, "_export"), " v JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil WHERE cc.IdCopil=", IDC, " ", IF(Filtru="","",CONCAT(" AND ", Filtru)), " ORDER BY ", Sort, " ", LimitClause
				);
  -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procFilter
-- ----------------------------
DROP PROCEDURE IF EXISTS `procFilter`;
delimiter ;;
CREATE PROCEDURE `procFilter`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filter` VARCHAR(16000),
		IN `Col` VARCHAR(1000),
		IN `GroupBy` VARCHAR(1000),
		IN `OrderBy` VARCHAR(1000))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET lc_time_names = 'ro_RO';
	SET Filter=IFNULL(NULLIF(Filter,''),'1=1');
	SET GroupBy=IFNULL(NULLIF(GroupBy,''),'1');
	SET OrderBy=IFNULL(NULLIF(OrderBy,''),'1');

	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
					SELECT ", Col, "
					FROM ", ViewName, " 
					WHERE ", Filter, "
					GROUP BY ", GroupBy, "
					ORDER BY ", OrderBy
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
					SELECT ", Col, "
					FROM ", ViewName, " v
					JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
					WHERE cc.IdCopil=", IDC," AND ", Filter, "
					GROUP BY ", GroupBy, "
					ORDER BY ", OrderBy
				);
   -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procFilter_Agenti
-- ----------------------------
DROP PROCEDURE IF EXISTS `procFilter_Agenti`;
delimiter ;;
CREATE PROCEDURE `procFilter_Agenti`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(1000))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');

	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
					SELECT IdAgent,NumeAgent,aTelefon,aMail,IdSursa
					FROM ", ViewName, " 
					WHERE ", Filtru, "
					GROUP BY IdAgent
					ORDER BY Sursa, IdSursa, NumeAgent, IdAgent"
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
					SELECT IdAgent,NumeAgent,aTelefon,aMail,IdSursa
					FROM ", ViewName, " v
					JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
					WHERE cc.IdCopil=", IDC," AND ", Filtru, "
					GROUP BY IdAgent
					ORDER BY Sursa, IdSursa, NumeAgent, IdAgent"
				);
   -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procFilter_Banci
-- ----------------------------
DROP PROCEDURE IF EXISTS `procFilter_Banci`;
delimiter ;;
CREATE PROCEDURE `procFilter_Banci`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(1000))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');

	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
					SELECT IdBanca,Banca
					FROM ", ViewName, " 
					WHERE ", Filtru, "
					GROUP BY Banca
					ORDER BY Banca"
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
					SELECT IdBanca,Banca
					FROM ", ViewName, " v
					JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
					WHERE cc.IdCopil=", IDC," AND ", Filtru, "
					GROUP BY Banca
					ORDER BY Banca"
				);
   -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procFilter_Consultanti
-- ----------------------------
DROP PROCEDURE IF EXISTS `procFilter_Consultanti`;
delimiter ;;
CREATE PROCEDURE `procFilter_Consultanti`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(1000))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');

	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
				SELECT IdConsultant, NumeConsultant, cTelefon, cMail, IdNivel, IdParinte FROM (
					SELECT IdConsultant, NumeConsultant, cTelefon, cMail, IdNivel, IdParinte
					FROM ", ViewName, " 
					WHERE ", Filtru, "
					GROUP BY IdConsultant
				) T "
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
				SELECT IdConsultant, NumeConsultant, cTelefon, cMail, IdNivel, IdParinte FROM (
					SELECT IdConsultant, NumeConsultant, cTelefon, cMail, IdNivel, IdParinte
					FROM ", ViewName, " 
					JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
					WHERE cc.IdCopil=", IDC," AND ", Filtru, "
					GROUP BY IdConsultant
				) T "
				);
  -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procFilter_Date
-- ----------------------------
DROP PROCEDURE IF EXISTS `procFilter_Date`;
delimiter ;;
CREATE PROCEDURE `procFilter_Date`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filter` VARCHAR(1000),
		IN `Col` VARCHAR(255))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Coll VARCHAR(255);
	DECLARE `OUT` VARCHAR(2000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET lc_time_names = 'ro_RO';
	SET Filter=IFNULL(NULLIF(Filter,''),'1=1');
	SET Coll=Col;
	-- SET Coll=SUBSTRING_INDEX(Col, ',', -1);
	-- SELECT MaxRecords,Filter,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
				SELECT DataInt, Data, YM, YMN FROM (
					SELECT UNIX_TIMESTAMP(STR_TO_DATE(", Coll, ",'%Y-%m-%d')) as DataInt, DATE_FORMAT(", Coll, ",'%d/%m/%Y') as Data, EXTRACT(YEAR_MONTH FROM ", Coll, ") as YM, CONCAT(YEAR(", Coll, "),'-',MONTHNAME(", Coll, ")) as YMN 
					FROM ", ViewName, " 
					WHERE YEAR(", Coll, ")>=YEAR(NOW())-2 AND ", Filter, "
				) T
				GROUP BY Data
				ORDER BY YM DESC,Data DESC"
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
				SELECT DataInt, Data, YM, YMN	 FROM (
					SELECT UNIX_TIMESTAMP(STR_TO_DATE(", Coll, ",'%Y-%m-%d')) as DataInt, DATE_FORMAT(", Coll, ",'%d/%m/%Y') as Data, EXTRACT(YEAR_MONTH FROM ", Coll, ") as YM, CONCAT(YEAR(", Coll, "),'-',MONTHNAME(", Coll, ")) as YMN 
					FROM ", ViewName, " v
					JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil
					WHERE cc.IdCopil=", IDC," AND YEAR(", Coll, ")>=YEAR(NOW())-2 AND ", Filter, "
				) T
				GROUP BY Data
				ORDER BY YM DESC,Data DESC"
				);
    -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procFilter_Luni
-- ----------------------------
DROP PROCEDURE IF EXISTS `procFilter_Luni`;
delimiter ;;
CREATE PROCEDURE `procFilter_Luni`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(1000))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	DECLARE Col VARCHAR(100);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET lc_time_names = 'ro_RO';
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');
	SET Col=IF(ViewName='viewBaza','DataPrimire','DataIntroducere');
	
	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
				SELECT YM, Data FROM (
					SELECT EXTRACT(YEAR_MONTH FROM ", Col, ") as YM, CONCAT(MONTHNAME(", Col, "), '/', YEAR(", Col, ")) as Data
					FROM ", ViewName, " 
					WHERE YEAR(", Col, ")>=YEAR(NOW())-2 AND ", Filtru, "
				) T
				GROUP BY YM
				ORDER BY YM DESC"
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
				SELECT YM, Data FROM (
					SELECT EXTRACT(YEAR_MONTH FROM ", Col, ") as YM, CONCAT(MONTHNAME(", Col, "), '/', YEAR(", Col, ")) as Data
					FROM ", ViewName, " v
					JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil
					WHERE cc.IdCopil=", IDC," AND YEAR(", Col, ")>=YEAR(NOW())-2 AND ", Filtru, "
				) T
				GROUP BY YM
				ORDER BY YM DESC"
				);
   -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procFilter_Sucursale
-- ----------------------------
DROP PROCEDURE IF EXISTS `procFilter_Sucursale`;
delimiter ;;
CREATE PROCEDURE `procFilter_Sucursale`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(1000))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');

	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
					SELECT IdSucursala, Sucursala, Judet_Banca, Oras_Banca, IdBanca
					FROM ", ViewName, " 
					WHERE ", Filtru, "
					GROUP BY IdSucursala
					ORDER BY Banca, IdBanca, Sucursala, IdSucursala"
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
					SELECT IdSucursala, Sucursala, Judet_Banca, Oras_Banca, IdBanca
					FROM ", ViewName, " v
					JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
					WHERE cc.IdCopil=", IDC," AND ", Filtru, "
					GROUP BY IdSucursala
					ORDER BY Banca, IdBanca, Sucursala, IdSucursala"
				);
   -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procFilter_Sursa
-- ----------------------------
DROP PROCEDURE IF EXISTS `procFilter_Sursa`;
delimiter ;;
CREATE PROCEDURE `procFilter_Sursa`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(1000))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');

	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
					SELECT IdSursa,Sursa
					FROM ", ViewName, " 
					WHERE ", Filtru, "
					GROUP BY IdSursa
					ORDER BY Sursa"
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
					SELECT IdSursa,Sursa
					FROM ", ViewName, " v
					JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
					WHERE cc.IdCopil=", IDC," AND ", Filtru, "
					GROUP BY IdSursa
					ORDER BY Sursa"
				);
   -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procFilter_Zile
-- ----------------------------
DROP PROCEDURE IF EXISTS `procFilter_Zile`;
delimiter ;;
CREATE PROCEDURE `procFilter_Zile`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(1000))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	DECLARE Col VARCHAR(100);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');
	SET Col=IF(ViewName='viewBaza','DataPrimire','DataIntroducere');
	
	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
				SELECT DataInt, Data, YM FROM (
					SELECT UNIX_TIMESTAMP(STR_TO_DATE(", Col, ",'%Y-%m-%d')) as DataInt, DATE_FORMAT(", Col, ",'%d/%m/%Y') as Data, EXTRACT(YEAR_MONTH FROM ", Col, ") as YM
					FROM ", ViewName, " 
					WHERE YEAR(", Col, ")>=YEAR(NOW())-2 AND ", Filtru, "
				) T
				GROUP BY Data
				ORDER BY YM DESC,Data DESC"
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
				SELECT DataInt, Data, YM FROM (
					SELECT UNIX_TIMESTAMP(STR_TO_DATE(", Col, ",'%Y-%m-%d')) as DataInt, DATE_FORMAT(", Col, ",'%d/%m/%Y') as Data, EXTRACT(YEAR_MONTH FROM ", Col, ") as YM
					FROM ", ViewName, " v
					JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil
					WHERE cc.IdCopil=", IDC," AND YEAR(", Col, ")>=YEAR(NOW())-2 AND ", Filtru, "
				) T
				GROUP BY Data
				ORDER BY YM DESC,Data DESC"
				);
   -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procFiltru_Baza
-- ----------------------------
DROP PROCEDURE IF EXISTS `procFiltru_Baza`;
delimiter ;;
CREATE PROCEDURE `procFiltru_Baza`(IN `pIDC` INT, IN `pSort` VARCHAR(255), IN `pFilter` VARCHAR (2000))
BEGIN
    -- Variable declarations
    SET @Sortare = IF(IFNULL(pSort,"")=""," IdBaza DESC ",pSort);
    SET @Filtru = IF(IFNULL(pFilter,"")="","1",pFilter);
    SET @NIV=0;
    SET @IDC="";

	-- Fetch consultant level
	SELECT IdNivel INTO @NIV FROM Consultanti WHERE IdConsultant=`pIDC`;

	-- Determine filtering condition based on consultant level
	CASE 
			WHEN @NIV <= 10 THEN SET @IDC = CONCAT("=",`pIDC`);
					
			WHEN @NIV > 10 AND @NIV <= 30 THEN
					-- For level 11 to 30, fetch related IDs
					SELECT CONCAT_WS(",",`pIDC`,GROUP_CONCAT(IdCopil)) INTO @IDC FROM Consultanti_Relatii WHERE IdParinte=`pIDC`;

					IF IFNULL(@IDC,'')='' THEN 
							SET @IDC= CONCAT("=",`pIDC`);
					ELSE    
							IF RIGHT(@IDC,1)="," THEN
									SET @IDC = CONCAT("IN (", MID(@IDC,1,LENGTH(@IDC)-1), ")");
							ELSE
									SET @IDC = CONCAT("IN (", @IDC, ")");            
							END IF;
					END IF;
					
			WHEN @NIV > 30 AND @NIV < 40 THEN
					-- For level 31 to 40, fetch related IDs by IdRegiune
					SELECT CONCAT_WS(",",`pIDC`,GROUP_CONCAT(IdConsultant)) INTO @IDC FROM Consultanti WHERE IdRegiune IN (SELECT IdRegiune FROM Consultanti WHERE IdConsultant=`pIDC`);

					IF IFNULL(@IDC,'')='' THEN 
							SET @IDC= CONCAT("=",`pIDC`);
					ELSE    
							IF RIGHT(@IDC,1)="," THEN
									SET @IDC = CONCAT("IN (", MID(@IDC,1,LENGTH(@IDC)-1), ")");
							ELSE
									SET @IDC = CONCAT("IN (", @IDC, ")");            
							END IF;
					END IF;
	
			WHEN @NIV >=40 AND @NIV <= 50 THEN SET @IDC = "LIKE '%'";
	END CASE;
		
	SET @sql = CONCAT("
			SELECT * FROM (
				SELECT
						B.`IdBaza` AS `IdBaza`,
						B.`IdAgent` AS `IDAgent`,
						B.`IdSursa` AS `IdSursa`,
						B.`IdConsultant` AS `IdConsultant`,
						B.`IdClient` AS `IdClient`,
						B.`DataPrimire` AS `DataPrimire`,
						C.`NumeClient` AS `NumeClient`,
						C.`TelefonP` AS `TelefonClient`,
						C.`EmailP` AS `EmailClient`,
						C.`CNPClient` AS `CNPClient`,
						C.`SMS` AS `SMS`,
						C.`DataNastere` AS `DataNastere`,
						C.`IdJudet` AS `IdJudet`,
						CO.`NumeConsultant` AS `NumeConsultant`,
						CO.`cTelefon` AS `cTelefon`,
						CO.`cMail` AS `cMail`,
						SL.`Sursa` AS `Sursa`,
						A.`NumeAgent` AS `NumeAgent`,
						A.`aTelefon` AS `aTelefon`,
						A.`aMail` AS `aMail`,
						FB.`IdFeedBack` AS `IdFeedBack`,
						BS.`IdStatus` AS `IdStatus`,
						BS.`IDSG` AS `IDSG`,
						BS.`FelStatus` AS `FelStatus`,
						BS.`TipStatus` AS `TipStatus`,
						BS.`BackColor` AS `BackColor`,
						FB.`DataConectare` AS `DataConectare`,
						FB.`Feedback` AS `FeedBack`,
						FB.`DataReconectare` AS `DataReconectare`,
						TO_DAYS(CURRENT_TIMESTAMP()) - TO_DAYS(FB.`DataReconectare`) AS `Dif`,
						TO_DAYS(CURRENT_TIMESTAMP()) - TO_DAYS(C.`DataNastere` + INTERVAL YEAR(CURDATE()) - YEAR(C.`DataNastere`) YEAR) AS `DifN`,
						TO_DAYS(CURRENT_TIMESTAMP()) - TO_DAYS(B.`DataPrimire`) AS `DifC`,
						CASE
								WHEN TO_DAYS(CURRENT_TIMESTAMP()) - TO_DAYS(FB.`DataReconectare`) = 0 THEN 1
								WHEN TO_DAYS(CURRENT_TIMESTAMP()) - TO_DAYS(FB.`DataReconectare`) = -1 THEN 2
								WHEN TO_DAYS(CURRENT_TIMESTAMP()) - TO_DAYS(FB.`DataReconectare`) = -2 THEN 2
								WHEN TO_DAYS(CURRENT_TIMESTAMP()) - TO_DAYS(FB.`DataReconectare`) = -3 THEN 2
								WHEN TO_DAYS(CURRENT_TIMESTAMP()) - TO_DAYS(FB.`DataReconectare`) > 0 THEN 0
								ELSE 3
						END AS `DIFF`
				FROM
						(
								(
										(
												(
														(
																`Baza` B
																JOIN `Clienti` C ON B.`IdClient` = C.`IdClient`
														)
														JOIN `SursaLead` SL ON B.`IdSursa` = SL.`IdSursa`
												)
												JOIN `Consultanti` CO ON B.`IdConsultant` = CO.`IdConsultant`
										)
										JOIN `Agenti` A ON B.`IdAgent` = A.`IdAgent`
								)
								JOIN `Baza_FeedBack` FB ON B.`IdBaza` = FB.`IdBaza`
						)
						JOIN `Baza_Status` BS ON FB.`IdStatus` = BS.`IdStatus`
				WHERE
						B.`Ascuns` = 0
						AND B.IdConsultant ", @IDC, "
			) T 
			WHERE ", @Filtru, "
			ORDER BY ", @Sortare, ";"
	);
	
	-- SELECT @sql;
	
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
 	DEALLOCATE PREPARE stmt;


END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procFormatConditions_Status
-- ----------------------------
DROP PROCEDURE IF EXISTS `procFormatConditions_Status`;
delimiter ;;
CREATE PROCEDURE `procFormatConditions_Status`(IN `pSelTab` VARCHAR ( 255 ))
BEGIN
	IF pSelTab='nvB1' THEN
		SET @BD='Baza';
	ELSE
		SET @BD='Dosar';
	END IF;
	
	SET @sql = CONCAT ("
		SELECT 
			*, 
			0 as OnOff,
			CAST(ROW_NUMBER() OVER(ORDER BY IdStatus) AS INTEGER) as Pozitie
		FROM
			(
			SELECT
				IdStatus,
				IDSG,
				Grup,
				FelStatus,
				BackColor,
				ForeColor,
				TipStatus,",
				@BD, "_Status.Ascuns,
				JSON_OBJECT('FontName',FontName,'FontSize',FontSize,'FontBold',FontBold,'FontItalic',FontItalic,'FontUnderline',FontUnderline,'FontColor',FontColor) as Font,
				JSON_OBJECT('BackColor',BackColor,'ForeColor',ForeColor,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828) as Color
			FROM
				`", @BD, "_Status` INNER JOIN `", @BD, "_Status_Grup` USING (IDSG)
			ORDER BY
				IDSG,IdStatus
			) as T
		");		

	PREPARE stmt FROM @sql;
	EXECUTE stmt;
 	DEALLOCATE PREPARE stmt;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procGetFieldsInTable
-- ----------------------------
DROP PROCEDURE IF EXISTS `procGetFieldsInTable`;
delimiter ;;
CREATE PROCEDURE `procGetFieldsInTable`(IN `pTableName` varchar(255), IN `pColName` VARCHAR(255))
BEGIN
    SET @sql = CONCAT('SELECT IF(INFORMATION_SCHEMA.COLUMNS.COLUMN_NAME="',pColName,'",1,0) as S,INFORMATION_SCHEMA.COLUMNS.COLUMN_NAME,COLUMN_DESC,COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS LEFT JOIN Coloane_DESC ON INFORMATION_SCHEMA.COLUMNS.COLUMN_NAME = Coloane_DESC.COLUMN_NAME WHERE TABLE_NAME = "', pTableName, '" ORDER BY IF(LEFT(Coloane_DESC.COLUMN_NAME,2)="ID",1,0),Coloane_DESC.COLUMN_NAME');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procGet_Online_Data
-- ----------------------------
DROP PROCEDURE IF EXISTS `procGet_Online_Data`;
delimiter ;;
CREATE PROCEDURE `procGet_Online_Data`(OUT `OUT` VARCHAR (255))
  READS SQL DATA 
BEGIN
	DECLARE countInserted INT;

	INSERT INTO `Online` ( IdOnline, IdJudet, Judet, Nume, Prenume, Email, Telefon, NewsLetter, DataPrimire ) SELECT
	IdOnline,
	IdJudet,
	Parsed_WP.Judet,
	Nume,
	Prenume,
	Email,
	Telefon,
	NewsLetter,
	DataPrimire
	FROM
		(
		SELECT
			id AS IdOnline,
			JSON_VALUE( response, '$.dropdown' ) AS Judet,
			JSON_VALUE( response, '$.names.first_name' ) AS Nume,
			JSON_VALUE( response, '$.names.last_name' ) AS Prenume,
			JSON_VALUE( response, '$.email' ) AS Email,
			JSON_VALUE( response, '$.phone' ) AS Telefon,
		CASE
				WHEN JSON_QUERY( response, '$.checkbox' ) IS NOT NULL THEN 1 
				ELSE 0 
		END AS NewsLetter,
		created_at as DataPrimire
		FROM
			WP_ONLINE 
		WHERE
			IFNULL( JSON_VALUE( response, '$.dropdown' ), '' )<> '' 
		) AS Parsed_WP
		INNER JOIN Judete ON Parsed_WP.Judet = Judete.Judet 
WHERE
	IdOnline NOT IN ( SELECT IdOnline FROM `Online` );
	
SET countInserted = ROW_COUNT();
SET countInserted = IFNULL(countInserted, 0); -- Set to 0 if NULL.
SET `OUT` = JSON_OBJECT("REZULTAT", countInserted);
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procMail_Feedback
-- ----------------------------
DROP PROCEDURE IF EXISTS `procMail_Feedback`;
delimiter ;;
CREATE PROCEDURE `procMail_Feedback`(IN `pIdBaza` VARCHAR ( 255 ))
  READS SQL DATA 
BEGIN
	SELECT GROUP_CONCAT(CONCAT_WS(' ', Coloana, ' AS ', Afisare)) INTO @Coloane FROM Coloane_Implicite_Export_Feedback;

	SET @sql = CONCAT("
						SELECT ",
					@Coloane, ", IdConsultant as _IdConsultant, IdFeedBack as _IdFeedback, BackColor as _BackColor, NumeConsultant as _NumeConsultant, NumeClient as _NumeClient, TelefonP as _TelefonClient, EmailP as _EmailClient, CNPClient as _CNP, Functie as _FunctieConsultant, DataPrimire as _DataPrimire
					FROM
						( SELECT 
								IdBaza, IdConsultant, IdSursa, IdAgent, IdClient, DataPrimire 
							FROM 
								Baza 
							WHERE IdBaza = ", pIdBaza, " 
						) AS Baza
						
					INNER JOIN 
						( SELECT 
								IdClient, NumeClient, TelefonP, EmailP, CNPClient 
							FROM 
								Clienti 
						) AS Clienti USING ( IdClient )
						
					INNER JOIN 
						( SELECT 
								IdConsultant, NumeConsultant, cTelefon, cMail, Functie 
							FROM 
								Consultanti 
						) AS Consultanti USING ( IdConsultant )
						
					INNER JOIN 
						(	SELECT 
								IdBaza,IdFeedBack,DataConectare,Feedback,DataReconectare,FelStatus,BackColor,MailTrimis 
							FROM
								Baza_FeedBack
							INNER JOIN 
								( SELECT 
										IdStatus, FelStatus, BackColor 
									FROM 
										Baza_Status 
									WHERE 
										Ascuns = FALSE 
								) AS Baza_Status USING ( IdStatus )
						) AS Baza_FeedBack USING ( IdBaza ) 
						
					ORDER BY
						IdBaza DESC,
						IdFeedback DESC;"
	);
	
	-- DEBUG: (remove -- from next line for debugging)
	-- SELECT @sql;
	
	-- Execute the dynamic SQL query
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procMain
-- ----------------------------
DROP PROCEDURE IF EXISTS `procMain`;
delimiter ;;
CREATE PROCEDURE `procMain`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `SyncTime` VARCHAR(50),
    IN `MaxRecords` VARCHAR(10))
BEGIN
	DECLARE Tbl VARCHAR(50);
	DECLARE viewList VARCHAR(255);
	DECLARE srtColumn VARCHAR(255);
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","");
		ROLLBACK;
	END;
	
	SET MaxRecords = CAST(COALESCE(MaxRecords,0) AS INT);
	SET Tbl = COALESCE(ViewName,'');
	SET viewList = ViewName;

	IF IFNULL(SyncTime,'')='' THEN
			SET @DataM=UNIX_TIMESTAMP('1989-04-22 01:01:01');
	ELSE
			SET @DataM=CAST(SyncTime AS INT);
	END IF;

	IF IDN >= 40 THEN
		WHILE CHAR_LENGTH(viewList) > 0 DO
			SET @sql = '';
			SET @view = TRIM(SUBSTRING_INDEX(viewList, ',', 1));
			SET viewList = TRIM(BOTH ',' FROM SUBSTRING(viewList, CHAR_LENGTH(@view) + 2));
			
			IF @view='viewBaza' THEN SET srtColumn = 'IdBaza';	ELSE SET srtColumn = 'IdDosar'; END IF;
							
			SET @sql = CONCAT(@sql, "
					SELECT ", @view, ".*, 
					UNIX_TIMESTAMP(NOW()) as SyncTime 
					FROM ", @view, " 
					WHERE UNIX_TIMESTAMP( DataModificare) > ", @DataM, " ",
					"ORDER BY ", srtColumn, " DESC ",
					IF(MaxRecords <= 0, '', CONCAT(" LIMIT ", MaxRecords)), " ",
					";");
		
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt; 

		END WHILE;
	ELSE
		WHILE CHAR_LENGTH(viewList) > 0 DO
			SET @sql = '';				
			SET @view = TRIM(SUBSTRING_INDEX(viewList, ',', 1));
			SET viewList = TRIM(BOTH ',' FROM SUBSTRING(viewList, CHAR_LENGTH(@view) + 2));

			IF @view='viewBaza' THEN SET srtColumn = 'IdBaza';	ELSE SET srtColumn = 'IdDosar'; END IF;
			
			SET @sql = CONCAT(@sql, "
					SELECT *, 
					UNIX_TIMESTAMP(NOW()) as SyncTime
					FROM ", @view, " v JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
					WHERE cc.IdCopil=", IDC," 
					AND UNIX_TIMESTAMP( DataModificare) > ", @DataM, " ",
					"ORDER BY ", srtColumn, " DESC ",
					IF(MaxRecords <= 0, '', CONCAT(" LIMIT ", MaxRecords)), " ",
					";");
  -- SELECT @sql;
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt; 
		END WHILE;
	END IF;
	
	IF LENGTH(`OUT`)<>0 THEN SELECT `OUT`; END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procMain_Filter
-- ----------------------------
DROP PROCEDURE IF EXISTS `procMain_Filter`;
delimiter ;;
CREATE PROCEDURE `procMain_Filter`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(2000),
		IN `Sort` VARCHAR(2000),
    IN `MaxRecords` VARCHAR(100),
		IN `IdCautat` INT)
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	DECLARE LimitClause VARCHAR(255);
	DECLARE ViewID VARCHAR(100);
	
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	-- SET MaxRecords = CAST(COALESCE(NULLIF(MaxRecords,''),200) AS INT);
	
-- Check if MaxRecords contains a comma (,) for LIMIT and OFFSET
	IF LOCATE(',', MaxRecords) > 0 THEN
			-- If MaxRecords contains a comma, extract LIMIT and OFFSET
			SET `LimitClause` = CONCAT('LIMIT ', SUBSTRING_INDEX(MaxRecords, ',', 1), ' OFFSET ', SUBSTRING_INDEX(MaxRecords, ',', -1));
	ELSE
			-- If no comma, just apply the LIMIT
			SET `LimitClause` = CONCAT('LIMIT ', MaxRecords);
	END IF;	
	
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');
	SET Sort = IFNULL(NULLIF(Sort,''), 
			CASE 
					WHEN LEFT(ViewName,8) = 'viewBaza' THEN 'IdBaza DESC'
					WHEN LEFT(ViewName,9) = 'viewDosar' THEN 'IdDosar DESC' 
					WHEN LEFT(ViewName,13) = 'viewIpotecare' THEN 'ID DESC'
					ELSE 'IdDosar DESC'
			END);
    
    -- Set ViewID based on ViewName
	CASE LEFT(ViewName,8)
			WHEN 'viewBaza' THEN SET ViewID = 'IdBaza';
			WHEN 'viewDosa' THEN SET ViewID = 'IdDosar'; 
			WHEN 'viewIpot' THEN SET ViewID = 'ID';
			ELSE SET ViewID = 'IdDosar'; -- default
	END CASE;
		
	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT(
				IF(IdCautat<>0,CONCAT("SELECT * FROM ", ViewName, " WHERE ", ViewID, "=", IdCautat, " UNION ALL "),""), "
				SELECT * FROM (SELECT *
				FROM ", ViewName, " 
				WHERE ", ViewID, "<>", IdCautat, " AND ", Filtru, " ORDER BY ", Sort, " ", LimitClause, ") T");

		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT(
				IF(IdCautat<>0,CONCAT("SELECT * FROM ", ViewName, " WHERE ", ViewID, "=", IdCautat, " UNION ALL "),"")	, "
				SELECT * FROM (SELECT v.*
				FROM ", ViewName, " v JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
				WHERE cc.IdCopil=", IDC," AND ", ViewID, "<>", IdCautat, " AND ", Filtru, ") T ORDER BY ", Sort, " ", LimitClause);

    -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
		
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procMain_Filter_2025
-- ----------------------------
DROP PROCEDURE IF EXISTS `procMain_Filter_2025`;
delimiter ;;
CREATE PROCEDURE `procMain_Filter_2025`(IN `IDC`        INT,        -- IdConsultant
    IN `IDN`        INT,        -- IdNivel
    IN `ViewName`   VARCHAR(255), 
    IN `Filtru`     VARCHAR(3000),
    IN `Sort`       VARCHAR(2000),
    IN `MaxRecords` VARCHAR(100),
    IN `IdCautat`   INT)
BEGIN
    DECLARE LimitClause VARCHAR(255);
    DECLARE ViewID      VARCHAR(100);
		DECLARE ColsToFetch VARCHAR(2000);
		
		-- Filter testing against injection
		DECLARE flt_bad     BOOLEAN DEFAULT FALSE;
		DECLARE flt_errmsg  TEXT;
		
		-- Sort testing against injection
		DECLARE srt_bad    BOOLEAN DEFAULT FALSE;
		DECLARE srt_errmsg TEXT;
		
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno    = MYSQL_ERRNO,
            @text     = MESSAGE_TEXT;
        SELECT CAST(
            JSON_OBJECT(
                "EROARE",     @errno,
                "DESCRIERE",  @text
            ) 
            AS CHAR(1000)
        ) AS error_message;
        ROLLBACK;
    END;

		SET SESSION group_concat_max_len = 5000;

		-- SELECT IDC,IDN,ViewName,Filtru,Sort,MaxRecords,IdCautat; -- il las poate am nevoie sa vad ce primeste procedura

    -- Build LIMIT / OFFSET
    IF LOCATE(',', MaxRecords) > 0 THEN
        SET LimitClause = CONCAT(
            'LIMIT ',
            SUBSTRING_INDEX(MaxRecords, ',', 1),
            ' OFFSET ',
            SUBSTRING_INDEX(MaxRecords, ',', -1)
        );
    ELSEIF CAST(MaxRecords AS int) <> -1 THEN
        SET LimitClause = CONCAT('LIMIT ', MaxRecords);
		ELSE
			  SET LimitClause = '';
    END IF;

    -- Defaults
    SET Filtru = IFNULL(NULLIF(Filtru, ''), '1=1');
    SET Sort   = IFNULL(
        NULLIF(Sort, ''),
        CASE 
            WHEN LEFT(ViewName,8) = 'viewBaza'      THEN 'IdBaza DESC'
            WHEN LEFT(ViewName,9) = 'viewDosar'     THEN 'IdDosar DESC'
            WHEN LEFT(ViewName,13) = 'viewIpotecare' THEN 'ID DESC'
        END
    );

    CASE LEFT(ViewName,8)
        WHEN 'viewBaza' THEN SET ViewID = 'IdBaza';
        WHEN 'viewDosa' THEN SET ViewID = 'IdDosar';
        WHEN 'viewIpot' THEN SET ViewID = 'ID';
    END CASE;

		BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '42S22'  -- unknown column
				SET flt_bad = TRUE;

			SET @test_flt = CONCAT(
				'SELECT 1 INTO @flt_dummy FROM ', ViewName,
				' WHERE ', Filtru,
				' LIMIT 0'
			);
			PREPARE _flt FROM @test_flt;
			EXECUTE _flt;
			DEALLOCATE PREPARE _flt;
		END;

		IF flt_bad THEN
			SET flt_errmsg = CONCAT('Invalid filter, unknown column in: ', Filtru);
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = flt_errmsg;
		END IF;

		BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '42S22'
				SET srt_bad = TRUE;

			SET @test_srt = CONCAT(
				'SELECT 1 INTO @srt_dummy FROM ', ViewName,
				' ORDER BY ', Sort,
				' LIMIT 0'
			);
			PREPARE _srt FROM @test_srt;
			EXECUTE _srt;
			DEALLOCATE PREPARE _srt;
		END;

		IF srt_bad THEN
			SET srt_errmsg = CONCAT('Invalid sort, unknown column in: ', Sort);
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = srt_errmsg;
		END IF;

		IF LEFT(ViewName,8) NOT IN ('viewBaza','viewDosa','viewIpot') THEN
				SIGNAL SQLSTATE '45000'
						SET MESSAGE_TEXT = 'Invalid ViewName';
		END IF;

		-- build columns list
		SELECT
			GROUP_CONCAT(CONCAT('v.`', COLUMN_NAME, '`')
									 ORDER BY ORDINAL_POSITION
									 SEPARATOR ', ') INTO ColsToFetch
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_SCHEMA = 'SVN_IM'
			AND TABLE_NAME   = viewName;

		IF ColsToFetch IS NULL OR ColsToFetch = '' THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Coloanele pentru baza selectata nu au putut fi gasite!';
		END IF;
		
    -- Choose logic based on user level
    IF IDN >= 40 THEN

        -- HIGH-LEVEL: no children filter
        IF IdCautat <> 0 THEN
            SET @sql = CONCAT(
                "SELECT ",ColsToFetch," FROM ", ViewName, " v",
                " WHERE ", ViewID, " = ", IdCautat,
                " UNION ALL ",
                "SELECT ",ColsToFetch," FROM ", ViewName, " v",
                " WHERE ", ViewID, " <> ", IdCautat,
                "   AND ", Filtru,
                " ORDER BY ", Sort, " ",
                LimitClause
            );
        ELSE
            -- NO search ID → drop the PK-inequality entirely
            SET @sql = CONCAT(
                "SELECT ",ColsToFetch," FROM ", ViewName, " v",
                " WHERE ", Filtru,
                " ORDER BY ", Sort, " ",
                LimitClause
            );
        END IF;

    ELSE

        -- LOW-LEVEL: restrict to children of IDC
        IF IdCautat <> 0 THEN
            SET @sql = CONCAT(
                "SELECT ",ColsToFetch," FROM ", ViewName, " v",
                " WHERE ", ViewID, " = ", IdCautat,
                " UNION ALL ",
                "SELECT ",ColsToFetch," FROM ", ViewName, " v",
                " JOIN SVN_00.Consultanti_Copii cc",
                "   ON v.IdConsultant = cc.IdCopilCopil",
                " WHERE cc.IdCopil = ", IDC,
                "   AND ", ViewID, " <> ", IdCautat,
                "   AND ", Filtru,
                " ORDER BY ", Sort, " ",
                LimitClause
            );
        ELSE
            -- NO search ID → drop the PK-inequality entirely
            SET @sql = CONCAT(
                "SELECT ",ColsToFetch," FROM ", ViewName, " v",
                " JOIN SVN_00.Consultanti_Copii cc",
                "   ON v.IdConsultant = cc.IdCopilCopil",
                " WHERE cc.IdCopil = ", IDC,
                "   AND ", Filtru,
                " ORDER BY ", Sort, " ",
                LimitClause
            );
        END IF;

    END IF;

    -- Execute dynamically
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

		SET
			@flt_dummy = NULL,
			@srt_dummy = NULL;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procMain_Filter_Consultanti
-- ----------------------------
DROP PROCEDURE IF EXISTS `procMain_Filter_Consultanti`;
delimiter ;;
CREATE PROCEDURE `procMain_Filter_Consultanti`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(1000))
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');

	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT("
					SELECT IdConsultant, NumeConsultant, cTelefon, cMail, IdNivel, IdParinte
					FROM ", ViewName, " 
					WHERE ", Filtru, "
					GROUP BY IdConsultant"
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

	ELSE
		SET @sql = CONCAT("
				SELECT IdConsultant, NumeConsultant, cTelefon, cMail, IdNivel, IdParinte FROM (
					SELECT IdConsultant, NumeConsultant, cTelefon, cMail, IdNivel, IdParinte
					FROM ", ViewName, " 
					JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
					WHERE cc.IdCopil=", IDC," AND ", Filtru, "
					GROUP BY IdConsultant
				) T "
				);
  -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procMain_Filter_temp_modificare_ID_Cautat
-- ----------------------------
DROP PROCEDURE IF EXISTS `procMain_Filter_temp_modificare_ID_Cautat`;
delimiter ;;
CREATE PROCEDURE `procMain_Filter_temp_modificare_ID_Cautat`(IN `IDC` INT, -- IdConsultant
    IN `IDN` INT, -- IdNivel
    IN `ViewName` VARCHAR(255), -- Increase the length to handle longer strings
    IN `Filtru` VARCHAR(2000),
		IN `Sort` VARCHAR(2000),
    IN `MaxRecords` VARCHAR(100),
		IN `IdCautat` INT)
BEGIN
	DECLARE IDPT INTEGER;
	DECLARE Cons VARCHAR(2000);
	DECLARE `OUT` VARCHAR(2000);
	DECLARE LimitClause VARCHAR(255);
	DECLARE ViewID VARCHAR(100);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		GET DIAGNOSTICS CONDITION 1
		@sqlstate = RETURNED_SQLSTATE,
		@errno = MYSQL_ERRNO,
		@text = MESSAGE_TEXT;
		SELECT CAST(JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG, "COMMAND","") AS CHAR(1000)) AS error_message;
		ROLLBACK;
	END;
	
	-- SET MaxRecords = CAST(COALESCE(NULLIF(MaxRecords,''),200) AS INT);
	
-- Check if MaxRecords contains a comma (,) for LIMIT and OFFSET
	IF LOCATE(',', MaxRecords) > 0 THEN
			-- If MaxRecords contains a comma, extract LIMIT and OFFSET
			SET `LimitClause` = CONCAT('LIMIT ', SUBSTRING_INDEX(MaxRecords, ',', 1), ' OFFSET ', SUBSTRING_INDEX(MaxRecords, ',', -1));
	ELSE
			-- If no comma, just apply the LIMIT
			SET `LimitClause` = CONCAT('LIMIT ', MaxRecords);
	END IF;	
	
	SET Filtru=IFNULL(NULLIF(Filtru,''),'1=1');
	SET Sort = IFNULL(NULLIF(Sort,''), 
			CASE 
					WHEN LEFT(ViewName,8) = 'viewBaza' THEN 'IdBaza DESC'
					WHEN LEFT(ViewName,9) = 'viewDosar' THEN 'IdDosar DESC' 
					WHEN LEFT(ViewName,13) = 'viewIpotecare' THEN 'ID DESC'
					ELSE 'IdDosar DESC'
			END);
    
    -- Set ViewID based on ViewName
	CASE LEFT(ViewName,8)
			WHEN 'viewBaza' THEN SET ViewID = 'IdBaza';
			WHEN 'viewDosa' THEN SET ViewID = 'IdDosar'; 
			WHEN 'viewIpot' THEN SET ViewID = 'ID';
			ELSE SET ViewID = 'IdDosar'; -- default
	END CASE;
		
	-- SELECT MaxRecords,Filtru,Sort;
	IF IDN >= 40 THEN							
		SET @sql = CONCAT(
				IF(IdCautat<>0,CONCAT("SELECT * FROM ", ViewName, " WHERE ", ViewID, "=", IdCautat, " UNION ALL "),""), "
				SELECT * FROM (SELECT *
				FROM ", ViewName, " 
				WHERE ", ViewID, "<>", IdCautat, " AND ", Filtru, ") T
				ORDER BY ", Sort, " ",
				LimitClause
				);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 

		IF IdCautat=0 THEN
			SET @sql = CONCAT("
					SELECT Count(", ViewID, ") as CNT 
					FROM ", ViewName, " 
					WHERE ", ViewID, "<>", IdCautat, " AND ", Filtru);
			-- SELECT @sql;
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt; 
		END IF;
		
	ELSE
		SET @sql = CONCAT(
				IF(IdCautat<>0,CONCAT("SELECT * FROM ", ViewName, " WHERE ", ViewID, "=", IdCautat, " UNION ALL "),"")	, "
				SELECT * FROM (SELECT v.*
				FROM ", ViewName, " v JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
				WHERE cc.IdCopil=", IDC," AND ", ViewID, "<>", IdCautat, " AND ", Filtru, ") T
				ORDER BY ", Sort, " ",
				LimitClause
				);
   -- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
	
	IF IdCautat=0 THEN
		SET @sql = CONCAT("
				SELECT Count(", ViewID, ") as CNT 
				FROM ", ViewName, " v JOIN SVN_00.Consultanti_Copii cc ON v.IdConsultant=cc.IdCopilCopil 
				WHERE cc.IdCopil=", IDC," AND ", ViewID, "<>", IdCautat, " AND ", Filtru);
		-- SELECT @sql;
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	END IF;
		
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procNewLeads
-- ----------------------------
DROP PROCEDURE IF EXISTS `procNewLeads`;
delimiter ;;
CREATE PROCEDURE `procNewLeads`(IN `pIDC` INT, IN `pDateTime` VARCHAR(255))
BEGIN
	DECLARE cNivel INT;
	
	SELECT IdNivel INTO cNivel FROM Consultanti c WHERE IdConsultant=pIDC;
		
	IF cNivel <=35 THEN
		/* NU VREAU SA ARAT LEAD-URILE DE AICI DECAT PENTRU FIECARE UTILIZATOR DACA NU E ADMIN.
			 MODIFIC AICI DACA VREAU SA MERG PE RELATIA PARINTE/COPIL.
			 ! TREBUIE REGANDITA ORDONAREA DACA ACTIVEZ PARTEA ASTA!!!
		SELECT i.*,
			c.IdNivel,
			c.NumeConsultant,
			(SELECT Sursa FROM SursaLead WHERE IdSursa=i.IdSursa) AS Sursa,
			COUNT(ic.IDIC) AS ExistaClienti,
			(SELECT GROUP_CONCAT(Note) FROM Clienti_Note WHERE IdClient=ic.IdClient) AS Note,
			NOW() AS SyncTime 
		FROM 
			SVN_00.ipotecare i 
			JOIN SVN_00.Consultanti c USING (IdConsultant) 
			JOIN SVN_00.Consultanti_Copii cc ON c.IdConsultant=cc.IdCopilCopil 
			LEFT JOIN SVN_00.ipotecare_c ic USING (id_ipotecare) 
		WHERE IdCopil=pIDC AND IdCopilCopil<> pIDC AND i.Rezolvat=0 AND i.IdBaza IS NULL
		GROUP BY ID 

		UNION ALL
		*/
		SELECT i.*,
			c.IdNivel,
			c.NumeConsultant,
			(SELECT Sursa FROM SursaLead WHERE IdSursa=i.IdSursa) AS Sursa,
			COUNT(ic.IDIC) AS ExistaClienti,
			(SELECT GROUP_CONCAT(Note) FROM Clienti_Note WHERE IdClient=ic.IdClient) AS Note,
			NOW() AS SyncTime,
			DATEDIFF(NOW(),i.DataAdaugare) as DIF
		FROM 
			SVN_00.ipotecare i 
			JOIN SVN_00.Consultanti c USING (IdConsultant) 
			LEFT JOIN SVN_00.ipotecare_c ic USING (id_ipotecare) 
		WHERE c.IdConsultant=pIDC AND i.Rezolvat=0 AND i.IdBaza IS NULL
		GROUP BY ID 
		
		ORDER BY CONCAT(YEAR(i.DataAdaugare),  LPAD(MONTH(i.DataAdaugare) ,2,"0")) DESC;
	
	ELSE
		SELECT i.*,
			c.IdNivel,
			c.NumeConsultant,
			(SELECT Sursa FROM SursaLead WHERE IdSursa=i.IdSursa) AS Sursa,
			COUNT(ic.IDIC) AS ExistaClienti,
			(SELECT GROUP_CONCAT(Note) FROM Clienti_Note WHERE IdClient=ic.IdClient) AS Note,
			NOW() AS SyncTime, 
			DATEDIFF(NOW(),i.DataAdaugare) as DIF
		FROM 
			SVN_00.ipotecare i 
			JOIN SVN_00.Consultanti c USING (IdConsultant) 
			LEFT JOIN SVN_00.ipotecare_c ic USING (id_ipotecare) 
		WHERE i.Rezolvat=0 AND i.IdBaza IS NULL
		GROUP BY ID 

		ORDER BY CONCAT(YEAR(i.DataAdaugare),  LPAD(MONTH(i.DataAdaugare) ,2,"0")) DESC, NumeConsultant, i.DataAdaugare DESC;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procNewLeads_Test
-- ----------------------------
DROP PROCEDURE IF EXISTS `procNewLeads_Test`;
delimiter ;;
CREATE PROCEDURE `procNewLeads_Test`(IN `pid_ipotecare` VARCHAR(255))
BEGIN
SELECT
	IdBaza,
	DataPrimire,
	IdClient,
	NumeClient,
	b.IdConsultant,
	NumeConsultant,
	cTelefon AS TelefonConsultant,
	IdStatus,
	FelStatus,
	IDSG 
FROM
	Clienti cl
	JOIN Baza b USING ( IdClient )
	JOIN Consultanti c USING ( IdConsultant )
	JOIN Baza_FeedBack bf USING ( IdBaza )
	JOIN Baza_Status USING ( IdStatus, IDSG )
	JOIN SVN_00.ipotecare_c ic USING ( IdClient ) 
WHERE
	ic.id_ipotecare = pid_ipotecare 
	AND Primar =1
;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procOnline_ADD
-- ----------------------------
DROP PROCEDURE IF EXISTS `procOnline_ADD`;
delimiter ;;
CREATE PROCEDURE `procOnline_ADD`(IN `pIDC` int,
	IN `pIDS` int,
	IN `pJSON` TEXT,
	IN `pNumeConsultantTransfer` VARCHAR(255),
	OUT `OUT` TEXT)
BEGIN
	DECLARE i INT DEFAULT 0;
	DECLARE num_items INT DEFAULT 0;
	DECLARE rowCount_Clienti INT DEFAULT 0;
	DECLARE rowCount_Telefon INT DEFAULT 0;
	DECLARE rowCount_Baza	 INT DEFAULT 0;
	DECLARE rowCount_FeedBack	 INT DEFAULT 0;
	DECLARE lst_Adauga TEXT;
	DECLARE lastID INT DEFAULT 0;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
			GET DIAGNOSTICS CONDITION 1
			@sqlstate = RETURNED_SQLSTATE,
			@errno = MYSQL_ERRNO,
			@text = MESSAGE_TEXT;
			SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
			ROLLBACK;
	END;

	SET @IDS = pIDS;
	SET @IDC = pIDC;
	
	SELECT IdAgent INTO @IDA FROM Agenti WHERE IdSursa=pIDS AND NumeAgent='(fără agent)' LIMIT 1;
	
	SET @ERRMSG="START";
	
  START TRANSACTION;
	
  SET num_items = JSON_LENGTH(pJSON);

	WHILE i < num_items DO
			IF JSON_UNQUOTE(JSON_EXTRACT(pJSON, CONCAT('$[', i, '].Exista'))) = 0 THEN
				SET lst_Adauga = CONCAT_WS(',',lst_Adauga,JSON_UNQUOTE(JSON_EXTRACT(pJSON, CONCAT('$[', i, '].IdLead'))));
			END IF;
			
			SET i = i + 1;
  END WHILE;

	SET @ERRMSG="ADD_CLIENTI_NOU";
	
	SET @sql = CONCAT("
									INSERT INTO Clienti (NumeClient, TelefonP, EmailP, IdJudet)
									SELECT 
										UCASE(CONCAT_WS(' ', Nume, Prenume)) as NumeClient,
										REGEXP_REPLACE(REPLACE(`Online`.Telefon,'+4',''),'\\D+','') as TelefonP,
										Email,
										IdJudet
									FROM 
										`Online`
									WHERE
										`Online`.IdLead IN (", lst_Adauga, ")
									GROUP BY
										REGEXP_REPLACE(REPLACE(`Online`.Telefon,'+4',''),'\\D+','');");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	SET rowCount_Clienti = ROW_COUNT();
	SET lastID = LAST_INSERT_ID();
	DEALLOCATE PREPARE stmt;
										
	-- ERROR CHECKING
	IF rowCount_Clienti = 0 THEN	
		SET @mesaj = CONCAT('Nu a fost adaugat niciun rand in Clienti!');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mesaj;
	END IF;
	-- ---------------
	
	SET @ERRMSG="GET_INSERTED_ROWS_CLIENT";
	SET @sql = CONCAT("SELECT GROUP_CONCAT(IdClient) ,COUNT(IdClient) INTO @listClienti, @listCountClienti
										FROM Clienti 
									WHERE
										IdClient >= ", lastID, "
										");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	-- ERROR CHECKING
	IF @listCountClienti = 0 THEN	
		SET @mesaj = CONCAT('Eroare preluare clienti adaugati! (0)');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mesaj;
	ELSEIF @listCountClienti <> rowCount_Clienti  THEN	
	 	SET @mesaj = CONCAT('Eroare preluare clienti adaugati (', @listCountClienti, ' <> ', rowCount_Clienti, ')!');
	 	SIGNAL SQLSTATE '45000'	SET MESSAGE_TEXT = @mesaj;
	END IF;
	-- ---------------
	
	SET @ERRMSG="ADD_TELEFON_NOU";
	
	SET @sql = CONCAT("
									INSERT INTO Clienti_Telefon (IdClient, Telefon, Primar)
									SELECT 
										IdClient,
										TelefonP,
										TRUE as Primar
									FROM 
										`Clienti`
									WHERE
										IdClient IN (", @listClienti, ");
									");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	SET rowCount_Telefon = ROW_COUNT();
	DEALLOCATE PREPARE stmt;
										
	IF rowCount_Telefon = 0 THEN	
		SET @mesaj = CONCAT('Nu a fost adaugat niciun rand in Telefon!');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mesaj;
	ELSEIF rowCount_Telefon <> rowCount_Clienti  THEN	
		SET @mesaj = CONCAT('Nu au fost adaugate toate randurile in Telefon (', rowCount_Clienti, ' <> ', rowCount_Telefon, ')!');
		SIGNAL SQLSTATE '45000'	SET MESSAGE_TEXT = @mesaj;
	END IF;

	SET @ERRMSG="ADD_BAZA_NOU";
	
	SET @sql = CONCAT("
									INSERT INTO Baza (IdLead, IdClient, IdSursa, IdAgent, IdConsultant, Nou, DataPrimire) 
										SELECT 
											IdOnline, 
											IdClient, 
											", @IDS, " as IdSursa,
											", @IDA, " as IdAgent,
											", @IDC, " as IdConsultant,
											TRUE as Nou,
											NOW()
										FROM
											`Online`
											INNER JOIN
											`Clienti`
											ON
											REGEXP_REPLACE(REPLACE(`Online`.Telefon,'+4',''),'\\D+','') = REGEXP_REPLACE(REPLACE(`Clienti`.TelefonP,'+4',''),'\\D+','')
										WHERE
											`Clienti`.IdClient IN (", @listClienti, ")");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	SET rowCount_Baza = ROW_COUNT();
	SET lastID = LAST_INSERT_ID();
	DEALLOCATE PREPARE stmt;
	
	IF rowCount_Baza = 0 THEN	
		SET @mesaj = CONCAT('Nu a fost adaugat niciun rand in Baza!');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mesaj;
	END IF;

	SET @ERRMSG="GET_INSERTED_ROWS_BAZA";
	SET @sql = CONCAT("SELECT GROUP_CONCAT(IdClient) ,COUNT(IdClient) INTO @listBaza, @listCountBaza
										FROM Baza 
									WHERE
										IdBaza >= ", lastID, "
									");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	-- ERROR CHECKING
	IF @listCountBaza = 0 THEN	
		SET @mesaj = CONCAT('Eroare preluare rânduri bază adăugate! (0)');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mesaj;
	ELSEIF @listCountBaza <> rowCount_Baza  THEN	
	 	SET @mesaj = CONCAT('Eroare preluare rânduri bază adăugate (', @listCountBaza, ' <> ', rowCount_Baza, ')!');
	 	SIGNAL SQLSTATE '45000'	SET MESSAGE_TEXT = @mesaj;
	END IF;
	-- ---------------
	
	SET @ERRMSG="ADD_FEEDBACK_NOU";
	SET @sql = CONCAT("INSERT INTO Baza_FeedBack (IdBaza, IdStatus, IDSG, IdConsultant, DataConectare, FeedBack, DataReconectare)
										SELECT
											IdBaza,
											108,
											2,
											", pIDC, ",
											NOW(),
											'Simulare transferata din Online de ", pNumeConsultantTransfer, "',
											DATE_ADD(NOW(), INTERVAL 1 DAY)
										FROM 
											Baza
										WHERE
											IdBaza IN (", @listBaza, ");");
											
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	SET rowCount_FeedBack = ROW_COUNT();
	SET lastID = LAST_INSERT_ID();
	DEALLOCATE PREPARE stmt;

	SET @ERRMSG="GET_INSERTED_ROWS_BAZA_FEEDBACK";
	SET @sql = CONCAT("SELECT GROUP_CONCAT(IdFeedBack) ,COUNT(IdFeedBack) INTO @listBazaF, @listCountBazaF
										FROM Baza_FeedBack 
									WHERE
										IdFeedBack >= ", lastID, "
									");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	-- ERROR CHECKING
	IF @listCountBazaF = 0 THEN	
		SET @mesaj = CONCAT('Eroare preluare rânduri bază feedback adăugate! (0)');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mesaj;
	ELSEIF @listCountBazaF <> rowCount_FeedBack  THEN	
		SET @mesaj = CONCAT('Eroare preluare rânduri bază feedback adăugate (', @listCountBazaF, ' <> ', rowCount_FeedBack, ')!');
		SIGNAL SQLSTATE '45000'	SET MESSAGE_TEXT = @mesaj;
	END IF;
	-- ---------------

	SET @ERRMSG="UPDATE_ONLINE";
	SET @sql = CONCAT("UPDATE Online SET Nou=0 WHERE IdLead IN (", lst_Adauga, ")");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	SET `OUT` = JSON_OBJECT("Clienți", rowCount_Clienti, "Telefon", rowCount_Telefon, "Baza", rowCount_Baza, "Feedback", rowCount_FeedBack);

	-- Reset session variables
	SET @listBaza = NULL;
	SET @listCountBaza = NULL;
	SET @listBazaF = NULL;
	SET @listCountBazaF = NULL;
	SET @listClienti = NULL;
	SET @IDS = NULL;
	SET @IDC = NULL;
	SET @IDA = NULL;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procOnline_List
-- ----------------------------
DROP PROCEDURE IF EXISTS `procOnline_List`;
delimiter ;;
CREATE PROCEDURE `procOnline_List`(IN `pDoarNoi` tinyint,
	IN `pLuna` varchar (255),
	IN `pIdJudet` varchar (255),
	IN `pSort` varchar (255),
	IN `pS` TINYINT)
  READS SQL DATA 
BEGIN
	SET @Sort = IF(IFNULL(pSort,'')='', 'IdLead DESC', pSort);
	SET @Luna = CONCAT("'",pLuna,"'");
	SET @IDJ = CONCAT("'",pIdJudet,"'");
	
	SET @sql = CONCAT ("
							SELECT
								",pS," as S,
								`Online`.IdLead, 
								`Online`.IdOnline, 
								`Online`.IdJudet, 
								DATE_FORMAT(`Online`.DataPrimire, '%d\/%m\/%Y %H\:%i\:%s') as DataPrimire,
								`Online`.Judet, 
								`Online`.Nume, 
								`Online`.Prenume,
								CONCAT(`Online`.Nume,' ' ,`Online`.Prenume) as NumePrenume, 
								`Online`.Email, 
								REPLACE(`Online`.Telefon,'+4','') as Telefon, 
								`Online`.NewsLetter,
								IF(IFNULL(Clienti_Telefon.IdTelefon,'')='',0,1) as Exista, 
								Clienti.NumeClient
							FROM
								`Online`
								LEFT JOIN	
								Clienti_Telefon
								ON 
									REGEXP_REPLACE(REPLACE(`Online`.Telefon,'+4',''), '\\D+','') = REGEXP_REPLACE(Clienti_Telefon.Telefon, '\\D+','')
								LEFT JOIN
								Clienti
								ON 
									Clienti_Telefon.IdClient = Clienti.IdClient
							WHERE
								`Online`.Nou=", pDoarNoi, " AND
								DATE_FORMAT( `Online`.DataPrimire, '%m\/%Y' ) LIKE ", @Luna, " AND
								`Online`.IdJudet LIKE ", @IDJ, "
							ORDER BY ",
								pSort, "
						");
  -- SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
 	DEALLOCATE PREPARE stmt;
		
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procOnline_Transfer
-- ----------------------------
DROP PROCEDURE IF EXISTS `procOnline_Transfer`;
delimiter ;;
CREATE PROCEDURE `procOnline_Transfer`(IN `pIDC` int,
	IN `pIDS` int,
	IN `pJSON` TEXT,
	IN `pNumeConsultantTransfer` VARCHAR(255),
	OUT `OUT` TEXT)
BEGIN
	DECLARE i INT DEFAULT 0;
	DECLARE lastID INT DEFAULT 0;
	
	DECLARE num_items INT;
	DECLARE exista_value INT;

	DECLARE lst_Clienti TEXT;
	
	DECLARE lst_Lead_Noi TEXT;
	DECLARE lst_Lead_Existente TEXT;
	DECLARE lst_Lead TEXT;
	
	DECLARE rowCount_Baza INT;
	DECLARE rowCount_FeedBack INT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
			GET DIAGNOSTICS CONDITION 1
			@sqlstate = RETURNED_SQLSTATE,
			@errno = MYSQL_ERRNO,
			@text = MESSAGE_TEXT;
			SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
			ROLLBACK;
	END;

	SET @IDS = pIDS;
	SET @IDC = pIDC;

	SELECT IdAgent INTO @IDA FROM Agenti WHERE IdSursa=pIDS AND NumeAgent='(fără agent)' LIMIT 1;
	
	SET @ERRMSG="START";
	
  START TRANSACTION;
	
  SET num_items = JSON_LENGTH(pJSON);

	WHILE i < num_items DO
			IF JSON_UNQUOTE(JSON_EXTRACT(pJSON, CONCAT('$[', i, '].Exista'))) = 1 THEN
				SET lst_Lead_Existente = CONCAT_WS(',',lst_Lead_Existente,JSON_UNQUOTE(JSON_EXTRACT(pJSON, CONCAT('$[', i, '].IdLead'))));
			END IF;
			
			SET i = i + 1;
  END WHILE;
		
	IF IFNULL(lst_Clienti,'') <>'' THEN
		SET @ERRMSG="CLIENTI_EXISTENTI_LIST";
	
		SET @sql = CONCAT("SELECT GROUP_CONCAT(IdClient) INTO @lstClientiExistenti
											FROM Clienti 
											WHERE REGEXP_REPLACE(REPLACE(TelefonP,'+4',''),'\\D+','') IN 
												(
												SELECT REGEXP_REPLACE(REPLACE(Telefon,'+4',''),'\\D+','') 
												FROM `Online` 
												WHERE IdLead IN 
													(", IFNULL(lst_Lead_Existente,''), ") 
												GROUP BY REGEXP_REPLACE(REPLACE(Telefon,'+4',''),'\\D+','')
												)");
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END IF;
	
	SET @ERRMSG="CLIENTI_NOI_ADD";
	SET i=0;

	WHILE i < num_items DO
			IF JSON_UNQUOTE(JSON_EXTRACT(pJSON, CONCAT('$[', i, '].Exista'))) = 0 THEN
				SET lst_Lead_Noi = CONCAT_WS(',',lst_Lead_Noi,JSON_UNQUOTE(JSON_EXTRACT(pJSON, CONCAT('$[', i, '].IdLead'))));
			END IF;
			
			SET i = i + 1;
  END WHILE;
	
	SET @sql = CONCAT("INSERT INTO Clienti (NumeClient,TelefonP,EmailP,IdJudet,IdLead)
											SELECT CONCAT_WS(' ',Nume, Prenume), REGEXP_REPLACE(REPLACE(Telefon,'+4',''),'\\D+',''), Email, IdJudet, IdLead
											FROM Online
											WHERE IdLead IN (", lst_Lead_Noi, ");");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	SET @ERRMSG="CLIENTI_NOI_LIST";

	SET @sql = CONCAT("SELECT GROUP_CONCAT(IdClient) INTO @lstClientiNoi FROM Clienti WHERE IdLead IN (", lst_Lead_Noi, ");");
	
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	SET lst_Clienti = CONCAT_WS(',',@lstClientiExistenti, @lstClientiNoi);
	SET lst_Lead = CONCAT_WS(',', lst_Lead_Existente, lst_Lead_Noi);
	
	SET @ERRMSG="ADD_EXISTA_BAZA";
	
	SET @sql = CONCAT("INSERT INTO Baza (IdLead, IdClient, IdSursa, IdAgent, IdConsultant, Nou, DataPrimire) 
										SELECT Clienti.IdLead, Clienti.IdClient, ", @IDS, " as IdSursa, ", @IDA, " as IdAgent, ", @IDC, " as IdConsultant, TRUE as Nou, NOW()
										FROM Clienti
										WHERE Clienti.IdClient IN (", lst_Clienti, ")");

	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	SET rowCount_Baza = ROW_COUNT();
	DEALLOCATE PREPARE stmt;

	-- ERROR CHECKING
	IF rowCount_Baza = 0 THEN	
		SET @mesaj = CONCAT('Nu a fost adaugat niciun rand in Baza!');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mesaj;
	END IF;
	-- ---------------
	
	SET @ERRMSG="GET_INSERTED_ROWS_BAZA";
	
	SET @sql = CONCAT("SELECT GROUP_CONCAT(IdBaza) ,COUNT(IdBaza) INTO @lstBaza, @lstCountBaza FROM Baza WHERE IdLead IN (", lst_Lead, ");");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	-- ERROR CHECKING
	IF @lstCountBaza = 0 THEN	
		SET @mesaj = CONCAT('Eroare preluare rânduri bază adăugate! (0)');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mesaj;
	ELSEIF @lstCountBaza <> rowCount_Baza  THEN	
		SET @mesaj = CONCAT('Eroare preluare rânduri bază adăugate (', @lstCountBaza, ' <> ', rowCount_Baza, ')!');
		SIGNAL SQLSTATE '45000'	SET MESSAGE_TEXT = @mesaj;
	END IF;
	-- ---------------
		
	SET @ERRMSG="ADD_FEEDBACK_NOU";
	SET @sql = CONCAT("INSERT INTO Baza_FeedBack (IdBaza, IdStatus, IDSG, IdLead, IdConsultant, DataConectare, FeedBack, DataReconectare)
										SELECT IdBaza, 108, 2, Baza.IdLead, ", pIDC, ", NOW(), 'Simulare transferata din Online de ", IFNULL(pNumeConsultantTransfer,''), "', DATE_ADD(NOW(), INTERVAL 1 DAY) 
										FROM Baza
										WHERE IdLead IN (", lst_Lead, ");");
											
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	SET rowCount_FeedBack = ROW_COUNT();
	SET lastID = LAST_INSERT_ID();
	DEALLOCATE PREPARE stmt;

	SET @ERRMSG="GET_INSERTED_ROWS_BAZA_FEEDBACK";
	SET @sql = CONCAT("SELECT GROUP_CONCAT(IdFeedBack) ,COUNT(IdFeedBack) INTO @lstBazaF, @lstCountBazaF FROM Baza_FeedBack WHERE IdLead IN (", lst_Lead, ");");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	-- ERROR CHECKING
	IF @lstCountBazaF = 0 THEN	
		SET @mesaj = CONCAT('Eroare preluare rânduri bază feedback adăugate! (0)');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mesaj;
	ELSEIF @lstCountBazaF <> rowCount_FeedBack  THEN	
		SET @mesaj = CONCAT('Eroare preluare rânduri bază feedback adăugate (', @lstCountBazaF, ' <> ', rowCount_FeedBack, ')!');
		SIGNAL SQLSTATE '45000'	SET MESSAGE_TEXT = @mesaj;
	END IF;
	-- ---------------
	
	SET @ERRMSG="UPDATE_ONLINE";
	SET @sql = CONCAT("UPDATE Online SET Nou=0 WHERE IdLead IN (", lst_Lead, ")");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	SET `OUT` = JSON_OBJECT("Baza", rowCount_Baza, "Feedback", rowCount_FeedBack);
	-- ROLLBACK;
	
	-- Reset session variables
	SET @lstClientiExistenti = NULL;
	SET @lstClientiNoi = NULL;
	SET @lstBaza = NULL;
	SET @lstCountBaza = NULL;
	SET @lstBazaF = NULL;
	SET @lstCountBazaF = NULL;
	SET @IDS = NULL;
	SET @IDC = NULL;
	SET @IDA = NULL;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procOnline_Tree
-- ----------------------------
DROP PROCEDURE IF EXISTS `procOnline_Tree`;
delimiter ;;
CREATE PROCEDURE `procOnline_Tree`(IN `pIDC` int)
BEGIN
	DECLARE cNivel INT;
	
	SELECT IdNivel INTO cNivel FROM Consultanti c WHERE IdConsultant=pIDC;
		
	IF cNivel <=35 THEN
		SELECT 
			i.ID,
			i.IdConsultant,
			i.L,
			i.D,
			c.IdNivel,
			UCASE(c.NumeConsultant) AS NumeConsultant,
			i.DataAdaugare,
			NOW() AS SyncTime,
			(SELECT 0) as Chk,
			(SELECT 0) as S
		FROM 
			SVN_00.ipotecare i 
			JOIN SVN_00.Consultanti c USING (IdConsultant) 
			LEFT JOIN SVN_00.ipotecare_c ic USING (id_ipotecare) 
		WHERE c.IdConsultant=pIDC AND i.Rezolvat=0 AND i.IdBaza IS NULL
		GROUP BY IdConsultant,L,D
		
		ORDER BY i.DataAdaugare DESC;
	
	ELSE
		SELECT
			i.ID,
			i.IdConsultant,
			i.L,
			i.D,
			c.IdNivel,
			UCASE(c.NumeConsultant) AS NumeConsultant,
			i.DataAdaugare,
			NOW() AS SyncTime,
			(SELECT 0) as Chk,
			(SELECT 0) as S
		FROM 
			SVN_00.ipotecare i 
			JOIN SVN_00.Consultanti c USING (IdConsultant) 
			LEFT JOIN SVN_00.ipotecare_c ic USING (id_ipotecare) 
		WHERE i.Rezolvat=0 AND i.IdBaza IS NULL
		GROUP BY IdConsultant,L,D

		ORDER BY CONCAT(YEAR(i.DataAdaugare),  LPAD(MONTH(i.DataAdaugare) ,2,"0")) DESC, NumeConsultant, i.DataAdaugare DESC;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procParams
-- ----------------------------
DROP PROCEDURE IF EXISTS `procParams`;
delimiter ;;
CREATE PROCEDURE `procParams`(IN `procName` VARCHAR(255))
BEGIN		
	SELECT
		PARAMETER_NAME as pName, CONCAT("[",JSON_OBJECT( "ORDINAL_POSITION", ORDINAL_POSITION, "PARAMETER_NAME", PARAMETER_NAME, "DATA_TYPE", DATA_TYPE ),"]") AS objJson
	FROM
	( 
		SELECT information_schema.PARAMETERS.ORDINAL_POSITION, information_schema.PARAMETERS.PARAMETER_NAME, information_schema.PARAMETERS.DATA_TYPE 
		FROM information_schema.PARAMETERS 
		WHERE SPECIFIC_NAME = procName AND SPECIFIC_SCHEMA = DATABASE()
		ORDER BY information_schema.PARAMETERS.ORDINAL_POSITION
	) AS T;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procParams_ALL
-- ----------------------------
DROP PROCEDURE IF EXISTS `procParams_ALL`;
delimiter ;;
CREATE PROCEDURE `procParams_ALL`(IN `schName` VARCHAR(255))
BEGIN		
	SELECT
		SPECIFIC_NAME as procName, PARAMETER_NAME as pName, CONCAT("[",JSON_OBJECT( "ORDINAL_POSITION", ORDINAL_POSITION, "PARAMETER_NAME", PARAMETER_NAME, "DATA_TYPE", DATA_TYPE ),"]") AS objJson
	FROM
	( 
		SELECT SPECIFIC_NAME, information_schema.PARAMETERS.ORDINAL_POSITION, information_schema.PARAMETERS.PARAMETER_NAME, information_schema.PARAMETERS.DATA_TYPE 
		FROM information_schema.PARAMETERS 
		WHERE SPECIFIC_SCHEMA = schName
		ORDER BY SPECIFIC_NAME,information_schema.PARAMETERS.ORDINAL_POSITION
	) AS T;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procRaportGeneral
-- ----------------------------
DROP PROCEDURE IF EXISTS `procRaportGeneral`;
delimiter ;;
CREATE PROCEDURE `procRaportGeneral`(IN `D1` DATE, IN `D2` DATE)
BEGIN

SELECT
	C.IdConsultant,
	C.IdParinte,
	C.NumeConsultant,
	C.cMail,
	C.cTelefon,
	C.IdNivel,
	P.NumeParinte,
	TOTAL_BAZE,
	TRANSFERAT,
	BAZA_TERMINAT,
	BAZA_IN_LUCRU,
	TOTAL_DOSARE,
	TRAS,
	DOSAR_TERMINAT,
	DOSAR_IN_LUCRU,
	GROUP_CONCAT(JSON_ARRAY("Intrare",L.Intrare,"Iesire",L.Iesire,"Timp",L.Timp)) as LOG
FROM
	SVN_00.Consultanti C
	LEFT JOIN (SELECT IdConsultant as IdParinte, NumeConsultant as NumeParinte FROM Consultanti) as P USING (IdParinte)
	LEFT JOIN (
	SELECT
		IdConsultant,
		Count( IdBaza ) AS TOTAL_BAZE,
		SUM(
		IF
		( IDSG = 1, 1, 0 )) AS TRANSFERAT,
		SUM(
		IF
		( IDSG = 2, 1, 0 )) AS BAZA_TERMINAT,
		SUM(
		IF
		( IDSG = 3, 1, 0 )) AS BAZA_IN_LUCRU 
	FROM
		(
		SELECT
			Baza.IdConsultant,
			Baza_FeedBack.IdBaza,
			Baza_FeedBack.IDSG 
		FROM
			Baza
			INNER JOIN Baza_FeedBack USING ( IdBaza )
			INNER JOIN Baza_Status USING ( IdStatus ) 
		WHERE
			Baza_FeedBack.Primar = 1 
			AND Baza.DataPrimire BETWEEN D1 
			AND D2 
		) T 
	GROUP BY
		IdConsultant 
	) AS BazaC USING ( IdConsultant )
	LEFT JOIN (
	SELECT
		IdConsultant,
		Count( IdDosar ) AS TOTAL_DOSARE,
		SUM(
		IF
		( IDSG = 1, 1, 0 )) AS TRAS,
		SUM(
		IF
		( IDSG = 2, 1, 0 )) AS DOSAR_TERMINAT,
		SUM(
		IF
		( IDSG = 3, 1, 0 )) AS DOSAR_IN_LUCRU 
	FROM
		(
		SELECT
			Dosar.IdDosar,
			Dosar.IdConsultant,
			Dosar_Status.IDSG 
		FROM
			Dosar
			INNER JOIN Dosar_Status USING ( IdStatus ) 
		WHERE
			Dosar.DataIntroducere BETWEEN D1 
			AND D2 
		) T 
	GROUP BY
		IdConsultant 
	) AS DosarC USING ( IdConsultant ) 
LEFT JOIN (
SELECT IdConsultant, Intrare, Iesire, ROUND(DIF/60,2) AS Timp, Corect 
FROM SVN_00.Consultanti_LOG
WHERE Corect=1
GROUP BY IdConsultant, Intrare
HAVING Intrare BETWEEN D1 AND D2
) as L USING (IdConsultant)
WHERE
	C.Nou = 0 
	AND C.Ascuns =0
GROUP BY IdConsultant;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procSchema
-- ----------------------------
DROP PROCEDURE IF EXISTS `procSchema`;
delimiter ;;
CREATE PROCEDURE `procSchema`(IN pTBL_NAME VARCHAR ( 255 ))
BEGIN
	SET @vTBL_NAME = IF(IFNULL(pTBL_NAME,"")="","%",pTBL_NAME);
	
	SELECT
		T.TABLE_NAME AS T,
		T.PRIMARY_COLUMN AS C,
		JSON_ARRAYAGG(
		JSON_OBJECT( "NAME", T.COLUMN_NAME, "TYPE", T.DATA_TYPE, "LENGTH", T.CHARACTER_MAXIMUM_LENGTH )) AS V
	FROM
		TABLES_INFO T 
	WHERE 
		T.TABLE_NAME LIKE @vTBL_NAME
	GROUP BY
		T.TABLE_NAME 
	ORDER BY
	T.TABLE_NAME,
	T.PRIMARY_COLUMN ;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procStatus_Add
-- ----------------------------
DROP PROCEDURE IF EXISTS `procStatus_Add`;
delimiter ;;
CREATE PROCEDURE `procStatus_Add`(IN `pTip` TINYINT (4),
	IN `pSelTab` VARCHAR (255),
	IN `pIDSG` INT,
	IN `pIdStatus` VARCHAR (255),
	IN `pFelStatus` VARCHAR (255),
	IN `pBackColor` VARCHAR (255),
	IN `pAscuns` TINYINT (4),
	IN `pFontJson` JSON,
	OUT `OUT` VARCHAR(2000))
proc_label: BEGIN
		DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		BEGIN
			GET DIAGNOSTICS CONDITION 1
			@sqlstate = RETURNED_SQLSTATE,
			@errno = MYSQL_ERRNO,
			@text = MESSAGE_TEXT;
			
			 SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
			ROLLBACK;
		END; 
END;

	IF `pSelTab`='nvB1' THEN
		SET @BD='Baza';
	ELSE
		SET @BD='Dosar';
	END IF;

	SET @ERRMSG=NULL;
	SET @IDSG = `pIDSG`;
	SET @IdStatus=`pIdStatus`;
	SET @FelStatus=`pFelStatus`;
	SET @BackColor=`pBackColor`;
	SET @Ascuns=`pAscuns`;
	SET @TipStatus=0;
	
	SET @FontName = TRIM(BOTH '"' FROM JSON_EXTRACT(`pFontJson`, CONCAT('$[0].FontName')));
	SET @FontSize = JSON_EXTRACT(`pFontJson`, CONCAT('$[0].FontSize'));
	SET @FontBold = JSON_EXTRACT(`pFontJson`, CONCAT('$[0].FontBold'));
	SET @FontItalic = JSON_EXTRACT(`pFontJson`, CONCAT('$[0].FontItalic'));
	SET @FontUnderline = JSON_EXTRACT(`pFontJson`, CONCAT('$[0].FontUnderline'));
	SET @FontColor = JSON_EXTRACT(`pFontJson`, CONCAT('$[0].FontColor'));
		
	START TRANSACTION;

	CASE `pTip`
		WHEN 0 THEN -- ADAUGARE
			SET @ERRMSG=CONCAT('ADD_STATUS_',@BD);
			
			IF @BD='Baza' THEN
				SELECT MAX(TipStatus)+1 FROM Baza_Status INTO @TipStatus;
			ELSE
				SELECT MAX(TipStatus)+1 FROM Dosar_Status INTO @TipStatus;
			END IF;
			
			SET @sql = CONCAT("INSERT INTO `", @BD, "_Status` (IDSG,FelStatus,TipStatus,BackColor,Ascuns,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontColor) 
													SELECT ?,?,?,?,?,?,?,?,?,?,?");

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING @IDSG, @FelStatus, @TipStatus, @BackColor, @Ascuns, @FontName, @FontSize, @FontBold, @FontItalic, @FontUnderline, @FontColor;
			DEALLOCATE PREPARE stmt;
				
			SET @IdStatus=LAST_INSERT_ID();

		WHEN 1 THEN -- MODIFICARE
			SET @ERRMSG=CONCAT('MOD_STATUS_',@BD);
		
			SET @sql = CONCAT("UPDATE `",@BD,"_Status` SET IDSG=?,FelStatus=?,BackColor=?,Ascuns=?,FontName=?,FontSize=?,FontBold=?,FontItalic=?,FontUnderline=?,FontColor=? WHERE IdStatus=?");
			
			PREPARE stmt FROM @sql;
			EXECUTE stmt USING @IDSG, @FelStatus, @BackColor, @Ascuns, @FontName, @FontSize, @FontBold, @FontItalic, @FontUnderline, @FontColor, @IdStatus;
			DEALLOCATE PREPARE stmt;
	
	END CASE;
	
	COMMIT;
	
	SET @OUT=JSON_OBJECT("IdStatus",@IdStatus);
	
	SET `OUT`=@OUT;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procSurseAgenti_Add
-- ----------------------------
DROP PROCEDURE IF EXISTS `procSurseAgenti_Add`;
delimiter ;;
CREATE PROCEDURE `procSurseAgenti_Add`(IN `pIdSursa` VARCHAR (255),
IN `pIdAgent` VARCHAR (255),
IN `pSursa` VARCHAR (255),
IN `pNumeAgent` VARCHAR (255),
IN `paMail` VARCHAR (255),
IN `paTelefon` VARCHAR (255),
OUT `OUT` VARCHAR(2000))
proc_label: BEGIN
		DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		BEGIN
			GET DIAGNOSTICS CONDITION 1
			@sqlstate = RETURNED_SQLSTATE,
			@errno = MYSQL_ERRNO,
			@text = MESSAGE_TEXT;
			
			 SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
			ROLLBACK;
		END; 
END;
	
	SET @ERRMSG=NULL;
	SET @IdSursa=`pIdSursa`;
	SET @IdAgent=`pIdAgent`;
	SET @Sursa=`pSursa`;
	SET @NumeAgent=`pNumeAgent`;
	SET @aMail=`paMail`;
	SET @aTelefon=`paTelefon`;

	START TRANSACTION;

	IF IFNULL(@IdSursa,'')='' AND IFNULL(@Sursa,'')<>'' THEN
		SET @ERRMSG='ADD_SURSA';
	
		SET @sql = CONCAT("INSERT INTO SursaLead (Sursa) VALUES (?)");
		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @Sursa;
		DEALLOCATE PREPARE stmt;

		SET @IdSursa=LAST_INSERT_ID();
	END IF;
	
	IF IFNULL(@IdSursa,'')<>'' THEN
		SET @ERRMSG='MOD_SURSA';

		SET @sql = CONCAT("UPDATE SursaLead SET Sursa=? WHERE IdSursa=?");
		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @Sursa, @IdSursa;
		DEALLOCATE PREPARE stmt;
	END IF;
	
	IF IFNULL(@IdAgent,'')='' AND IFNULL(@NumeAgent,'') <> '' THEN
		SET @ERRMSG='ADD_AGENT';
				
		SET @sql = CONCAT("INSERT INTO Agenti (IdSursa, NumeAgent, aTelefon, aMail) SELECT ?, ?, ?, ?");

		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @IdSursa, @NumeAgent, @aTelefon, @aMail;
		DEALLOCATE PREPARE stmt;

		SET @IdAgent=LAST_INSERT_ID();
	END IF;
	
	IF IFNULL(@IdAgent,'')<>'' THEN
		SET @ERRMSG='MOD_AGENT';

		SET @sql = CONCAT("UPDATE Agenti SET NumeAgent=?,aMail=?,aTelefon=? WHERE IdAgent=?");
		
		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @NumeAgent, @aTelefon, @aMail, @IdAgent;
		DEALLOCATE PREPARE stmt;
	END IF;
	
	COMMIT;
	
	SET @OUT=JSON_OBJECT("IdSursa",@IdSursa,"IdAgent",@IdAgent);
	
	SET `OUT`=@OUT;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procUtilizatori_Add
-- ----------------------------
DROP PROCEDURE IF EXISTS `procUtilizatori_Add`;
delimiter ;;
CREATE PROCEDURE `procUtilizatori_Add`(IN `pSchema` VARCHAR(255),
    IN `pSuffix` VARCHAR(1),
    IN `pIdConsultant` VARCHAR(255),
    IN `pNumeConsultant` VARCHAR(255),
    IN `pTelefon` VARCHAR(255),
    IN `pMail` VARCHAR(255),
    IN `pIdRegiune` VARCHAR(255),
    IN `pIdNivel` VARCHAR(255),
    IN `pIdParinte` VARCHAR(255),
    IN `pJudetJson` JSON,
    OUT `OUT` VARCHAR(255))
proc_label: BEGIN	
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
            GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @text = MESSAGE_TEXT;

        SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
        ROLLBACK;
    END;

    -- Initialization
    SET @RoleNamePrefix = SUBSTRING_INDEX(pSchema, '_', -1);
    SET @ERRMSG="START";
    SET @JudetCount = JSON_LENGTH(pJudetJson);
    SET @i = 0;
    SET @IdConsultant=0;
    SET @Rol="";
		SET @UserName="";
		
    -- Check if pIdConsultant is null or empty
    IF IFNULL(pIdConsultant,'') = '' THEN	
        SELECT IDC+1 INTO @IdConsultant FROM view_MaxIDC;
    ELSE
        SET @IdConsultant=pIdConsultant;
    END IF;

    -- Sanitize inputs
    SET @NumeConsultant=IF(IFNULL(pNumeConsultant,'')='',NULL,pNumeConsultant);
    SET @Telefon=IF(IFNULL(pTelefon,'')='',NULL,pTelefon);
    SET @Mail=IF(IFNULL(pMail,'')='',NULL,pMail);
    SET @IdRegiune=IF(IFNULL(pIdRegiune,'')='',NULL,pIdRegiune);
    SET @IdNivel=IF(IFNULL(pIdNivel,'')='',NULL,pIdNivel);
    SET @IdParinte=IF(IFNULL(pIdParinte,'')='',NULL,pIdParinte);
		SET @Suffix=IFNULL(pSuffix,"");
		
    -- If pIdConsultant is not provided, then add new user
    IF IFNULL(pIdConsultant,'')='' THEN
				-- If the new user is less than RM and no parent was provided, raise error.
        IF ISNULL(@IdParinte) AND @IdNivel < 40 THEN
						SET `OUT` = JSON_OBJECT("EROARE", 45000, "DESCRIERE", "Utilizatorul pe nivelul selectat TREBUIE sa aiba parinte!", "MODUL", "ADD_UTILIZATOR");
						LEAVE proc_label;
        END IF;

        -- Assign role based on @IdNivel
        CASE @IdNivel
            WHEN 10 THEN SET @Rol=CONCAT("CO_", @RoleNamePrefix);    -- UTILIZATOR
            WHEN 20 THEN SET @Rol=CONCAT("TL_", @RoleNamePrefix);    -- TEAM LEADER
            WHEN 30 THEN SET @Rol=CONCAT("CM_", @RoleNamePrefix);    -- CITY MANGER
            WHEN 40 THEN SET @Rol=CONCAT("RM_", @RoleNamePrefix);    -- REGIONAL
            WHEN 50 THEN SET @Rol=CONCAT("AD");                        -- ADMIN
        END CASE;

        -- Insert data into Consultanti table
        SET @ERRMSG='ADD_UTILIZATOR';
        SET @sql = CONCAT("INSERT INTO Consultanti (IdConsultant, IdNivel, IdRegiune, NumeConsultant, cMail, cTelefon, SchimbaParola, CodJudet, CodOras, Suffix, Nou) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)");

        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @IdConsultant, @IdNivel, @IdRegiune, @NumeConsultant, @Mail, @Telefon, TRUE, @Judet, @Oras, @Suffix;
        DEALLOCATE PREPARE stmt;
								
        -- If @IdParinte is provided, insert into Consultanti_Relatii
        IF IFNULL(@IdParinte,'')<>'' THEN
            SET @ERRMSG='ADD_RELATIE';
            SET @sql = CONCAT("INSERT INTO Consultanti_Relatii (IdParinte, IdCopil) VALUES (?, ?)");

            PREPARE stmt FROM @sql;
            EXECUTE stmt USING @IdParinte, @IdConsultant;
            DEALLOCATE PREPARE stmt;
        END IF;

        -- Insert into Consultanti_Judete for each region in pJudetJson
        SET @ERRMSG='ADD_JUDETE';
        WHILE @i < @JudetCount DO
            SET @IdJudet = JSON_EXTRACT(pJudetJson, CONCAT('$[', @i, '].IdJudet'));
            -- SET @IdRegiune = JSON_EXTRACT(pJudetJson, CONCAT('$[', @i, '].IdRegiune'));

            SET @sql = CONCAT("INSERT INTO Consultanti_Judete (IdJudet, IdRegiune, IdConsultant) VALUES (?, ?, ?)");

            PREPARE stmt FROM @sql;
            EXECUTE stmt USING @IdJudet, @IdRegiune, @IdConsultant;
            DEALLOCATE PREPARE stmt;

            SET @i = @i + 1;
        END WHILE;

        -- Create MySQL user
        SET @ERRMSG='CREATE_USER';
        SET @UserName = CONCAT(@Suffix, LPAD(@IdConsultant,3,'0'));
        SET @sql=CONCAT('CREATE USER \'', @UserName, '\'@"%" IDENTIFIED WITH mysql_native_password USING PASSWORD(\'Ad.Credit2023\') REQUIRE SSL;');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Grant role to MySQL user
        SET @ERRMSG='GRANT_ROLE';
        SET @sql=CONCAT('GRANT `', @Rol, '` TO `', @UserName, '`@`%`');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Set default role for MySQL user
        SET @ERRMSG='SET_DEFAULT_ROLE';
        SET @sql=CONCAT('SET DEFAULT ROLE `', @Rol, '` FOR `', @UserName, '`;');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        FLUSH PRIVILEGES;

        -- Set the output
        SET @OUT=JSON_OBJECT("IdConsultant",@UserName);
    ELSE
        -- If @IdParinte is not provided, check additional conditions
        IF ISNULL(@IdParinte) AND @IdNivel < 40 THEN
							SET `OUT` = JSON_OBJECT("EROARE", 45000, "DESCRIERE", "Utilizatorul pe nivelul selectat TREBUIE sa aiba parinte!", "MODUL", "MOD_UTILIZATOR");
							LEAVE proc_label;
        END IF;

        -- Update data in Consultanti table
        SET @ERRMSG='MOD_UTILIZATOR';
        SET @sql = CONCAT("UPDATE Consultanti SET IdNivel=?, IdRegiune=?, NumeConsultant=?, cMail=?, cTelefon=?, CodJudet=?, CodOras=? WHERE IdConsultant=?");

        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @IdNivel, @IdRegiune, @NumeConsultant, @Mail, @Telefon, @Judet, @Oras, @IdConsultant;
        DEALLOCATE PREPARE stmt;

        -- Remove existing entries in Consultanti_Judete for the user
        SET @ERRMSG='MOD_JUDETE';
        DELETE FROM Consultanti_Judete WHERE IdConsultant = @IdConsultant;

        -- Insert into Consultanti_Judete for each region in pJudetJson
        WHILE @i < @JudetCount DO
            SET @IdJudet = JSON_EXTRACT(pJudetJson, CONCAT('$[', @i, '].IdJudet'));
            -- SET @IdRegiune = JSON_EXTRACT(pJudetJson, CONCAT('$[', @i, '].IdRegiune'));

            SET @sql = CONCAT("INSERT INTO Consultanti_Judete (IdJudet, IdRegiune, IdConsultant) VALUES (?, ?, ?)");

            PREPARE stmt FROM @sql;
            EXECUTE stmt USING @IdJudet, @IdRegiune, @IdConsultant;
            DEALLOCATE PREPARE stmt;

            SET @i = @i + 1;
        END WHILE;

        -- If @IdParinte is provided, insert or update Consultanti_Relatii
        IF NOT ISNULL(@IdParinte) THEN
            SET @ERRMSG='MOD_RELATIE';
            SET @sql = CONCAT("INSERT INTO Consultanti_Relatii (IdParinte, IdCopil) VALUES (?,?) ON DUPLICATE KEY UPDATE IdParinte=?, IdCopil=?");
            PREPARE stmt FROM @sql;
            EXECUTE stmt USING @IdParinte, @IdConsultant,@IdParinte, @IdConsultant;
            DEALLOCATE PREPARE stmt;
        END IF;

        -- Set the output
        SET @OUT=JSON_OBJECT("IdConsultant",@IdConsultant);
    END IF;

    SET `OUT`=@OUT;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for procUtilizatori_Edit
-- ----------------------------
DROP PROCEDURE IF EXISTS `procUtilizatori_Edit`;
delimiter ;;
CREATE PROCEDURE `procUtilizatori_Edit`(IN `pSchema` VARCHAR(255),
    IN `pSuffix` VARCHAR(10),
    IN `pIdConsultant` INT,
    IN `pNumeConsultant` VARCHAR(255),
    IN `pTelefon` VARCHAR(255),
    IN `pMail` VARCHAR(255),
    IN `pIdRegiune` VARCHAR(255),
    IN `pIdNivel` VARCHAR(255),
    IN `pIdParinte` VARCHAR(255),
    IN `pJudetJson` JSON,
    OUT `OUT` VARCHAR(255))
proc_label: BEGIN	
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
            GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @text = MESSAGE_TEXT;

        SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
        ROLLBACK;
    END;
		
    -- Check if pIdConsultant is null or empty
    IF IFNULL(pIdConsultant,0) = 0 THEN	
				SET `OUT` = JSON_OBJECT("EROARE", 45000, "DESCRIERE", "Nu ai ce sa modifici! Lipsa IdConsultant!", "MODUL", "INIT_UTILIZATOR");
				LEAVE proc_label;        
    END IF;
		
		IF IFNULL(pIdParinte,'')='' AND IFNULL(pIdNivel,0) < 40 THEN
				SET `OUT` = JSON_OBJECT("EROARE", 45000, "DESCRIERE", "Utilizatorul pe nivelul selectat TREBUIE sa aiba parinte!", "MODUL", "INIT_UTILIZATOR");
				LEAVE proc_label;
		END IF;
		
    -- Initialization
    SET @RoleNamePrefix = SUBSTRING_INDEX(pSchema, '_', -1);
    SET @ERRMSG="START";
    SET @JudetCount = JSON_LENGTH(pJudetJson);
    SET @i = 0;
    SET @Rol="";
		SET @UserName="";


    -- Sanitize inputs
		SET @IdConsultant=pIdConsultant;
    SET @NumeConsultant=IF(IFNULL(pNumeConsultant,'')='',NULL,pNumeConsultant);
    SET @Telefon=IF(IFNULL(pTelefon,'')='',NULL,pTelefon);
    SET @Mail=IF(IFNULL(pMail,'')='',NULL,pMail);
    SET @IdRegiune=IF(IFNULL(pIdRegiune,'')='',NULL,pIdRegiune);
    SET @IdNivel=IF(IFNULL(pIdNivel,'')='',NULL,pIdNivel);
    SET @IdParinte=IF(IFNULL(pIdParinte,'')='',NULL,pIdParinte);
		SET @Suffix=IFNULL(pSuffix,"");

		-- Update data in Consultanti table
		SET @ERRMSG='MOD_UTILIZATOR';
		SET @sql = CONCAT("UPDATE Consultanti SET IdNivel=?, IdRegiune=?, NumeConsultant=?, cMail=?, cTelefon=? WHERE IdConsultant=?");

		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @IdNivel, @IdRegiune, @NumeConsultant, @Mail, @Telefon, @IdConsultant;
		DEALLOCATE PREPARE stmt;

		-- Remove existing entries in Consultanti_Judete for the user
		SET @ERRMSG='DEL_JUDETE';
		
		DELETE FROM Consultanti_Judete WHERE IdConsultant = @IdConsultant;

        -- Insert into Consultanti_Judete for each region in pJudetJson
		SET @ERRMSG='ADD_JUDETE';
		SET @sql='';
		
		WHILE @i < @JudetCount DO
				SET @IdJudet = JSON_EXTRACT(pJudetJson, CONCAT('$[', @i, '].IdJudet'));
		-- 		SET @IdRegiune = JSON_EXTRACT(pJudetJson, CONCAT('$[', @i, '].IdRegiune'));

				IF @sql = '' THEN
						SET @sql = CONCAT("INSERT INTO Consultanti_Judete (IdJudet, IdRegiune, IdConsultant) VALUES (", @IdJudet, ", ", @IdRegiune, ", ", @IdConsultant, ")");
				ELSE
						SET @sql = CONCAT(@sql, ", (", @IdJudet, ", ", @IdRegiune, ", ", @IdConsultant, ")");
				END IF;

				SET @i = @i + 1;
		END WHILE;

		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		-- If @IdParinte is provided, insert or update Consultanti_Relatii
		SET @ERRMSG='DEL_RELATII';
		
		DELETE FROM Consultanti_Relatii WHERE IdCopil = @IdConsultant;		
		
		SET @ERRMSG='ADD_RELATII';
		
		IF NOT ISNULL(@IdParinte) THEN
				SET @sql = CONCAT("INSERT INTO Consultanti_Relatii (IdParinte, IdCopil) VALUES (?,?)");
				PREPARE stmt FROM @sql;
				EXECUTE stmt USING @IdParinte, @IdConsultant;
				DEALLOCATE PREPARE stmt;
		END IF;

		-- Set the output
		SET @OUT=JSON_OBJECT("IdConsultant",@IdConsultant);

    SET `OUT`=@OUT;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for rapActivitateConsultanti
-- ----------------------------
DROP PROCEDURE IF EXISTS `rapActivitateConsultanti`;
delimiter ;;
CREATE PROCEDURE `rapActivitateConsultanti`(IN di DATE,
    IN dsf DATE,
    IN nivmax INT)
BEGIN
		-- Creează ierarhia consultanților
    WITH RECURSIVE Hierarchy AS (
        SELECT
            c.IdConsultant,
            c.IdParinte,
            c.IdNivel,
            c.NumeConsultant,
            c.cMail,
            c.cTelefon,
            c.DataAdaugare,
            c.Ascuns,
            0 AS HierarchyLevel,
            CAST(c.NumeConsultant AS CHAR(255) CHARSET utf8mb4) AS HierarchyPath
        FROM SVN_IM.Consultanti c
        WHERE c.IdParinte IS NULL
          AND c.Plecat = 0
          AND c.Sistem = 0

        UNION ALL

        SELECT
            c.IdConsultant,
            c.IdParinte,
            c.IdNivel,
            c.NumeConsultant,
            c.cMail,
            c.cTelefon,
            c.DataAdaugare,
            c.Ascuns,
            h.HierarchyLevel + 1,
            CONCAT(h.HierarchyPath, ',', c.NumeConsultant)
        FROM SVN_IM.Consultanti c
        JOIN Hierarchy h ON c.IdParinte = h.IdConsultant
        WHERE h.HierarchyLevel <= 8
    ),

		-- Creează lista tuturor lunilor din perioada selectată
		Luni AS (
				SELECT DATE_FORMAT(di,'%Y-%m-01') AS Luna
				UNION ALL
				SELECT DATE_ADD(Luna, INTERVAL 1 MONTH)
				FROM Luni
				WHERE Luna < DATE_FORMAT(dsf,'%Y-%m-01')
		),

		-- Dosarele filtrate și aggregate pe lună
    DosareFiltrate AS (
        SELECT 
            d.IdConsultant,
            DATE_FORMAT(d.DataDebursare,'%Y-%m-01') AS LunaStart,
            COUNT(*) AS NrDosare
        FROM Dosar d
        JOIN SVN_IM.Consultanti c ON d.IdConsultant = c.IdConsultant
        WHERE d.DataDebursare BETWEEN di AND dsf
          AND c.IdNivel <= nivmax
        GROUP BY d.IdConsultant, DATE_FORMAT(d.DataDebursare,'%Y-%m-01')
    )

		-- Rezultatul final
		SELECT
			h.IdConsultant,
			CONCAT(h.HierarchyPath, REPEAT(',', 6 - h.HierarchyLevel)) AS HierarchyPath,
			DATE(h.DataAdaugare) as DataAdaugare,
			COALESCE(SUM(df.NrDosare),0) AS NrDosareTotal,
			GROUP_CONCAT(COALESCE(df.NrDosare,'') ORDER BY l.Luna) AS Luni
    FROM Hierarchy h
    CROSS JOIN Luni l
    LEFT JOIN DosareFiltrate df 
      ON df.IdConsultant = h.IdConsultant
     AND df.LunaStart = l.Luna
    WHERE h.Ascuns = 0
    GROUP BY h.IdConsultant
    ORDER BY h.HierarchyPath;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for rapDosareTransferate
-- ----------------------------
DROP PROCEDURE IF EXISTS `rapDosareTransferate`;
delimiter ;;
CREATE PROCEDURE `rapDosareTransferate`(IN `DI` date,IN `DSF` date)
BEGIN
SELECT
	SVN_00.UpPath3(IdConsultant) as Parinti,
	Sursa,
	IdNivel,
	IdConsultant,
	NumeConsultant,
	NumarDosare,
	TipCredit,
	DataTransfer,
	FelStatus,
	TotalCredite,
	DATE(DataAdaugare) as DataAdaugareConsultant
FROM
	(
	SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, LPAD(IdConsultant,3,'0') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=40 AND Ascuns=0
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM Consultanti WHERE IdNivel=35 AND Ascuns=0 
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=30 AND Ascuns=0 
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=25 AND Ascuns=0 
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=20 AND Ascuns=0 
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=15 AND Ascuns=0 
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=10 AND Ascuns=0
) t
INNER JOIN (
	SELECT
		d.IdConsultant,
		COUNT(IdDosar) as NumarDosare,
		TipCredit,
		DataConectare as DataTransfer,
		FelStatus,
		SUM(ValoareCreditRON) as TotalCredite,
		Sursa
		
		-- REPLACE(GROUP_CONCAT(DATE_FORMAT(DataConectare,'%d.%m.%Y')),',','\n') as DateTransferuri
	FROM
		Dosar as d
		INNER JOIN Baza_FeedBack as bf USING (IdBaza)
		INNER JOIN Dosar_TipCredit as dtc USING (IdTipCredit)
		INNER JOIN Dosar_Status as dst ON d.IdStatus=dst.IdStatus 
		INNER JOIN SursaLead as s ON d.IdSursa=s.IdSursa
	WHERE
		bf.IDSG = 1 AND bf.DataConectare BETWEEN DI AND DSF
	GROUP BY
		IdConsultant,
		IdBaza
	) as tblTransferuri USING (IdConsultant)
;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for rapDosareTrase
-- ----------------------------
DROP PROCEDURE IF EXISTS `rapDosareTrase`;
delimiter ;;
CREATE PROCEDURE `rapDosareTrase`(IN `DI` date,IN `DSF` date)
BEGIN
SELECT
	SVN_00.UpPath3(IdConsultant) as Parinti,
	Sursa,
	IdNivel,
	IdConsultant,
	NumeConsultant,
	NumarDosare,
	TipCredit,
	DataTragere,
	TotalCredite,
	DATE(DataAdaugare) as DataAdaugareConsultant
FROM
	(
	SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, LPAD(IdConsultant,3,'0') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=40 AND Ascuns=0
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM Consultanti WHERE IdNivel=35 AND Ascuns=0 
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=30 AND Ascuns=0 
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=25 AND Ascuns=0 
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=20 AND Ascuns=0 
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=15 AND Ascuns=0 
	UNION ALL SELECT IdConsultant, IdNivel, NumeConsultant, cMail, cTelefon, DataAdaugare, Replace(`SVN_00`.UpPath2(IdConsultant),LPAD(IdConsultant,3,'0'),'') as Path FROM `SVN_00`.Consultanti WHERE IdNivel=10 AND Ascuns=0
) t
INNER JOIN (
	SELECT
		d.IdConsultant,
		COUNT(IdDosar) as NumarDosare,
		TipCredit,
		DATE_FORMAT(DataDebursare,'%m#%Y') as DataTragere,
		SUM(ValoareCreditRON) as TotalCredite,
		Sursa
		
		-- REPLACE(GROUP_CONCAT(DATE_FORMAT(DataConectare,'%d.%m.%Y')),',','\n') as DateTransferuri
	FROM
		Dosar as d
		INNER JOIN Dosar_TipCredit as dtc USING (IdTipCredit)
		INNER JOIN SursaLead as s ON d.IdSursa=s.IdSursa
	WHERE
		d.DataDebursare BETWEEN DI AND DSF
	GROUP BY
		IdConsultant,
		IdDosar
	) as tblTransferuri USING (IdConsultant) -- WHERE Sursa='IPOTECARE.RO'
;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for rocDosar_Add
-- ----------------------------
DROP PROCEDURE IF EXISTS `rocDosar_Add`;
delimiter ;;
CREATE PROCEDURE `rocDosar_Add`(IN `TIP` VARCHAR (255),
	IN `IdDosar` VARCHAR (255),
	IN `IdBaza` VARCHAR (255),
	IN `IdClient` VARCHAR (255),
	IN `IdConsultant` VARCHAR (255),
	IN `IdSursa` VARCHAR (255),
	IN `IdAgent` VARCHAR (255),
	IN `IdStatus` VARCHAR (255),
	IN `IdStare` VARCHAR (255),
	IN `Codebitor` VARCHAR (255),
	IN `NumeCodebitor` VARCHAR (255),
	IN `IdMotiv` VARCHAR (255),
	IN `ObservatiiFinale` VARCHAR (255),
	IN `JSONVenit` JSON, -- 	IN `IdVenit` VARCHAR (255),	IN `Venit` VARCHAR (255), 	IN `TipCredit` VARCHAR (255),	IN `IdTipMoneda` VARCHAR (255),	IN `PerioadaCredit` VARCHAR (255),	IN `ValoareCredit` VARCHAR (255),	IN `IdTipDobanda` VARCHAR (255),	IN `Dobanda` VARCHAR (255),	IN `CursMoneda` DOUBLE,
	IN `JSONBanca` JSON, -- 	IN `IdBanca` VARCHAR (255),	IN `IdSucursala` VARCHAR (255),	IN `ConsilierBanca` VARCHAR (255),	IN `CodBanca` VARCHAR (255),
	IN `JSONFunctie` JSON, -- IN `IdFunctie` VARCHAR (255),IN `IdFunctieFunctie` VARCHAR (255),IN `IdCompanie` VARCHAR (255),IN `IdDomeniu` VARCHAR (255),IN `Domeniu` VARCHAR (255),IN `Functie` VARCHAR (255),IN `Companie` VARCHAR (255),IN `TipCompanie` VARCHAR (255),
	IN `JSONFeedback` JSON, -- IN `IdFeedBack` VARCHAR (255),	IN `IdStatusFeedback` VARCHAR (255),	IN `FeedBack` VARCHAR (1000),	IN `DataConectare` VARCHAR (255),	IN `DataReconectare` VARCHAR (255),
	IN `JSONDate` JSON, -- IN `DataDebursare` VARCHAR (255),	IN `DataRespingere` VARCHAR (255), IN `DataOpinieJ` VARCHAR (255), IN `DataPreaprobare` VARCHAR (255), IN `DataTrimitere` VARCHAR (255)
	OUT `OUT` VARCHAR (2000))
BEGIN

	DECLARE num_items INT;
	DECLARE i INT DEFAULT 0;
	DECLARE pfn VARCHAR(10);
	DECLARE psf VARCHAR(10);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
 			ROLLBACK; 
		BEGIN
			GET DIAGNOSTICS CONDITION 1
			@sqlstate = RETURNED_SQLSTATE,
			@errno = MYSQL_ERRNO,
			@text = MESSAGE_TEXT;

			SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
			ROLLBACK;
		END; 
	END;

	SET @ERRMSG="START";

	SET @TIP = IFNULL(`TIP`,'');
	-- extract json
	-- Functie
	SET @IdFunctie = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdFunctie')), 'null');
	SET pfn=CAST(IFNULL(@IdFunctie,0) AS INT);
	SET @IdCompanie = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdCompanie')), 'null');
	SET @IdDomeniu = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdDomeniu')), 'null');
	SET @IdFunctieFunctie = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdFunctieFunctie')), 'null');
	SET @IdTipCompanie = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdTipCompanie')), 'null');

	-- Banca
	SET @IdBanca = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdBanca')), 'null');
	SET @IdSucursala = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdSucursala')), 'null');
	SET @ConsilierBanca = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.ConsilierBanca')), 'null');
	SET @CodBanca = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.CodBanca')), 'null');
	SET @CursMoneda = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.CursMoneda')), 'null');
	SET @IdNotar = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdNotar')),'null');
	SET @IdEvaluator = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdEvaluator')),'null');

	-- Venit
	SET @IdVenit = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdVenit')), 'null');
	SET @Venit = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.Venit')), 'null');

	SET @IdTipImobil = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipImobil')), 'null');
	SET @AreImobil = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.AreImobil')), 'null');
	SET @ValoareImobil = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.ValoareImobil')), 'null');
	
	SET @IdTipCredit = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipCredit')), 'null');
	SET @PerioadaCredit = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.PerioadaCredit')), 'null');
	SET @IdTipMoneda = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipMoneda')), 'null');
	SET @ValoareCredit = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.ValoareCredit')), 'null');
	
	SET @IdTipDobanda = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipDobanda')), 'null');
	SET @Dobanda = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.Dobanda')), 'null');
	SET @MarjaDobanda = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.MarjaDobanda')), 'null');
	SET @MarjaDobandaDF = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.MarjaDobandaDF')), 'null');
	SET @PerioadaDobanda = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.PerioadaDobanda')), 'null');
	
	-- Feedback
	SET @IdFeedBack = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFeedback, '$.IdFeedBack')), 'null');
	SET @IdStatusFeedback = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFeedback, '$.IdStatusFeedback')), 'null');
	SET psf=CAST(IFNULL(@IdFeedBack,0) AS INT);
	SET @DataConectare = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFeedback, '$.DataConectare')), 'null') AS DATE);
	SET @DataReconectare = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFeedback, '$.DataReconectare')), 'null') AS DATE);
	SET @FeedBack = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONFeedback, '$.FeedBack')), 'null');

	-- Date
	SET @DataIntroducere = NOW();
	SET @DataDebursare = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataDebursare')), 'null') AS DATE);
	SET @DataRespingere = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataRespingere')), 'null') AS DATE);
	SET @DataOpinieJ = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataOpinieJ')), 'null') AS DATE);
	SET @DataPreaprobare = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataPreaprobare')), 'null') AS DATE);
	SET @DataTrimitere = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataTrimitere')), 'null') AS DATE);


	-- iduri
	SET @IdDosar = NULLIF(IFNULL(IdDosar, ''), 'null');
	SET @IdBaza = NULLIF(IFNULL(IdBaza, ''), 'null');
	SET @IdClient = NULLIF(IFNULL(IdClient, ''), 'null');
	SET @IdConsultant = NULLIF(IFNULL(IdConsultant, ''), 'null');
	SET @IdSursa = NULLIF(IFNULL(IdSursa, ''), 'null');
	SET @IdAgent = NULLIF(IFNULL(IdAgent, ''), 'null');
	SET @IdStatus = NULLIF(IFNULL(IdStatus, ''), 'null');
	SET @IdStare = NULLIF(IFNULL(IdStare, ''), 'null');
	SET @IdMotiv = NULLIF(IdMotiv, '');
	
	-- alti parametri
	SET @Codebitor = CAST(Codebitor AS INT);
	SET @NumeCodebitor = NULLIF(NumeCodebitor, 'null');
	SET @ObservatiiFinale = NULLIF(ObservatiiFinale, 'null');

	SELECT  @TIP, CAST(JSON_OBJECT('IdFunctie',@IdFunctie,'IdCompanie',@IdCompanie,'IdDomeniu',@IdDomeniu,'IdFunctieFunctie',@IdFunctieFunctie,'IdTipCompanie',@IdTipCompanie,'IdBanca',@IdBanca,'IdSucursala',@IdSucursala,'ConsilierBanca',@ConsilierBanca,'CodBanca',@CodBanca,'CursMoneda',@CursMoneda,'IdVenit',@IdVenit,'Venit',@Venit,'IdTipImobil',@IdTipImobil,'AreImobil',@AreImobil,'ValoareImobil',@ValoareImobil,'IdTipCredit',@IdTipCredit,'PerioadaCredit',@PerioadaCredit,'IdTipMoneda',@IdTipMoneda,'ValoareCredit',@ValoareCredit,'IdTipDobanda',@IdTipDobanda,'Dobanda',@Dobanda,'MarjaDobanda',@MarjaDobanda,'MarjaDobandaDF',@MarjaDobandaDF,'PerioadaDobanda',@PerioadaDobanda,'IdFeedBack',@IdFeedBack,'IdStatusFeedback',@IdStatusFeedback,'DataConectare',@DataConectare,'DataReconectare',@DataReconectare,'FeedBack',@FeedBack,'DataDebursare',@DataDebursare,'DataRespingere',@DataRespingere,'DataOpinieJ',@DataOpinieJ,'DataPreaprobare',@DataPreaprobare,'DataTrimitere',@DataTrimitere,'IdDosar',@IdDosar,'IdBaza',@IdBaza,'IdClient',@IdClient,'IdConsultant',@IdConsultant,'IdSursa',@IdSursa,'IdAgent',@IdAgent,'IdStatus',@IdStatus,'IdStare',@IdStare,'IdMotiv',@IdMotiv,'Codebitor',@Codebitor,'NumeCodebitor',@NumeCodebitor,'ObservatiiFinale',@ObservatiiFinale) AS VARCHAR(1000)) AS json_result, pfn, psf;
	
	SET @ERRMSG=NULL;

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	
	START TRANSACTION;
	
	IF IFNULL(@IdFunctie,'')='' THEN -- se adauga functie noua
		SET @ERRMSG='ADD_FUNCTIE';
		
		SET @sql = "INSERT INTO Dosar_Functii (IdClient,IdFunctieFunctie,IdDomeniu,IdCompanie,IdTipCompanie) SELECT ?,?,?,?,?;";
		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @IdClient,@IdFunctieFunctie,@IdDomeniu,@IdCompanie,@IdTipCompanie;
		DEALLOCATE PREPARE stmt;

		SET @IdFunctie=LAST_INSERT_ID();
	END IF;
	
	CASE 
		WHEN @TIP IN ('ADD','TRA') THEN

			SET @ERRMSG='ADD_DOSAR'; -- adaugare Dosar
			SET @sql = "
				INSERT INTO Dosar (
					IdBaza, IdClient, IdConsultant, IdAgent, IdSursa, 
					IdBanca, IdSucursala, ConsilierBanca, CodBanca, IdEvaluator, IdNotar, 
					IdFunctie, IdFunctieFunctie, IdDomeniu, IdCompanie, IdTipCompanie,
					IdStare, IdStatus, IdMotiv, 
					IdVenit, Venit, 
					IdTipImobil, AreImobil, ValoareImobil, 
					IdTipCredit, IdTipMoneda, PerioadaCredit, ValoareCredit, CursMoneda, 
					IdTipDobanda, Dobanda, MarjaDobanda, MarjaDobandaDF, PerioadaDobanda, 
					Codebitor, NumeCodebitor, 
					DataIntroducere, DataPreaprobare, DataOpinieJ, DataTrimitere, DataDebursare, DataRespingere,
					ObservatiiFinale
					) 
				VALUES 
					(
					?, ?, ?, ?, ?, 
					?, ?, ?, ?, ?, ?,
					?, ?, ?, ?, ?,
					?, ?, ?, 
					?, ?,
					?, ?, ?, 
					?, ?, ?, ?, ?,
					?, ?, ?, ?, ?,
					?, ?,
					?, ?, ?, ?, ?, ?,
					?
					)";

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING 
					@IdBaza, @IdClient, @IdConsultant, @IdAgent, @IdSursa, 
					@IdBanca, @IdSucursala, @ConsilierBanca, @CodBanca, @IdEvaluator, @IdNotar, 
					@IdFunctie, @IdFunctieFunctie, @IdDomeniu, @IdCompanie, @IdTipCompanie,
					@IdStare, @IdStatus, @IdMotiv, 
					@IdVenit, @Venit, 
					@IdTipImobil, @AreImobil, @ValoareImobil, 
					@IdTipCredit, @IdTipMoneda, @PerioadaCredit, @ValoareCredit, @CursMoneda, 
					@IdTipDobanda, @Dobanda, @MarjaDobanda, @MarjaDobandaDF, @PerioadaDobanda, 
					@Codebitor, @NumeCodebitor, 
					@DataIntroducere, @DataPreaprobare, @DataOpinieJ, @DataTrimitere, @DataDebursare, @DataRespingere, 
					@ObservatiiFinale;

			DEALLOCATE PREPARE stmt;

			SET @IdDosar=LAST_INSERT_ID(); 

			IF IFNULL(@IdStatusFeedback,'')<>'' THEN -- doar daca exista un FeedBack
				SET @ERRMSG='ADD_FEEDBACK'; -- adaugare FeedBack

				SET @sql = "INSERT INTO Dosar_FeedBack (IdDosar, IdStatus, IdConsultant, DataConectare, FeedBack, DataReconectare, Primar) 
										SELECT ?, ?, ?, ?, ?, ?, 1";

				PREPARE stmt FROM @sql;
				EXECUTE stmt USING @IdDosar, @IdStatusFeedback, @IdConsultant, @DataConectare, @FeedBack, @DataReconectare;
				DEALLOCATE PREPARE stmt;
				
				SET @IdFeedBack=LAST_INSERT_ID();
			END IF;
			
			IF @TIP='TRA' THEN
				SET @ERRMSG='UPD_FEEDBACK_OLD';
				UPDATE Baza_FeedBack SET Primar=0 WHERE IdBaza=@IdBaza;
				
				SET @ERRMSG='ADD_FEEDBACK_BAZA';
				SET @sql = "INSERT INTO Baza_FeedBack (IdBaza, IdStatus, IDSG, IdConsultant, DataConectare, FeedBack, Primar) SELECT ?, 1, 1, ?, ?, 'Transferat în Analiză Bancară', 1";

				PREPARE stmt FROM @sql;
				EXECUTE stmt USING @IdBaza, @IdConsultant, @DataIntroducere;
				DEALLOCATE PREPARE stmt;
				
				SET @IdFeedBackBaza = LAST_INSERT_ID();
			END IF;
															
		WHEN 'ADDF' THEN
			SET @ERRMSG='UPD_FEEDBACK_OLD';
			UPDATE Dosar_FeedBack SET Primar=0 WHERE IdDosar=@IdDosar;
			
			SET @ERRMSG='ADDF_FEEDBACK';
			SET @sql = "INSERT INTO Dosar_FeedBack (IdDosar, IdStatusFeedback, IdConsultant, DataConectare, FeedBack, DataReconectare, Primar) 
									SELECT ?, ?, ?, ?, ?, ?, 1";

			PREPARE stmt FROM @sql;
			EXECUTE stmt USING @IdDosar, @IdStatusFeedback, @IdConsultant, @DataConectare, @FeedBack, @DataReconectare;
			DEALLOCATE PREPARE stmt;
			
	END CASE;
	
	COMMIT;
			
	SET @ERRMSG='PRELUARE_DATE';
	
	SELECT D.IdDosar,D.IdBaza,D.IdClient,D.IdConsultant,D.IdAgent,D.IdSursa,D.IdFunctie,D.IdBanca,D.IdSucursala,D.IdStare,D.IdStatus,D.IdDomeniu,D.IdFunctieFunctie,D.IdTipCompanie,D.IdCompanie,D.IdEvaluator,D.IdMotiv,D.IdNotar,D.IdTipImobil,D.IdVenit,D.IdTipDobanda,D.IdTipMoneda,D.IdTipCredit,D.Venit,D.ValoareCredit,D.PerioadaCredit,D.PerioadaDobanda,D.Dobanda,D.NumeCodebitor,D.MarjaDobanda,D.MarjaDobandaDF,D.ValoareImobil,D.ConsilierBanca,D.CodBanca,D.DataIntroducere,D.DataPreaprobare,D.DataOpinieJ,D.DataTrimitere,D.DataDebursare,D.DataRespingere,D.CursMoneda,D.Codebitor,D.AreImobil,D.ObservatiiFinale,DS.Stare,DSt.FelStatus,DSt.TipStatus,DSt.IDSG,B.DataPrimire,Cl.NumeClient,Cl.CNPClient,Cl.TelefonP AS TelefonClient,Cl.EmailP AS EmailClient,Cl.DataNastere,Cl.IdJudet,C.NumeConsultant,C.cTelefon,C.cMail,A.NumeAgent,SL.Sursa,DFD.Domeniu,DFTC.TipCompanie,DFF.Functie,DFC.Companie,Bc.Banca,S.Sucursala,DTV.TipVenit,DTD.TipDobanda,DTM.Moneda,DTC.TipCredit,DFB.IdFeedBack,DFB.IdStatusFeedBack,DFB.DataConectare,DFB.DataReconectare,DN.Notar,DE.Evaluator,DTI.TipImobil,DM.Motiv,0 AS DIF,0 AS aDIF,0 AS cDIF,0 AS OLD,D.DataModificare,'Dosar' AS TblName,'IdDosar' AS IdName 
	FROM ((((((((((((((((((((((
	Dosar D 
	JOIN Dosar_Stare DS ON (D.IdStare=DS.IdStare)) 
	JOIN Dosar_Status DSt ON (D.IdStatus=DSt.IdStatus)) 
	JOIN Baza B ON (D.IdBaza=B.IdBaza)) 
	JOIN Agenti A ON (D.IdAgent=A.IdAgent)) 
	JOIN Consultanti C ON (D.IdConsultant=C.IdConsultant)) 
	JOIN Clienti Cl ON (D.IdClient=Cl.IdClient)) 
	JOIN SursaLead SL ON (D.IdSursa=SL.IdSursa)) 
	JOIN Dosar_Functii_Companie DFC ON (D.IdCompanie=DFC.IdCompanie)) 
	JOIN Dosar_Functii_Domeniu DFD ON (D.IdDomeniu=DFD.IdDomeniu)) 
	JOIN Dosar_Functii_Functie DFF ON (D.IdFunctieFunctie=DFF.IdFunctieFunctie)) 
	JOIN Dosar_Functii_TipCompanie DFTC ON (D.IdTipCompanie=DFTC.IdTipCompanie)) 
	JOIN Banci Bc ON (D.IdBanca=Bc.IdBanca))
	JOIN Sucursale S ON (D.IdSucursala=S.IdSucursala)) 
	JOIN Dosar_TipVenit DTV ON (D.IdVenit=DTV.IdVenit)) 
	LEFT JOIN Dosar_TipDobanda DTD ON (D.IdTipDobanda=DTD.IdTipDobanda)) 
	JOIN Dosar_TipMoneda DTM ON (D.IdTipMoneda=DTM.IdTipMoneda)) 
	JOIN Dosar_TipCredit DTC ON (D.IdTipCredit=DTC.IdTipCredit)) 
	LEFT JOIN (
	SELECT DFF.IdFeedBack,DFF.IdDosar,DFF.IdStatusFeedback,DFF.DataConectare,DFF.DataReconectare FROM (Dosar_FeedBack DFF JOIN (
	SELECT max(Dosar_FeedBack.IdFeedBack) AS IdFeedBack FROM Dosar_FeedBack GROUP BY Dosar_FeedBack.IdDosar) df ON (DFF.IdFeedBack=df.IdFeedBack))) DFB ON (D.IdDosar=DFB.IdDosar)) 
	LEFT JOIN Dosar_Notari DN ON (D.IdNotar=DN.IdNotar)) 
	LEFT JOIN Dosar_Evaluatori DE ON (D.IdEvaluator=DE.IdEvaluator)) 
	LEFT JOIN Dosar_TipImobil DTI ON (D.IdTipImobil=DTI.IdTipImobil)) 
	LEFT JOIN Dosar_Motiv DM ON (D.IdMotiv=DM.IdMotiv)) 
	WHERE D.IdDosar=@IdDosar;
							
	IF psf=0 AND @IdFeedBack<>0 THEN -- s-a adaugat si feedback, deci il iau si pe el
		SELECT IdFeedBack,IdStatusFeedback,IdDosar,DataConectare,FeedBack,DataReconectare,FelStatusFeedback,'Dosar_FeedBack' as TblName, 'IdFeedBack' as IdName  
		FROM Dosar_FeedBack df 
		JOIN Dosar_FeedBack_Status dfs USING (IdStatusFeedBack) 
		JOIN (SELECT max(IdFeedBack) AS IdFeedBack FROM Dosar_FeedBack WHERE IdDosar=@IdDosar) dfm USING (IdFeedBack) 
		WHERE IdDosar=@IdDosar;
	END IF;			
	
	IF pfn=0 AND @IdFunctie<> 0 THEN
		SELECT IdFunctie,IdClient,IdFunctieFunctie,IdCompanie,IdDomeniu,IdTipCompanie,Ascuns,DataModificare,'Dosar_Functii' as TblName, 'IdFunctie' as IdName FROM Dosar_Functii WHERE IdFunctie=@IdFunctie;
	END IF;
	
SET `OUT`=JSON_OBJECT('IdDosar',@IdDosar,'IdFunctie',@IdFunctie,'IdFeedBack',@IdFeedBack);	

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for rocDosar_Mod
-- ----------------------------
DROP PROCEDURE IF EXISTS `rocDosar_Mod`;
delimiter ;;
CREATE PROCEDURE `rocDosar_Mod`(IN `TIP` VARCHAR (255),
	IN `IdDosar` VARCHAR (255),
	IN `IdBaza` VARCHAR (255),
	IN `IdClient` VARCHAR (255),
	IN `IdConsultant` VARCHAR (255),
	IN `IdSursa` VARCHAR (255),
	IN `IdAgent` VARCHAR (255),
	IN `IdStatus` VARCHAR (255),
	IN `IdStare` VARCHAR (255),
	IN `Codebitor` VARCHAR (255),
	IN `NumeCodebitor` VARCHAR (255),
	IN `IdMotiv` VARCHAR (255),
	IN `ObservatiiFinale` VARCHAR (2000),
	IN `JSONVenit` JSON, -- 	IN `IdVenit` VARCHAR (255),	IN `Venit` VARCHAR (255), 	IN `TipCredit` VARCHAR (255),	IN `IdTipMoneda` VARCHAR (255),	IN `PerioadaCredit` VARCHAR (255),	IN `ValoareCredit` VARCHAR (255),	IN `IdTipDobanda` VARCHAR (255),	IN `Dobanda` VARCHAR (255),	IN `CursMoneda` DOUBLE,
	IN `JSONBanca` JSON, -- 	IN `IdBanca` VARCHAR (255),	IN `IdSucursala` VARCHAR (255),	IN `ConsilierBanca` VARCHAR (255),	IN `CodBanca` VARCHAR (255),
	IN `JSONFunctie` VARCHAR(2000), -- IN `IdFunctie` VARCHAR (255),IN `IdFunctieFunctie` VARCHAR (255),IN `IdCompanie` VARCHAR (255),IN `IdDomeniu` VARCHAR (255),IN `Domeniu` VARCHAR (255),IN `Functie` VARCHAR (255),IN `Companie` VARCHAR (255),IN `TipCompanie` VARCHAR (255),
	IN `JSONFeedback` JSON, -- IN `IdFeedBack` VARCHAR (255),	IN `IdStatusFeedback` VARCHAR (255),	IN `FeedBack` VARCHAR (1000),	IN `DataConectare` VARCHAR (255),	IN `DataReconectare` VARCHAR (255),
	IN `JSONDate` JSON, -- IN `DataDebursare` VARCHAR (255),	IN `DataRespingere` VARCHAR (255), IN `DataOpinieJ` VARCHAR (255), IN `DataPreaprobare` VARCHAR (255), IN `DataTrimitere` VARCHAR (255)
	OUT `OUT` VARCHAR (2000))
BEGIN
	DECLARE num_items INT;
	DECLARE i INT DEFAULT 0;
	DECLARE pfn VARCHAR(10);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
 			ROLLBACK; 
		BEGIN
			GET DIAGNOSTICS CONDITION 1
			@sqlstate = RETURNED_SQLSTATE,
			@errno = MYSQL_ERRNO,
			@text = MESSAGE_TEXT;

			SET `OUT` = JSON_OBJECT("EROARE", @errno, "DESCRIERE", @text, "MODUL", @ERRMSG);
			ROLLBACK;
		END; 
	END;
	
	s: BEGIN
	SELECT  JSONVenit, JSONBanca, JSONFunctie, JSONFeedback, JSONDate;
	LEAVE s;	
	-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

	SET @ERRMSG="START";

	SET @TIP = IFNULL(`TIP`,'');
	-- extract json
	-- Functie
	SET @IdFunctie = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdFunctie')) AS INT);
	SET pfn=CAST(IFNULL(@IdFunctie,0) AS INT);
	SET @IdCompanie = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdCompanie')) AS INT);
	SET @IdDomeniu = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdDomeniu')) AS INT);
	SET @IdFunctieFunctie = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdFunctieFunctie')) AS INT);
	SET @IdTipCompanie = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONFunctie, '$.IdTipCompanie')) AS INT);

	-- Banca
	SET @IdBanca = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdBanca')) AS INT);
	SET @IdSucursala = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdSucursala')) AS INT);
	SET @ConsilierBanca = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.ConsilierBanca')), 'NULL');
	SET @CodBanca = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.CodBanca')),'NULL');
	SET @CursMoneda = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.CursMoneda')) AS INT);
	SET @IdNotar = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdNotar')),'null');
	SET @IdEvaluator = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(JSONBanca, '$.IdEvaluator')),'null');
	-- Venit
	SET @IdVenit = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdVenit')) AS INT);
	SET @Venit = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.Venit')) AS INT);

	SET @IdTipImobil = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipImobil')) AS INT);
	SET @AreImobil = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.AreImobil')) AS INT);
	SET @ValoareImobil = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.ValoareImobil')) AS INT);
	
	SET @IdTipCredit = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipCredit')) AS INT);
	SET @PerioadaCredit = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.PerioadaCredit')) AS INT);
	SET @IdTipMoneda = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipMoneda')) AS INT);
	SET @ValoareCredit = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.ValoareCredit')) AS INT);
	
	SET @IdTipDobanda = CAST(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.IdTipDobanda')) AS INT);
	SET @Dobanda = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.Dobanda')),0),'NULL');
	SET @MarjaDobanda = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.MarjaDobanda')),0),'NULL');
	SET @MarjaDobandaDF = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.MarjaDobandaDF')),0),'NULL');
	SET @PerioadaDobanda = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONVenit, '$.PerioadaDobanda')),0),'NULL');

	-- Date
	SET @DataDebursare = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataDebursare')), 'null'),'null');
	SET @DataRespingere =IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataRespingere')), 'null'),'null');
	SET @DataOpinieJ = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataOpinieJ')), 'null'),'null');
	SET @DataPreaprobare = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataPreaprobare')), 'null'),'null');
	SET @DataTrimitere = IFNULL(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(JSONDate, '$.DataTrimitere')), 'null'),'null');

	IF IFNULL(@DataDebursare,'null')<>'null' THEN SET @DataDebursare=CONCAT("'",@DataDebursare,"'"); END IF;
	IF IFNULL(@DataRespingere,'null')<>'null' THEN SET @DataRespingere=CONCAT("'",@DataRespingere,"'"); END IF;
	IF IFNULL(@DataOpinieJ,'null')<>'null' THEN SET @DataOpinieJ=CONCAT("'",@DataOpinieJ,"'"); END IF;
	IF IFNULL(@DataPreaprobare,'null')<>'null' THEN SET @DataPreaprobare=CONCAT("'",@DataPreaprobare,"'"); END IF;
	IF IFNULL(@DataTrimitere,'null')<>'null' THEN SET @DataTrimitere=CONCAT("'",@DataTrimitere,"'"); END IF;
	
	-- iduri
	SET @IdDosar = CAST(IdDosar as INT);
	SET @IdStatus = CAST(IdStatus AS INT);
	SET @IdStare = CAST(IdStare AS INT);
	SET @IdMotiv = IFNULL(NULLIF(CAST(IdMotiv AS INT),''),'null');
	
	-- alti parametri
	SET @Codebitor = CAST(Codebitor AS INT);
	SET @NumeCodebitor = IFNULL(NULLIF(NumeCodebitor,''),'null');
	SET @ObservatiiFinale = IFNULL(NULLIF(ObservatiiFinale,''),'null');
	
	SET @ERRMSG=NULL;

	SELECT  @TIP, CAST(JSON_OBJECT('IdFunctie',@IdFunctie,'IdCompanie',@IdCompanie,'IdDomeniu',@IdDomeniu,'IdFunctieFunctie',@IdFunctieFunctie,'IdTipCompanie',@IdTipCompanie,'IdBanca',@IdBanca,'IdSucursala',@IdSucursala,'ConsilierBanca',@ConsilierBanca,'CodBanca',@CodBanca,'CursMoneda',@CursMoneda,'IdVenit',@IdVenit,'Venit',@Venit,'IdTipImobil',@IdTipImobil,'AreImobil',@AreImobil,'ValoareImobil',@ValoareImobil,'IdTipCredit',@IdTipCredit,'PerioadaCredit',@PerioadaCredit,'IdTipMoneda',@IdTipMoneda,'ValoareCredit',@ValoareCredit,'IdTipDobanda',@IdTipDobanda,'Dobanda',@Dobanda,'MarjaDobanda',@MarjaDobanda,'MarjaDobandaDF',@MarjaDobandaDF,'PerioadaDobanda',@PerioadaDobanda,'DataDebursare',@DataDebursare,'DataRespingere',@DataRespingere,'DataOpinieJ',@DataOpinieJ,'DataPreaprobare',@DataPreaprobare,'DataTrimitere',@DataTrimitere,'IdDosar',@IdDosar,'IdStatus',@IdStatus,'IdStare',@IdStare,'IdMotiv',@IdMotiv,'Codebitor',@Codebitor,'NumeCodebitor',@NumeCodebitor,'ObservatiiFinale',@ObservatiiFinale,'IdNotar',@IdNotar,'IdEvaluator',@IdEvaluator) AS VARCHAR(2000)) AS json_result, pfn, 'TEST' as TblName;
		
	-- START TRANSACTION;
	
	IF IFNULL(@IdFunctie,'')='' THEN -- se adauga functie noua
		SET @ERRMSG='ADD_FUNCTIE';
		
		SET @sql = "INSERT INTO Dosar_Functii (IdClient,IdFunctieFunctie,IdDomeniu,IdCompanie,IdTipCompanie) SELECT ?,?,?,?,?;";
		PREPARE stmt FROM @sql;
		EXECUTE stmt USING @IdClient,@IdFunctieFunctie,@IdDomeniu,@IdCompanie,@IdTipCompanie;
		DEALLOCATE PREPARE stmt;

		SET @IdFunctie=LAST_INSERT_ID();
	END IF;
					
	SET @ERRMSG='MOD_DOSAR'; -- modificare Dosar
	
	/*SET @sql = "UPDATE Dosar SET
		IdBanca=?, IdSucursala=?, ConsilierBanca=?, CodBanca=?, IdEvaluator=?, IdNotar=?, 
		IdFunctie=?, IdFunctieFunctie=?, IdDomeniu=?, IdCompanie=?, IdTipCompanie=?,
		IdStare=?, IdStatus=?, IdMotiv=?, 
		IdVenit=?, Venit=?, 
		IdTipImobil=?, AreImobil=?, ValoareImobil=?, 
		IdTipCredit=?, IdTipMoneda=?, PerioadaCredit=?, ValoareCredit=?, CursMoneda=?, 
		IdTipDobanda=?, Dobanda=?, MarjaDobanda=?, MarjaDobandaDF=?, PerioadaDobanda=?, 
		Codebitor=?, NumeCodebitor=?, 
		DataPreaprobare=?, DataOpinieJ=?, DataTrimitere=?, DataDebursare=?, DataRespingere=?,
		ObservatiiFinale=?
	WHERE IdDosar = ?";

	PREPARE stmt FROM @sql;
	EXECUTE stmt USING
		@IdBanca, @IdSucursala, @ConsilierBanca, @CodBanca, @IdEvaluator, @IdNotar, 
		@IdFunctie, @IdFunctieFunctie, @IdDomeniu, @IdCompanie, @IdTipCompanie,
		@IdStare, @IdStatus, @IdMotiv, 
		@IdVenit, @Venit, 
		@IdTipImobil, @AreImobil, @ValoareImobil, 
		@IdTipCredit, @IdTipMoneda, @PerioadaCredit, @ValoareCredit, @CursMoneda, 
		@IdTipDobanda, @Dobanda, @MarjaDobanda, @MarjaDobandaDF, @PerioadaDobanda, 
		@Codebitor, @NumeCodebitor, 
		@DataPreaprobare, @DataOpinieJ, @DataTrimitere, @DataDebursare, @DataRespingere, 
		@ObservatiiFinale,
		@pIdDosar;
	DEALLOCATE PREPARE stmt;*/
	SET @sql = CONCAT_WS("",
			"UPDATE Dosar SET ",
			"IdBanca = ", @IdBanca, ", ",
			"IdSucursala = ", @IdSucursala, ", ",
			"ConsilierBanca = ", @ConsilierBanca, ", ",
			"CodBanca = ", @CodBanca, ", ",
			"IdEvaluator = ", @IdEvaluator, ", ",
			"IdNotar = ", @IdNotar, ", ",
			"IdFunctie = ", @IdFunctie, ", ",
			"IdFunctieFunctie = ", @IdFunctieFunctie, ", ",
			"IdDomeniu = ", @IdDomeniu, ", ",
			"IdCompanie = ", @IdCompanie, ", ",
			"IdTipCompanie = ", @IdTipCompanie, ", ",
			"IdStare = ", @IdStare, ", ",
			"IdStatus = ", @IdStatus, ", ",
			"IdMotiv = ", @IdMotiv, ", ",
			"IdVenit = ", @IdVenit, ", ",
			"Venit = ", @Venit, ", ",
			"IdTipImobil = ", @IdTipImobil, ", ",
			"AreImobil = ", @AreImobil, ", ",
			"ValoareImobil = ", @ValoareImobil, ", ",
			"IdTipCredit = ", @IdTipCredit, ", ",
			"IdTipMoneda = ", @IdTipMoneda, ", ",
			"PerioadaCredit = ", @PerioadaCredit, ", ",
			"ValoareCredit = ", @ValoareCredit, ", ",
			"CursMoneda = ", @CursMoneda, ", ",
			"IdTipDobanda = ", @IdTipDobanda, ", ",
			"Dobanda = ", @Dobanda, ", ",
			"MarjaDobanda = ", @MarjaDobanda, ", ",
			"MarjaDobandaDF = ", @MarjaDobandaDF, ", ",
			"PerioadaDobanda = ", @PerioadaDobanda, ", ",
			"Codebitor = ", @Codebitor, ", ",
			"NumeCodebitor = ", @NumeCodebitor, ", ",
			"DataPreaprobare = ", @DataPreaprobare, ", ",
			"DataOpinieJ = ", @DataOpinieJ, ", ",
			"DataTrimitere = ", @DataTrimitere, ", ",
			"DataDebursare = ", @DataDebursare, ", ",
			"DataRespingere = ", @DataRespingere, ", ",
			"ObservatiiFinale = ", @ObservatiiFinale, " ",
			"WHERE IdDosar = ", @IdDosar
	);
	SELECT @sql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
		-- COMMIT;
			
	SET @ERRMSG='PRELUARE_DATE';
	
	SELECT D.IdDosar,D.IdBaza,D.IdClient,D.IdConsultant,D.IdAgent,D.IdSursa,D.IdFunctie,D.IdBanca,D.IdSucursala,D.IdStare,D.IdStatus,D.IdDomeniu,D.IdFunctieFunctie,D.IdTipCompanie,D.IdCompanie,D.IdEvaluator,D.IdMotiv,D.IdNotar,D.IdTipImobil,D.IdVenit,D.IdTipDobanda,D.IdTipMoneda,D.IdTipCredit,D.Venit,D.ValoareCredit,D.PerioadaCredit,D.PerioadaDobanda,D.Dobanda,D.NumeCodebitor,D.MarjaDobanda,D.MarjaDobandaDF,D.ValoareImobil,D.ConsilierBanca,D.CodBanca,D.DataIntroducere,D.DataPreaprobare,D.DataOpinieJ,D.DataTrimitere,D.DataDebursare,D.DataRespingere,D.CursMoneda,D.Codebitor,D.AreImobil,D.ObservatiiFinale,DS.Stare,DSt.FelStatus,DSt.TipStatus,DSt.IDSG,B.DataPrimire,Cl.NumeClient,Cl.CNPClient,Cl.TelefonP AS TelefonClient,Cl.EmailP AS EmailClient,Cl.DataNastere,Cl.IdJudet,C.NumeConsultant,C.cTelefon,C.cMail,A.NumeAgent,SL.Sursa,DFD.Domeniu,DFTC.TipCompanie,DFF.Functie,DFC.Companie,Bc.Banca,S.Sucursala,DTV.TipVenit,DTD.TipDobanda,DTM.Moneda,DTC.TipCredit,DFB.IdFeedBack,DFB.IdStatusFeedBack,DFB.DataConectare,DFB.DataReconectare,DN.Notar,DE.Evaluator,DTI.TipImobil,DM.Motiv,0 AS DIF,0 AS aDIF,0 AS cDIF,0 AS OLD,D.DataModificare,'Dosar' AS TblName,'IdDosar' AS IdName 
	FROM ((((((((((((((((((((((
	Dosar D 
	JOIN Dosar_Stare DS ON (D.IdStare=DS.IdStare)) 
	JOIN Dosar_Status DSt ON (D.IdStatus=DSt.IdStatus)) 
	JOIN Baza B ON (D.IdBaza=B.IdBaza)) 
	JOIN Agenti A ON (D.IdAgent=A.IdAgent)) 
	JOIN Consultanti C ON (D.IdConsultant=C.IdConsultant)) 
	JOIN Clienti Cl ON (D.IdClient=Cl.IdClient)) 
	JOIN SursaLead SL ON (D.IdSursa=SL.IdSursa)) 
	JOIN Dosar_Functii_Companie DFC ON (D.IdCompanie=DFC.IdCompanie)) 
	JOIN Dosar_Functii_Domeniu DFD ON (D.IdDomeniu=DFD.IdDomeniu)) 
	JOIN Dosar_Functii_Functie DFF ON (D.IdFunctieFunctie=DFF.IdFunctieFunctie)) 
	JOIN Dosar_Functii_TipCompanie DFTC ON (D.IdTipCompanie=DFTC.IdTipCompanie)) 
	JOIN Banci Bc ON (D.IdBanca=Bc.IdBanca))
	JOIN Sucursale S ON (D.IdSucursala=S.IdSucursala)) 
	JOIN Dosar_TipVenit DTV ON (D.IdVenit=DTV.IdVenit)) 
	LEFT JOIN Dosar_TipDobanda DTD ON (D.IdTipDobanda=DTD.IdTipDobanda)) 
	JOIN Dosar_TipMoneda DTM ON (D.IdTipMoneda=DTM.IdTipMoneda)) 
	JOIN Dosar_TipCredit DTC ON (D.IdTipCredit=DTC.IdTipCredit)) 
	LEFT JOIN (
	SELECT DFF.IdFeedBack,DFF.IdDosar,DFF.IdStatusFeedback,DFF.DataConectare,DFF.DataReconectare FROM (Dosar_FeedBack DFF JOIN (
	SELECT max(Dosar_FeedBack.IdFeedBack) AS IdFeedBack FROM Dosar_FeedBack GROUP BY Dosar_FeedBack.IdDosar) df ON (DFF.IdFeedBack=df.IdFeedBack))) DFB ON (D.IdDosar=DFB.IdDosar)) 
	LEFT JOIN Dosar_Notari DN ON (D.IdNotar=DN.IdNotar)) 
	LEFT JOIN Dosar_Evaluatori DE ON (D.IdEvaluator=DE.IdEvaluator)) 
	LEFT JOIN Dosar_TipImobil DTI ON (D.IdTipImobil=DTI.IdTipImobil)) 
	LEFT JOIN Dosar_Motiv DM ON (D.IdMotiv=DM.IdMotiv)) 
	WHERE D.IdDosar=@IdDosar;
	
	IF pfn=0 AND @IdFunctie<> 0 THEN
		SELECT IdFunctie,IdClient,IdFunctieFunctie,IdCompanie,IdDomeniu,IdTipCompanie,Ascuns,DataModificare,'Dosar_Functii' as TblName, 'IdFunctie' as IdName FROM Dosar_Functii WHERE IdFunctie=@IdFunctie;
	END IF;
				
	SET `OUT`=JSON_OBJECT('IdDosar',@IdDosar,'IdFunctie',@IdFunctie,'IdFeedBack',@IdFeedBack);	
	END s;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for _GLOBAL_SCHEMA
-- ----------------------------
DROP PROCEDURE IF EXISTS `_GLOBAL_SCHEMA`;
delimiter ;;
CREATE PROCEDURE `_GLOBAL_SCHEMA`(IN `pAnumitTabel` VARCHAR ( 255 ),
	IN `pAnumitID` VARCHAR (255),
	IN `pAnumiteColoane` VARCHAR (255),
	IN `pDoarStructura` TINYINT)
BEGIN
    DECLARE columnName VARCHAR(255);
    DECLARE jsonResult TEXT DEFAULT '';
    DECLARE done INT DEFAULT FALSE;
		DECLARE jAnumiteColoane VARCHAR(2000);
		DECLARE iAnumiteColoane TEXT DEFAULT '';
		DECLARE structura VARCHAR(255) DEFAULT '';
		
	IF pDoarStructura <> 0 THEN
		SET structura = "[{""""NAME"""": """"NAME"""", """"TYPE"""": """"202"""", """"LENGTH"""": 255},{""""NAME"""": """"TYPE"""", """"TYPE"""": """"202"""", """"LENGTH"""": 255},{""""NAME"""": """"LENGTH"""", """"TYPE"""": """"4"""", """"LENGTH"""": null}]";
		
		IF IFNULL(pAnumitTabel,'') <> '' THEN
			IF IFNULL(pAnumiteColoane,'') <> '' THEN
				SET jAnumiteColoane = IFNULL(pAnumiteColoane,'');
				
				-- Iterate through the provided column names
				col_loop: LOOP
						SET columnName = SUBSTRING_INDEX(jAnumiteColoane, ',', 1);
						SET jAnumiteColoane = SUBSTRING(jAnumiteColoane, LENGTH(columnName) + 2);

						-- Construct the JSON-like string
						SET jsonResult = CONCAT(jsonResult, "'", columnName, "', ", columnName, ',');
						SET iAnumiteColoane = CONCAT(iAnumiteColoane, "'", columnName, "',");

						-- Check if there are more columns
						IF LENGTH(jAnumiteColoane) = 0 THEN
								LEAVE col_loop;
						END IF;
				END LOOP;

				-- Remove the trailing comma
				SET jsonResult = LEFT(jsonResult, LENGTH(jsonResult) - 1);	
				SET iAnumiteColoane = LEFT(iAnumiteColoane, LENGTH(iAnumiteColoane) - 1);					
				
				SET @SQL = CONCAT ("
					SELECT TABLE_NAME as T,'", pAnumitID, "' AS C, JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) AS V, """, structura, """ as J
					FROM TABLES_INFO 
					WHERE TABLE_NAME = '", pAnumitTabel, "' AND COLUMN_NAME IN (", iAnumiteColoane, ");");
				
			ELSE
				SET @SQL = CONCAT ("
					SELECT TABLE_NAME as T,'", pAnumitID, "' AS C, JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) AS V, """, structura, """ as J
					FROM TABLES_INFO 
					WHERE TABLE_NAME = '", pAnumitTabel, "';");
			END IF;
		ELSE
				SET @SQL = CONCAT ("
					SELECT TABLE_NAME as T,", IF(pDoarStructura=1,"IFNULL(MAX(PRIMARY_COLUMN),TABLE_NAME)", "MAX(PRIMARY_COLUMN)"), " AS C,  JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) AS V, """, structura, """ as J
					FROM TABLES_INFO T",
					IF(pDoarStructura=2," INNER JOIN (SELECT TABLE_NAME FROM TABLES_INFO WHERE PRIMARY_COLUMN <>'') TT USING (TABLE_NAME) ",""), "
					GROUP BY TABLE_NAME;");
		END IF;
	ELSE
		IF IFNULL(`pAnumitTabel`,'') <> '' THEN

			IF IFNULL(pAnumiteColoane,'')='' THEN	
				SELECT GROUP_CONCAT(COLUMN_NAME ORDER BY ID) INTO jAnumiteColoane FROM TABLES_INFO WHERE TABLE_NAME = pAnumitTabel;
			ELSE
				SET jAnumiteColoane = IFNULL(pAnumiteColoane,'');
			END IF;
			
			-- Iterate through the provided column names
			col_loop: LOOP
					SET columnName = SUBSTRING_INDEX(jAnumiteColoane, ',', 1);
					SET jAnumiteColoane = SUBSTRING(jAnumiteColoane, LENGTH(columnName) + 2);

					-- Construct the JSON-like string
					SET jsonResult = CONCAT(jsonResult, "'", columnName, "', ", columnName, ',');
					SET iAnumiteColoane = CONCAT(iAnumiteColoane, "'", columnName, "',");

					-- Check if there are more columns
					IF LENGTH(jAnumiteColoane) = 0 THEN
							LEAVE col_loop;
					END IF;
			END LOOP;

			-- Remove the trailing comma
			SET jsonResult = LEFT(jsonResult, LENGTH(jsonResult) - 1);	
			SET iAnumiteColoane = LEFT(iAnumiteColoane, LENGTH(iAnumiteColoane) - 1);		
			
			IF IFNULL(pAnumitID,'') = '' THEN
				SELECT PRIMARY_COLUMN INTO pAnumitID FROM TABLES_INFO WHERE TABLE_NAME=pAnumitTabel AND IFNULL(PRIMARY_COLUMN,'')<>'';
			END IF;
			
			SET @SQL = CONCAT ("
				SELECT TABLE_NAME as T,'", pAnumitID, "' AS C, 
				JSON_ARRAYAGG(
				JSON_OBJECT(", jsonResult, ")
				) AS V,
				(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
				FROM TABLES_INFO WHERE TABLE_NAME = '", pAnumitTabel, "' ",
				IF(IFNULL(pAnumiteColoane,'')<>'',
					CONCAT(" AND COLUMN_NAME IN (", iAnumiteColoane, ")"),
					""), 
				") AS J
				FROM ", pAnumitTabel, " ",
				IF(IFNULL(pAnumiteColoane,'')<>'',CONCAT("ORDER BY ", pAnumiteColoane, ""),""), "
			");

		ELSE	
			SET @SQL = CONCAT ( "
				SELECT T,C,V,J FROM (
					SELECT T,C,V,J FROM (
					SELECT 'Agenti' AS T,'IdAgent' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdAgent',IdAgent,'NumeAgent',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),NumeAgent),'IdSursa',IdSursa,'Ascuns',Ascuns,'Implicit',Implicit)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Agenti') AS J FROM Agenti ORDER BY Ascuns,NumeAgent) Q
					 UNION ALL 

					SELECT T,C,V,J FROM (
					SELECT 'SursaLead' AS T,'IdSursa' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdSursa',IdSursa,'Sursa',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Sursa),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='SursaLead') AS J FROM SursaLead ORDER BY Ascuns,Sursa) Q
					 UNION ALL 

					SELECT T,C,V,J FROM (
					SELECT 'Banci' AS T,'IdBanca' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdBanca',IdBanca,'Banca',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Banca),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Banci') AS J FROM Banci ORDER BY Ascuns,Banca) Q
					 UNION ALL 
					 
					-- Dosar_TipVenit
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_TipVenit' AS T,'IdVenit' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdVenit',IdVenit,'TipVenit',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),TipVenit),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_TipVenit') AS J FROM Dosar_TipVenit ORDER BY Ascuns,TipVenit) Q
					 UNION ALL 
					 
					-- Dosar_TipDobanda
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_TipDobanda' AS T,'IdTipDobanda' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdTipDobanda',IdTipDobanda,'TipDobanda',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),TipDobanda),'Fields',`Fields`,'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_TipDobanda') AS J FROM Dosar_TipDobanda ORDER BY Ascuns,TipDobanda) Q
					 UNION ALL 
					 
					-- Dosar_Status
					SELECT T,C,V,J FROM (
					SELECT 'viewDosar_Status' AS T,'IdStatus' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdStatus',IdStatus,'FelStatus',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),FelStatus),'TipStatus',TipStatus,'BackColor',BackColor,'Ascuns',Ascuns,'Implicit',Implicit)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='viewDosar_Status') AS J FROM viewDosar_Status) Q
					 UNION ALL 
					 
					-- Dosar_Motiv
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Motiv' AS T,'IdMotiv' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdMotiv',IdMotiv,'Motiv',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Motiv),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Motiv') AS J FROM Dosar_Motiv ORDER BY Ascuns,Motiv) Q
					 UNION ALL 
					 
					-- Dosar_TipMoneda
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_TipMoneda' AS T,'IdTipMoneda' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdTipMoneda',IdTipMoneda,'Moneda',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Moneda),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_TipMoneda') AS J FROM Dosar_TipMoneda ORDER BY Ascuns,Moneda) Q
					 UNION ALL 
					 
					-- Dosar_TipCredit
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_TipCredit' AS T,'IdTipCredit' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdTipCredit',IdTipCredit,'TipCredit',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),TipCredit),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_TipCredit') AS J FROM Dosar_TipCredit ORDER BY Ascuns,TipCredit) Q
					 UNION ALL 
					 
					-- Dosar_Stare
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Stare' AS T,'IdStare' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdStare',IdStare,'Stare',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Stare),'Ascuns',Ascuns,'Implicit',Implicit)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Stare') AS J FROM Dosar_Stare ORDER BY Stare) Q
					 UNION ALL 
					 
					-- Dosar_TipImobil
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_TipImobil' AS T,'IdTipImobil' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdTipImobil',IdTipImobil,'TipImobil',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),TipImobil),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_TipImobil') AS J FROM Dosar_TipImobil ORDER BY Ascuns,TipImobil) Q
					 UNION ALL 
											
					-- Sucursale (view)
					SELECT T,C,V,J FROM (
					SELECT 'viewSucursale' AS T,'IdSucursala' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdSucursala',IdSucursala,'Sucursala',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Sucursala),'Judet',Judet,'Orasul',Orasul,'IdBanca',IdBanca,'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='viewSucursale') AS J FROM viewSucursale ORDER BY Ascuns) Q
					 UNION ALL 
					 
					-- Parinti (view)
					SELECT T,C,V,J FROM (
					SELECT 'viewParinti' AS T,'IdParinte' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdParinte',IdParinte,'NumeConsultant',NumeConsultant,'cTelefon',cTelefon,'IdRegiune',IdRegiune,'IdNivel',IdNivel,'IdParinteParinte', IdParinteParinte)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='viewParinti') AS J FROM viewParinti) Q
					 UNION ALL 
					 
					-- Dosar_Notari
					SELECT T,C,V,J FROM (
					SELECT 'viewNotari' AS T,'IdNotar' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdNotar',IdNotar,'Notar',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Notar),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='viewNotari') AS J FROM Dosar_Notari ORDER BY Ascuns,Notar) Q
					 UNION ALL 
					 
					-- Dosar_Evaluatori
					SELECT T,C,V,J FROM (
					SELECT 'viewEvaluatori' AS T,'IdEvaluator' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdEvaluator',IdEvaluator,'Evaluator',UCASE(CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Evaluator)),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='viewEvaluatori') AS J FROM Dosar_Evaluatori ORDER BY Ascuns,Evaluator) Q
					 UNION ALL 

					-- Dosar_Functii
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Functii' AS T,'IdFunctie' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdFunctie',IdFunctie,'IdClient',IdClient,'IdFunctieFunctie',IdFunctieFunctie,'IdCompanie',IdCompanie,'IdDomeniu',IdDomeniu,'IdTipCompanie',IdTipCompanie,'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Functii') AS J FROM Dosar_Functii ORDER BY IdClient) Q
					 UNION ALL 
											
					-- Dosar_Functii_Functie
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Functii_Functie' AS T,'IdFunctieFunctie' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdFunctieFunctie',IdFunctieFunctie,'Functie',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Functie),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Functii_Functie') AS J FROM Dosar_Functii_Functie ORDER BY Ascuns,Functie) Q
					 UNION ALL 
					 
					-- Dosar_Functii_Companie
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Functii_Companie' AS T,'IdCompanie' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdCompanie',IdCompanie,'Companie',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Companie),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Functii_Companie') AS J FROM Dosar_Functii_Companie ORDER BY Ascuns,Companie) Q
					 UNION ALL 

					-- Dosar_Functii_Domeniu
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Functii_Domeniu' AS T,'IdDomeniu' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdDomeniu',IdDomeniu,'Domeniu',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Domeniu),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Functii_Domeniu') AS J FROM Dosar_Functii_Domeniu ORDER BY Ascuns,Domeniu) Q
					 UNION ALL 

					-- Dosar_Functii_TipCompantie
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Functii_TipCompanie' AS T,'IdTipCompanie' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdTipCompanie',IdTipCompanie,'TipCompanie',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),TipCompanie),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Functii_TipCompanie') AS J FROM Dosar_Functii_TipCompanie ORDER BY Ascuns,TipCompanie) Q
					 UNION ALL 

					-- Baza_Status
					SELECT T,C,V,J FROM (
					SELECT 'Baza_Status' AS T,'IdStatusBaza' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdStatus',IdStatus,'FelStatus',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),FelStatus),'TipStatus',TipStatus,'BackColor',BackColor,'Ascuns',Ascuns,'IDSG',IDSG)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Baza_Status') AS J FROM Baza_Status ORDER BY Ascuns,FelStatus) Q
					 UNION ALL 

					SELECT T,C,V,J FROM (
					SELECT 'Dosar_FeedBack_Status' AS T,'FelStatusFeedback' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdStatusFeedback',IdStatusFeedback,'FelStatusFeedback',FelStatusFeedback,'BackColorFeedback',`BackColorFeedback`)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_FeedBack_Status') AS J FROM Dosar_FeedBack_Status ORDER BY FelStatusFeedback) Q
					UNION ALL 
					
					SELECT T,C,V,J FROM (
					SELECT 'Niveluri' AS T,'IdNivel' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdNivel',IdNivel,'Explicatie', Explicatie, 'Ascuns', Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Niveluri') AS J FROM Niveluri ORDER BY IdNivel) Q

					UNION ALL 
					
					SELECT T,C,V,J FROM (
					SELECT 'Regiuni' AS T,'IdRegiune' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdRegiune',IdRegiune,'Regiune', Regiune, 'Ascuns', Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Regiuni') AS J FROM Regiuni ORDER BY IdRegiune) Q
					 UNION ALL 

					SELECT T,C,V,J FROM (
					SELECT 'Judete' AS T,'IdJudet' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdJudet',IdJudet,'Judet',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Judet),'Ascuns',Ascuns,'IdRegiune',IdRegiune,'CodJudet',CodJudet)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Judete') AS J FROM Judete ORDER BY Ascuns,Judet) Q
					 
					/*SELECT T,C,V,J FROM (
					SELECT 'Cons_Tree' AS T,'IDT' AS C, '' AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME = 'Cons_Tree') AS J
					) Q*/
				) TBL
				ORDER BY T" );
		END IF;
	END IF;
	
	SELECT @SQL;
	PREPARE stmt FROM	@SQL;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for _procDateGenerale
-- ----------------------------
DROP PROCEDURE IF EXISTS `_procDateGenerale`;
delimiter ;;
CREATE PROCEDURE `_procDateGenerale`(IN `pAnumitTabel` VARCHAR ( 255 ),
	IN `pAnumitID` VARCHAR (255),
	IN `pAnumiteColoane` VARCHAR (255),
	IN `pDoarStructura` TINYINT)
BEGIN
    DECLARE columnName VARCHAR(255);
    DECLARE jsonResult TEXT DEFAULT '';
    DECLARE done INT DEFAULT FALSE;
		DECLARE jAnumiteColoane VARCHAR(2000);
		DECLARE iAnumiteColoane TEXT DEFAULT '';
		DECLARE structura VARCHAR(255) DEFAULT '';
		
	IF pDoarStructura <> 0 THEN
		SET structura = "[{""""NAME"""": """"NAME"""", """"TYPE"""": """"202"""", """"LENGTH"""": 255},{""""NAME"""": """"TYPE"""", """"TYPE"""": """"202"""", """"LENGTH"""": 255},{""""NAME"""": """"LENGTH"""", """"TYPE"""": """"4"""", """"LENGTH"""": null}]";
		
		IF IFNULL(pAnumitTabel,'') <> '' THEN
			IF IFNULL(pAnumiteColoane,'') <> '' THEN
				SET jAnumiteColoane = IFNULL(pAnumiteColoane,'');
				
				-- Iterate through the provided column names
				col_loop: LOOP
						SET columnName = SUBSTRING_INDEX(jAnumiteColoane, ',', 1);
						SET jAnumiteColoane = SUBSTRING(jAnumiteColoane, LENGTH(columnName) + 2);

						-- Construct the JSON-like string
						SET jsonResult = CONCAT(jsonResult, "'", columnName, "', ", columnName, ',');
						SET iAnumiteColoane = CONCAT(iAnumiteColoane, "'", columnName, "',");

						-- Check if there are more columns
						IF LENGTH(jAnumiteColoane) = 0 THEN
								LEAVE col_loop;
						END IF;
				END LOOP;

				-- Remove the trailing comma
				SET jsonResult = LEFT(jsonResult, LENGTH(jsonResult) - 1);	
				SET iAnumiteColoane = LEFT(iAnumiteColoane, LENGTH(iAnumiteColoane) - 1);					
				
				SET @SQL = CONCAT ("
					SELECT TABLE_NAME as T,'", pAnumitID, "' AS C, JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) AS V, """, structura, """ as J
					FROM TABLES_INFO 
					WHERE TABLE_NAME = '", pAnumitTabel, "' AND COLUMN_NAME IN (", iAnumiteColoane, ");");
				
			ELSE
				SET @SQL = CONCAT ("
					SELECT TABLE_NAME as T,'", pAnumitID, "' AS C, JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) AS V, """, structura, """ as J
					FROM TABLES_INFO 
					WHERE TABLE_NAME = '", pAnumitTabel, "';");
			END IF;
		ELSE
				SET @SQL = CONCAT ("
					SELECT TABLE_NAME as T,", IF(pDoarStructura=1,"IFNULL(MAX(PRIMARY_COLUMN),TABLE_NAME)", "MAX(PRIMARY_COLUMN)"), " AS C,  JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) AS V, """, structura, """ as J
					FROM TABLES_INFO T",
					IF(pDoarStructura=2," INNER JOIN (SELECT TABLE_NAME FROM TABLES_INFO WHERE PRIMARY_COLUMN <>'') TT USING (TABLE_NAME) ",""), "
					GROUP BY TABLE_NAME;");
		END IF;
	ELSE
		IF IFNULL(`pAnumitTabel`,'') <> '' THEN

			IF IFNULL(pAnumiteColoane,'')='' THEN	
				SELECT GROUP_CONCAT(COLUMN_NAME ORDER BY ID) INTO jAnumiteColoane FROM TABLES_INFO WHERE TABLE_NAME = pAnumitTabel;
			ELSE
				SET jAnumiteColoane = IFNULL(pAnumiteColoane,'');
			END IF;
			
			-- Iterate through the provided column names
			col_loop: LOOP
					SET columnName = SUBSTRING_INDEX(jAnumiteColoane, ',', 1);
					SET jAnumiteColoane = SUBSTRING(jAnumiteColoane, LENGTH(columnName) + 2);

					-- Construct the JSON-like string
					SET jsonResult = CONCAT(jsonResult, "'", columnName, "', ", columnName, ',');
					SET iAnumiteColoane = CONCAT(iAnumiteColoane, "'", columnName, "',");

					-- Check if there are more columns
					IF LENGTH(jAnumiteColoane) = 0 THEN
							LEAVE col_loop;
					END IF;
			END LOOP;

			-- Remove the trailing comma
			SET jsonResult = LEFT(jsonResult, LENGTH(jsonResult) - 1);	
			SET iAnumiteColoane = LEFT(iAnumiteColoane, LENGTH(iAnumiteColoane) - 1);		
			
			IF IFNULL(pAnumitID,'') = '' THEN
				SELECT PRIMARY_COLUMN INTO pAnumitID FROM TABLES_INFO WHERE TABLE_NAME=pAnumitTabel AND IFNULL(PRIMARY_COLUMN,'')<>'';
			END IF;
			
			SET @SQL = CONCAT ("
				SELECT TABLE_NAME as T,'", pAnumitID, "' AS C, 
				JSON_ARRAYAGG(
				JSON_OBJECT(", jsonResult, ")
				) AS V,
				(SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) 
				FROM TABLES_INFO WHERE TABLE_NAME = '", pAnumitTabel, "' ",
				IF(IFNULL(pAnumiteColoane,'')<>'',
					CONCAT(" AND COLUMN_NAME IN (", iAnumiteColoane, ")"),
					""), 
				") AS J
				FROM ", pAnumitTabel, " ",
				IF(IFNULL(pAnumiteColoane,'')<>'',CONCAT("ORDER BY ", pAnumiteColoane, ""),""), "
			");

		ELSE	
			SET @SQL = CONCAT ( "
				SELECT T,C,V,J FROM (
					SELECT T,C,V,J FROM (
					SELECT 'Agenti' AS T,'IdAgent' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdAgent',IdAgent,'NumeAgent',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),NumeAgent),'IdSursa',IdSursa,'Ascuns',Ascuns,'Implicit',Implicit)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Agenti') AS J FROM Agenti ORDER BY Ascuns,NumeAgent) Q
					 UNION ALL 

					SELECT T,C,V,J FROM (
					SELECT 'SursaLead' AS T,'IdSursa' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdSursa',IdSursa,'Sursa',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Sursa),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='SursaLead') AS J FROM SursaLead ORDER BY Ascuns,Sursa) Q
					 UNION ALL 

					SELECT T,C,V,J FROM (
					SELECT 'Banci' AS T,'IdBanca' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdBanca',IdBanca,'Banca',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Banca),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Banci') AS J FROM Banci ORDER BY Ascuns,Banca) Q
					 UNION ALL 
					 
					-- Dosar_TipVenit
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_TipVenit' AS T,'IdVenit' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdVenit',IdVenit,'TipVenit',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),TipVenit),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_TipVenit') AS J FROM Dosar_TipVenit ORDER BY Ascuns,TipVenit) Q
					 UNION ALL 
					 
					-- Dosar_TipDobanda
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_TipDobanda' AS T,'IdTipDobanda' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdTipDobanda',IdTipDobanda,'TipDobanda',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),TipDobanda),'Fields',`Fields`,'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_TipDobanda') AS J FROM Dosar_TipDobanda ORDER BY Ascuns,TipDobanda) Q
					 UNION ALL 
					 
					-- Dosar_Status
					SELECT T,C,V,J FROM (
					SELECT 'viewDosar_Status' AS T,'IdStatus' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdStatus',IdStatus,'FelStatus',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),FelStatus),'TipStatus',TipStatus,'BackColor',BackColor,'Ascuns',Ascuns,'Implicit',Implicit)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='viewDosar_Status') AS J FROM viewDosar_Status) Q
					 UNION ALL 
					 
					-- Dosar_Motiv
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Motiv' AS T,'IdMotiv' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdMotiv',IdMotiv,'Motiv',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Motiv),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Motiv') AS J FROM Dosar_Motiv ORDER BY Ascuns,Motiv) Q
					 UNION ALL 
					 
					-- Dosar_TipMoneda
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_TipMoneda' AS T,'IdTipMoneda' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdTipMoneda',IdTipMoneda,'Moneda',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Moneda),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_TipMoneda') AS J FROM Dosar_TipMoneda ORDER BY Ascuns,Moneda) Q
					 UNION ALL 
					 
					-- Dosar_TipCredit
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_TipCredit' AS T,'IdTipCredit' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdTipCredit',IdTipCredit,'TipCredit',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),TipCredit),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_TipCredit') AS J FROM Dosar_TipCredit ORDER BY Ascuns,TipCredit) Q
					 UNION ALL 
					 
					-- Dosar_Stare
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Stare' AS T,'IdStare' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdStare',IdStare,'Stare',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Stare),'Ascuns',Ascuns,'Implicit',Implicit)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Stare') AS J FROM Dosar_Stare ORDER BY Stare) Q
					 UNION ALL 
					 
					-- Dosar_TipImobil
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_TipImobil' AS T,'IdTipImobil' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdTipImobil',IdTipImobil,'TipImobil',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),TipImobil),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_TipImobil') AS J FROM Dosar_TipImobil ORDER BY Ascuns,TipImobil) Q
					 UNION ALL 
											
					-- Sucursale (view)
					SELECT T,C,V,J FROM (
					SELECT 'viewSucursale' AS T,'IdSucursala' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdSucursala',IdSucursala,'Sucursala',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Sucursala),'Judet',Judet,'Orasul',Orasul,'IdBanca',IdBanca,'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='viewSucursale') AS J FROM viewSucursale ORDER BY Ascuns) Q
					 UNION ALL 
					 
					-- Parinti (view)
					SELECT T,C,V,J FROM (
					SELECT 'viewParinti' AS T,'IdParinte' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdParinte',IdParinte,'NumeConsultant',NumeConsultant,'cTelefon',cTelefon,'IdRegiune',IdRegiune,'IdNivel',IdNivel,'IdParinteParinte', IdParinteParinte)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='viewParinti') AS J FROM viewParinti) Q
					 UNION ALL 
					 
					-- Dosar_Notari
					SELECT T,C,V,J FROM (
					SELECT 'viewNotari' AS T,'IdNotar' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdNotar',IdNotar,'Notar',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Notar),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='viewNotari') AS J FROM Dosar_Notari ORDER BY Ascuns,Notar) Q
					 UNION ALL 
					 
					-- Dosar_Evaluatori
					SELECT T,C,V,J FROM (
					SELECT 'viewEvaluatori' AS T,'IdEvaluator' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdEvaluator',IdEvaluator,'Evaluator',UCASE(CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Evaluator)),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='viewEvaluatori') AS J FROM Dosar_Evaluatori ORDER BY Ascuns,Evaluator) Q
					 UNION ALL 

					-- Dosar_Functii
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Functii' AS T,'IdFunctie' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdFunctie',IdFunctie,'IdClient',IdClient,'IdFunctieFunctie',IdFunctieFunctie,'IdCompanie',IdCompanie,'IdDomeniu',IdDomeniu,'IdTipCompanie',IdTipCompanie,'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Functii') AS J FROM Dosar_Functii ORDER BY IdClient) Q
					 UNION ALL 
											
					-- Dosar_Functii_Functie
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Functii_Functie' AS T,'IdFunctieFunctie' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdFunctieFunctie',IdFunctieFunctie,'Functie',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Functie),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Functii_Functie') AS J FROM Dosar_Functii_Functie ORDER BY Ascuns,Functie) Q
					 UNION ALL 
					 
					-- Dosar_Functii_Companie
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Functii_Companie' AS T,'IdCompanie' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdCompanie',IdCompanie,'Companie',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Companie),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Functii_Companie') AS J FROM Dosar_Functii_Companie ORDER BY Ascuns,Companie) Q
					 UNION ALL 

					-- Dosar_Functii_Domeniu
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Functii_Domeniu' AS T,'IdDomeniu' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdDomeniu',IdDomeniu,'Domeniu',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Domeniu),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Functii_Domeniu') AS J FROM Dosar_Functii_Domeniu ORDER BY Ascuns,Domeniu) Q
					 UNION ALL 

					-- Dosar_Functii_TipCompantie
					SELECT T,C,V,J FROM (
					SELECT 'Dosar_Functii_TipCompanie' AS T,'IdTipCompanie' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdTipCompanie',IdTipCompanie,'TipCompanie',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),TipCompanie),'Ascuns',Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_Functii_TipCompanie') AS J FROM Dosar_Functii_TipCompanie ORDER BY Ascuns,TipCompanie) Q
					 UNION ALL 

					-- Baza_Status
					SELECT T,C,V,J FROM (
					SELECT 'Baza_Status' AS T,'IdStatusBaza' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdStatus',IdStatus,'FelStatus',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),FelStatus),'TipStatus',TipStatus,'BackColor',BackColor,'Ascuns',Ascuns,'IDSG',IDSG)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Baza_Status') AS J FROM Baza_Status ORDER BY Ascuns,FelStatus) Q
					 UNION ALL 

					SELECT T,C,V,J FROM (
					SELECT 'Dosar_FeedBack_Status' AS T,'FelStatusFeedback' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdStatusFeedback',IdStatusFeedback,'FelStatusFeedback',FelStatusFeedback,'BackColorFeedback',`BackColorFeedback`)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Dosar_FeedBack_Status') AS J FROM Dosar_FeedBack_Status ORDER BY FelStatusFeedback) Q
					UNION ALL 
					
					SELECT T,C,V,J FROM (
					SELECT 'Niveluri' AS T,'IdNivel' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdNivel',IdNivel,'Explicatie', Explicatie, 'Ascuns', Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Niveluri') AS J FROM Niveluri ORDER BY IdNivel) Q

					UNION ALL 
					
					SELECT T,C,V,J FROM (
					SELECT 'Regiuni' AS T,'IdRegiune' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdRegiune',IdRegiune,'Regiune', Regiune, 'Ascuns', Ascuns)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Regiuni') AS J FROM Regiuni ORDER BY IdRegiune) Q
					 UNION ALL 

					SELECT T,C,V,J FROM (
					SELECT 'Judete' AS T,'IdJudet' AS C,JSON_ARRAYAGG(JSON_OBJECT('IdJudet',IdJudet,'Judet',CONCAT(IF (ABS(Ascuns)=1,' !!! ',''),Judet),'Ascuns',Ascuns,'IdRegiune',IdRegiune,'CodJudet',CodJudet)) AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME',COLUMN_NAME,'TYPE',DATA_TYPE,'LENGTH',CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME='Judete') AS J FROM Judete ORDER BY Ascuns,Judet) Q
					 
					/*SELECT T,C,V,J FROM (
					SELECT 'Cons_Tree' AS T,'IDT' AS C, '' AS V,(
					SELECT JSON_ARRAYAGG(JSON_OBJECT('NAME', COLUMN_NAME, 'TYPE', DATA_TYPE, 'LENGTH', CHARACTER_MAXIMUM_LENGTH)) FROM TABLES_INFO WHERE TABLE_NAME = 'Cons_Tree') AS J
					) Q*/
				) TBL
				ORDER BY T" );
		END IF;
	END IF;
	
	-- SELECT @SQL;
	PREPARE stmt FROM	@SQL;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for _Test
-- ----------------------------
DROP PROCEDURE IF EXISTS `_Test`;
delimiter ;;
CREATE PROCEDURE `_Test`()
BEGIN
    SELECT *, CAST(0 as UNSIGNED) as F FROM Filtru_Dosar;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for _TOATE_DATELE
-- ----------------------------
DROP PROCEDURE IF EXISTS `_TOATE_DATELE`;
delimiter ;;
CREATE PROCEDURE `_TOATE_DATELE`(IN `pIDC` INT, IN `jsonParam` VARCHAR(2000))
  READS SQL DATA 
BEGIN
	DECLARE i INT DEFAULT 0;
	DECLARE jsonLength INT DEFAULT JSON_LENGTH(NULLIF(jsonParam,''));
	DECLARE tableName VARCHAR(255);

	IF IFNULL(jsonParam,'')<>'' THEN
    WHILE i < jsonLength DO
        SET tableName = JSON_UNQUOTE(JSON_EXTRACT(jsonParam, CONCAT('$[', i, '].TblName')));

        CASE tableName
            WHEN 'Params' THEN
                SELECT *,'Params' as TblName, 'IdName' as IdName FROM viewParams;
            
						WHEN 'DrepturiGenerale' THEN
								SELECT *, 'DrepturiGenerale' as TblName, 'IdDrept' as IdName FROM Drepturi;
						
						WHEN 'Drepturi' THEN
								SELECT *, 'Drepturi' as TblName, 'IdCD' as IdName FROM Consultanti_Drepturi WHERE IdConsultant=pIDC;
								
            WHEN 'Schema' THEN
                SELECT *,'Schema' as TblName, 'Schema' as IdName FROM viewSchema;

            WHEN 'SetariADC' THEN
                SELECT *,'SetariADC' as TblName, 'IDS' as IdName FROM SetariADC ORDER BY IDS;

            WHEN 'Niveluri' THEN
                SELECT *,'Niveluri' as TblName, 'IdNivel' as IdName FROM Niveluri ORDER BY IdNivel;

            WHEN 'Regiuni' THEN
                SELECT *,'Regiuni' as TblName, 'IdRegiune' as IdName FROM Regiuni ORDER BY IdRegiune;

            WHEN 'Judete' THEN
                SELECT *,'Judete' as TblName, 'IdJudet' as IdName FROM Judete FORCE INDEX (Judet) ORDER BY Judet;

            WHEN 'viewParinti' THEN
                SELECT *,'viewParinti' as TblName, 'IdParinte' as IdName FROM viewParinti;

            WHEN 'Filtru' THEN
		SELECT IDF,IdColoana,f.SelTab,f.Ascuns,NumeColoana,AfisareColoana AS Afisare,PozitieInitiala AS Pozitie,NumeTabel AS Tbl,ColoanaPK=NumeColoana AS ID,TipCamp AS FldType,ColoanaPK AS PrCol,IF (TipCamp='date',1,0) AS Dt,IF (TipCamp='int',1,0) AS Nm,IF (TipCamp='double',1,0) AS Pr,AlteColoane,'{"FontName":"Consolas","FontSize":10,"FontBold":0,"FontItalic":0,"FontUnderline":0,"FontColor":"0000000"}' AS Font,JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828,'PressedForeColor',16711731) AS Color,-1 AS Latime,0 AS S,'Filtru' AS TblName,'IDF' AS IdName 
		FROM `Filtru` f 
		JOIN Coloane_Implicite ci USING (IdColoana)
		ORDER BY f.SelTab,f.Ascuns,f.IDF;
							
            WHEN 'Consultanti_Setari' THEN
                SELECT IdSetare,Setare,Valoare,'Setari' AS TblName,'IdSetare' AS IdName FROM Consultanti_Setari WHERE IdConsultant=`pIDC` UNION SELECT 0 AS IdSetare,'-' AS Setare,0 AS Valoare,'Setari' AS TblName,'IdSetare' AS IdName;

            WHEN 'Conditii' THEN
                SELECT *,'Conditii' as TblName, 'IdConditie' as IdName FROM Conditii FORCE INDEX (Afisare) ORDER BY Afisare;

            WHEN 'ConditiiS' THEN
                SELECT *,'ConditiiS' as TblName, 'IdConditieS' as IdName FROM ConditiiS;

            WHEN 'Semne' THEN
								SELECT *,'Semne' as TblName, 'IdSemn' as IdName FROM Semne;

            WHEN 'ConditiiSalvare' THEN
                SELECT *,'ConditiiSalvare' as TblName, 'IdConditie' as IdName FROM viewConditii_Salvare ORDER BY IdConditie;

            WHEN 'Coloane_FC' THEN
                SELECT *,'Coloane_FC' as TblName, 'IdFC' as IdName FROM Coloane_FC;
								
            WHEN 'Coloane_Implicite' THEN
								SELECT *,'Coloane_Implicite' as TblName, 'IdColoana' as IdName FROM Coloane_Implicite;

            WHEN 'Consultanti_Coloane_Excel' THEN
								SELECT *,'Consultanti_Coloane_Excel' as TblName, 'IDCOL' as IdName FROM Consultanti_Coloane_Excel WHERE IdConsultant=`pIDC`;

            WHEN 'Consultanti_Coloane_Excel_Config' THEN
								SELECT *,'Consultanti_Coloane_Excel_Config' as TblName, 'IdConfig' as IdName FROM Consultanti_Coloane_Excel_Config WHERE IdConsultant=`pIDC`;
		
            WHEN 'viewConsultanti_Coloane_Excel' THEN
								SELECT Consultanti_Coloane_Excel.IDCOL,Consultanti_Coloane_Excel_Config.IdConfig,Consultanti_Coloane_Excel_Config.NumeConfig,Coloane_Implicite.IdColoana,Coloane_Implicite.SelTab,Coloane_Implicite.NumeTabel,Coloane_Implicite.NumeColoana,Coloane_Implicite.TipCamp,Consultanti_Coloane_Excel.Pozitie,Consultanti_Coloane_Excel.Marime,Consultanti_Coloane_Excel.Afisare,Consultanti_Coloane_Excel.Aliniere,Consultanti_Coloane_Excel.Font,NOT Consultanti_Coloane_Excel.Ascuns AS Vizibil,Consultanti_Coloane_Excel.Formatare,JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828,'PressedForeColor',16711731) AS Color,Consultanti_Coloane_Excel.DataAdaugare,Consultanti_Coloane_Excel.DataModificare,'viewConsultanti_Coloane_Excel' AS TblName,'IDCOL' AS IdName 
								FROM Coloane_Implicite 
								INNER JOIN Consultanti_Coloane_Excel USING (IdColoana) 
								INNER JOIN Consultanti_Coloane_Excel_Config  USING (IdConfig) 
								WHERE Consultanti_Coloane_Excel_Config.IdConsultant=`pIDC`;

						WHEN 'Consultanti_Coloane' THEN
							SELECT *,'Consultanti_Coloane' as TblName, 'IdColoana' as IdName FROM Consultanti_Coloane WHERE IdConsultant=`pIDC`;
							
            WHEN 'viewConsultanti_Coloane' THEN
								SELECT cc.IDCOL,cc.Afisare AS AfisareColoana,cc.Pozitie,cc.Marime,cc.Ascuns,cc.Aliniere,cc.Formatare,	NOT cc.Ascuns AS Vizibil,ci.IdColoana,ci.NumeColoana,ci.TipCamp,ci.Special,ci.SelTab,JSON_EXTRACT((
									SELECT json_arrayagg(json_object('NumeColoana',cf.NumeColoana,'Semn',cf.Semn,'Valoare',cf.Valoare,'BackColor',ifnull(cf.BackColor,0),'ForeColor',ifnull(cf.ForeColor,0),'FontBold',cf.FontBold,'FontItalic',cf.FontItalic,'Activ',cf.Activ)) FROM Coloane_FC cf WHERE ci.IdColoana=cf.IdColoana GROUP BY cf.IdColoana),'$') AS FC_JSON,JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828,'PressedForeColor',16711731) AS Color,'{"FontName":"Consolas","FontSize":10,"FontBold":0,"FontItalic":0,"FontUnderline":0,"FontColor":"0000000"}' AS Font,0 AS Implicit,'viewConsultanti_Coloane' AS TblName,'IDCOL' AS IdName 
								FROM Coloane_Implicite ci 
								JOIN Consultanti_Coloane cc USING (IdColoana) 
								WHERE IdConsultant=`pIDC` 
								ORDER BY SelTab,Pozitie;

                /*UNION ALL

                SELECT IDCOL,IdColoana,ci.NumeColoana,AfisareColoana,PozitieInitiala AS Pozitie,MarimeInitiala AS Marime,AscunsImplicit AS Ascuns,AliniereInitiala AS Aliniere,FormatareInitiala AS Formatare,JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828) AS Color,'{"FontName":"Consolas","FontSize":10,"FontBold":0,"FontItalic":0,"FontUnderline":0,"FontColor":"0000000"}' AS Font,json_arrayagg(json_object('Conditie',`Coloane_FC`.`Conditie`,'BackColor',ifnull(`Coloane_FC`.`BackColor`,0),'ForeColor',ifnull(`Coloane_FC`.`ForeColor`,0),'FontBold',`Coloane_FC`.`FontBold`,'FontItalic',`Coloane_FC`.`FontItalic`,'Activ',`Coloane_FC`.`Activ`)) AS FC,Coloane_FC.NumeColoana AS NumeColoana_FC,NOT AscunsImplicit AS Vizibil,1 AS Implicit,Special,SelTab ,'Consultanti_Coloane' as TblName, 'IDCOL' as IdName FROM 
                (SELECT IDCOL,IdColoana,IdConsultant FROM Consultanti_Coloane) cc 
                INNER JOIN Coloane_Implicite ci USING (IdColoana) 
                LEFT JOIN Coloane_FC USING (IdColoana) 
                WHERE IdConsultant=`pIDC`  
                GROUP BY IdColoana 
                ORDER BY SelTab,Implicit,Vizibil DESC,Pozitie;	*/

            WHEN 'Agenti' THEN
                SELECT *,'Agenti' as TblName, 'IdAgent' as IdName FROM Agenti FORCE INDEX (NumeAgent) ORDER BY NumeAgent;

            WHEN 'SursaLead' THEN
                SELECT *,'SursaLead' as TblName, 'IdSursa' as IdName FROM SursaLead FORCE INDEX (Sursa) ORDER BY Sursa;

            WHEN 'Baza_Status' THEN
                SELECT IdStatus,FelStatus,TipStatus,BackColor,Ascuns,IDSG,'Baza_Status' AS TblName,'IdStatusBaza' AS IdName FROM Baza_Status FORCE INDEX (FelStatus) ORDER BY FelStatus;

            WHEN 'Consultanti' THEN
                SELECT *,'Consultanti' as TblName, 'IdConsultant' as IdName FROM viewConsultanti;

            WHEN 'view_Baza_Dosare' THEN
                SELECT *,'Baza_Dosare' as TblName, 'IdBaza' as IdName FROM view_Baza_Dosare;

            WHEN 'Banci' THEN
                SELECT IdBanca,Banca,Ascuns,'Banci' as TblName, 'IdBanca' as IdName FROM Banci ORDER BY Banca;

            WHEN 'Dosar_TipVenit' THEN
                SELECT *,'Dosar_TipVenit' as TblName, 'IdVenit' as IdName FROM Dosar_TipVenit FORCE INDEX (TipVenit) ORDER BY TipVenit;

            WHEN 'Dosar_TipDobanda' THEN
                SELECT *,'Dosar_TipDobanda' as TblName, 'IdTipDobanda' as IdName FROM Dosar_TipDobanda FORCE INDEX (TipDobanda) ORDER BY TipDobanda;

            WHEN 'Dosar_Motiv' THEN
                SELECT *,'Dosar_Motiv' as TblName, 'IdMotiv' as IdName FROM Dosar_Motiv FORCE INDEX (Motiv) ORDER BY Motiv;

            WHEN 'Dosar_TipMoneda' THEN
                SELECT *,'Dosar_TipMoneda' as TblName, 'IdTipMoneda' as IdName FROM Dosar_TipMoneda;

            WHEN 'Dosar_TipCredit' THEN
                SELECT *,'Dosar_TipCredit' as TblName, 'IdTipCredit' as IdName FROM Dosar_TipCredit;

            WHEN 'Dosar_Stare' THEN
                SELECT *,'Dosar_Stare' as TblName, 'IdStare' as IdName FROM Dosar_Stare;

            WHEN 'Dosar_TipImobil' THEN
                SELECT *,'Dosar_TipImobil' as TblName, 'IdTipImobil' as IdName FROM Dosar_TipImobil;

						-- WHEN 'view_Dosar_Functii' THEN
						-- 		SELECT *,'viewFunctii' as TblName, 'IdFunctie_view' as IdName FROM view_Dosar_Functii;
						
            WHEN 'Dosar_Functii' THEN
                SELECT *,'Dosar_Functii' as TblName, 'IdFunctie' as IdName FROM Dosar_Functii ORDER BY IdFunctie;

            WHEN 'Dosar_Functii_Functie' THEN
                SELECT *,'Dosar_Functii_Functie' as TblName, 'IdFunctieFunctie' as IdName FROM Dosar_Functii_Functie ORDER BY Functie;

            WHEN 'Dosar_Functii_Companie' THEN
                SELECT *,'Dosar_Functii_Companie' as TblName, 'IdCompanie' as IdName FROM Dosar_Functii_Companie FORCE INDEX (Companie) ORDER BY Companie;

            WHEN 'Dosar_Functii_Domeniu' THEN
                SELECT *,'Dosar_Functii_Domeniu' as TblName, 'IdDomeniu' as IdName FROM Dosar_Functii_Domeniu FORCE INDEX (Domeniu) ORDER BY Domeniu;

            WHEN 'Dosar_Functii_TipCompanie' THEN
                SELECT *,'Dosar_Functii_TipCompanie' as TblName, 'IdTipCompanie' as IdName FROM Dosar_Functii_TipCompanie FORCE INDEX (TipCompanie) ORDER BY TipCompanie;	

            WHEN 'Dosar_FeedBack_Status' THEN
                SELECT *,'Dosar_FeedBack_Status' as TblName, 'IdStatusFeedBack' as IdName FROM Dosar_FeedBack_Status ORDER BY FelStatusFeedback;

            WHEN 'Dosar_Status' THEN
                SELECT *,'Dosar_Status' as TblName, 'IdStatus' as IdName FROM Dosar_Status;

            WHEN 'Sucursale' THEN
                SELECT *,'Sucursale' as TblName, 'IdSucursala' as IdName FROM Sucursale;

            WHEN 'Notari' THEN
                SELECT *,'Notari' as TblName, 'IdNotar' as IdName FROM Dosar_Notari;

            WHEN 'Evaluatori' THEN
                SELECT *,'Evaluatori' as TblName, 'IdEvaluator' as IdName FROM Dosar_Evaluatori;

            -- Add more WHEN clauses for each table you want to handle

            -- ELSE
                -- Handle unknown or unsupported table names
                -- You can choose to ignore or raise an error
        END CASE;
				
        SET i = i + 1;
				
    END WHILE;
		
	ELSE
		-- PARAMETERS \ SCHEMA
		SELECT *,'Params' as TblName, 'IdName' as IdName FROM viewParams;
		-- SELECT *,'Schema' as TblName, 'Schema' as IdName FROM viewSchema;
		
		-- MISC
		SELECT *,'SetariADC' as TblName, 'IDS' as IdName FROM SetariADC ORDER BY IDS;
		SELECT *,'Niveluri' as TblName, 'IdNivel' as IdName FROM Niveluri ORDER BY IdNivel;
		SELECT *,'Regiuni' as TblName, 'IdRegiune' as IdName FROM Regiuni ORDER BY IdRegiune;
		SELECT *,'Judete' as TblName, 'IdJudet' as IdName FROM Judete FORCE INDEX (Judet) ORDER BY Judet;
		SELECT *,'DrepturiGenerale' as TblName, 'IdDrept' as IdName FROM Drepturi;
		SELECT *,'Drepturi' as TblName, 'IdCD' as IdName FROM Consultanti_Drepturi WHERE IdConsultant=pIDC;
		SELECT *,'viewParinti' as TblName, 'IdParinte' as IdName FROM viewParinti;
		SELECT IdSetare,Setare,Valoare,'Setari' AS TblName,'IdSetare' AS IdName FROM Consultanti_Setari WHERE IdConsultant=`pIDC` UNION SELECT 0 AS IdSetare,'-' AS Setare,0 AS Valoare,'Setari' AS TblName,'IdSetare' AS IdName;
		SELECT IDF,IdColoana,f.SelTab,f.Ascuns,NumeColoana,AfisareColoana AS Afisare,PozitieInitiala AS Pozitie,NumeTabel AS Tbl,ColoanaPK=NumeColoana AS ID,TipCamp AS FldType,ColoanaPK AS PrCol,IF (TipCamp='date',1,0) AS Dt,IF (TipCamp='int',1,0) AS Nm,IF (TipCamp='double',1,0) AS Pr,AlteColoane,'{"FontName":"Consolas","FontSize":10,"FontBold":0,"FontItalic":0,"FontUnderline":0,"FontColor":"0000000"}' AS Font,JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828,'PressedForeColor',16711731) AS Color,-1 AS Latime,0 AS S,'Filtru' AS TblName,'IDF' AS IdName 
		FROM `Filtru` f 
		JOIN Coloane_Implicite ci USING (IdColoana)
		ORDER BY f.SelTab,f.Ascuns,f.IDF;
		
		-- CONDITII
		SELECT *,'Conditii' as TblName, 'IdConditie' as IdName FROM Conditii FORCE INDEX (Afisare) ORDER BY Afisare;
		SELECT *,'ConditiiS' as TblName, 'IdConditieS' as IdName FROM ConditiiS; -- ORDER BY IdConditie,Grup,Pozitie,CandDaca;
		SELECT *,'ConditiiSalvare' as TblName, 'IdConditie' as IdName FROM viewConditii_Salvare ORDER BY IdConditie;
		SELECT *,'Coloane_FC' as TblName, 'IdFC' as IdName FROM Coloane_FC;
		SELECT *,'Coloane_Implicite' as TblName, 'IdColoana' as IdName FROM Coloane_Implicite;
		SELECT *,'Semne' as TblName, 'IdSemn' as IdName FROM Semne;

		/*SELECT *,'ConditiiFormatare' as TblName, 'IdColoana' as IdName FROM view_FC ORDER BY NumeColoana;
		SELECT IDF,ColV AS NumeColoana,Col AS Afisare,Pozitie,Tbl,SelTab,IsID AS ID,Ascuns,FldType,PrCol,Dt,Nm,Pr,JSON_OBJECT('FontName','Consolas','FontSize',10,'FontBold',0,'FontItalic',0,'FontUnderline',0,'FontColor','0000000') AS Font,JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828) AS Color,-1 AS Latime,0 AS S,'Filtru' as TblName, 'IDF' as IdName FROM `Filtru` FORCE INDEX (idx_ordering) GROUP BY IDF ORDER BY SelTab,Pozitie;*/

	 -- CONSULTANTI
		SELECT *,'Consultanti_Coloane' as TblName, 'IdColoana' as IdName FROM Consultanti_Coloane WHERE IdConsultant=`pIDC`;
		SELECT *,'Consultanti_Coloane_Excel' as TblName, 'IDCOL' as IdName FROM Consultanti_Coloane_Excel WHERE IdConsultant=`pIDC`;
		SELECT *,'Consultanti_Coloane_Excel_Config' as TblName, 'IdConfig' as IdName FROM Consultanti_Coloane_Excel_Config WHERE IdConsultant=`pIDC`;
		SELECT Consultanti_Coloane_Excel.IDCOL,Consultanti_Coloane_Excel_Config.IdConfig,Consultanti_Coloane_Excel_Config.NumeConfig,Coloane_Implicite.IdColoana,Coloane_Implicite.SelTab,Coloane_Implicite.NumeTabel,Coloane_Implicite.NumeColoana,Coloane_Implicite.TipCamp,Consultanti_Coloane_Excel.Pozitie,Consultanti_Coloane_Excel.Marime,Consultanti_Coloane_Excel.Afisare,Consultanti_Coloane_Excel.Aliniere,Consultanti_Coloane_Excel.Font,NOT Consultanti_Coloane_Excel.Ascuns AS Vizibil,Consultanti_Coloane_Excel.Formatare,JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828,'PressedForeColor',16711731) AS Color,Consultanti_Coloane_Excel.DataAdaugare,Consultanti_Coloane_Excel.DataModificare,'viewConsultanti_Coloane_Excel' AS TblName,'IDCOL' AS IdName 
		FROM Coloane_Implicite 
		INNER JOIN Consultanti_Coloane_Excel USING (IdColoana) 
		INNER JOIN Consultanti_Coloane_Excel_Config  USING (IdConfig) 
		WHERE Consultanti_Coloane_Excel_Config.IdConsultant=`pIDC`;
		
		SELECT cc.IDCOL,cc.Afisare AS AfisareColoana,cc.Pozitie,cc.Marime,cc.Ascuns,cc.Aliniere,cc.Formatare,	NOT cc.Ascuns AS Vizibil,ci.IdColoana,ci.NumeColoana,ci.TipCamp,ci.Special,ci.SelTab,JSON_EXTRACT((
			SELECT json_arrayagg(json_object('NumeColoana',cf.NumeColoana,'Semn',cf.Semn,'Valoare',cf.Valoare,'BackColor',ifnull(cf.BackColor,0),'ForeColor',ifnull(cf.ForeColor,0),'FontBold',cf.FontBold,'FontItalic',cf.FontItalic,'Activ',cf.Activ)) FROM Coloane_FC cf WHERE ci.IdColoana=cf.IdColoana GROUP BY cf.IdColoana),'$') AS FC_JSON,JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828,'PressedForeColor',16711731) AS Color,'{"FontName":"Consolas","FontSize":10,"FontBold":0,"FontItalic":0,"FontUnderline":0,"FontColor":"0000000"}' AS Font,0 AS Implicit,'viewConsultanti_Coloane' AS TblName,'IDCOL' AS IdName 
			FROM Coloane_Implicite ci 
			JOIN Consultanti_Coloane cc USING (IdColoana) 
			WHERE IdConsultant=`pIDC` 
			ORDER BY SelTab,Pozitie;
		/*UNION ALL

		SELECT IDCOL,IdColoana,ci.NumeColoana,AfisareColoana,PozitieInitiala AS Pozitie,MarimeInitiala AS Marime,AscunsImplicit AS Ascuns,AliniereInitiala AS Aliniere,FormatareInitiala AS Formatare,JSON_OBJECT('BackColor',15266810,'ForeColor',0,'HoverColor',14151142,'HoverForeColor',0,'PressedColor',13434828) AS Color,'{"FontName":"Consolas","FontSize":10,"FontBold":0,"FontItalic":0,"FontUnderline":0,"FontColor":"0000000"}' AS Font,json_arrayagg(json_object('Conditie',`Coloane_FC`.`Conditie`,'BackColor',ifnull(`Coloane_FC`.`BackColor`,0),'ForeColor',ifnull(`Coloane_FC`.`ForeColor`,0),'FontBold',`Coloane_FC`.`FontBold`,'FontItalic',`Coloane_FC`.`FontItalic`,'Activ',`Coloane_FC`.`Activ`)) AS FC,Coloane_FC.NumeColoana AS NumeColoana_FC,NOT AscunsImplicit AS Vizibil,1 AS Implicit,Special,SelTab ,'Consultanti_Coloane' as TblName, 'IDCOL' as IdName FROM 
		(SELECT IDCOL,IdColoana,IdConsultant FROM Consultanti_Coloane) cc 
		INNER JOIN Coloane_Implicite ci USING (IdColoana) 
		LEFT JOIN Coloane_FC USING (IdColoana) 
		WHERE IdConsultant=`pIDC`  
		GROUP BY IdColoana 
		ORDER BY SelTab,Implicit,Vizibil DESC,Pozitie;	*/
		
		-- BAZA
		SELECT *,'Agenti' as TblName, 'IdAgent' as IdName FROM Agenti FORCE INDEX (NumeAgent) ORDER BY NumeAgent;
		SELECT *,'SursaLead' as TblName, 'IdSursa' as IdName FROM SursaLead FORCE INDEX (Sursa) ORDER BY Sursa;
		SELECT IdStatus,FelStatus,TipStatus,BackColor,Ascuns,IDSG,'Baza_Status' AS TblName,'IdStatusBaza' AS IdName FROM Baza_Status FORCE INDEX (FelStatus) ORDER BY FelStatus;
		SELECT *,'Consultanti' as TblName, 'IdConsultant' as IdName FROM viewConsultanti;
		SELECT *,'Baza_Dosare' as TblName, 'IdBaza' as IdName FROM view_Baza_Dosare;
		
		-- DOSAR
		SELECT IdBanca,Banca,Ascuns,'Banci' as TblName, 'IdBanca' as IdName FROM Banci ORDER BY Banca;
		SELECT *,'Dosar_TipVenit' as TblName, 'IdVenit' as IdName FROM Dosar_TipVenit FORCE INDEX (TipVenit) ORDER BY TipVenit ;
		SELECT *,'Dosar_TipDobanda' as TblName, 'IdTipDobanda' as IdName FROM Dosar_TipDobanda FORCE INDEX (TipDobanda) ORDER BY TipDobanda;
		SELECT *,'Dosar_Motiv' as TblName, 'IdMotiv' as IdName FROM Dosar_Motiv FORCE INDEX (Motiv) ORDER BY Motiv;
		SELECT *,'Dosar_TipMoneda' as TblName, 'IdTipMoneda' as IdName FROM Dosar_TipMoneda;
		SELECT *,'Dosar_TipCredit' as TblName, 'IdTipCredit' as IdName FROM Dosar_TipCredit;
		SELECT *,'Dosar_Stare' as TblName, 'IdStare' as IdName FROM Dosar_Stare;
		SELECT *,'Dosar_TipImobil' as TblName, 'IdTipImobil' as IdName FROM Dosar_TipImobil;
		SELECT *,'Dosar_Functii' as TblName, 'IdFunctie' as IdName FROM Dosar_Functii ORDER BY IdFunctie;
		-- SELECT *,'viewFunctii' as TblName, 'IdFunctie_view' as IdName FROM view_Dosar_Functii;
		
		SELECT *,'Dosar_Functii_Functie' as TblName, 'IdFunctieFunctie' as IdName FROM Dosar_Functii_Functie FORCE INDEX (Functie) ORDER BY Functie;
		SELECT *,'Dosar_Functii_Companie' as TblName, 'IdCompanie' as IdName FROM Dosar_Functii_Companie FORCE INDEX (Companie) ORDER BY Companie;
		SELECT *,'Dosar_Functii_Domeniu' as TblName, 'IdDomeniu' as IdName FROM Dosar_Functii_Domeniu FORCE INDEX (Domeniu) ORDER BY Domeniu;
		SELECT *,'Dosar_Functii_TipCompanie' as TblName, 'IdTipCompanie' as IdName FROM Dosar_Functii_TipCompanie FORCE INDEX (TipCompanie) ORDER BY TipCompanie;	
		SELECT *,'Dosar_FeedBack_Status' as TblName, 'IdStatusFeedBack' as IdName FROM Dosar_FeedBack_Status ORDER BY FelStatusFeedback;
		
		SELECT *,'Dosar_Status' as TblName, 'IdStatus' as IdName FROM Dosar_Status;
		SELECT *,'Sucursale' as TblName, 'IdSucursala' as IdName FROM Sucursale;
		SELECT *,'Notari' as TblName, 'IdNotar' as IdName FROM Dosar_Notari;
		SELECT *,'Evaluatori' as TblName, 'IdEvaluator' as IdName FROM Dosar_Evaluatori;
END IF;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for _UpdateSchema
-- ----------------------------
DROP PROCEDURE IF EXISTS `_UpdateSchema`;
delimiter ;;
CREATE PROCEDURE `_UpdateSchema`(IN `pSchema` varchar (255), IN optional_NumeTabel varchar(255), OUT `OUT` VARCHAR(255))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE current_table VARCHAR(255);
    DECLARE current_column VARCHAR(255);
    DECLARE SchemaExists INT;
    
    -- Declare cursor for iterating over tables and columns, excluding federated tables
    DECLARE cur_tables CURSOR FOR
        SELECT c.TABLE_NAME, c.COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS c
        JOIN INFORMATION_SCHEMA.TABLES t ON c.TABLE_NAME = t.TABLE_NAME
        WHERE c.TABLE_SCHEMA = IFNULL(pSchema,'') AND IFNULL(t.ENGINE,'') <> 'FEDERATED';
    
    -- Declare continue handler to exit loop
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET @SCH = IFNULL(pSchema,'');
		SET @RecAdded=0;
		SET @RecDeleted=0;
    SELECT 1 INTO SchemaExists FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @SCH LIMIT 1;

		IF IFNULL(optional_NumeTabel,'')<>'' THEN
			INSERT INTO TABLES_INFO (TABLE_NAME, COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH, DATA_TYPE, PRIMARY_COLUMN) 
			SELECT TABLE_NAME, COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH, 
					CASE 
							WHEN DATA_TYPE = 'int' THEN '4' 
							WHEN DATA_TYPE = 'tinyint' THEN '16' 
							WHEN DATA_TYPE = 'smallint' THEN '2' 
							WHEN DATA_TYPE = 'mediumint' THEN '3' 
							WHEN DATA_TYPE = 'bigint' THEN '20' 
							WHEN DATA_TYPE = 'float' THEN '6' 
							WHEN DATA_TYPE = 'double' THEN '5' 
							WHEN DATA_TYPE = 'decimal' THEN '14' 
							WHEN DATA_TYPE = 'char' THEN '129' 
							WHEN DATA_TYPE = 'varchar' THEN '202' 
							WHEN DATA_TYPE = 'text' THEN '202' 
							WHEN DATA_TYPE = 'date' THEN '7' 
							WHEN DATA_TYPE = 'time' THEN '134' 
							WHEN DATA_TYPE = 'datetime' THEN '135' 
							WHEN DATA_TYPE = 'timestamp' THEN '135' 
							WHEN DATA_TYPE = 'enum' THEN '202' 
							WHEN DATA_TYPE = 'set' THEN '202' 
							WHEN DATA_TYPE = 'binary' THEN '128' 
							WHEN DATA_TYPE = 'varbinary' THEN '204' 
							WHEN DATA_TYPE = 'blob' THEN '204' 
							WHEN DATA_TYPE = 'json' THEN '203' 
							ELSE DATA_TYPE 
					END AS DATA_TYPE,  
					CASE WHEN COLUMN_KEY = 'PRI' THEN COLUMN_NAME ELSE NULL END AS PRIMARY_KEY_COLUMN 
			FROM INFORMATION_SCHEMA.COLUMNS 
			WHERE TABLE_SCHEMA =  pSchema AND TABLE_NAME = optional_NumeTabel;
					
			SET @RecAdded=@RecAdded+ROW_COUNT();
			
			-- Drop columns that no longer exist in the schema
			DELETE t
			FROM TABLES_INFO t
			LEFT JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME AND t.COLUMN_NAME = c.COLUMN_NAME
			WHERE c.COLUMN_NAME IS NULL AND t.TABLE_NAME = optional_NumeTabel;
			
			SET @RecDeleted=ROW_COUNT();
						
		ELSE
			IF SchemaExists IS NULL THEN
					-- Set the error message to the OUT variable
					SET `OUT` = 'Schema does not exist.';

					-- Signal a custom exception to exit the procedure
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Custom error: Schema does not exist.';
			END IF;
		
			-- Open the cursor
			OPEN cur_tables;
			
			-- Loop over tables and columns
			read_loop: LOOP
					-- Fetch the next table and column
					FETCH cur_tables INTO current_table, current_column;
					IF done THEN
							LEAVE read_loop;
					END IF;
					
					-- Check if the column exists in TABLES_INFO
					IF NOT EXISTS (
							SELECT 1
							FROM TABLES_INFO
							WHERE TABLE_NAME = current_table
								AND COLUMN_NAME = current_column
					) THEN
							-- Column does not exist, add it to TABLES_INFO
							SET @sql = CONCAT(
									"INSERT INTO TABLES_INFO (TABLE_NAME, COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH, DATA_TYPE, PRIMARY_COLUMN) 
									SELECT TABLE_NAME, COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH, 
											CASE 
													WHEN DATA_TYPE = 'int' THEN '4' 
													WHEN DATA_TYPE = 'tinyint' THEN '16' 
													WHEN DATA_TYPE = 'smallint' THEN '2' 
													WHEN DATA_TYPE = 'mediumint' THEN '3' 
													WHEN DATA_TYPE = 'bigint' THEN '20' 
													WHEN DATA_TYPE = 'float' THEN '6' 
													WHEN DATA_TYPE = 'double' THEN '5' 
													WHEN DATA_TYPE = 'decimal' THEN '14' 
													WHEN DATA_TYPE = 'char' THEN '129' 
													WHEN DATA_TYPE = 'varchar' THEN '202' 
													WHEN DATA_TYPE = 'text' THEN '202' 
													WHEN DATA_TYPE = 'date' THEN '7' 
													WHEN DATA_TYPE = 'time' THEN '134' 
													WHEN DATA_TYPE = 'datetime' THEN '135' 
													WHEN DATA_TYPE = 'timestamp' THEN '135' 
													WHEN DATA_TYPE = 'enum' THEN '202' 
													WHEN DATA_TYPE = 'set' THEN '202' 
													WHEN DATA_TYPE = 'binary' THEN '128' 
													WHEN DATA_TYPE = 'varbinary' THEN '204' 
													WHEN DATA_TYPE = 'blob' THEN '204' 
													WHEN DATA_TYPE = 'json' THEN '203' 
													ELSE DATA_TYPE 
											END AS DATA_TYPE,  
											CASE WHEN COLUMN_KEY = 'PRI' THEN COLUMN_NAME ELSE NULL END AS PRIMARY_KEY_COLUMN 
									FROM INFORMATION_SCHEMA.COLUMNS 
									WHERE TABLE_SCHEMA = '", pSchema, "' AND TABLE_NAME = '", current_table, "' AND COLUMN_NAME = '", current_column, "';");
							PREPARE stmt FROM @sql;
							EXECUTE stmt;
							SET @RecAdded=@RecAdded+ROW_COUNT();
							DEALLOCATE PREPARE stmt;
					END IF;
			END LOOP;
			
			-- Close the cursor
			CLOSE cur_tables;
			
			-- Drop columns that no longer exist in the schema
			DELETE t
			FROM TABLES_INFO t
			LEFT JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME AND t.COLUMN_NAME = c.COLUMN_NAME
			WHERE c.COLUMN_NAME IS NULL;
			
			SET @RecDeleted=ROW_COUNT();
			
		END IF;
    SET `OUT`=JSON_OBJECT('Rows_Added',@RecAdded,'Rows_Deleted',@RecDeleted);
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for __PROBLEME DOSAR STATUS
-- ----------------------------
DROP PROCEDURE IF EXISTS `__PROBLEME DOSAR STATUS`;
delimiter ;;
CREATE PROCEDURE `__PROBLEME DOSAR STATUS`(IN `pIdBaza` int)
BEGIN
SELECT 
	(SELECT Count(IdDosar) FROM Dosar JOIN Dosar_Status USING (IdStatus) WHERE IDSG=3 AND AltaBanca=0 AND IdBaza=pIdBaza) as Dosare_Inchise_Negativ, 
	(SELECT GROUP_CONCAT(IdDosar) FROM Dosar JOIN Dosar_Status USING (IdStatus) WHERE IDSG=3 AND AltaBanca=0 AND IdBaza=pIdBaza) as IdDosare_Inchise_Negativ, 
	(SELECT Count(IdDosar) FROM Dosar JOIN Dosar_Status USING (IdStatus) WHERE IDSG=1 AND AltaBanca=0 AND IdBaza=pIdBaza AND IdStatus=1) as Dosare_Inchise_Pozitiv,
	(SELECT GROUP_CONCAT(IdDosar) FROM Dosar JOIN Dosar_Status USING (IdStatus) WHERE IDSG=1 AND AltaBanca=0 AND IdBaza=pIdBaza AND IdStatus=1) as IdDosare_Inchise_Pozitiv
;

END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Agenti
-- ----------------------------
DROP TRIGGER IF EXISTS `Agenti_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Agenti_ADD_AFTER` AFTER INSERT ON `Agenti` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Agenti_ADD_BEFORE';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Agenti' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'Sursa', (SELECT Sursa FROM SursaLead WHERE IdSursa=new.IdSursa), 
    'NumeAgent', new.NumeAgent, 
    'aTelefon', new.aTelefon, 
    'aMail', new.aMail, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdSursa,IdAgent,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdSursa,new.IdAgent,Res,"ADD_AGENT",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Agenti
-- ----------------------------
DROP TRIGGER IF EXISTS `Agenti_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Agenti_MOD_AFTER` AFTER UPDATE ON `Agenti` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Agenti_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Agenti' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'Sursa', (SELECT Sursa FROM SursaLead WHERE IdSursa=new.IdSursa), 
    'NumeAgent', new.NumeAgent, 
    'aTelefon', new.aTelefon, 
    'aMail', new.aMail, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdSursa,IdAgent,EXPL,Tip,Sch) 
 VALUES (Usr,SESSION_USER(),new.IdSursa,new.IdAgent,Res,"MOD_AGENT",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Agenti
-- ----------------------------
DROP TRIGGER IF EXISTS `Agenti_DEL_BEFORE`;
delimiter ;;
CREATE TRIGGER `Agenti_DEL_BEFORE` BEFORE DELETE ON `Agenti` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Agenti_DEL_BEFORE';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Agenti' AND Tip='DEL';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'Sursa', (SELECT Sursa FROM SursaLead WHERE IdSursa=old.IdSursa), 
    'NumeAgent', old.NumeAgent, 
    'aTelefon', old.aTelefon, 
    'aMail', old.aMail, 
    'Ascuns',IF(old.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdSursa,IdAgent,EXPL,Tip,Sch) 
 VALUES (Usr,SESSION_USER(),IdSursa,IdAgent,Res,"DEL_AGENT",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Banci
-- ----------------------------
DROP TRIGGER IF EXISTS `Banci_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Banci_ADD_AFTER` AFTER INSERT ON `Banci` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Banci_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Banci' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdBanca', new.IdBanca, 
    'Banca', new.Banca,
		'Ascuns','NU'
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,EXPL,Tip,Sch) VALUES (Usr,SESSION_USER(),Res,"ADD_BANCA",Database());
  
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Banci
-- ----------------------------
DROP TRIGGER IF EXISTS `Banci_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Banci_MOD_AFTER` AFTER UPDATE ON `Banci` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Banci_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Banci' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdBanca', new.IdBanca, 
    'Banca', new.Banca,
		'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,EXPL,Tip,Sch) VALUES (Usr,SESSION_USER(),Res,"MOD_BANCA",Database());
  
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Baza
-- ----------------------------
DROP TRIGGER IF EXISTS `Baza_ADD_BEFORE`;
delimiter ;;
CREATE TRIGGER `Baza_ADD_BEFORE` BEFORE INSERT ON `Baza` FOR EACH ROW BEGIN
		DECLARE errorMessage TEXT DEFAULT 'Nu poți să modifici informații după adăugare!';
		DECLARE v_count INT DEFAULT 0;
		DECLARE d_count INT DEFAULT 0;
    DECLARE v_telefon VARCHAR(255);
    DECLARE v_error_message VARCHAR(255);
    
    -- Obținem telefonul clientului care urmează să fie salvat
    SELECT TelefonP INTO v_telefon 
    FROM Clienti 
    WHERE IdClient = NEW.IdClient;
    
    -- Verificăm dacă există alte înregistrări în Baza cu clienți care au același telefon
    -- Excludem înregistrarea curentă din verificare
    SELECT COUNT(*) INTO v_count
    FROM Baza b
    INNER JOIN Clienti c ON b.IdClient = c.IdClient
		INNER JOIN Baza_FeedBack bf ON b.IdBaza = bf.IdBaza
    WHERE c.TelefonP = v_telefon 
      AND c.TelefonP IS NOT NULL 
      AND c.TelefonP != ''
      AND b.IdBaza != NEW.IdBaza  -- Excludem înregistrarea curentă
      AND bf.Primar = 1 AND bf.IDSG = 2 AND b.IdConsultant<>new.IdConsultant;           -- Doar înregistrările active

    SELECT COUNT(*) INTO d_count
    FROM Dosar d
    INNER JOIN Clienti c ON d.IdClient = c.IdClient
		INNER JOIN Dosar_Status ds ON d.IdStatus = ds.IdStatus
    WHERE c.TelefonP = v_telefon 
      AND c.TelefonP IS NOT NULL 
      AND c.TelefonP != ''
      AND ds.IDSG = 2 AND d.IdConsultant<>new.IdConsultant;           -- Doar înregistrările active    
			
    -- Dacă există duplicate, blocăm salvarea
    IF v_count > 0 THEN
        SET v_error_message = CONCAT('Eroare: Există ', v_count, ' înregistrare(i) în baza cu clienți care au telefonul: ', COALESCE(v_telefon, 'NULL'), ' și sunt în lucru!');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

    IF d_count > 0 THEN
        SET v_error_message = CONCAT('Eroare: Există ', d_count, ' înregistrare(i) în DOSAR cu clienți care au telefonul: ', COALESCE(v_telefon, 'NULL'), ' și sunt în lucru!');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;
		
    SELECT COUNT(*) INTO v_count
    FROM Clienti c
    INNER JOIN Dosar d USING (IdClient)
		INNER JOIN Dosar_Status ds USING (IdStatus)
    WHERE c.TelefonP = v_telefon 
      AND c.TelefonP IS NOT NULL 
      AND c.TelefonP != ''
      AND d.IdBaza != NEW.IdBaza  -- Excludem înregistrarea curentă
      AND ds.IDSG = 2;           -- Doar înregistrările active
    
    -- Dacă există duplicate, blocăm salvarea
    IF v_count > 0 THEN
        SET v_error_message = CONCAT('Eroare: Există ', v_count, ' înregistrare(i) în dosare cu clienți care au telefonul: ', COALESCE(v_telefon, 'NULL'), ' și sunt în lucru!');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Baza
-- ----------------------------
DROP TRIGGER IF EXISTS `Baza_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Baza_ADD_AFTER` AFTER INSERT ON `Baza` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
	DECLARE cntIpo INT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Baza_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;

	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;

	IF NOT ISNULL(new.IdLead) THEN
		SET cntIpo=0;
		SELECT COUNT(ID) INTO cntIpo FROM SVN_00.ipotecare WHERE id_ipotecare=NEW.IdLead;
		
		IF cntIpo>0 THEN
			UPDATE SVN_00.TRIGS t SET VAL=1 WHERE Tbl='Ipotecare' AND TIP='MOD';
			UPDATE SVN_00.ipotecare i SET i.IdBaza=new.IdBaza, i.Rezolvat=1 WHERE i.id_ipotecare=new.IdLead;
			UPDATE SVN_00.TRIGS t SET VAL=0 WHERE Tbl='Ipotecare' AND TIP='MOD';
		ELSE
			INSERT INTO SVN_00.ipotecare (id_ipotecare, IdBaza, IdConsultant, IdAgent, IdSursa, IdJudet, Rezolvat)
			SELECT new.IdLead, new.IdBaza, new.IdConsultant, new.IdAgent, new.IdSursa, (SELECT IdJudet FROM SVN_00.Judete JOIN Clienti USING (IdJudet) WHERE IdClient=new.IdClient), 1;
		END IF;
	END IF;

	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Baza' AND Tip='ADD';
  
	IF IsDisabled = 0 THEN
		SELECT
			JSON_ARRAY(
			 JSON_OBJECT( 
				'Client', (SELECT CONCAT_WS(',',NumeClient,TelefonP,EmailP) FROM Clienti WHERE IdClient=new.IdClient),
				'Sursa', (SELECT Sursa FROM SursaLead WHERE IdSursa=new.IdSursa),
				'Agent',(SELECT NumeAgent FROM Agenti WHERE IdAgent=new.IdAgent),
				'Consultant',(SELECT NumeConsultant FROM SVN_00.Consultanti WHERE IdConsultant=new.IdConsultant),
				'DataPrimire',DATE_FORMAT(new.DataPrimire, '%m-%d-%Y'),
				'ONLINE',IF(new.Nou=1,'DA','NU')
				)
			 ) 
		INTO Res;

		INSERT INTO `LOG`.LOG (IdCons,UserName,IdConsultant,IdBaza,IdClient,IdSursa,IdAgent,EXPL,Tip,Sch) 
		VALUES (Usr,SESSION_USER(),new.IdConsultant,new.IdBaza,new.IdClient,new.IdSursa,new.IdAgent,Res,"ADD_BAZA",Database());
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Baza
-- ----------------------------
DROP TRIGGER IF EXISTS `Baza_MOD_BEFORE`;
delimiter ;;
CREATE TRIGGER `Baza_MOD_BEFORE` BEFORE UPDATE ON `Baza` FOR EACH ROW BEGIN
	DECLARE errorMessage TEXT DEFAULT 'Nu poți să modifici informații după adăugare!';
	
    IF OLD.IdBaza != NEW.IdBaza OR
       OLD.DataAdaugare != NEW.DataAdaugare THEN
       
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = errorMessage;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Baza
-- ----------------------------
DROP TRIGGER IF EXISTS `Baza_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Baza_MOD_AFTER` AFTER UPDATE ON `Baza` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
	DECLARE LeadAscuns TINYINT (4);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Baza_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;

	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;

	IF new.IdConsultant<>old.IdConsultant THEN
		UPDATE Dosar SET IdConsultant=new.IdConsultant WHERE Dosar.IdBaza=old.IdBaza;
		UPDATE Dosar_Alarme JOIN Dosar USING (IdDosar) SET Dosar_Alarme.IdConsultant=new.IdConsultant WHERE Dosar.IdBaza=old.IdBaza;
		UPDATE Baza_Alarme SET IdConsultant=new.IdConsultant WHERE Baza_Alarme.IdBaza=old.IdBaza;
	END IF;
	
	IF new.IdSursa<>old.IdSursa THEN
		UPDATE Dosar SET IdSursa=new.IdSursa WHERE Dosar.IdBaza=old.IdBaza;
	END IF;

	IF new.IdAgent<>old.IdAgent THEN
		UPDATE Dosar SET IdAgent=new.IdAgent WHERE Dosar.IdBaza=old.IdBaza;
	END IF;

	SET LeadAscuns = new.Ascuns;
	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Baza' AND Tip='MOD';
 
	SET Res='';
	IF IsDisabled = 0 THEN
		-- Construim JSON array doar cu câmpurile modificate
		SELECT JSON_ARRAYAGG(
				CASE 
						WHEN new.IdClient <> old.IdClient THEN 
								JSON_OBJECT('Client', CONCAT(
										(SELECT CONCAT_WS(',',NumeClient,TelefonP,EmailP) FROM Clienti WHERE IdClient=old.IdClient),
										' > ',
										(SELECT CONCAT_WS(',',NumeClient,TelefonP,EmailP) FROM Clienti WHERE IdClient=new.IdClient)
								))
						WHEN new.IdSursa <> old.IdSursa THEN 
								JSON_OBJECT('Sursa', CONCAT(
										(SELECT Sursa FROM SursaLead WHERE IdSursa=old.IdSursa),
										' > ',
										(SELECT Sursa FROM SursaLead WHERE IdSursa=new.IdSursa)
								))
						WHEN new.IdAgent <> old.IdAgent THEN 
								JSON_OBJECT('Agent', CONCAT(
										(SELECT NumeAgent FROM Agenti WHERE IdAgent=old.IdAgent),
										' > ',
										(SELECT NumeAgent FROM Agenti WHERE IdAgent=new.IdAgent)
								))
						WHEN new.IdConsultant <> old.IdConsultant THEN 
								JSON_OBJECT('Consultant', CONCAT(
										(SELECT NumeConsultant FROM SVN_00.Consultanti WHERE IdConsultant=old.IdConsultant),
										' > ',
										(SELECT NumeConsultant FROM SVN_00.Consultanti WHERE IdConsultant=new.IdConsultant)
								))
						WHEN new.DataPrimire <> old.DataPrimire THEN 
								JSON_OBJECT('DataPrimire', CONCAT(
										DATE_FORMAT(old.DataPrimire, '%m-%d-%Y'),
										' > ',
										DATE_FORMAT(new.DataPrimire, '%m-%d-%Y')
								))
						WHEN new.Nou <> old.Nou THEN 
								JSON_OBJECT('ONLINE', CONCAT(
										IF(old.Nou=1,'DA','NU'),
										' > ',
										IF(new.Nou=1,'DA','NU')
								))
						WHEN new.Ascuns <> old.Ascuns THEN
								JSON_OBJECT('ȘTERS', CONCAT(
										IF(old.Ascuns=1,'DA','NU'),
										' > ',
										IF(new.Ascuns=1,'DA','NU')
								))
				END
		) INTO Res
		FROM (
				SELECT 1 as dummy
				WHERE new.IdClient <> old.IdClient 
					 OR new.IdSursa <> old.IdSursa 
					 OR new.IdAgent <> old.IdAgent 
					 OR new.IdConsultant <> old.IdConsultant 
					 OR new.DataPrimire <> old.DataPrimire 
					 OR new.Nou <> old.Nou
					 OR new.Ascuns <> old.Ascuns
		) t;
		
		IF Res <> '' THEN
			IF LeadAscuns = TRUE THEN
				INSERT INTO `LOG`.LOG (IdCons,UserName,IdConsultant,IdBaza,IdClient,IdSursa,IdAgent,EXPL,Tip,Sch) 
				VALUES (Usr,SESSION_USER(),new.IdConsultant,new.IdBaza,new.IdClient,new.IdSursa,new.IdAgent,Res,"DEL_BAZA",Database());				
			ELSE
				INSERT INTO `LOG`.LOG (IdCons,UserName,IdConsultant,IdBaza,IdClient,IdSursa,IdAgent,EXPL,Tip,Sch) 
				VALUES (Usr,SESSION_USER(),new.IdConsultant,new.IdBaza,new.IdClient,new.IdSursa,new.IdAgent,Res,"MOD_BAZA",Database());
			END IF;
		END IF;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Baza_FeedBack
-- ----------------------------
DROP TRIGGER IF EXISTS `Baza_Feedback_BEFORE_AFTER`;
delimiter ;;
CREATE TRIGGER `Baza_Feedback_BEFORE_AFTER` BEFORE INSERT ON `Baza_FeedBack` FOR EACH ROW BEGIN
	IF new.DataReconectare IS NULL AND new.IDSG=2 THEN
		SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
		SET MESSAGE_TEXT = 'Nu poți să adaugi un FeedBack <DE RECONTACTAT> fără Dată Reconectare!';
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Baza_FeedBack
-- ----------------------------
DROP TRIGGER IF EXISTS `Baza_Feedback_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Baza_Feedback_ADD_AFTER` AFTER INSERT ON `Baza_FeedBack` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Baza_Feedback_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;
	
	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;

	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Baza_FeedBack' AND Tip='ADD';
	
	IF IsDisabled = 0 THEN
		SELECT
			JSON_ARRAY(
				JSON_OBJECT( 
					'Status',(SELECT FelStatus FROM Baza_Status WHERE IdStatus=new.IdStatus),
					'Stare', (SELECT GRUP FROM Baza_Status_Grup WHERE IDSG=new.IDSG),
					'DataConectare',DATE_FORMAT(NEW.DataConectare, '%m-%d-%Y'),
					'DataReconectare',DATE_FORMAT(NEW.DataReconectare, '%m-%d-%Y'),
					'MailTrimis','NU',
					'Intalnire',IF(new.Intalnire=1,'DA','NU'),
					'Ora/Minut',CONCAT(new.Ora,':',new.Minut),
					'FeedBack',REGEXP_REPLACE (REPLACE(new.FeedBack,'<BR>','\n'), '<.+?>', '')
					)
				) 
		INTO Res;
			
		INSERT INTO `LOG`.LOG ( IdCons, UserName, IdConsultant, IdBaza, IdClient, IdBazaFeedback, EXPL, Tip, Sch )
		SELECT Usr,SESSION_USER(),new.IdConsultant,new.IdBaza,(SELECT IdClient FROM Baza WHERE IdBaza=new.IdBaza),new.IdFeedBack,Res,"ADD_BAZA_FEEDBACK",Database();
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Baza_FeedBack
-- ----------------------------
DROP TRIGGER IF EXISTS `Baza_Feedback_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Baza_Feedback_MOD_AFTER` AFTER UPDATE ON `Baza_FeedBack` FOR EACH ROW trigger_body: BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
	DECLARE changes JSON DEFAULT JSON_ARRAY();
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Baza_Feedback_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;
	
	LEAVE trigger_body; -- nu exista niciodata modificari in FEEDBACK!
	
	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;
	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Baza_FeedBack' AND Tip='MOD';
	
	IF new.Primar=0 THEN 
		LEAVE trigger_body;
	END IF;
	
	IF IsDisabled = 0 THEN
		-- Verificăm și adăugăm doar câmpurile modificate
		
		-- Status
		IF IFNULL(new.IdStatus,0) <> IFNULL(old.IdStatus,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Status', CONCAT(
					IFNULL((SELECT FelStatus FROM Baza_Status WHERE IdStatus=old.IdStatus), 'NULL'),
					' <> ',
					IFNULL((SELECT FelStatus FROM Baza_Status WHERE IdStatus=new.IdStatus), 'NULL')
				))
			);
		END IF;
		
		-- Stare
		IF IFNULL(new.IDSG,0) <> IFNULL(old.IDSG,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Stare', CONCAT(
					IFNULL((SELECT GRUP FROM Baza_Status_Grup WHERE IDSG=old.IDSG), 'NULL'),
					' <> ',
					IFNULL((SELECT GRUP FROM Baza_Status_Grup WHERE IDSG=new.IDSG), 'NULL')
				))
			);
		END IF;
		
		-- DataConectare
		IF IFNULL(new.DataConectare,'') <> IFNULL(old.DataConectare,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('DataConectare', CONCAT(
					IFNULL(DATE_FORMAT(old.DataConectare, '%m-%d-%Y'), 'NULL'),
					' <> ',
					IFNULL(DATE_FORMAT(new.DataConectare, '%m-%d-%Y'), 'NULL')
				))
			);
		END IF;
		
		-- DataReconectare
		IF IFNULL(new.DataReconectare,'') <> IFNULL(old.DataReconectare,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('DataReconectare', CONCAT(
					IFNULL(DATE_FORMAT(old.DataReconectare, '%m-%d-%Y'), 'NULL'),
					' <> ',
					IFNULL(DATE_FORMAT(new.DataReconectare, '%m-%d-%Y'), 'NULL')
				))
			);
		END IF;
		
		-- Intalnire
		IF IFNULL(new.Intalnire,0) <> IFNULL(old.Intalnire,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Intalnire', CONCAT(
					IF(old.Intalnire=1,'DA','NU'),
					' <> ',
					IF(new.Intalnire=1,'DA','NU')
				))
			);
		END IF;
		
		-- Ora
		IF IFNULL(new.Ora,0) <> IFNULL(old.Ora,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Ora', CONCAT(
					IFNULL(old.Ora, 'NULL'),
					' <> ',
					IFNULL(new.Ora, 'NULL')
				))
			);
		END IF;
		
		-- Minut
		IF IFNULL(new.Minut,0) <> IFNULL(old.Minut,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Minut', CONCAT(
					IFNULL(old.Minut, 'NULL'),
					' <> ',
					IFNULL(new.Minut, 'NULL')
				))
			);
		END IF;
		
		-- FeedBack
		IF IFNULL(new.FeedBack,'') <> IFNULL(old.FeedBack,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('FeedBack', CONCAT(
					IFNULL(REGEXP_REPLACE(REPLACE(old.FeedBack,'<BR>','\n'), '<.+?>', ''), 'NULL'),
					' <> ',
					IFNULL(REGEXP_REPLACE(REPLACE(new.FeedBack,'<BR>','\n'), '<.+?>', ''), 'NULL')
				))
			);
		END IF;
		
		-- Setăm Res cu modificările găsite
		SET Res = CAST(changes AS CHAR);
		
		-- Inserăm în log doar dacă au fost modificări
		IF JSON_LENGTH(changes) > 0 THEN
			INSERT INTO `LOG`.LOG ( IdCons, UserName, IdConsultant, IdBaza, IdClient, IdBazaFeedback, EXPL, Tip, Sch )
			SELECT Usr,SESSION_USER(),new.IdConsultant,new.IdBaza,(SELECT IdClient FROM Baza WHERE IdBaza=new.IdBaza),new.IdFeedBack,Res,"MOD_BAZA_FEEDBACK",Database();
		END IF;
	END IF;
END trigger_body
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Clienti
-- ----------------------------
DROP TRIGGER IF EXISTS `Clienti_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Clienti_ADD_AFTER` AFTER INSERT ON `Clienti` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Clienti_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;

	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;

	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Clienti' AND Tip='ADD';

	IF IsDisabled = 0 THEN
		SELECT
			JSON_ARRAY(
			 JSON_OBJECT( 
				'NumeClient', new.NumeClient ,
				'CNPClient',new.CNPClient,
				'TelefonP',new.TelefonP,
				'EmailP',new.EmailP,
				'DataNastere',DATE_FORMAT(new.DataNastere,'%d-%m-%Y')
				)
			 ) 
		INTO Res;

		INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,NumeClient,TelefonClient,CNP,EXPL,Tip,Sch) 
		VALUES (Usr,SESSION_USER(),new.IdClient,new.NumeClient,new.TelefonP,new.CNPClient,Res,"ADD_CLIENT",Database());

		INSERT INTO Clienti_Telefon (IdClient,Telefon,Primar,NoTrig) VALUES (new.IdClient,new.TelefonP,TRUE,TRUE);

		IF IFNULL(new.EmailP,'') <> '' THEN
			INSERT INTO Clienti_Mail (IdClient,Email,Primar,NoTrig) VALUES (new.IdClient,new.EmailP,TRUE,TRUE);
		END IF;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Clienti
-- ----------------------------
DROP TRIGGER IF EXISTS `Clienti_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Clienti_MOD_AFTER` AFTER UPDATE ON `Clienti` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
	DECLARE changes JSON DEFAULT JSON_ARRAY();
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Clienti_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;
	
	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;
	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Clienti' AND Tip='MOD';
 
	IF IsDisabled = 0 THEN
		-- NumeClient
		IF IFNULL(new.NumeClient,'') <> IFNULL(old.NumeClient,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('NumeClient', CONCAT(
					IFNULL(old.NumeClient, 'NULL'),
					' > ',
					IFNULL(new.NumeClient, 'NULL')
				))
			);
		END IF;
		
		-- CNPClient
		IF IFNULL(new.CNPClient,'') <> IFNULL(old.CNPClient,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('CNPClient', CONCAT(
					IFNULL(old.CNPClient, 'NULL'),
					' > ',
					IFNULL(new.CNPClient, 'NULL')
				))
			);
		END IF;
		
		-- TelefonP
		IF IFNULL(new.TelefonP,'') <> IFNULL(old.TelefonP,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('TelefonP', CONCAT(
					IFNULL(old.TelefonP, 'NULL'),
					' > ',
					IFNULL(new.TelefonP, 'NULL')
				))
			);
		END IF;
		
		-- EmailP
		IF IFNULL(new.EmailP,'') <> IFNULL(old.EmailP,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('EmailP', CONCAT(
					IFNULL(old.EmailP, 'NULL'),
					' > ',
					IFNULL(new.EmailP, 'NULL')
				))
			);
		END IF;
		
		-- DataNastere
		IF IFNULL(new.DataNastere,'') <> IFNULL(old.DataNastere,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('DataNastere', CONCAT(
					IFNULL(DATE_FORMAT(old.DataNastere,'%d-%m-%Y'), 'NULL'),
					' > ',
					IFNULL(DATE_FORMAT(new.DataNastere,'%d-%m-%Y'), 'NULL')
				))
			);
		END IF;
		
		-- Setăm Res cu modificările găsite
		SET Res = CAST(changes AS CHAR);
		
		-- Inserăm în log doar dacă au fost modificări
		IF JSON_LENGTH(changes) > 0 THEN
			INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,NumeClient,TelefonClient,CNP,EXPL,Tip,Sch) 
			VALUES (Usr,SESSION_USER(),new.IdClient,new.NumeClient,new.TelefonP,new.CNPClient,Res,"MOD_CLIENT",Database());
		END IF;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Clienti_Mail
-- ----------------------------
DROP TRIGGER IF EXISTS `Clienti_Mail_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Clienti_Mail_ADD_AFTER` AFTER INSERT ON `Clienti_Mail` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Clienti_Mail_ADD_BEFORE';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;

	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;

	IF new.NoTrig=0 THEN 
	 SET IsDisabled=0;
	 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Clienti_Mail' AND Tip='ADD';
	 
		IF IsDisabled = 0 THEN
		 SELECT
			JSON_ARRAY(
			 JSON_OBJECT(
			  'IdEmail',new.IdEmail,
				'Email',new.Email,
				'Primar',IF(new.Primar=1,'DA','NU')
				)
			 ) 
			INTO Res;
		
		 INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,EXPL,Tip,Sch) 
		 VALUES (Usr,SESSION_USER(),new.IdClient,Res,"ADD_MAIL_CLIENT",Database());
		END IF;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Clienti_Mail
-- ----------------------------
DROP TRIGGER IF EXISTS `Clienti_Mail_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Clienti_Mail_MOD_AFTER` AFTER UPDATE ON `Clienti_Mail` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Clienti_Mail_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;

	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;

	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Clienti_Mail' AND Tip='MOD';

	IF IsDisabled = 0 THEN
		SELECT
			JSON_ARRAY(
			 JSON_OBJECT( 
				'IdEmail', new.IdEmail,
				'Email',new.Email,
				'Primar',IF(new.Primar=1,'DA','NU')
				)
			 ) 
		INTO Res;

		INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,EXPL,Tip,Sch) 
		VALUES (Usr,SESSION_USER(),new.IdClient,Res,"MOD_MAIL_CLIENT",Database());
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Clienti_Mail
-- ----------------------------
DROP TRIGGER IF EXISTS `Clienti_Mail_DEL_BEFORE`;
delimiter ;;
CREATE TRIGGER `Clienti_Mail_DEL_BEFORE` BEFORE DELETE ON `Clienti_Mail` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Clienti_Mail_DEL_BEFORE';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;

	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;

	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Clienti_Mail' AND Tip='DEL';

	IF IsDisabled = 0 THEN
		SELECT
			JSON_ARRAY(
			 JSON_OBJECT( 
				'IdEmail', old.IdEmail,
				'Email',old.Email,
				'Primar',IF(old.Primar=1,'DA','NU')
				)
			 ) 
		INTO Res;

		INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,EXPL,Tip,Sch) 
		VALUES (Usr,SESSION_USER(),old.IdClient,Res,"DEL_MAIL_CLIENT",Database());
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Clienti_Note
-- ----------------------------
DROP TRIGGER IF EXISTS `Clienti_Note_ADD`;
delimiter ;;
CREATE TRIGGER `Clienti_Note_ADD` AFTER INSERT ON `Clienti_Note` FOR EACH ROW BEGIN
	DECLARE
		Res TEXT ( 10000 );
	DECLARE
		NClient VARCHAR ( 255 );
	DECLARE
		TClient VARCHAR ( 255 );
	DECLARE
		CClient VARCHAR ( 255 );
	DECLARE
		IsDisabled TINYINT ( 4 );
	DECLARE
		Usr INT;
	DECLARE
		errorCode CHAR ( 5 ) DEFAULT '00000';
	DECLARE
		errorMessage TEXT DEFAULT '';
	DECLARE
	EXIT HANDLER FOR SQLEXCEPTION BEGIN
		BEGIN
				
				SET @TRIGNAME = 'Clienti_Note_ADD';
			GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE,
			errorMessage = MESSAGE_TEXT;
			
			SET @ERM = CONCAT_WS( "\n", @TRIGNAME, errorCode, errorMessage );
			SIGNAL SQLSTATE '45000' 
			SET MESSAGE_TEXT = @ERM;
			
		END;
		
	END;
	IF
		UCASE(
		SUBSTRING_INDEX( SESSION_USER(), "@", 1 )) = "ADMIN" 
		OR UCASE(
			SUBSTRING_INDEX( SESSION_USER(), "@", 1 )) = "ROOT" THEN
			
			SET Usr = 0;
		ELSE 
			SET Usr = CAST( REGEXP_REPLACE ( SUBSTRING_INDEX( SESSION_USER(), '@', 1 ), '\\D+', '' ) AS INT );
		
	END IF;
	
	SET IsDisabled = 0;
	SELECT
		Val INTO IsDisabled 
	FROM
		TRIGS 
	WHERE
		TBL = 'Clienti_Note' 
		AND Tip = 'ADD';
	IF
		IsDisabled = 0 THEN
			INSERT INTO `LOG`.LOG ( IdCons, UserName, IdClient, NumeClient, TelefonClient, CNP, EXPL, Tip, Sch ) SELECT
			Usr,
			SESSION_USER(),
			IdClient,
			NumeClient,
			TelefonP,
			CNPClient,
			JSON_ARRAY(
				JSON_OBJECT( 'IdClientNota', new.IdClientNota, 'IdClient', new.IdClient, 'IdConsultant', new.IdConsultant, 'Note', new.Note )),
				"ADD_NOTA",Database() 
			FROM
				Clienti_Note
				JOIN Clienti USING ( IdClient );
			
		END IF;
	
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Clienti_Note
-- ----------------------------
DROP TRIGGER IF EXISTS `Clienti_Note_MOD`;
delimiter ;;
CREATE TRIGGER `Clienti_Note_MOD` AFTER UPDATE ON `Clienti_Note` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE NClient VARCHAR (255);
 DECLARE TClient VARCHAR (255);
 DECLARE CClient VARCHAR (255);
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Clienti_Note_MOD';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Clienti_Note' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  NumeClient,
  CNPClient,
  TelefonP,
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdClientNota',new.IdClientNota,
    'IdClient', new.IdClient,
    'IdConsultant', new.IdConsultant,
    'Note',new.Note
    )
   ) INTO 
    NClient,
    CClient,
    TClient,
    Res
 FROM
  Clienti INNER JOIN Clienti_Note USING (IdClient)
 WHERE
  IdClientNota =new.IdClientNota;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,NumeClient,TelefonClient,CNP,EXPL,Tip,Sch) VALUES (Usr,SESSION_USER(),new.IdClient,NClient,TClient,CClient,Res,"MOD_NOTA",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Clienti_Telefon
-- ----------------------------
DROP TRIGGER IF EXISTS `Clienbti_Telefon_ADD`;
delimiter ;;
CREATE TRIGGER `Clienbti_Telefon_ADD` AFTER INSERT ON `Clienti_Telefon` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Clienti_Telefon_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;

	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;

	IF new.NoTrig=0 THEN
		SET IsDisabled=0;
		SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Clienti_Telefon' AND Tip='MOD';
	 
		IF IsDisabled = 0 THEN
			SELECT
				JSON_ARRAY(
				JSON_OBJECT( 
				'IdTelefon', new.IdTelefon,
				'Telefon',new.Telefon,
				'Primar',IF(new.Primar=1,'DA','NU')
				)
				) 
			INTO Res;

			INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,EXPL,Tip,Sch) 
			VALUES (Usr,SESSION_USER(),new.IdClient,Res,"ADD_TELEFON_CLIENT",Database());
		END IF;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Clienti_Telefon
-- ----------------------------
DROP TRIGGER IF EXISTS `Clienti_Telefon_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Clienti_Telefon_MOD_AFTER` AFTER UPDATE ON `Clienti_Telefon` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Clienti_Telefon_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;

	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;

	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Clienti_Telefon' AND Tip='MOD';

	IF IsDisabled = 0 THEN
		SELECT
			JSON_ARRAY(
			 JSON_OBJECT( 
				'IdTelefon', new.IdTelefon,
				'Telefon',new.Telefon,
				'Primar',IF(new.Primar=1,'DA','NU')
				)
			 ) 
		INTO Res;

		INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,EXPL,Tip,Sch) 
		VALUES (Usr,SESSION_USER(),new.IdClient,Res,"MOD_TELEFON_CLIENT",Database());
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Coloane_Implicite
-- ----------------------------
DROP TRIGGER IF EXISTS `Coloane_Implicite__BEFORE_ADD`;
delimiter ;;
CREATE TRIGGER `Coloane_Implicite__BEFORE_ADD` BEFORE INSERT ON `Coloane_Implicite` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Consultanti_Coloane_BEFORE_ADD';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
 END; 

	IF IFNULL(new.PozitieInitiala,'')='' THEN
		SET NEW.PozitieInitiala = COALESCE((SELECT MAX(PozitieInitiala) + 1 FROM Coloane_Implicite WHERE Coloane_Implicite.SelTab=new.SelTab), 1);
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Coloane_Implicite
-- ----------------------------
DROP TRIGGER IF EXISTS `Coloane_Implicite__AFTER_ADD`;
delimiter ;;
CREATE TRIGGER `Coloane_Implicite__AFTER_ADD` AFTER INSERT ON `Coloane_Implicite` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Consultanti_Coloane_AFTER_ADD';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 

 INSERT INTO Consultanti_Coloane (IdColoana,IdConsultant,Pozitie,Marime,Ascuns,SelTab,Afisare,Special,Formatare,Aliniere) SELECT IdColoana,IdConsultant,PozitieInitiala,MarimeInitiala,AscunsImplicit,SelTab,AfisareColoana,Special,FormatareInitiala,AliniereInitiala FROM Consultanti,Coloane_Implicite WHERE IdColoana=new.IdColoana;
 
 INSERT INTO Coloane_Implicite_Excel (IdColoana,AfisareColoana,PozitieInitiala,MarimeInitiala,AliniereInitiala,AscunsImplicit,SelTab,FontInitial) SELECT IdColoana,AfisareColoana,PozitieInitiala,MarimeInitiala,AliniereInitiala,AscunsImplicit,SelTab,'{"FontName":"Consolas","FontSize":10,"FontBold":0,"FontItalic":0,"FontUnderline":0,"ForeColor":"0000000"}' FROM Coloane_Implicite WHERE IdColoana=new.IdColoana;
 
 INSERT INTO Consultanti_Coloane_Excel (IdColoana,IdConfig,IdConsultant,Pozitie,Marime,Ascuns,SelTab,Afisare,Font,Aliniere,Formatare) SELECT ci.IdColoana,ccec.IdConfig,c.IdConsultant,ci.PozitieInitiala,ci.MarimeInitiala,ci.AscunsImplicit,ci.SelTab,ci.AfisareColoana,ci.FontInitial,ci.AliniereInitiala,ci.FormatareInitiala FROM Coloane_Implicite_Excel ci,(Consultanti c JOIN Consultanti_Coloane_Excel_Config ccec ON c.IdConsultant=ccec.IdConsultant) WHERE ci.IdColoana=new.IdColoana;

END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Coloane_Implicite
-- ----------------------------
DROP TRIGGER IF EXISTS `Coloane_Implicite__MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Coloane_Implicite__MOD_AFTER` AFTER UPDATE ON `Coloane_Implicite` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Consultanti_Coloane_AFTER_ADD';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 

	IF new.PozitieInitiala <> old.PozitieInitiala THEN
		UPDATE Consultanti_Coloane SET Pozitie = new.PozitieInitiala WHERE IdColoana=new.IdColoana;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Coloane_Implicite
-- ----------------------------
DROP TRIGGER IF EXISTS `Coloane_Implicite__DEL`;
delimiter ;;
CREATE TRIGGER `Coloane_Implicite__DEL` BEFORE DELETE ON `Coloane_Implicite` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Consultanti_Coloane_DEL';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
 END; 
 
 DELETE FROM Consultanti_Coloane WHERE IdColoana=old.IdColoana;

END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Coloane_Implicite_Excel
-- ----------------------------
DROP TRIGGER IF EXISTS `Coloane_Implicite_Excel__ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Coloane_Implicite_Excel__ADD_AFTER` AFTER INSERT ON `Coloane_Implicite_Excel` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Coloane_Implicite_Excel__INS_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;

	INSERT INTO Consultanti_Coloane_Excel ( IdConfig, IdColoana, IdConsultant, SelTab, Pozitie, Marime, Afisare, Aliniere, Formatare, Font, Vizibil, Ascuns)
	SELECT IdConfig, new.IdColoana, IdConsultant, new.SelTab, new.PozitieInitiala, new.MarimeInitiala, new.AfisareColoana, new.AliniereInitiala, new.FormatareInitiala, new.FontInitial, NOT new.AscunsImplicit, new.AscunsImplicit
	FROM Consultanti_Coloane_Excel_Config
	WHERE Consultanti_Coloane_Excel_Config.SelTab = new.SelTab;
		
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Coloane_Implicite_Excel
-- ----------------------------
DROP TRIGGER IF EXISTS `Coloane_Implicite_Excel__MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Coloane_Implicite_Excel__MOD_AFTER` AFTER UPDATE ON `Coloane_Implicite_Excel` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Coloane_Implicite_Excel__ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;

	IF new.PozitieInitiala<>old.PozitieInitiala THEN
		UPDATE Consultanti_Coloane_Excel cce JOIN Consultanti_Coloane_Excel_Config ccec USING (IdConfig) SET cce.Pozitie=new.PozitieInitiala WHERE cce.IdColoana=new.IdColoana AND ccec.NumeConfig='(implicit)';
	END IF;
	
	IF new.AfisareColoana<>old.AfisareColoana THEN
		UPDATE Consultanti_Coloane_Excel cce JOIN Consultanti_Coloane_Excel_Config ccec USING (IdConfig) SET cce.Afisare=new.AfisareColoana WHERE cce.IdColoana=new.IdColoana AND ccec.NumeConfig='(implicit)';
	END IF;
	
	IF new.AscunsImplicit<>old.AscunsImplicit THEN
		UPDATE Consultanti_Coloane_Excel cce JOIN Consultanti_Coloane_Excel_Config ccec USING (IdConfig) SET cce.Ascuns=new.AscunsImplicit, cce.Vizibil=NOT new.AscunsImplicit WHERE cce.IdColoana=new.IdColoana AND ccec.NumeConfig='(implicit)';
	END IF;
-- 	UPDATE Consultanti_Coloane_Excel SET Pozitie=new.PozitieInitiala, Marime=new.MarimeInitiala, Afisare=new.AfisareColoana, Aliniere=new.AliniereInitiala, Font=new.FontInitial, Ascuns=new.AscunsImplicit, Formatare=new.FormatareInitiala WHERE IdColoana=new.IdColoana;
	
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table ConditiiS
-- ----------------------------
DROP TRIGGER IF EXISTS `ConditiiS_ADD_After`;
delimiter ;;
CREATE TRIGGER `ConditiiS_ADD_After` AFTER INSERT ON `ConditiiS` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='ConditiiS_ADD_After';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;
	
	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;
	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='ConditiiS' AND Tip="ADD";
	
	IF IsDisabled = 0 THEN
		SELECT
			JSON_ARRAY(
				JSON_OBJECT( 
					'IdConditie', new.IdConditie, 
					'IdConditieS', new.IdConditieS,
					'SelTab', new.SelTab,
					'Grup', new.Grup,
					'Denumire', new.Denumire,
					'Pozitie', new.Pozitie,
					'CampPrincipal', new.CampPrincipal,
					'AfisareCampPrincipal', new.AfisareCampPrincipal,
					'TipCampPrincipal', new.TipCampPrincipal,
					'CampAsociat', new.CampAsociat,
					'AfisareCampAsociat', new.AfisareCampAsociat,
					'TipCampAsociat', new.TipCampAsociat,
					'Valoare', new.Valoare,
					'AfisareValoare', new.AfisareValoare,
					'TipCampValoare', new.TipCampValoare,
					'Semn', new.Semn,
					'AfisareSemn', new.AfisareSemn,
					'AltCamp', new.AltCamp,
					'Mesaj', new.Mesaj,
					'CandDaca', IF(new.CandDaca=0,'Cand','Daca'),
					'Functie', new.Functie,
					'Activa', IF(new.Activa=1,'DA','NU'),
					'Versiune', new.Versiune,
					'DataAdaugare', DATE_FORMAT(new.DataAdaugare, '%m-%d-%Y %H:%i:%s'),
					'DataModificare', DATE_FORMAT(new.DataModificare, '%m-%d-%Y %H:%i:%s')
				)
			) INTO Res;
		
		INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,EXPL,Tip) 
		VALUES (Database(),Usr,SESSION_USER(),Res,"ADD_COND");
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table ConditiiS
-- ----------------------------
DROP TRIGGER IF EXISTS `ConditiiS_DEL_After`;
delimiter ;;
CREATE TRIGGER `ConditiiS_DEL_After` AFTER DELETE ON `ConditiiS` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='ConditiiS_DEL_After';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;
	
	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;
	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='ConditiiS' AND Tip="DEL";
	
	IF IsDisabled = 0 THEN
		SELECT
			JSON_ARRAY(
				JSON_OBJECT( 
					'IdConditie', old.IdConditie, 
					'IdConditieS', old.IdConditieS,
					'SelTab', old.SelTab,
					'Grup', old.Grup,
					'Denumire', old.Denumire,
					'Pozitie', old.Pozitie,
					'CampPrincipal', old.CampPrincipal,
					'AfisareCampPrincipal', old.AfisareCampPrincipal,
					'TipCampPrincipal', old.TipCampPrincipal,
					'CampAsociat', old.CampAsociat,
					'AfisareCampAsociat', old.AfisareCampAsociat,
					'TipCampAsociat', old.TipCampAsociat,
					'Valoare', old.Valoare,
					'AfisareValoare', old.AfisareValoare,
					'TipCampValoare', old.TipCampValoare,
					'Semn', old.Semn,
					'AfisareSemn', old.AfisareSemn,
					'AltCamp', old.AltCamp,
					'Mesaj', old.Mesaj,
					'CandDaca', IF(old.CandDaca=0,'Cand','Daca'),
					'Functie', old.Functie,
					'Activa', IF(old.Activa=1,'DA','NU'),
					'Versiune', old.Versiune,
					'DataAdaugare', DATE_FORMAT(old.DataAdaugare, '%m-%d-%Y %H:%i:%s'),
					'DataModificare', DATE_FORMAT(old.DataModificare, '%m-%d-%Y %H:%i:%s')
				)
			) INTO Res;
		
		INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,EXPL,Tip) 
		VALUES (Database(),Usr,SESSION_USER(),Res,"DEL_COND");
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table ConditiiS
-- ----------------------------
DROP TRIGGER IF EXISTS `ConditiiS_MOD_After`;
delimiter ;;
CREATE TRIGGER `ConditiiS_MOD_After` AFTER UPDATE ON `ConditiiS` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
	DECLARE changes JSON DEFAULT JSON_ARRAY();
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='ConditiiS_MOD_After';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;
	
	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;
	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='ConditiiS' AND Tip="MOD";
	
	IF IsDisabled = 0 THEN
		-- IdConditie
		IF IFNULL(new.IdConditie,0) <> IFNULL(old.IdConditie,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('IdConditie', CONCAT(
					IFNULL(old.IdConditie, 'NULL'),
					' > ',
					IFNULL(new.IdConditie, 'NULL')
				))
			);
		END IF;
		
		-- SelTab
		IF IFNULL(new.SelTab,'') <> IFNULL(old.SelTab,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('SelTab', CONCAT(
					IFNULL(old.SelTab, 'NULL'),
					' > ',
					IFNULL(new.SelTab, 'NULL')
				))
			);
		END IF;
		
		-- Grup
		IF IFNULL(new.Grup,0) <> IFNULL(old.Grup,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Grup', CONCAT(
					IFNULL(old.Grup, 'NULL'),
					' > ',
					IFNULL(new.Grup, 'NULL')
				))
			);
		END IF;
		
		-- Denumire
		IF IFNULL(new.Denumire,'') <> IFNULL(old.Denumire,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Denumire', CONCAT(
					IFNULL(old.Denumire, 'NULL'),
					' > ',
					IFNULL(new.Denumire, 'NULL')
				))
			);
		END IF;
		
		-- Pozitie
		IF IFNULL(new.Pozitie,0) <> IFNULL(old.Pozitie,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Pozitie', CONCAT(
					IFNULL(old.Pozitie, 'NULL'),
					' > ',
					IFNULL(new.Pozitie, 'NULL')
				))
			);
		END IF;
		
		-- CampPrincipal
		IF IFNULL(new.CampPrincipal,'') <> IFNULL(old.CampPrincipal,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('CampPrincipal', CONCAT(
					IFNULL(old.CampPrincipal, 'NULL'),
					' > ',
					IFNULL(new.CampPrincipal, 'NULL')
				))
			);
		END IF;
		
		-- AfisareCampPrincipal
		IF IFNULL(new.AfisareCampPrincipal,'') <> IFNULL(old.AfisareCampPrincipal,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('AfisareCampPrincipal', CONCAT(
					IFNULL(old.AfisareCampPrincipal, 'NULL'),
					' > ',
					IFNULL(new.AfisareCampPrincipal, 'NULL')
				))
			);
		END IF;
		
		-- TipCampPrincipal
		IF IFNULL(new.TipCampPrincipal,'') <> IFNULL(old.TipCampPrincipal,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('TipCampPrincipal', CONCAT(
					IFNULL(old.TipCampPrincipal, 'NULL'),
					' > ',
					IFNULL(new.TipCampPrincipal, 'NULL')
				))
			);
		END IF;
		
		-- CampAsociat
		IF IFNULL(new.CampAsociat,'') <> IFNULL(old.CampAsociat,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('CampAsociat', CONCAT(
					IFNULL(old.CampAsociat, 'NULL'),
					' > ',
					IFNULL(new.CampAsociat, 'NULL')
				))
			);
		END IF;
		
		-- AfisareCampAsociat
		IF IFNULL(new.AfisareCampAsociat,'') <> IFNULL(old.AfisareCampAsociat,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('AfisareCampAsociat', CONCAT(
					IFNULL(old.AfisareCampAsociat, 'NULL'),
					' > ',
					IFNULL(new.AfisareCampAsociat, 'NULL')
				))
			);
		END IF;
		
		-- TipCampAsociat
		IF IFNULL(new.TipCampAsociat,'') <> IFNULL(old.TipCampAsociat,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('TipCampAsociat', CONCAT(
					IFNULL(old.TipCampAsociat, 'NULL'),
					' > ',
					IFNULL(new.TipCampAsociat, 'NULL')
				))
			);
		END IF;
		
		-- Valoare
		IF IFNULL(new.Valoare,'') <> IFNULL(old.Valoare,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Valoare', CONCAT(
					IFNULL(old.Valoare, 'NULL'),
					' > ',
					IFNULL(new.Valoare, 'NULL')
				))
			);
		END IF;
		
		-- AfisareValoare
		IF IFNULL(new.AfisareValoare,'') <> IFNULL(old.AfisareValoare,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('AfisareValoare', CONCAT(
					IFNULL(old.AfisareValoare, 'NULL'),
					' > ',
					IFNULL(new.AfisareValoare, 'NULL')
				))
			);
		END IF;
		
		-- TipCampValoare
		IF IFNULL(new.TipCampValoare,'') <> IFNULL(old.TipCampValoare,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('TipCampValoare', CONCAT(
					IFNULL(old.TipCampValoare, 'NULL'),
					' > ',
					IFNULL(new.TipCampValoare, 'NULL')
				))
			);
		END IF;
		
		-- Semn
		IF IFNULL(new.Semn,'') <> IFNULL(old.Semn,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Semn', CONCAT(
					IFNULL(old.Semn, 'NULL'),
					' > ',
					IFNULL(new.Semn, 'NULL')
				))
			);
		END IF;
		
		-- AfisareSemn
		IF IFNULL(new.AfisareSemn,'') <> IFNULL(old.AfisareSemn,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('AfisareSemn', CONCAT(
					IFNULL(old.AfisareSemn, 'NULL'),
					' > ',
					IFNULL(new.AfisareSemn, 'NULL')
				))
			);
		END IF;
		
		-- AltCamp
		IF IFNULL(new.AltCamp,0) <> IFNULL(old.AltCamp,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('AltCamp', CONCAT(
					IFNULL(old.AltCamp, 'NULL'),
					' > ',
					IFNULL(new.AltCamp, 'NULL')
				))
			);
		END IF;
		
		-- Mesaj
		IF IFNULL(new.Mesaj,'') <> IFNULL(old.Mesaj,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Mesaj', CONCAT(
					IFNULL(old.Mesaj, 'NULL'),
					' > ',
					IFNULL(new.Mesaj, 'NULL')
				))
			);
		END IF;
		
		-- CandDaca
		IF IFNULL(new.CandDaca,0) <> IFNULL(old.CandDaca,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('CandDaca', CONCAT(
					IF(old.CandDaca=0,'Cand','Daca'),
					' > ',
					IF(new.CandDaca=0,'Cand','Daca')
				))
			);
		END IF;
		
		-- Functie
		IF IFNULL(new.Functie,0) <> IFNULL(old.Functie,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Functie', CONCAT(
					IFNULL(old.Functie, 'NULL'),
					' > ',
					IFNULL(new.Functie, 'NULL')
				))
			);
		END IF;
		
		-- Activa
		IF IFNULL(new.Activa,0) <> IFNULL(old.Activa,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Activa', CONCAT(
					IF(old.Activa=1,'DA','NU'),
					' > ',
					IF(new.Activa=1,'DA','NU')
				))
			);
		END IF;
		
		-- Versiune
		IF IFNULL(new.Versiune,0) <> IFNULL(old.Versiune,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Versiune', CONCAT(
					IFNULL(old.Versiune, 'NULL'),
					' > ',
					IFNULL(new.Versiune, 'NULL')
				))
			);
		END IF;
		
		-- Setăm Res cu modificările găsite
		SET Res = CAST(changes AS CHAR);
		
		-- Inserăm în log doar dacă au fost modificări
		IF JSON_LENGTH(changes) > 0 THEN
			INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,EXPL,Tip) 
			VALUES (Database(),Usr,SESSION_USER(),Res,"MOD_COND");
		END IF;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table ConditiiS_192
-- ----------------------------
DROP TRIGGER IF EXISTS `ConditiiS_ADD_After_copy2`;
delimiter ;;
CREATE TRIGGER `ConditiiS_ADD_After_copy2` AFTER INSERT ON `ConditiiS_192` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='ConditiiS_ADD_After';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='ConditiiS' AND Tip="ADD";

IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdConditie', new.IdConditie, 
    'IdConditieS', new.IdConditieS ,
		'CampAsociat', new.CampAsociat,
		'Semn', new.Semn,
		'Valoare', new.Valoare
    )
   ) INTO Res;
  
		INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,EXPL,Tip) VALUES (Database(),Usr,SESSION_USER(),Res,"ADD_COND");
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table ConditiiS_192
-- ----------------------------
DROP TRIGGER IF EXISTS `ConditiiS_MOD_After_copy2`;
delimiter ;;
CREATE TRIGGER `ConditiiS_MOD_After_copy2` AFTER UPDATE ON `ConditiiS_192` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='ConditiiS_MOD_After';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='ConditiiS' AND Tip="MOD";

IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdConditie', new.IdConditie, 
    'IdConditieS', new.IdConditieS ,
		'CampAsociat', new.CampAsociat,
		'Semn', new.Semn,
		'Valoare', new.Valoare
    )
   ) INTO Res;
  
		INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,EXPL,Tip) VALUES (Database(),Usr,SESSION_USER(),Res,"MOD_COND");
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table ConditiiS_192
-- ----------------------------
DROP TRIGGER IF EXISTS `ConditiiS_DEL_After_copy2`;
delimiter ;;
CREATE TRIGGER `ConditiiS_DEL_After_copy2` AFTER DELETE ON `ConditiiS_192` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='ConditiiS_DEL_After';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='ConditiiS' AND Tip="DEL";

IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdConditie', old.IdConditie, 
    'IdConditieS', old.IdConditieS ,
		'CampAsociat', old.CampAsociat,
		'Semn', old.Semn,
		'Valoare', old.Valoare
    )
   ) INTO Res;
  
		INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,EXPL,Tip) VALUES (Database(),Usr,SESSION_USER(),Res,"DEL_COND");
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table ConditiiS_Implicite
-- ----------------------------
DROP TRIGGER IF EXISTS `ConditiiS_ADD_After_copy1`;
delimiter ;;
CREATE TRIGGER `ConditiiS_ADD_After_copy1` AFTER INSERT ON `ConditiiS_Implicite` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='ConditiiS_ADD_After';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='ConditiiS' AND Tip="ADD";

IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdConditie', new.IdConditie, 
    'IdConditieS', new.IdConditieS ,
		'CampAsociat', new.CampAsociat,
		'Semn', new.Semn,
		'Valoare', new.Valoare
    )
   ) INTO Res;
  
		INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,EXPL,Tip) VALUES (Database(),Usr,SESSION_USER(),Res,"ADD_COND");
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table ConditiiS_Implicite
-- ----------------------------
DROP TRIGGER IF EXISTS `ConditiiS_MOD_After_copy1`;
delimiter ;;
CREATE TRIGGER `ConditiiS_MOD_After_copy1` AFTER UPDATE ON `ConditiiS_Implicite` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='ConditiiS_MOD_After';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='ConditiiS' AND Tip="MOD";

IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdConditie', new.IdConditie, 
    'IdConditieS', new.IdConditieS ,
		'CampAsociat', new.CampAsociat,
		'Semn', new.Semn,
		'Valoare', new.Valoare
    )
   ) INTO Res;
  
		INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,EXPL,Tip) VALUES (Database(),Usr,SESSION_USER(),Res,"MOD_COND");
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table ConditiiS_Implicite
-- ----------------------------
DROP TRIGGER IF EXISTS `ConditiiS_DEL_After_copy1`;
delimiter ;;
CREATE TRIGGER `ConditiiS_DEL_After_copy1` AFTER DELETE ON `ConditiiS_Implicite` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='ConditiiS_DEL_After';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='ConditiiS' AND Tip="DEL";

IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdConditie', old.IdConditie, 
    'IdConditieS', old.IdConditieS ,
		'CampAsociat', old.CampAsociat,
		'Semn', old.Semn,
		'Valoare', old.Valoare
    )
   ) INTO Res;
  
		INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,EXPL,Tip) VALUES (Database(),Usr,SESSION_USER(),Res,"DEL_COND");
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Consultanti_Coloane
-- ----------------------------
DROP TRIGGER IF EXISTS `Consultanti_Coloane_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Consultanti_Coloane_ADD_AFTER` AFTER INSERT ON `Consultanti_Coloane` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Consultanti_Coloane_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;
	
	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;
	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Consultanti_Coloane' AND Tip='ADD';
	
	IF IsDisabled = 0 THEN
		SELECT
			JSON_ARRAY(
				JSON_OBJECT( 
					'IDCOL', new.IDCOL,
					'IdColoana', new.IdColoana,
					'IdConsultant', new.IdConsultant,
					'NumeConsultant', (SELECT NumeConsultant FROM SVN_00.Consultanti WHERE IdConsultant=new.IdConsultant),
					'Afisare', new.Afisare,
					'Pozitie', new.Pozitie,
					'Marime', new.Marime,
					'Ascuns', IF(new.Ascuns=1,'DA','NU'),
					'Aliniere', new.Aliniere,
					'Formatare', new.Formatare,
					'SelTab', new.SelTab,
					'Special', new.Special,
					'DataAdaugare', DATE_FORMAT(new.DataAdaugare, '%m-%d-%Y %H:%i:%s'),
					'DataModificare', DATE_FORMAT(new.DataModificare, '%m-%d-%Y %H:%i:%s')
				)
			) INTO Res;
		
		INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,IdConsultant,EXPL,Tip) 
		VALUES (Database(),Usr,SESSION_USER(),new.IdConsultant,Res,"ADD_CONS_COL");
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Consultanti_Coloane
-- ----------------------------
DROP TRIGGER IF EXISTS `Consultanti_Coloane_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Consultanti_Coloane_MOD_AFTER` AFTER UPDATE ON `Consultanti_Coloane` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
	DECLARE changes JSON DEFAULT JSON_ARRAY();
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Consultanti_Coloane_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;
	
	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;
	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Consultanti_Coloane' AND Tip='MOD';
	
	IF IsDisabled = 0 THEN
		-- IdColoana
		IF IFNULL(new.IdColoana,0) <> IFNULL(old.IdColoana,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('IdColoana', CONCAT(
					IFNULL(old.IdColoana, 'NULL'),
					' > ',
					IFNULL(new.IdColoana, 'NULL')
				))
			);
		END IF;
		
		-- IdConsultant
		IF IFNULL(new.IdConsultant,0) <> IFNULL(old.IdConsultant,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('IdConsultant', CONCAT(
					IFNULL((SELECT NumeConsultant FROM SVN_00.Consultanti WHERE IdConsultant=old.IdConsultant), 'NULL'),
					' > ',
					IFNULL((SELECT NumeConsultant FROM SVN_00.Consultanti WHERE IdConsultant=new.IdConsultant), 'NULL')
				))
			);
		END IF;
		
		-- Afisare
		IF IFNULL(new.Afisare,'') <> IFNULL(old.Afisare,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Afisare', CONCAT(
					IFNULL(old.Afisare, 'NULL'),
					' > ',
					IFNULL(new.Afisare, 'NULL')
				))
			);
		END IF;
		
		-- Pozitie
		IF IFNULL(new.Pozitie,0) <> IFNULL(old.Pozitie,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Pozitie', CONCAT(
					IFNULL(old.Pozitie, 'NULL'),
					' > ',
					IFNULL(new.Pozitie, 'NULL')
				))
			);
		END IF;
		
		-- Marime
		IF IFNULL(new.Marime,0) <> IFNULL(old.Marime,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Marime', CONCAT(
					IFNULL(old.Marime, 'NULL'),
					' > ',
					IFNULL(new.Marime, 'NULL')
				))
			);
		END IF;
		
		-- Ascuns
		IF IFNULL(new.Ascuns,0) <> IFNULL(old.Ascuns,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Ascuns', CONCAT(
					IF(old.Ascuns=1,'DA','NU'),
					' > ',
					IF(new.Ascuns=1,'DA','NU')
				))
			);
		END IF;
		
		-- Aliniere
		IF IFNULL(new.Aliniere,0) <> IFNULL(old.Aliniere,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Aliniere', CONCAT(
					IFNULL(old.Aliniere, 'NULL'),
					' > ',
					IFNULL(new.Aliniere, 'NULL')
				))
			);
		END IF;
		
		-- Formatare
		IF IFNULL(new.Formatare,'') <> IFNULL(old.Formatare,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Formatare', CONCAT(
					IFNULL(old.Formatare, 'NULL'),
					' > ',
					IFNULL(new.Formatare, 'NULL')
				))
			);
		END IF;
		
		-- SelTab
		IF IFNULL(new.SelTab,'') <> IFNULL(old.SelTab,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('SelTab', CONCAT(
					IFNULL(old.SelTab, 'NULL'),
					' > ',
					IFNULL(new.SelTab, 'NULL')
				))
			);
		END IF;
		
		-- Special
		IF IFNULL(new.Special,0) <> IFNULL(old.Special,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Special', CONCAT(
					IFNULL(old.Special, 'NULL'),
					' > ',
					IFNULL(new.Special, 'NULL')
				))
			);
		END IF;
		
		-- Setăm Res cu modificările găsite
		SET Res = CAST(changes AS CHAR);
		
		-- Inserăm în log doar dacă au fost modificări
		IF JSON_LENGTH(changes) > 0 THEN
			INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,IdConsultant,EXPL,Tip) 
			VALUES (Database(),Usr,SESSION_USER(),new.IdConsultant,Res,"MOD_CONS_COL");
		END IF;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Consultanti_Coloane
-- ----------------------------
DROP TRIGGER IF EXISTS `Consultanti_Coloane_DEL_AFTER`;
delimiter ;;
CREATE TRIGGER `Consultanti_Coloane_DEL_AFTER` AFTER DELETE ON `Consultanti_Coloane` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Consultanti_Coloane_DEL_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;
	
	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;
	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Consultanti_Coloane' AND Tip='DEL';
	
	IF IsDisabled = 0 THEN
		SELECT
			JSON_ARRAY(
				JSON_OBJECT( 
					'IDCOL', old.IDCOL,
					'IdColoana', old.IdColoana,
					'IdConsultant', old.IdConsultant,
					'NumeConsultant', (SELECT NumeConsultant FROM SVN_00.Consultanti WHERE IdConsultant=old.IdConsultant),
					'Afisare', old.Afisare,
					'Pozitie', old.Pozitie,
					'Marime', old.Marime,
					'Ascuns', IF(old.Ascuns=1,'DA','NU'),
					'Aliniere', old.Aliniere,
					'Formatare', old.Formatare,
					'SelTab', old.SelTab,
					'Special', old.Special,
					'DataAdaugare', DATE_FORMAT(old.DataAdaugare, '%m-%d-%Y %H:%i:%s'),
					'DataModificare', DATE_FORMAT(old.DataModificare, '%m-%d-%Y %H:%i:%s')
				)
			) INTO Res;
		
		INSERT INTO `LOG`.LOG (Sch,IdCons,UserName,IdConsultant,EXPL,Tip) 
		VALUES (Database(),Usr,SESSION_USER(),old.IdConsultant,Res,"DEL_CONS_COL");
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_ADD_AFTER` AFTER INSERT ON `Dosar` FOR EACH ROW BEGIN
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE Res TEXT (10000);
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Dosar_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;

	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;

	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar' AND Tip='ADD';
 
	IF IsDisabled = 0 THEN
		SELECT 
			JSON_ARRAY(
				JSON_OBJECT(
					'DataIntroducere',DATE_FORMAT(NEW.DataIntroducere, '%m-%d-%Y'),
					'Status',(SELECT FelStatus FROM Dosar_Status WHERE IdStatus=new.IdStatus),
					'Stare',(SELECT Stare FROM Dosar_Stare WHERE IdStare=new.IdStare),
					'Codebitor', IF(new.Codebitor=1,'DA','NU'),
					'NumeCodebitor',NEW.NumeCodebitor,
					'TipVenit',(SELECT TipVenit FROM Dosar_TipVenit WHERE IdVenit=NEW.IdVenit),
					'Venit',NEW.Venit,
					'TipImobil',(SELECT TipImobil FROM Dosar_TipImobil WHERE IdTipImobil=NEW.IdTipImobil),
					'AreImobil',IF(new.AreImobil=1,'DA','NU'),
					'ValoareImobil',new.ValoareImobil,
					'TipCredit', (SELECT TipCredit FROM Dosar_TipCredit WHERE IdTipCredit=NEW.IdTipCredit),
					'PerioadaCredit',CONCAT(new.PerioadaCredit,' ani'),
					'Moneda', (SELECT Moneda FROM Dosar_TipMoneda WHERE IdTipMoneda=NEW.IdTipMoneda),
					'CursMoneda',new.CursMoneda,
					'ValoareCredit',NEW.ValoareCredit,
					'ValoareCreditRON',NEW.ValoareCreditRON,
					'TipDobanda', (SELECT TipDobanda FROM Dosar_TipDobanda WHERE IdTipDobanda=NEW.IdTipDobanda),
					'PerioadaDobanda', CONCAT(new.PerioadaDobanda, ' luni'),
					'Dobanda', CONCAT(ROUND(new.Dobanda*100,2),'%'),
					'MarjaDobanda', CONCAT(ROUND(new.MarjaDobanda*100,2),'%'),
					'MarjaDobandaDF', CONCAT(ROUND(new.MarjaDobandaDF*100,2),'%'),
					'Banca',(SELECT Banca FROM Banci WHERE IdBanca=new.IdBanca),
					'Sucursala',(SELECT Sucursala FROM Sucursale WHERE IdSucursala=new.IdSucursala),
					'ConsilierBanca',NEW.ConsilierBanca,
					'CodBanca',NEW.CodBanca,
					'Notar',(SELECT Notar FROM Dosar_Notari WHERE IdNotar=new.IdNotar),
					'Evaluator',(SELECT Evaluator FROM Dosar_Evaluatori WHERE IdEvaluator=new.IdEvaluator)
				)
			)
		INTO Res;
		
		INSERT INTO `LOG`.LOG (IdCons,UserName,IdConsultant,IdClient,IdDosar,IdBaza,IdSursa,IdAgent,EXPL,Tip,Sch) 
		SELECT Usr,SESSION_USER(),new.IdConsultant,new.IdClient,new.IdDosar,new.IdBaza,new.IdSursa,new.IdAgent,Res,'ADD_DOSAR',Database();
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_MOD_BEFORE`;
delimiter ;;
CREATE TRIGGER `Dosar_MOD_BEFORE` BEFORE UPDATE ON `Dosar` FOR EACH ROW BEGIN
  IF old.IdStatus<>1 AND new.IdStatus=1 THEN
		SET new.ValoareCreditTras = new.ValoareCreditRON;
	END IF;
	 
 IF old.IdStatus=1 THEN
	  SET new.ModificatDupaTragere=1;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_MOD_AFTER` AFTER UPDATE ON `Dosar` FOR EACH ROW BEGIN
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE Res TEXT (10000);
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
	DECLARE changes JSON DEFAULT JSON_ARRAY();
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Dosar_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;
	
	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;
	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar' AND Tip='MOD';
 
	IF IsDisabled = 0 THEN
		-- DataIntroducere
		IF IFNULL(new.DataIntroducere,'') <> IFNULL(old.DataIntroducere,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('DataIntroducere', CONCAT(
					IFNULL(DATE_FORMAT(old.DataIntroducere, '%m-%d-%Y'), 'NULL'),
					' > ',
					IFNULL(DATE_FORMAT(new.DataIntroducere, '%m-%d-%Y'), 'NULL')
				))
			);
		END IF;
		
		-- Status
		IF IFNULL(new.IdStatus,0) <> IFNULL(old.IdStatus,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Status', CONCAT(
					IFNULL((SELECT FelStatus FROM Dosar_Status WHERE IdStatus=old.IdStatus), 'NULL'),
					' > ',
					IFNULL((SELECT FelStatus FROM Dosar_Status WHERE IdStatus=new.IdStatus), 'NULL')
				))
			);
		END IF;
		
		-- Stare
		IF IFNULL(new.IdStare,0) <> IFNULL(old.IdStare,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Stare', CONCAT(
					IFNULL((SELECT Stare FROM Dosar_Stare WHERE IdStare=old.IdStare), 'NULL'),
					' > ',
					IFNULL((SELECT Stare FROM Dosar_Stare WHERE IdStare=new.IdStare), 'NULL')
				))
			);
		END IF;
		
		-- Codebitor
		IF IFNULL(new.Codebitor,0) <> IFNULL(old.Codebitor,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Codebitor', CONCAT(
					IF(old.Codebitor=1,'DA','NU'),
					' > ',
					IF(new.Codebitor=1,'DA','NU')
				))
			);
		END IF;
		
		-- NumeCodebitor
		IF IFNULL(new.NumeCodebitor,'') <> IFNULL(old.NumeCodebitor,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('NumeCodebitor', CONCAT(
					IFNULL(old.NumeCodebitor, 'NULL'),
					' > ',
					IFNULL(new.NumeCodebitor, 'NULL')
				))
			);
		END IF;
		
		-- TipVenit
		IF IFNULL(new.IdVenit,0) <> IFNULL(old.IdVenit,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('TipVenit', CONCAT(
					IFNULL((SELECT TipVenit FROM Dosar_TipVenit WHERE IdVenit=old.IdVenit), 'NULL'),
					' > ',
					IFNULL((SELECT TipVenit FROM Dosar_TipVenit WHERE IdVenit=new.IdVenit), 'NULL')
				))
			);
		END IF;
		
		-- Venit
		IF IFNULL(new.Venit,0) <> IFNULL(old.Venit,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Venit', CONCAT(
					IFNULL(old.Venit, 'NULL'),
					' > ',
					IFNULL(new.Venit, 'NULL')
				))
			);
		END IF;
		
		-- TipImobil
		IF IFNULL(new.IdTipImobil,0) <> IFNULL(old.IdTipImobil,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('TipImobil', CONCAT(
					IFNULL((SELECT TipImobil FROM Dosar_TipImobil WHERE IdTipImobil=old.IdTipImobil), 'NULL'),
					' > ',
					IFNULL((SELECT TipImobil FROM Dosar_TipImobil WHERE IdTipImobil=new.IdTipImobil), 'NULL')
				))
			);
		END IF;
		
		-- AreImobil
		IF IFNULL(new.AreImobil,0) <> IFNULL(old.AreImobil,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('AreImobil', CONCAT(
					IF(old.AreImobil=1,'DA','NU'),
					' > ',
					IF(new.AreImobil=1,'DA','NU')
				))
			);
		END IF;
		
		-- ValoareImobil
		IF IFNULL(new.ValoareImobil,0) <> IFNULL(old.ValoareImobil,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('ValoareImobil', CONCAT(
					IFNULL(old.ValoareImobil, 'NULL'),
					' > ',
					IFNULL(new.ValoareImobil, 'NULL')
				))
			);
		END IF;
		
		-- TipCredit
		IF IFNULL(new.IdTipCredit,0) <> IFNULL(old.IdTipCredit,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('TipCredit', CONCAT(
					IFNULL((SELECT TipCredit FROM Dosar_TipCredit WHERE IdTipCredit=old.IdTipCredit), 'NULL'),
					' > ',
					IFNULL((SELECT TipCredit FROM Dosar_TipCredit WHERE IdTipCredit=new.IdTipCredit), 'NULL')
				))
			);
		END IF;
		
		-- PerioadaCredit
		IF IFNULL(new.PerioadaCredit,0) <> IFNULL(old.PerioadaCredit,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('PerioadaCredit', CONCAT(
					CONCAT(IFNULL(old.PerioadaCredit, 'NULL'), ' ani'),
					' > ',
					CONCAT(IFNULL(new.PerioadaCredit, 'NULL'), ' ani')
				))
			);
		END IF;
		
		-- Moneda
		IF IFNULL(new.IdTipMoneda,0) <> IFNULL(old.IdTipMoneda,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Moneda', CONCAT(
					IFNULL((SELECT Moneda FROM Dosar_TipMoneda WHERE IdTipMoneda=old.IdTipMoneda), 'NULL'),
					' > ',
					IFNULL((SELECT Moneda FROM Dosar_TipMoneda WHERE IdTipMoneda=new.IdTipMoneda), 'NULL')
				))
			);
		END IF;
		
		-- CursMoneda
		IF IFNULL(new.CursMoneda,0) <> IFNULL(old.CursMoneda,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('CursMoneda', CONCAT(
					IFNULL(old.CursMoneda, 'NULL'),
					' > ',
					IFNULL(new.CursMoneda, 'NULL')
				))
			);
		END IF;
		
		-- ValoareCredit
		IF IFNULL(new.ValoareCredit,0) <> IFNULL(old.ValoareCredit,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('ValoareCredit', CONCAT(
					IFNULL(old.ValoareCredit, 'NULL'),
					' > ',
					IFNULL(new.ValoareCredit, 'NULL')
				))
			);
		END IF;
		
		-- ValoareCreditRON
		IF IFNULL(new.ValoareCreditRON,0) <> IFNULL(old.ValoareCreditRON,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('ValoareCreditRON', CONCAT(
					IFNULL(old.ValoareCreditRON, 'NULL'),
					' > ',
					IFNULL(new.ValoareCreditRON, 'NULL')
				))
			);
		END IF;
		
		-- TipDobanda
		IF IFNULL(new.IdTipDobanda,0) <> IFNULL(old.IdTipDobanda,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('TipDobanda', CONCAT(
					IFNULL((SELECT TipDobanda FROM Dosar_TipDobanda WHERE IdTipDobanda=old.IdTipDobanda), 'NULL'),
					' > ',
					IFNULL((SELECT TipDobanda FROM Dosar_TipDobanda WHERE IdTipDobanda=new.IdTipDobanda), 'NULL')
				))
			);
		END IF;
		
		-- PerioadaDobanda
		IF IFNULL(new.PerioadaDobanda,0) <> IFNULL(old.PerioadaDobanda,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('PerioadaDobanda', CONCAT(
					CONCAT(IFNULL(old.PerioadaDobanda, 'NULL'), ' luni'),
					' > ',
					CONCAT(IFNULL(new.PerioadaDobanda, 'NULL'), ' luni')
				))
			);
		END IF;
		
		-- Dobanda
		IF IFNULL(new.Dobanda,0) <> IFNULL(old.Dobanda,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Dobanda', CONCAT(
					CONCAT(ROUND(IFNULL(old.Dobanda,0)*100,2),'%'),
					' > ',
					CONCAT(ROUND(IFNULL(new.Dobanda,0)*100,2),'%')
				))
			);
		END IF;
		
		-- MarjaDobanda
		IF IFNULL(new.MarjaDobanda,0) <> IFNULL(old.MarjaDobanda,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('MarjaDobanda', CONCAT(
					CONCAT(ROUND(IFNULL(old.MarjaDobanda,0)*100,2),'%'),
					' > ',
					CONCAT(ROUND(IFNULL(new.MarjaDobanda,0)*100,2),'%')
				))
			);
		END IF;
		
		-- MarjaDobandaDF
		IF IFNULL(new.MarjaDobandaDF,0) <> IFNULL(old.MarjaDobandaDF,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('MarjaDobandaDF', CONCAT(
					CONCAT(ROUND(IFNULL(old.MarjaDobandaDF,0)*100,2),'%'),
					' > ',
					CONCAT(ROUND(IFNULL(new.MarjaDobandaDF,0)*100,2),'%')
				))
			);
		END IF;
		
		-- Banca
		IF IFNULL(new.IdBanca,0) <> IFNULL(old.IdBanca,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Banca', CONCAT(
					IFNULL((SELECT Banca FROM Banci WHERE IdBanca=old.IdBanca), 'NULL'),
					' > ',
					IFNULL((SELECT Banca FROM Banci WHERE IdBanca=new.IdBanca), 'NULL')
				))
			);
		END IF;
		
		-- Sucursala
		IF IFNULL(new.IdSucursala,0) <> IFNULL(old.IdSucursala,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Sucursala', CONCAT(
					IFNULL((SELECT Sucursala FROM Sucursale WHERE IdSucursala=old.IdSucursala), 'NULL'),
					' > ',
					IFNULL((SELECT Sucursala FROM Sucursale WHERE IdSucursala=new.IdSucursala), 'NULL')
				))
			);
		END IF;
		
		-- ConsilierBanca
		IF IFNULL(new.ConsilierBanca,'') <> IFNULL(old.ConsilierBanca,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('ConsilierBanca', CONCAT(
					IFNULL(old.ConsilierBanca, 'NULL'),
					' > ',
					IFNULL(new.ConsilierBanca, 'NULL')
				))
			);
		END IF;
		
		-- CodBanca
		IF IFNULL(new.CodBanca,'') <> IFNULL(old.CodBanca,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('CodBanca', CONCAT(
					IFNULL(old.CodBanca, 'NULL'),
					' > ',
					IFNULL(new.CodBanca, 'NULL')
				))
			);
		END IF;
		
		-- Notar
		IF IFNULL(new.IdNotar,0) <> IFNULL(old.IdNotar,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Notar', CONCAT(
					IFNULL((SELECT Notar FROM Dosar_Notari WHERE IdNotar=old.IdNotar), 'NULL'),
					' > ',
					IFNULL((SELECT Notar FROM Dosar_Notari WHERE IdNotar=new.IdNotar), 'NULL')
				))
			);
		END IF;
		
		-- Evaluator
		IF IFNULL(new.IdEvaluator,0) <> IFNULL(old.IdEvaluator,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Evaluator', CONCAT(
					IFNULL((SELECT Evaluator FROM Dosar_Evaluatori WHERE IdEvaluator=old.IdEvaluator), 'NULL'),
					' > ',
					IFNULL((SELECT Evaluator FROM Dosar_Evaluatori WHERE IdEvaluator=new.IdEvaluator), 'NULL')
				))
			);
		END IF;
		
		-- DataPreaprobare
		IF IFNULL(new.DataPreaprobare,'') <> IFNULL(old.DataPreaprobare,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('DataPreaprobare', CONCAT(
					IFNULL(DATE_FORMAT(old.DataPreaprobare, '%m-%d-%Y'), 'NULL'),
					' > ',
					IFNULL(DATE_FORMAT(new.DataPreaprobare, '%m-%d-%Y'), 'NULL')
				))
			);
		END IF;
		
		-- DataOpinieJ
		IF IFNULL(new.DataOpinieJ,'') <> IFNULL(old.DataOpinieJ,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('DataOpinieJ', CONCAT(
					IFNULL(DATE_FORMAT(old.DataOpinieJ, '%m-%d-%Y'), 'NULL'),
					' > ',
					IFNULL(DATE_FORMAT(new.DataOpinieJ, '%m-%d-%Y'), 'NULL')
				))
			);
		END IF;
		
		-- DataTrimitere
		IF IFNULL(new.DataTrimitere,'') <> IFNULL(old.DataTrimitere,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('DataTrimitere', CONCAT(
					IFNULL(DATE_FORMAT(old.DataTrimitere, '%m-%d-%Y'), 'NULL'),
					' > ',
					IFNULL(DATE_FORMAT(new.DataTrimitere, '%m-%d-%Y'), 'NULL')
				))
			);
		END IF;
		
		-- DataDebursare (DataTragere)
		IF IFNULL(new.DataDebursare,'') <> IFNULL(old.DataDebursare,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('DataTragere', CONCAT(
					IFNULL(DATE_FORMAT(old.DataDebursare, '%m-%d-%Y'), 'NULL'),
					' > ',
					IFNULL(DATE_FORMAT(new.DataDebursare, '%m-%d-%Y'), 'NULL')
				))
			);
		END IF;
		
		-- DataRespingere
		IF IFNULL(new.DataRespingere,'') <> IFNULL(old.DataRespingere,'') THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('DataRespingere', CONCAT(
					IFNULL(DATE_FORMAT(old.DataRespingere, '%m-%d-%Y'), 'NULL'),
					' > ',
					IFNULL(DATE_FORMAT(new.DataRespingere, '%m-%d-%Y'), 'NULL')
				))
			);
		END IF;
		
		-- IdSursa
		IF IFNULL(new.IdSursa,0) <> IFNULL(old.IdSursa,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Sursa', CONCAT(
					IFNULL((SELECT Sursa FROM SursaLead WHERE IdSursa=old.IdSursa), 'NULL'),
					' > ',
					IFNULL((SELECT Sursa FROM SursaLead WHERE IdSursa=new.IdSursa), 'NULL')
				))
			);
		END IF;
		
		-- IdAgent
		IF IFNULL(new.IdAgent,0) <> IFNULL(old.IdAgent,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Agent', CONCAT(
					IFNULL((SELECT NumeAgent FROM Agenti WHERE IdAgent=old.IdAgent), 'NULL'),
					' > ',
					IFNULL((SELECT NumeAgent FROM Agenti WHERE IdAgent=new.IdAgent), 'NULL')
				))
			);
		END IF;
		
		-- IdConsultant
		IF IFNULL(new.IdConsultant,0) <> IFNULL(old.IdConsultant,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Consultant', CONCAT(
					IFNULL((SELECT NumeConsultant FROM SVN_00.Consultanti WHERE IdConsultant=old.IdConsultant), 'NULL'),
					' > ',
					IFNULL((SELECT NumeConsultant FROM SVN_00.Consultanti WHERE IdConsultant=new.IdConsultant), 'NULL')
				))
			);
		END IF;
		
		-- Setăm Res cu modificările găsite
		SET Res = CAST(changes AS CHAR);
		
		-- Inserăm în log doar dacă au fost modificări
		IF JSON_LENGTH(changes) > 0 THEN
			INSERT INTO `LOG`.LOG (IdCons,UserName,IdConsultant,IdClient,IdDosar,IdBaza,IdSursa,IdAgent,EXPL,Tip,Sch) 
			SELECT Usr,SESSION_USER(),new.IdConsultant,new.IdClient,new.IdDosar,new.IdBaza,new.IdSursa,new.IdAgent,Res,'MOD_DOSAR',Database();
		END IF;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Evaluatori
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Evaluatori_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Evaluatori_ADD_AFTER` AFTER INSERT ON `Dosar_Evaluatori` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Evaluatori_ADD';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Evaluatori' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'Evaluator', new.Evaluator, 
    'IdJudet', new.IdJudet, 
    'Judet', (SELECT Judet FROM Judete WHERE IdJudet=new.IdJudet),
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdEvaluator,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdEvaluator,Res,"ADD_EVALUATOR",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Evaluatori
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Evaluatori_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Evaluatori_MOD_AFTER` AFTER UPDATE ON `Dosar_Evaluatori` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Evaluatori_ADD';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Evaluatori' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'Evaluator', new.Evaluator, 
    'IdJudet', new.IdJudet, 
    'Judet', (SELECT Judet FROM Judete WHERE IdJudet=new.IdJudet),
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdEvaluator,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdEvaluator,Res,"MOD_EVALUATOR",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_FeedBack
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_FeedBack_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_FeedBack_ADD_AFTER` AFTER INSERT ON `Dosar_FeedBack` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE ICLIENT INT;
 DECLARE NClient VARCHAR (255);
 DECLARE TClient VARCHAR (255);
 DECLARE CClient VARCHAR (255);
 DECLARE ISURSA INT;
 DECLARE IAGENT INT;
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_FeedBack_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_FeedBack' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  IdClient,
  NumeClient,
  CNPClient,
  TelefonP,
  IdSursa,
  IdAgent,
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdFeedBack', new.IdFeedBack,
    'IdDosar', new.IdDosar,
    'DataConectare', new.DataConectare,
    'FeedBack',TO_BASE64(new.FeedBack),
    'DataReconectare', new.DataReconectare
    )
   ) INTO 
    ICLIENT,
    NClient,
    CClient,
    TClient,
    ISURSA,
    IAGENT,
    Res
 FROM
  Dosar INNER JOIN Clienti USING (IdClient) INNER JOIN Dosar_FeedBack USING (IdDosar) 
 WHERE
  IdDosar =new.IdDosar AND IdFeedBack=new.IdFeedBack;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,NumeClient,TelefonClient,CNP,IdDosarFeedback,IdDosar,IdSursa,IdAgent,EXPL,Tip) VALUES (Usr,SESSION_USER(),ICLIENT,NClient,TClient,CClient,new.IdFeedBack,new.IdDosar,ISURSA,IAGENT,Res,"ADD_DOSAR_FEEDBACK");
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_FeedBack
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_FeedBack_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_FeedBack_MOD_AFTER` AFTER UPDATE ON `Dosar_FeedBack` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE ICLIENT INT;
 DECLARE NClient VARCHAR (255);
 DECLARE TClient VARCHAR (255);
 DECLARE CClient VARCHAR (255);
 DECLARE ISURSA INT;
 DECLARE IAGENT INT;
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_FeedBack_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='DOSAR_FeedBack' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
  SELECT
  IdClient,
  NumeClient,
  CNPClient,
  TelefonP,
  IdSursa,
  IdAgent,
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdFeedBack', new.IdFeedBack,
    'IdDosar', new.IdDosar,
    'DataConectare', new.DataConectare,
    'FeedBack',TO_BASE64(new.FeedBack),
    'DataReconectare', new.DataReconectare
    )
   ) INTO 
    ICLIENT,
    NClient,
    CClient,
    TClient,
    ISURSA,
    IAGENT,
    Res
 FROM
  Dosar INNER JOIN Clienti USING (IdClient) INNER JOIN Dosar_FeedBack USING (IdDosar) 
 WHERE
  IdDosar =new.IdDosar AND IdFeedBack=new.IdFeedBack;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,NumeClient,TelefonClient,CNP,IdBazaFeedback,IdSursa,IdAgent,EXPL,Tip) VALUES (Usr,SESSION_USER(),ICLIENT,NClient,TClient,CClient,new.IdFeedBack,ISURSA,IAGENT,Res,"MOD_DOSAR_FEEDBACK");
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Functii
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Functii_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Functii_ADD_AFTER` AFTER INSERT ON `Dosar_Functii` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE NClient VARCHAR (255);
 DECLARE TClient VARCHAR (255);
 DECLARE CClient VARCHAR (255);
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Functii_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;
 
 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Functii' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  NumeClient,
  CNPClient,
  TelefonP,
  JSON_ARRAY(
   JSON_OBJECT( 
        'IdFunctie', NEW.IdFunctie,
        'IdClient', NEW.IdClient,
        'IdFunctieFunctie', NEW.IdFunctieFunctie,
        'IdCompanie', NEW.IdCompanie,
        'IdDomeniu', NEW.IdDomeniu,
        'IdTipCompanie', NEW.IdTipCompanie,
        'NumeFunctie', Dosar_Functii_Functie.Functie,
        'NumeCompanie', Dosar_Functii_Companie.Companie,
        'TipCompanie', Dosar_Functii_TipCompanie.TipCompanie,
        'Domeniu', Dosar_Functii_Domeniu.Domeniu)
   ) INTO 
    NClient,
    CClient,
    TClient,
    Res
 FROM
  Dosar_Functii INNER JOIN 
  Dosar_Functii_Functie USING (IdFunctieFunctie) INNER JOIN
  Dosar_Functii_Companie USING (IdCompanie) INNER JOIN
  Dosar_Functii_Domeniu USING (IdDomeniu) INNER JOIN
  Dosar_Functii_TipCompanie USING (IdTipCompanie) INNER JOIN
  Clienti USING (IdClient)
  
 WHERE
  IdFunctie =new.IdFunctie;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,NumeClient,TelefonClient,CNP,EXPL,Tip) VALUES (Usr,SESSION_USER(),new.IdClient,NClient,TClient,CClient,Res,"ADD_FUNCTIE");
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Functii
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Functii_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Functii_MOD_AFTER` AFTER UPDATE ON `Dosar_Functii` FOR EACH ROW BEGIN
	DECLARE Res TEXT (10000);
	DECLARE NClient VARCHAR (255);
	DECLARE TClient VARCHAR (255);
	DECLARE CClient VARCHAR (255);
	DECLARE IsDisabled TINYINT (4);
	DECLARE Usr INT;
	DECLARE errorCode CHAR(5) DEFAULT '00000';
	DECLARE errorMessage TEXT DEFAULT '';
	DECLARE changes JSON DEFAULT JSON_ARRAY();
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
		SET @TRIGNAME='Dosar_Functii_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END;
	
	IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
		SET Usr=0;
	ELSE
		SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
	END IF;
	
	SET IsDisabled=0;
	SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Functii' AND Tip='MOD';
	
	IF IsDisabled = 0 THEN
		-- IdFunctieFunctie (Functia)
		IF IFNULL(new.IdFunctieFunctie,0) <> IFNULL(old.IdFunctieFunctie,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('NumeFunctie', CONCAT(
					IFNULL((SELECT Functie FROM Dosar_Functii_Functie WHERE IdFunctieFunctie=old.IdFunctieFunctie), 'NULL'),
					' > ',
					IFNULL((SELECT Functie FROM Dosar_Functii_Functie WHERE IdFunctieFunctie=new.IdFunctieFunctie), 'NULL')
				))
			);
		END IF;
		
		-- IdCompanie
		IF IFNULL(new.IdCompanie,0) <> IFNULL(old.IdCompanie,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('NumeCompanie', CONCAT(
					IFNULL((SELECT Companie FROM Dosar_Functii_Companie WHERE IdCompanie=old.IdCompanie), 'NULL'),
					' > ',
					IFNULL((SELECT Companie FROM Dosar_Functii_Companie WHERE IdCompanie=new.IdCompanie), 'NULL')
				))
			);
		END IF;
		
		-- IdDomeniu
		IF IFNULL(new.IdDomeniu,0) <> IFNULL(old.IdDomeniu,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('Domeniu', CONCAT(
					IFNULL((SELECT Domeniu FROM Dosar_Functii_Domeniu WHERE IdDomeniu=old.IdDomeniu), 'NULL'),
					' > ',
					IFNULL((SELECT Domeniu FROM Dosar_Functii_Domeniu WHERE IdDomeniu=new.IdDomeniu), 'NULL')
				))
			);
		END IF;
		
		-- IdTipCompanie
		IF IFNULL(new.IdTipCompanie,0) <> IFNULL(old.IdTipCompanie,0) THEN
			SET changes = JSON_ARRAY_APPEND(changes, '$', 
				JSON_OBJECT('TipCompanie', CONCAT(
					IFNULL((SELECT TipCompanie FROM Dosar_Functii_TipCompanie WHERE IdTipCompanie=old.IdTipCompanie), 'NULL'),
					' > ',
					IFNULL((SELECT TipCompanie FROM Dosar_Functii_TipCompanie WHERE IdTipCompanie=new.IdTipCompanie), 'NULL')
				))
			);
		END IF;
		
		-- Setăm Res cu modificările găsite
		SET Res = CAST(changes AS CHAR);
		
		-- Inserăm în log doar dacă au fost modificări
		IF JSON_LENGTH(changes) > 0 THEN
			-- Obținem datele clientului
			SELECT
				NumeClient,
				CNPClient,
				TelefonP
			INTO 
				NClient,
				CClient,
				TClient
			FROM Clienti 
			WHERE IdClient = new.IdClient;
			
			INSERT INTO `LOG`.LOG (IdCons,UserName,IdClient,NumeClient,TelefonClient,CNP,EXPL,Tip) 
			VALUES (Usr,SESSION_USER(),new.IdClient,NClient,TClient,CClient,Res,"MOD_FUNCTIE");
		END IF;
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Functii_Companie
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Functii_Companie_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Functii_Companie_ADD_AFTER` AFTER INSERT ON `Dosar_Functii_Companie` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Functii_Companie_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Functii_Companie' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdCompanie',new.IdCompanie, 
    'Companie', new.Companie, 
    'CodFiscal', new.CodFiscal,
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdCompanie,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdCompanie,Res,"ADD_Companie",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Functii_Companie
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Functii_Companie_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Functii_Companie_MOD_AFTER` AFTER UPDATE ON `Dosar_Functii_Companie` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Functii_Companie_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Functii_Companie' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdCompanie',new.IdCompanie, 
    'Companie', new.Companie, 
    'CodFiscal', new.CodFiscal,
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdCompanie,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdCompanie,Res,"MOD_Companie",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Functii_Domeniu
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Functii_Domeniu_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Functii_Domeniu_ADD_AFTER` AFTER INSERT ON `Dosar_Functii_Domeniu` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Functii_Domeniu_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Functii_Domeniu' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdDomeniu',new.IdDomeniu, 
    'Domeniu', new.Domeniu, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdDomeniu,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdDomeniu,Res,"ADD_DOMENIU",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Functii_Domeniu
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Functii_Domeniu_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Functii_Domeniu_MOD_AFTER` AFTER UPDATE ON `Dosar_Functii_Domeniu` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Functii_Domeniu_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Functii_Domeniu' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdDomeniu',new.IdDomeniu, 
    'Domeniu', new.Domeniu, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdDomeniu,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdDomeniu,Res,"MOD_DOMENIU",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Functii_Functie
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Functii_Functie_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Functii_Functie_ADD_AFTER` AFTER INSERT ON `Dosar_Functii_Functie` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Functii_Functie_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Functii_Functie' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdFunctie',new.IdFunctieFunctie, 
    'Functie', new.Functie, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdFunctieFunctie,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdFunctieFunctie,Res,"ADD_FUNCTIE",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Functii_Functie
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Functii_Functie_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Functii_Functie_MOD_AFTER` AFTER UPDATE ON `Dosar_Functii_Functie` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Functii_Functie_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Functii_Functie' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdFunctie',new.IdFunctieFunctie, 
    'Functie', new.Functie, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdFunctieFunctie,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdFunctieFunctie,Res,"MOD_FUNCTIE",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Functii_TipCompanie
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Functii_TipCompanie_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Functii_TipCompanie_ADD_AFTER` AFTER INSERT ON `Dosar_Functii_TipCompanie` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Functii_TipCompanie_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Functii_TipCompanie' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdTipCompanie',new.IdTipCompanie, 
    'TipCompanie', new.TipCompanie, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdTipCompanie,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdTipCompanie,Res,"ADD_TIPCOMPANIE",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Functii_TipCompanie
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Functii_TipCompanie_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Functii_TipCompanie_MOD_AFTER` AFTER UPDATE ON `Dosar_Functii_TipCompanie` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Functii_TipCompanie_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Functii_TipCompanie' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdTipCompanie',new.IdTipCompanie, 
    'TipCompanie', new.TipCompanie, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdTipCompanie,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdTipCompanie,Res,"MOD_TIPCOMPANIE",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Motiv
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Motiv_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Motiv_ADD_AFTER` AFTER INSERT ON `Dosar_Motiv` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Motiv_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Motiv' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdMotiv',new.IdMotiv, 
    'Motiv', new.Motiv, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),Res,"ADD_MOTIV",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Motiv
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Motiv_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Motiv_MOD_AFTER` AFTER UPDATE ON `Dosar_Motiv` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Motiv_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Motiv' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdMotiv',new.IdMotiv, 
    'Motiv', new.Motiv, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),Res,"MOD_MOTIV",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Notari
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Notari_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Notari_ADD_AFTER` AFTER INSERT ON `Dosar_Notari` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Notari_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Notari' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdNotar',new.IdNotar, 
    'Notar', new.Notar, 
    'IdJudet', new.IdJudet, 
    'Judet', (SELECT Judet FROM Judete WHERE IdJudet=new.IdJudet),
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdNotar,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdNotar,Res,"ADD_NOTAR",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_Notari
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_Notari_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_Notari_MOD_AFTER` AFTER UPDATE ON `Dosar_Notari` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_Notari_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_Notari' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdNotar',new.IdNotar, 
    'Notar', new.Notar, 
    'IdJudet', new.IdJudet, 
    'Judet', (SELECT Judet FROM Judete WHERE IdJudet=new.IdJudet),
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdNotar,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdNotar,Res,"MOD_NOTAR",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_TipCredit
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_TipCredit_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_TipCredit_ADD_AFTER` AFTER INSERT ON `Dosar_TipCredit` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_TipCredit_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_TipCredit' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdTipCredit',new.IdTipCredit, 
    'TipCredit', new.TipCredit, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdTipCredit,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdTipCredit,Res,"ADD_TIPCREDIT",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_TipCredit
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_TipCredit_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_TipCredit_MOD_AFTER` AFTER UPDATE ON `Dosar_TipCredit` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_TipCredit_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_TipCredit' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdTipCredit',new.IdTipCredit, 
    'TipCredit', new.TipCredit, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdTipCredit,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdTipCredit,Res,"MOD_TIPCREDIT",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_TipDobanda
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_TipDobanda_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_TipDobanda_ADD_AFTER` AFTER INSERT ON `Dosar_TipDobanda` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_TipDobanda_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_TipDobanda' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdTipDobanda',new.IdTipDobanda, 
    'TipDobanda', new.TipDobanda, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdTipDobanda,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdTipDobanda,Res,"ADD_TIPDOBANDA",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_TipDobanda
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_TipDobanda_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_TipDobanda_MOD_AFTER` AFTER UPDATE ON `Dosar_TipDobanda` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_TipDobanda_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_TipDobanda' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdTipDobanda',new.IdTipDobanda, 
    'TipDobanda', new.TipDobanda, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdTipDobanda,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdTipDobanda,Res,"MOD_TIPDOBANDA",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_TipImobil
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_TipImobil_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_TipImobil_ADD_AFTER` AFTER INSERT ON `Dosar_TipImobil` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_TipImobil_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_TipImobil' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdTipImobil',new.IdTipImobil, 
    'TipImobil', new.TipImobil, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdTipImobil,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdTipImobil,Res,"ADD_TIPIMOBIL",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_TipImobil
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_TipImobil_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_TipImobil_MOD_AFTER` AFTER UPDATE ON `Dosar_TipImobil` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_TipImobil_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_TipImobil' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdTipImobil',new.IdTipImobil, 
    'TipImobil', new.TipImobil, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdTipImobil,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdTipImobil,Res,"MOD_TIPIMOBIL",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_TipVenit
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_TipVenit_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_TipVenit_ADD_AFTER` AFTER INSERT ON `Dosar_TipVenit` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_TipVenit_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_TipVenit' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdVenit',new.IdVenit, 
    'TipVenit', new.TipVenit, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdVenit,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdVenit,Res,"ADD_TIPVENIT",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Dosar_TipVenit
-- ----------------------------
DROP TRIGGER IF EXISTS `Dosar_TipVenit_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Dosar_TipVenit_MOD_AFTER` AFTER UPDATE ON `Dosar_TipVenit` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Dosar_TipVenit_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Dosar_TipVenit' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdVenit',new.IdVenit, 
    'TipVenit', new.TipVenit, 
    'Ascuns',IF(new.Ascuns=1,'DA','NU')
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdVenit,EXPL,Tip, Sch) 
 VALUES (Usr,SESSION_USER(),new.IdVenit,Res,"MOD_TIPVENIT",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Setari
-- ----------------------------
DROP TRIGGER IF EXISTS `Setari_ADD_After`;
delimiter ;;
CREATE TRIGGER `Setari_ADD_After` AFTER INSERT ON `Setari` FOR EACH ROW BEGIN
 INSERT INTO Consultanti_Setari ( IdConsultant, IdSetare, Setare, Valoare)
 SELECT Consultanti.IdConsultant, Setari.IdSetare, Setari.SetareImplicita, Setari.ValoareImplicita
 FROM Consultanti, Setari
 WHERE Setari.IdSetare = new.IdSetare;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Setari
-- ----------------------------
DROP TRIGGER IF EXISTS `Setari_MOD_After`;
delimiter ;;
CREATE TRIGGER `Setari_MOD_After` AFTER UPDATE ON `Setari` FOR EACH ROW BEGIN
 UPDATE Consultanti_Setari
 SET Consultanti_Setari.Setare = new.SetareImplicita
 WHERE Consultanti_Setari.IdSetare = new.IdSetare;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Sucursale
-- ----------------------------
DROP TRIGGER IF EXISTS `Sucursale_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Sucursale_ADD_AFTER` AFTER INSERT ON `Sucursale` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Sucursale_ADD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Sucursale' AND Tip='ADD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT(
		'IdSucursala',new.IdSucursala,
    'IdBanca', new.IdBanca, 
		'Sucursala',new.Sucursala,
		'IdJudet',new.IdJudet,
    'Judet', (SELECT Judet FROM Judete WHERE IdJudet=new.IdJudet),
		'Orasul',new.Orasul
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdSucursala,IdBanca,EXPL,Tip,Sch) VALUES (Usr,SESSION_USER(),new.IdSucursala,new.IdBanca, Res,"ADD_SUCURSALA",Database());
  
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table Sucursale
-- ----------------------------
DROP TRIGGER IF EXISTS `Sucursale_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Sucursale_MOD_AFTER` AFTER UPDATE ON `Sucursale` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Sucursale_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='Sucursale' AND Tip='MOD';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT(
		'IdSucursala',new.IdSucursala,
    'IdBanca', new.IdBanca, 
		'Sucursala',new.Sucursala,
		'IdJudet',new.IdJudet,
    'Judet', (SELECT Judet FROM Judete WHERE IdJudet=new.IdJudet),
		'Orasul',new.Orasul
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdSucursala,IdBanca,EXPL,Tip,Sch) VALUES (Usr,SESSION_USER(),new.IdSucursala,new.IdBanca, Res,"MOD_SUCURSALA",Database());
  
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table SursaLead
-- ----------------------------
DROP TRIGGER IF EXISTS `Sursa_ADD_AFTER`;
delimiter ;;
CREATE TRIGGER `Sursa_ADD_AFTER` AFTER INSERT ON `SursaLead` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Sursa_ADD_BEFORE';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='SursaLead' AND Tip='ADD';
 
IF IsDisabled = 0 THEN 
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdSursa', new.IdSursa, 
    'Sursa', new.Sursa ,
    'Explicatie',new.Explicatie,
    'Ascuns',new.Ascuns
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdSursa,EXPL,Tip,Sch) VALUES (Usr,SESSION_USER(),new.IdSursa,Res,"ADD_SURSA",Database());
 INSERT INTO Agenti (IdSursa, NumeAgent, Implicit) VALUES (new.IdSursa,'(fără agent)',1);
end IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table SursaLead
-- ----------------------------
DROP TRIGGER IF EXISTS `Sursa_MOD_AFTER`;
delimiter ;;
CREATE TRIGGER `Sursa_MOD_AFTER` AFTER UPDATE ON `SursaLead` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Sursa_MOD_AFTER';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='SursaLead' AND Tip='ADD';
 
IF IsDisabled = 0 THEN 
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdSursa', new.IdSursa, 
    'Sursa', new.Sursa ,
    'Explicatie',new.Explicatie,
    'Ascuns',new.Ascuns
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdSursa,EXPL,Tip,Sch) VALUES (Usr,SESSION_USER(),new.IdSursa,Res,"MOD_SURSA",Database());
END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table SursaLead
-- ----------------------------
DROP TRIGGER IF EXISTS `Sursa_DEL_BEFORE`;
delimiter ;;
CREATE TRIGGER `Sursa_DEL_BEFORE` BEFORE DELETE ON `SursaLead` FOR EACH ROW BEGIN
 DECLARE Res TEXT (10000);
 DECLARE IsDisabled TINYINT (4);
 DECLARE Usr INT;
 DECLARE errorCode CHAR(5) DEFAULT '00000';
 DECLARE errorMessage TEXT DEFAULT '';
		
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN 
	BEGIN
		SET @TRIGNAME='Sursa_DEL_BEFORE';
		GET DIAGNOSTICS CONDITION 1 errorCode = RETURNED_SQLSTATE, errorMessage = MESSAGE_TEXT;
		SET @ERM=CONCAT_WS("\n",@TRIGNAME,errorCode,errorMessage);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @ERM; 
	END; 
END;

 IF UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ADMIN" OR UCASE(SUBSTRING_INDEX(SESSION_USER(),"@",1)) = "ROOT" THEN
  SET Usr=0;
 ELSE
  SET Usr = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SESSION_USER(),'@',1),'\\D+','') AS INT);
 END IF;

 SET IsDisabled=0;
 SELECT Val INTO IsDisabled FROM TRIGS WHERE TBL='SursaLead' AND Tip='DEL';
 
IF IsDisabled = 0 THEN
 SELECT
  JSON_ARRAY(
   JSON_OBJECT( 
    'IdSursa', old.IdSursa, 
    'Sursa', old.Sursa 
    )
   ) INTO Res;
  
 INSERT INTO `LOG`.LOG (IdCons,UserName,IdSursa,IdAgent,EXPL,Tip) VALUES (Usr,SESSION_USER(),IdSursa,Idagent,Res,"DEL_AGENT");
END IF;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
