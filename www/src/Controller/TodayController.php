<?php
// src/Controller/TodayController.php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Doctrine\DBAL\Connection;

class TodayController extends AbstractController
{

    private Connection $connection;

    /**
     * @Route("/today", name="today")
     */
    public function today(Connection $connection)
    {
        $this->connection = $connection;
        $date = date('Y-m-d');
        return $this->render('today/index.html.twig', [
            "species" => $this->recorded_species_by_date($date),
        ]);
    }

    /**
     * @Route("/today/species", name="today_species")
     */
    public function today_species_page(Connection $connection)
    {
        $this->connection = $connection;
        $date = date('Y-m-d');
        return $this->render('today/index.html.twig', [
            "species" => $this->recorded_species_by_date($date)
        ]);
    }

    /**
     * @Route("/today/species/{id}", name="today_species_id")
     */
    public function today_species_by_id(Connection $connection, $id)
    {
        $this->connection = $connection;
        $date = date('Y-m-d');
        return $this->render('today/species.html.twig', [
            "results" => $this->recorded_species_by_id_and_date($id, $date)
        ]);
    }


    /**
     * @Route("/today/{date}", name="today_date")
     */
    public function today_date(Connection $connection, $date)
    {
        return $this->redirectToRoute('today_species_date', array('date' => $date));
    }

    /**
     * @Route("/today/{date}/species", name="today_species_date")
     */
    public function today_species_by_date(Connection $connection, $date)
    {
        $this->connection = $connection;
        return $this->render('today/index.html.twig', [
            "date" => $date,
            "results" => $this->recorded_species_by_date($date)
        ]);
    }

    /**
     * @Route("/today/{date}/species/{id}", name="today_species_id_and_date")
     */
    public function today_species_by_id_and_date(Connection $connection, $date, $id)
    {
        $this->connection = $connection;
        return $this->render('today/species.html.twig', [
            "date" => $date,
            "results" => $this->recorded_species_by_id_and_date($id, $date)
        ]);
    }


    private function recorded_species_by_date($date)
    {
        $sql = "SELECT `taxon`.`taxon_id`, `scientific_name`, `common_name`, COUNT(*) AS `contact_count`, MAX(`confidence`) AS max_confidence
                FROM observation 
                INNER JOIN taxon 
                ON observation.taxon_id = taxon.taxon_id 
                WHERE strftime('%Y-%m-%d', `observation`.`date`) =:date 
                GROUP BY observation.taxon_id";
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(':date', $date);
        $result = $stmt->executeQuery();
        return $result->fetchAllAssociative();
    }

    private function recorded_species_by_id_and_date($id, $date)
    {
        /* Get taxon even if there is no record this date */
        $sql = "SELECT * FROM `taxon` WHERE `taxon_id` = :id";
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(':id', $id);
        $result = $stmt->executeQuery();
        $taxon = $result->fetchAssociative();
        if (!$taxon) {
            return [];
        }
        /* Get daily stats */
        $sql = "SELECT COUNT(*) AS `contact_count`, MAX(`confidence`) AS `max_confidence` 
                FROM `taxon` 
                INNER JOIN `observation` 
                ON `taxon`.`taxon_id` = `observation`.`taxon_id` 
                WHERE strftime('%Y-%m-%d', `observation`.`date`) = :date
                AND `observation`.`taxon_id` = :id";
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(':id', $id);
        $stmt->bindValue(':date', $date);
        $result = $stmt->executeQuery();
        $stat = $result->fetchAllAssociative();
        $sql = "SELECT * FROM `observation` 
                WHERE `taxon_id` = :id 
                AND strftime('%Y-%m-%d', `observation`.`date`) = :date";
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(':id', $id);
        $stmt->bindValue(':date', $date);
        $result = $stmt->executeQuery();
        $records = $result->fetchAllAssociative();
        return array("taxon" => $taxon, "stat" => $stat, "records" => $records);
    }

    private function best_confidence_today($id, $date)
    {
        $sql = "SELECT MAX(`confidence`) AS confidence 
                FROM `observation` 
                WHERE strftime('%Y-%m-%d', `observation`.`date`) = :date 
                AND `taxon_id` = :id";
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(':id', $id);
        $stmt->bindValue(':date', $date);
        $result = $stmt->executeQuery();
        return $result->fetchAllAssociative();
    }
}
