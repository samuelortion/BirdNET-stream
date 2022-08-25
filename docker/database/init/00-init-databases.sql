CREATE DATABASE IF NOT EXISTS birdnet_default;
CREATE DATABASE IF NOT EXISTS birdnet_observations;

GRANT ALL ON `birdnet_observations`.* TO 'birdnet'@'%' IDENTIFIED BY 'secret';
GRANT ALL ON `birdnet_default`.* TO 'birdnet'@'%' IDENTIFIED BY 'secret';