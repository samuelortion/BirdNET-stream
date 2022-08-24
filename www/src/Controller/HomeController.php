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
    public function index()
    {
        return $this->render('index.html.twig', [
            "stats" => $this->get_stats(),
            "charts" => $this->last_chart_generated(),
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

    private function get_stats()
    {
        $stats = array();
        $stats["most-recorded-species"] = $this->get_most_recorded_species();
        $stats["last-detected-species"] = $this->get_last_recorded_species();
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
