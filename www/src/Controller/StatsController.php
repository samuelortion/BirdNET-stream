<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Doctrine\DBAL\Connection;

class StatsController extends AbstractController
{
    private Connection $connection;

    /**
     * @Route("/stats", name="stats")
     * @Route("/{_locale<%app.supported_locales%>}/stats", name="stats_i18n")
     */
    public function index(Connection $connection)
    {
        return $this->render("stats/index.html.twig");
    }
}