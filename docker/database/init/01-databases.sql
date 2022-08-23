CREATE DATABASE IF NOT EXISTS `birdnet_observations`;
CREATE DATABASE IF NOT EXISTS `birdnet_default`;

GRANT ALL PRIVILEGES ON birdnet_observations.* TO 'birdnet'@'%';
GRANT ALL PRIVILEGES ON birdnet_default.* TO 'birdnet'@'%';

FLUSH PRIVILEGES;