DELIMITER $$ 

CREATE TRIGGER default_crop
BEFORE INSERT ON Sites
FOR EACH ROW
BEGIN 
        DECLARE default_crop_ID INT;
        SET default_crop_ID = '603' -- cashew crop I'd

       DECLARE min_rainfall INT DEFAULT 25;
       DECLARE min_temperature INT DEFAULT 20;
       DECLARE max_rainfall INT DEFAULT 450;
      DEFAULT max_temperature INT DEFAULT 35;

IF NEW.rainfall NOT BETWEEN min_rainfall AND max_rainfall OR NEW.temperature NOT BETWEEN min_temperature AND max_temperature THEN
    SET New.cropID = 603;
  END IF;
END $$

DELIMITER ;