<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Doctrine\DBAL\Connection;

class HomeController extends AbstractController
{
    private Connection $connection;

    /**
     * @Route("/", name="home")
     */
    public function index(Connection $connection)
    {
        $this->connection = $connection;
        return $this->render('index.html.twig', [
            "stats" => $this->get_stats(),
            "charts" => $this->last_chart_generated(),
        ]);
    }
     
    /**
     * @Route("/about", name="about")
     */
    public function about()
    {
        return $this->render('about/index.html.twig', [
            
        ]);
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
        $sql = "SELECT `scientific_name`, `common_name`, COUNT(*) AS contact_count 
                FROM `taxon` 
                INNER JOIN `observation` 
                ON `taxon`.`taxon_id` = `observation`.`taxon_id`
                ORDER BY `contact_count` DESC LIMIT 1";
        $stmt = $this->connection->prepare($sql);
        $result = $stmt->executeQuery();
        return $result->fetchAllAssociative()[0];
    }

    private function get_last_recorded_species() 
    {
        $sql = "SELECT `scientific_name`, `common_name`, `date`, `audio_file`, `confidence`
                FROM `observation`
                INNER JOIN `taxon`
                ON `observation`.`taxon_id` = `taxon`.`taxon_id`
                ORDER BY `date` DESC LIMIT 1";
        $stmt = $this->connection->prepare($sql);
        $result = $stmt->executeQuery();
        return $result->fetchAllAssociative();
    }

    private function last_chart_generated() {
    
        $files = glob($this->getParameter('kernel.project_dir') . '/../var/charts/*.png');
        usort($files, function($a, $b) {
            return filemtime($b) - filemtime($a);
        });
        $last_chart = basename(array_pop($files));
        return $last_chart;
    }

}