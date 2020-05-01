-- MySQL dump 10.17  Distrib 10.3.12-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: pizza
-- ------------------------------------------------------
-- Server version	10.3.12-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ingredient`
--

DROP TABLE IF EXISTS `ingredient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ingredient` (
  `ingredient_id` int(11) NOT NULL,
  `ingredient_name` varchar(20) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`ingredient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredient`
--

LOCK TABLES `ingredient` WRITE;
/*!40000 ALTER TABLE `ingredient` DISABLE KEYS */;
INSERT INTO `ingredient` VALUES (1,'Курица'),(2,'Свинина'),(3,'Говядина'),(4,'Колбаса'),(5,'Грибы'),(6,'Сыр Моцарелла'),(7,'Сыр Пармезан'),(8,'Сыр Фета'),(9,'Помидор'),(10,'Болгарский перец'),(11,'Ветчина'),(12,'Оливки');
/*!40000 ALTER TABLE `ingredient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `order_address` varchar(100) CHARACTER SET utf8 NOT NULL,
  `order_user_phone` varchar(20) NOT NULL,
  `order_comment` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `order_is_done` tinyint(1) DEFAULT 0,
  `order_delivery_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (10,28,'2020-05-27 07:54:59','Ул. Сумская д.15 кв.56','0965438341','',1,'2020-05-29 05:16:29'),(11,27,'2020-05-28 06:25:42','Spartaka Ul., bld. 13','096-665-3228','',0,NULL),(13,27,'2020-05-28 08:52:33','Spartaka Ul., bld. 13','096-665-3228','',1,'2020-05-29 05:01:05'),(14,27,'2020-05-29 05:24:46','Spartaka Ul., bld. 13','096-665-3228','AAAA',1,'2020-05-29 05:24:51'),(15,27,'2020-05-29 06:47:05','Spartaka Ul., bld. 13','096-665-3228','',0,NULL);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp1251 */ ;
/*!50003 SET character_set_results = cp1251 */ ;
/*!50003 SET collation_connection  = cp1251_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER update_orders BEFORE UPDATE ON orders
FOR EACH ROW begin
  IF new.order_is_done = 1 and old.order_is_done = 0 then
set new.order_delivery_date = NOW();
  END IF;
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER delete_from_orders BEFORE DELETE ON orders
FOR EACH ROW BEGIN
  IF old.order_is_done = 0 then
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE canceled'; 
  END IF;
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `orders_pizza`
--

DROP TABLE IF EXISTS `orders_pizza`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders_pizza` (
  `order_id` int(11) NOT NULL,
  `pizza_title_id` int(11) NOT NULL,
  `pizza_size_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  PRIMARY KEY (`order_id`,`pizza_title_id`,`pizza_size_id`),
  KEY `pizza_title_id` (`pizza_title_id`),
  KEY `pizza_size_id` (`pizza_size_id`),
  CONSTRAINT `orders_pizza_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `orders_pizza_ibfk_2` FOREIGN KEY (`pizza_title_id`) REFERENCES `pizza_title` (`pizza_title_id`),
  CONSTRAINT `orders_pizza_ibfk_3` FOREIGN KEY (`pizza_size_id`) REFERENCES `pizza_size` (`pizza_size_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders_pizza`
--

LOCK TABLES `orders_pizza` WRITE;
/*!40000 ALTER TABLE `orders_pizza` DISABLE KEYS */;
INSERT INTO `orders_pizza` VALUES (10,3,2,1),(11,3,2,4),(11,4,1,1),(11,5,3,1),(13,3,2,2),(14,2,2,2),(14,5,3,1),(15,2,1,1);
/*!40000 ALTER TABLE `orders_pizza` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp1251 */ ;
/*!50003 SET character_set_results = cp1251 */ ;
/*!50003 SET collation_connection  = cp1251_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER delete_from_orders_pizza BEFORE DELETE ON orders_pizza
FOR EACH ROW begin
  SET @is_done := (SELECT orders.order_is_done FROM orders where old.order_id = orders.order_id);
  IF @is_done = 0 then
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE canceled'; 
  END IF;
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `pizza`
--

DROP TABLE IF EXISTS `pizza`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pizza` (
  `pizza_title_id` int(11) NOT NULL,
  `pizza_size_id` int(11) NOT NULL,
  `pizza_price` decimal(8,2) NOT NULL,
  PRIMARY KEY (`pizza_title_id`,`pizza_size_id`),
  KEY `pizza_size_id` (`pizza_size_id`),
  CONSTRAINT `pizza_ibfk_1` FOREIGN KEY (`pizza_title_id`) REFERENCES `pizza_title` (`pizza_title_id`),
  CONSTRAINT `pizza_ibfk_2` FOREIGN KEY (`pizza_size_id`) REFERENCES `pizza_size` (`pizza_size_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza`
--

LOCK TABLES `pizza` WRITE;
/*!40000 ALTER TABLE `pizza` DISABLE KEYS */;
INSERT INTO `pizza` VALUES (1,1,30.00),(1,2,60.00),(1,3,90.00),(2,1,32.00),(2,2,64.00),(2,3,95.00),(3,1,40.00),(3,2,68.00),(3,3,100.00),(4,1,42.00),(4,2,65.00),(4,3,102.00),(5,1,40.00),(5,2,60.00),(5,3,95.00);
/*!40000 ALTER TABLE `pizza` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pizza_ingredient`
--

DROP TABLE IF EXISTS `pizza_ingredient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pizza_ingredient` (
  `ingredient_id` int(11) NOT NULL,
  `pizza_title_id` int(11) NOT NULL,
  PRIMARY KEY (`ingredient_id`,`pizza_title_id`),
  KEY `pizza_title_id` (`pizza_title_id`),
  CONSTRAINT `pizza_ingredient_ibfk_1` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredient` (`ingredient_id`),
  CONSTRAINT `pizza_ingredient_ibfk_2` FOREIGN KEY (`pizza_title_id`) REFERENCES `pizza_title` (`pizza_title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza_ingredient`
--

LOCK TABLES `pizza_ingredient` WRITE;
/*!40000 ALTER TABLE `pizza_ingredient` DISABLE KEYS */;
INSERT INTO `pizza_ingredient` VALUES (1,2),(1,3),(3,5),(4,1),(4,2),(5,1),(5,2),(5,4),(6,4),(7,5),(8,1),(8,2),(8,3),(9,3),(9,4),(10,1),(10,3),(11,5),(12,4);
/*!40000 ALTER TABLE `pizza_ingredient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pizza_size`
--

DROP TABLE IF EXISTS `pizza_size`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pizza_size` (
  `pizza_size_id` int(11) NOT NULL,
  `size_value` int(11) NOT NULL,
  PRIMARY KEY (`pizza_size_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza_size`
--

LOCK TABLES `pizza_size` WRITE;
/*!40000 ALTER TABLE `pizza_size` DISABLE KEYS */;
INSERT INTO `pizza_size` VALUES (1,20),(2,28),(3,34);
/*!40000 ALTER TABLE `pizza_size` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pizza_title`
--

DROP TABLE IF EXISTS `pizza_title`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pizza_title` (
  `pizza_title_id` int(11) NOT NULL,
  `pizza_name` varchar(20) CHARACTER SET utf8 NOT NULL,
  `pizza_description` varchar(100) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`pizza_title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza_title`
--

LOCK TABLES `pizza_title` WRITE;
/*!40000 ALTER TABLE `pizza_title` DISABLE KEYS */;
INSERT INTO `pizza_title` VALUES (1,'С грибами','Запеченное тесто вместе с грибами и остальными ингредиентами'),(2,'С курицой и грибами','Нежная курица со свежими грибами и сыром'),(3,'Фитнес','Разные овощи и диетическая куринная грудка'),(4,'Фирменная','Запеченное тесто со свежими овощами и грибами'),(5,'Мясная','Много говядины, ветчины, покрытой сыром');
/*!40000 ALTER TABLE `pizza_title` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_surname` varchar(20) CHARACTER SET utf8 NOT NULL,
  `user_name` varchar(20) CHARACTER SET utf8 NOT NULL,
  `user_patronymic` varchar(20) CHARACTER SET utf8 NOT NULL,
  `user_login` varchar(20) NOT NULL,
  `user_password` varchar(256) NOT NULL,
  `user_password_salt` varchar(256) NOT NULL,
  `user_phone` varchar(20) NOT NULL,
  `user_address` varchar(100) CHARACTER SET utf8 NOT NULL,
  `user_registration_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `user_is_admin` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `user_login` (`user_login`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (27,'Пасичный','Константин','Дмитриевич','admin','84cfcb58c5078800c0b87e8c3054a9679c1593d94a9a05c47476c31dd934d14cc5ae051b4fa247409a6f1da9342eb7979d78508021e656dd581899ae606a7d0a','f09720187310374f7c2b74a4b3e1237fecb4226d58ab18c37d3ad5e9a5edaf738fa0962e7ca5b09852855160b56159d78f02e18fe9c3b1d8e1c0bd37bd2d79bc','096-665-3228','Spartaka Ul., bld. 13','2020-05-27 07:02:29',1),(28,'Степанов','Олег','Витальевич','oleg1','b1f44c5384197807c87469d22af5777b34f1fa9e57c2d393cdfb555abec479b1863776505854803221c30bcf86c65a4ef28df543e45b0cbfc2365c3f1e57ccc4','373e10732120bed4ccf35450155990489a0ec493a4b29e35ba5879900a9fe730f9091885324ec95cecc6664d75699b27e9fc7677db61b4b0dd4c090e620cbe89','0965438341','Ул. Сумская д.15 кв.56','2020-05-27 07:31:38',0),(30,'Степанов','Олег','Витальевич','oleg2','6f1ce23b15a99d3690d73f833fb935d764e5cbd61244ae4a5e48d36dac9350dad1b84c7573f9cbb50853948c248f9fe8657a2ac53cb419d8f5443900bad97ab9','b037daefe016a9cd4d7e9c2d811511ffdce9237fefb837d97d9c7d891bb05719ab535692356ff20c46454495c9443195287528e34129509d61f60e6c763d851f','0965438341','Ул. Пушкинская 69/2 кв 22','2020-05-27 07:32:46',0);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp1251 */ ;
/*!50003 SET character_set_results = cp1251 */ ;
/*!50003 SET collation_connection  = cp1251_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER check_phone BEFORE INSERT ON user
FOR EACH ROW begin
  IF char_length(new.user_phone) < 4 then
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled'; 
  END IF;
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp1251 */ ;
/*!50003 SET character_set_results = cp1251 */ ;
/*!50003 SET collation_connection  = cp1251_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER check_phone_update BEFORE UPDATE ON user
FOR EACH ROW begin
  IF char_length(new.user_phone) < 4 then
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE canceled'; 
  END IF;
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-05-30 19:38:55
