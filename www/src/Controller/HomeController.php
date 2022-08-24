<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use App\AppBundle\ConnectionObservations;
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpKernel\Log\Logger;

class HomeController extends AbstractController
{
    private ConnectionObservations $connection;
    private LoggerInterface $logger;

    public function __construct(ConnectionObservations $connection, LoggerInterface $logger)
    {
        $this->connection = $connection;
        $this->logger = $logger;
    }

    /**
     * @Route("", name="home")
     * @Route("/{_locale<%app.supported_locales%>}/", name="home_i18n")
     */
    public function index(Request $request)
    {
        $date = $request->get("on");
        if ($date == null) {
            $date = date("Y-m-d");
        }
        return $this->render('index.html.twig', [
            "stats" => $this->get_stats($date),
            "charts" => $this->last_chart_generated($date),
        ]);
    }

    /**
     * @Route("/about", name="about")
     * @Route("/{_locale<%app.supported_locales%>}/about", name="about_i18n")
     */
    public function about()
    {
        return $this->render('about/index.html.twig', []);
    }

    private function get_stats($date)
    {
        $stats = array();
        $stats["most-recorded-species"] = $this->get_most_recorded_species();
        $stats["last-detected-species"] = $this->get_last_recorded_species();
        $stats["number-of-species-detected"] = $this->get_number_of_species_detected($date);
        return $stats;
    }

    private function get_most_recorded_species()
    {
        $species = [];
        $sql = "SELECT `scientific_name`, `common_name`, COUNT(*) AS contact_count 
                FROM `taxon` 
                INNER JOIN `observation` 
                ON `taxon`.`taxon_id` = `observation`.`taxon_id`
                ORDER BY `contact_count` DESC LIMIT 1";
        try {
            $stmt = $this->connection->prepare($sql);
            $result = $stmt->executeQuery();
            $species = $result->fetchAllAssociative()[0];
        } catch (\Exception $e) {
            $this->logger->error($e->getMessage());
        }
        return $species;
    }

    private function get_last_recorded_species()
    {
        $species = [];
        $sql = "SELECT `scientific_name`, `common_name`, `date`, `audio_file`, `confidence`
                FROM `observation`
                INNER JOIN `taxon`
                ON `observation`.`taxon_id` = `taxon`.`taxon_id`
                ORDER BY `date` DESC LIMIT 1";
        try {
            $stmt = $this->connection->prepare($sql);
            $result = $stmt->executeQuery();    
            $species = $result->fetchAllAssociative()[0];
        } catch (\Exception $e) {
            $this->logger->error($e->getMessage());
        }
        return $species;
    }

    private function get_number_of_species_detected($date)
    {
        $count = 0;
        $sql = "SELECT COUNT(`taxon_id`) AS contact_count
                FROM `observation`
                WHERE STRFTIME('%Y-%m-%d', `date`) = :date
                GROUP BY `taxon_id`";
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->bindValue(":date", $date);
            $result = $stmt->executeQuery();
            $output = $result->fetchAllAssociative();
            if ($output != null) {
                $count = $output[0]["contact_count"];
            }
        } catch (\Exception $e) {
            $this->logger->error($e->getMessage());
        }
        return $count;
    }

    private function last_chart_generated()
    {
        $files = glob($this->getParameter('kernel.project_dir') . '/../var/charts/*.png');
        if (count($files) > 0) {
            usort($files, function ($a, $b) {
                return filemtime($a) - filemtime($b);
            });
            
            $last_chart = basename(array_pop($files));
            return $last_chart;
        } else {
            $this->logger->info("No charts found");
            return "";
        }
    }
}
