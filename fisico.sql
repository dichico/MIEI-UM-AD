-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema dw
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema dw
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `dw` DEFAULT CHARACTER SET utf8 ;
USE `dw` ;

-- -----------------------------------------------------
-- Table `dw`.`dim_local`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dw`.`dim_local` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `city` VARCHAR(45) NOT NULL,
  `state` VARCHAR(45) NOT NULL,
  `country` VARCHAR(45) NOT NULL,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dw`.`dim_time`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dw`.`dim_time` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `date` DATETIME NOT NULL,
  `day` INT NOT NULL,
  `month` INT NOT NULL,
  `year` INT NOT NULL,
  `week` INT NOT NULL,
  `quarter` INT NOT NULL,
  `weekday` VARCHAR(45) NOT NULL,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dw`.`dim_supplier`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dw`.`dim_supplier` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_su` INT NOT NULL,
  `company` VARCHAR(45) NOT NULL,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dw`.`dim_shipper`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dw`.`dim_shipper` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_sh` INT NOT NULL,
  `company` VARCHAR(45) NOT NULL,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dw`.`dim_employee`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dw`.`dim_employee` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_e` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `company` VARCHAR(45) NOT NULL,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dw`.`dim_product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dw`.`dim_product` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_p` INT NOT NULL,
  `standard_cost` DECIMAL(19,4) NOT NULL,
  `category_name` VARCHAR(45) NOT NULL,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dw`.`fact_vendas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dw`.`fact_vendas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `total_price` DECIMAL(19,4) NOT NULL,
  `quantity` DECIMAL(18,4) NOT NULL,
  `order_date` INT NOT NULL,
  `preparation_time` INT NOT NULL,
  `client_local` INT NOT NULL,
  `supplier` INT NOT NULL,
  `shipper` INT NOT NULL,
  `employee` INT NOT NULL,
  `product` INT NOT NULL,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `supplier_fk_idx` (`supplier` ASC) VISIBLE,
  INDEX `shipper_fk_idx` (`shipper` ASC) VISIBLE,
  INDEX `local_fk_idx` (`client_local` ASC) VISIBLE,
  INDEX `employee_fk_idx` (`employee` ASC) VISIBLE,
  INDEX `time_fk_idx` (`order_date` ASC) VISIBLE,
  INDEX `product_fk_idx` (`product` ASC) VISIBLE,
  CONSTRAINT `supplier_fk`
    FOREIGN KEY (`supplier`)
    REFERENCES `dw`.`dim_supplier` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `shipper_fk`
    FOREIGN KEY (`shipper`)
    REFERENCES `dw`.`dim_shipper` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `local_fk`
    FOREIGN KEY (`client_local`)
    REFERENCES `dw`.`dim_local` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `employee_fk`
    FOREIGN KEY (`employee`)
    REFERENCES `dw`.`dim_employee` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `time_fk`
    FOREIGN KEY (`order_date`)
    REFERENCES `dw`.`dim_time` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `product_fk`
    FOREIGN KEY (`product`)
    REFERENCES `dw`.`dim_product` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
