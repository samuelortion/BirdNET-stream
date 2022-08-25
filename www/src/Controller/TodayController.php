<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use App\AppBundle\ConnectionObservations;
use Psr\Log\LoggerInterface;

class TodayController extends AbstractController
{    
    private ConnectionObservations $connection;
    private LoggerInterface $logger;

    public function __construct(ConnectionObservations $connection, LoggerInterface $logger)
    {
        $this->connection = $connection;
        $this->logger = $logger;
    }


    /**
     * @Route("/today", name="today")
     * @Route("/{_locale<%app.supported_locales%>}/today", name="today_i18n")
     */
    public function today(ConnectionObservations $connection)
    {
       return $this->redirectToRoute("today_species_i18n");
    }

    /**
     * @Route("/today/species", name="today_species")
     * @Route("/{_locale<%app.supported_locales%>}/today/species", name="today_species_i18n")
     */
    public function today_species_page(ConnectionObservations $connection)
    {
        $this->connection = $connection;
        $date = date('Y-m-d');
        return $this->render('today/index.html.twig', [
            "date" => $date,
            "results" => $this->recorded_species_by_date($date),
        ]);
    }

    /**
     * @Route("/today/species/{id}", name="today_species_id")
     * @Route("/{_locale<%app.supported_locales%>}/today/species/{id}", name="today_species_id_i18n")
     */
    public function today_species_by_id($id)
    {
        $date = date('Y-m-d');
        return $this->render('today/species.html.twig', [
            "date" => $date,
            "results" => $this->recorded_species_by_id_and_date($id, $date)
        ]);
    }


    /**
     * @Route("/today/{date}", name="today_date")
     * @Route("/{_locale<%app.supported_locales%>}/today/{date}", name="today_date_i18n")
     */
    public function today_date($date="2022-08-13")
    {
        return $this->redirectToRoute('today_species_date', array('date' => $date));
    }

    /**
     * @Route("/today/{date}/species", name="today_species_date")
     * @Route("/{_locale<%app.supported_locales%>}/today/{date}/species", name="today_species_date_i18n")
     */
    public function today_species_by_date($date="2022-08-13")
    {
        return $this->render('today/index.html.twig', [
            "date" => $date,
            "results" => $this->recorded_species_by_date($date)
        ]);
    }

    /**
     * @Route("/today/{date}/species/{id}", name="today_species_id_and_date")
     * @Route("/{_locale<%app.supported_locales%>}/today/{date}/species/{id}", name="today_species_id_and_date_i18n")
     */
    public function today_species_by_id_and_date($id, $date="2022-08-13")
    {
        return $this->render('today/species.html.twig', [
            "date" => $date,
            "results" => $this->recorded_species_by_id_and_date($id, $date)
        ]);
    }


    private function recorded_species_by_date($date)
    {
        $recorded_species = [];
        $sql = "SELECT `taxon`.`taxon_id`, `scientific_name`, `common_name`, COUNT(*) AS `contact_count`, MAX(`confidence`) AS max_confidence
                FROM observation 
                INNER JOIN taxon 
                ON observation.taxon_id = taxon.taxon_id 
                WHERE strftime('%Y-%m-%d', `observation`.`date`) = :date 
                GROUP BY observation.taxon_id";
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->bindValue(':date', $date);
            $result = $stmt->executeQuery();
            $recorded_species = $result->fetchAllAssociative();
        } catch (\Exception $e) {
            $this->logger->error($e->getMessage());
        }
        return $recorded_species;
    }

    private function recorded_species_by_id_and_date($id, $date)
    {
        /* Get taxon even if there is no record this date */
        $sql = "SELECT * FROM `taxon` WHERE `taxon_id` = :id";
        $taxon = [];
        $stat = [];
        $records = [];
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->bindValue(':id', $id);
            $result = $stmt->executeQuery();
            $taxon = $result->fetchAllAssociative()[0];
        } catch (\Exception $e) {
            $this->logger->error($e->getMessage());
        }
        /* Get daily stats */
        $sql = "SELECT COUNT(*) AS `contact_count`, MAX(`confidence`) AS `max_confidence` 
                FROM `taxon` 
                INNER JOIN `observation` 
                ON `taxon`.`taxon_id` = `observation`.`taxon_id` 
                WHERE strftime('%Y-%m-%d', `observation`.`date`) = :date
                AND `observation`.`taxon_id` = :id";
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->bindValue(':id', $id);
            $stmt->bindValue(':date', $date);
            $result = $stmt->executeQuery();
            $stat = $result->fetchAllAssociative();
        } catch (\Exception $e) {
            $this->logger->error($e->getMessage());
        }
        $sql = "SELECT * FROM `observation` 
                WHERE `taxon_id` = :id 
                AND strftime('%Y-%m-%d', `observation`.`date`) = :date
                ORDER BY `observation`.`date` ASC";
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->bindValue(':id', $id);
            $stmt->bindValue(':date', $date);
            $result = $stmt->executeQuery();
            $records = $result->fetchAllAssociative();
        } catch (\Exception $e) {
            $this->logger->error($e->getMessage());
        }
        return array("taxon" => $taxon, "stat" => $stat, "records" => $records);
    }

    private function best_confidence_today($id, $date)
    {
        $best_confidence = 0;
        $sql = "SELECT MAX(`confidence`) AS confidence 
                FROM `observation` 
                WHERE strftime('%Y-%m-%d', `observation`.`date`) = :date 
                AND `taxon_id` = :id";
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->bindValue(':id', $id);
            $stmt->bindValue(':date', $date);
            $result = $stmt->executeQuery();
            $result->fetchAllAssociative();
        } catch (\Exception $e) {
            $this->logger->error($e->getMessage());
        }
        return $best_confidence;
    }
}