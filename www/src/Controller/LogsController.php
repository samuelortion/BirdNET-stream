<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class LogsController extends AbstractController
{
    private $allowed_services = "recording analyzis miner plotter";
    /**
     * @Route("/logs/{service}", name="logs")
     * @Route("/{_locale<%app.supported_locales%>}/logs/{service}", name="logs_i18n")
     */
    public function logs($service = "all")
    {
        $logs = "";
        if ($service === "all") {
            foreach (explode(" ", $this->allowed_services) as $service) {
                $logs .= $this->journal_logs($service);
            }
        } else if (str_contains($this->allowed_services, $service)) {
            $logs .= $this->journal_logs($service);
        } else {
            return new Response("Service not found", Response::HTTP_BAD_REQUEST);
        }
        return $this->render('logs/logs.html.twig', [
            'logs' => $logs
        ]);
    }

    private function journal_logs($service)
    {
        $logs = shell_exec("journalctl -u birdnet_recording -n 10");
        return $logs;
    }
}
