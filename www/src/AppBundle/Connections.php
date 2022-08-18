<?php
namespace App\AppBundle\Connections;
use Doctrine\DBAL\Connection;

class ConnectionObservations extends Connection
{

}

// Reference: https://stackoverflow.com/questions/46235336/autowire-specific-dbal-connection-when-using-multiple-of-them