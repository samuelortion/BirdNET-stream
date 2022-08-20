<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use App\AppBundle\ConnectionObservations;

class StatsController extends AbstractController
{
    private ConnectionObservations $connection;

    public function __construct(ConnectionObservations $connection)
    {
        $this->connection = $connection;
    }

    /**
     * @Route("/stats", name="stats")
     * @Route("/{_locale<%app.supported_locales%>}/stats", name="stats_i18n")
     */
    public function index()
    {
        return $this->render("stats/index.html.twig");
    }
}