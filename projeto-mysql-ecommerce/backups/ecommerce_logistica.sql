-- MySQL dump 10.13  Distrib 8.4.6, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: ecommerce
-- ------------------------------------------------------
-- Server version	8.4.6

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `ecommerce`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `ecommerce` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `ecommerce`;

--
-- Table structure for table `auditoria_estoque`
--

DROP TABLE IF EXISTS `auditoria_estoque`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria_estoque` (
  `id` int NOT NULL AUTO_INCREMENT,
  `produto_id` int NOT NULL,
  `estoque_anterior` int NOT NULL,
  `estoque_novo` int NOT NULL,
  `alterado_em` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `produto_id` (`produto_id`),
  CONSTRAINT `auditoria_estoque_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_estoque`
--

LOCK TABLES `auditoria_estoque` WRITE;
/*!40000 ALTER TABLE `auditoria_estoque` DISABLE KEYS */;
INSERT INTO `auditoria_estoque` VALUES (1,1,27,25,'2026-10-18 16:50:46');
/*!40000 ALTER TABLE `auditoria_estoque` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (1,'Cliente Demonstracao','cliente@example.com'),(2,'Cliente Teste','teste@example.com');
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `itens_pedido`
--

DROP TABLE IF EXISTS `itens_pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `itens_pedido` (
  `pedido_id` int NOT NULL,
  `produto_id` int NOT NULL,
  `quantidade` int NOT NULL,
  `preco_unitario` decimal(10,2) NOT NULL,
  PRIMARY KEY (`pedido_id`,`produto_id`),
  KEY `produto_id` (`produto_id`),
  CONSTRAINT `itens_pedido_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`),
  CONSTRAINT `itens_pedido_ibfk_2` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`),
  CONSTRAINT `itens_pedido_chk_1` CHECK ((`quantidade` > 0)),
  CONSTRAINT `itens_pedido_chk_2` CHECK ((`preco_unitario` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itens_pedido`
--

LOCK TABLES `itens_pedido` WRITE;
/*!40000 ALTER TABLE `itens_pedido` DISABLE KEYS */;
INSERT INTO `itens_pedido` VALUES (1,1,2,150.00);
/*!40000 ALTER TABLE `itens_pedido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedidos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente_id` int NOT NULL,
  `criado_em` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `total` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cliente_id` (`cliente_id`),
  CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  CONSTRAINT `pedidos_chk_1` CHECK ((`total` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
INSERT INTO `pedidos` VALUES (1,1,'2026-10-18 16:50:46',300.00);
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `produtos`
--

DROP TABLE IF EXISTS `produtos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `produtos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `preco` decimal(10,2) NOT NULL,
  `estoque` int NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `produtos_chk_1` CHECK ((`preco` > 0)),
  CONSTRAINT `produtos_chk_2` CHECK ((`estoque` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produtos`
--

LOCK TABLES `produtos` WRITE;
/*!40000 ALTER TABLE `produtos` DISABLE KEYS */;
INSERT INTO `produtos` VALUES (1,'Teclado',150.00,25),(2,'Mouse',80.00,30);
/*!40000 ALTER TABLE `produtos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_auditar_estoque` AFTER UPDATE ON `produtos` FOR EACH ROW BEGIN
 IF OLD.estoque <> NEW.estoque THEN
  INSERT INTO auditoria_estoque (produto_id,estoque_anterior,estoque_novo)
  VALUES (NEW.id,OLD.estoque,NEW.estoque);
 END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `vw_resumo_pedidos`
--

DROP TABLE IF EXISTS `vw_resumo_pedidos`;
/*!50001 DROP VIEW IF EXISTS `vw_resumo_pedidos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_resumo_pedidos` AS SELECT 
 1 AS `id`,
 1 AS `cliente`,
 1 AS `criado_em`,
 1 AS `total`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'ecommerce'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `ev_limpar_auditoria` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `ev_limpar_auditoria` ON SCHEDULE EVERY 1 DAY STARTS '2026-10-18 11:50:46' ON COMPLETION NOT PRESERVE DISABLE DO DELETE FROM auditoria_estoque WHERE alterado_em < CURRENT_TIMESTAMP - INTERVAL 90 DAY */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'ecommerce'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_registrar_pedido` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_pedido`(
 IN p_cliente_id INT, IN p_produto_id INT, IN p_quantidade INT,
 IN p_simular_erro BOOLEAN
)
BEGIN
 DECLARE v_preco DECIMAL(10,2);
 DECLARE v_pedido_id INT;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN
  ROLLBACK;
  RESIGNAL;
 END;
 START TRANSACTION;
 IF p_quantidade IS NULL OR p_quantidade <= 0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Quantidade deve ser positiva';
 END IF;
 -- UPDATE atomico: bloqueia a linha e impede venda acima do estoque.
 UPDATE produtos SET estoque=estoque-p_quantidade
 WHERE id=p_produto_id AND estoque>=p_quantidade;
 IF ROW_COUNT()=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Produto inexistente ou estoque insuficiente';
 END IF;
 SELECT preco INTO v_preco FROM produtos WHERE id=p_produto_id;
 -- Cliente inexistente causa erro de FK DEPOIS da alteracao no estoque.
 INSERT INTO pedidos (cliente_id,total) VALUES (p_cliente_id,v_preco*p_quantidade);
 SET v_pedido_id=LAST_INSERT_ID();
 INSERT INTO itens_pedido VALUES (v_pedido_id,p_produto_id,p_quantidade,v_preco);
 IF COALESCE(p_simular_erro,FALSE) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Falha simulada: transacao revertida';
 END IF;
 COMMIT;
 SELECT v_pedido_id AS pedido_criado;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `logistica`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `logistica` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `logistica`;

--
-- Table structure for table `centros_distribuicao`
--

DROP TABLE IF EXISTS `centros_distribuicao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `centros_distribuicao` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `centros_distribuicao`
--

LOCK TABLES `centros_distribuicao` WRITE;
/*!40000 ALTER TABLE `centros_distribuicao` DISABLE KEYS */;
INSERT INTO `centros_distribuicao` VALUES (1,'Centro Demonstracao');
/*!40000 ALTER TABLE `centros_distribuicao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'logistica'
--

--
-- Dumping routines for database 'logistica'
--

--
-- Current Database: `ecommerce`
--

USE `ecommerce`;

--
-- Final view structure for view `vw_resumo_pedidos`
--

/*!50001 DROP VIEW IF EXISTS `vw_resumo_pedidos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_resumo_pedidos` AS select `p`.`id` AS `id`,`c`.`nome` AS `cliente`,`p`.`criado_em` AS `criado_em`,`p`.`total` AS `total` from (`pedidos` `p` join `clientes` `c` on((`c`.`id` = `p`.`cliente_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Current Database: `logistica`
--

USE `logistica`;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-18 11:50:46
