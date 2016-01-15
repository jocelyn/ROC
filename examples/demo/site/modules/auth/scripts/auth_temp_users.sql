CREATE TABLE `auth_temp_users` (
  `uid` INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `password` VARCHAR(100) NOT NULL,
  `salt` VARCHAR(100) NOT NULL,
  `email` VARCHAR(250) NOT NULL,
  `application` TEXT NOT NULL, 
  CONSTRAINT `name`
    UNIQUE(`name`)
);


